# Plano de Implementação — Chat de Agendamento para o Cliente

> **Contexto:** O sistema atual possui um backend Flask com API REST, um app Flutter (versão do barbeiro) e um frontend web Flutter compilado. Este plano descreve a transformação da interface web do cliente em um **chat guiado por etapas**, que coleta as informações necessárias e dispara o agendamento automaticamente, notificando o barbeiro via push notification no celular.

---

## 1. Visão Geral da Proposta

### Como funciona hoje
O frontend web atual exige que o **barbeiro** esteja logado para criar agendamentos. O cliente não tem nenhuma interface própria.

### Como vai funcionar
O cliente acessa uma **URL pública** (sem login) e é atendido por um chat conversacional que:
1. Coleta o nome e telefone do cliente (ou reconhece se já está cadastrado);
2. Apresenta os serviços disponíveis como botões de escolha;
3. Apresenta os dias disponíveis;
4. Apresenta os horários disponíveis para o dia escolhido;
5. Faz um resumo e pede confirmação;
6. Cria o agendamento via API;
7. Notifica o barbeiro via push notification no celular.

### Diagrama do fluxo geral

```
Cliente (Web)                 Backend Flask              App Flutter (Barbeiro)
     │                              │                              │
     │── GET /api/public/servicos ──►│                              │
     │◄─ lista de serviços ─────────│                              │
     │                              │                              │
     │── GET /api/public/horarios ──►│                              │
     │◄─ slots disponíveis ─────────│                              │                   
     │                              │                              │
     │── POST /api/public/agendar ──►│                              │
     │                              │── salva agendamento ─────────│
     │                              │── envia push notification ───►│
     │◄─ confirmação ───────────────│                   [notificação no celular]
     │                              │                              │
```

---

## 2. Etapas do Chat (UX/Fluxo de Conversa)

O chat guia o cliente em **6 etapas sequenciais**. Cada etapa é uma "mensagem do sistema" com botões de resposta rápida — o cliente nunca digita nada além do nome e telefone.

### Etapa 1 — Boas-vindas e identificação
```
🤖 Olá! Bem-vindo à Barbearia Ponto do Corte.
   Vou te ajudar a marcar um horário rapidinho. 😄
   
   Qual é o seu nome?
   [campo de texto livre]
```

### Etapa 2 — Telefone (para cadastro/reconhecimento)
```
🤖 Prazer, {nome}! Qual é o seu telefone?
   (Usamos para confirmar seu agendamento)
   
   [campo de texto — aceita formato (XX) XXXXX-XXXX]
```

> **Lógica interna:** O backend verifica se o telefone já existe na tabela `clientes`. Se sim, usa o `cliente_id` existente. Se não, cria um novo cliente automaticamente via `POST /api/public/clientes`.

### Etapa 3 — Escolha do serviço
```
🤖 Que ótimo! Qual serviço você quer realizar?

   [Corte de Cabelo — R$ 35,00 • 30min]
   [Barba         — R$ 25,00 • 20min]
   [Combo         — R$ 55,00 • 50min]
   [Sobrancelha   — R$ 15,00 • 15min]
```
> Botões gerados dinamicamente a partir de `GET /api/public/servicos`.

### Etapa 4 — Escolha do dia
```
🤖 Perfeito! Escolha um dia:

   [Hoje — Sex, 11/04]
   [Sábado — 12/04]
   [Segunda — 14/04]
   [Terça — 15/04]
   [Outro dia ▸]
```
> Exibe os próximos 5 dias úteis com agenda disponível.

### Etapa 5 — Escolha do horário
```
🤖 Ótimo! Para {dia escolhido}, os horários disponíveis são:

   [08:00]  [08:30]  [09:00]
   [09:30]  [10:00]  [11:00]
   [14:00]  [15:00]  [16:30]
```
> Gerado por `GET /api/public/horarios?data=YYYY-MM-DD&servico_id=X`. O backend exclui horários já ocupados na tabela `agendamentos`.

### Etapa 6 — Confirmação
```
🤖 Perfeito! Veja o resumo do seu agendamento:

   📋 Cliente:  João Silva
   ✂️  Serviço:  Corte de Cabelo
   📅 Data:     Sábado, 12/04/2026
   🕐 Horário:  09:30
   💰 Valor:    R$ 35,00

   Confirmar agendamento?
   
   [✅ Confirmar]   [❌ Cancelar]
```

### Etapa 7 — Sucesso
```
🤖 ✅ Agendamento confirmado!
   
   Te esperamos no sábado às 09:30.
   Até lá, {nome}! 💈
   
   [Fazer outro agendamento]
```

---

## 3. O que precisa ser construído

### 3.1 Backend Flask — Novas rotas públicas

Todas as novas rotas ficam sob o prefixo `/api/public/` e **não exigem autenticação JWT** (são públicas para o cliente). Devem ser criadas em um novo Blueprint: `routes/public.py`.

#### `GET /api/public/servicos`
Retorna todos os serviços ativos.

```python
# Exemplo de resposta
[
  { "id": 1, "nome": "Corte de Cabelo", "preco": 35.0, "duracao_minutos": 30 },
  { "id": 2, "nome": "Barba",           "preco": 25.0, "duracao_minutos": 20 }
]
```

#### `GET /api/public/horarios?data=YYYY-MM-DD&servico_id=X`
Retorna os slots de horário disponíveis para um dia e serviço específico.

**Lógica:** gera slots de 30 em 30 minutos (ou conforme `duracao_minutos` do serviço) entre 08:00 e 18:00, e exclui os que já possuem agendamento com status `agendado`.

```python
# Exemplo de resposta
{
  "data": "2026-04-12",
  "disponiveis": ["08:00", "08:30", "09:30", "10:00", "14:00"],
  "ocupados":    ["09:00", "10:30"]
}
```

#### `POST /api/public/cliente`
Cria ou localiza um cliente pelo telefone (upsert).

```python
# Corpo da requisição
{ "nome": "João Silva", "telefone": "(19) 99999-0000" }

# Resposta
{ "id": 42, "nome": "João Silva", "novo": true }
```

#### `POST /api/public/agendar`
Cria o agendamento e dispara a notificação push para o barbeiro.

```python
# Corpo da requisição
{
  "cliente_id":  42,
  "servico_id":  1,
  "data_hora":   "2026-04-12T09:30:00",
  "observacoes": ""
}

# Resposta
{
  "id": 99,
  "message": "Agendamento criado com sucesso",
  "notificacao_enviada": true
}
```

> **Importante:** Esta rota deve aplicar validação de conflito de horário no banco antes de inserir, para evitar condição de corrida quando dois clientes selecionam o mesmo slot simultaneamente. Usar `INSERT ... WHERE NOT EXISTS` ou verificar com `SELECT FOR` antes do `INSERT`.

---

### 3.2 Sistema de Notificações Push

Esta é a peça central que conecta o agendamento do cliente ao celular do barbeiro.

#### Tecnologia recomendada: **Firebase Cloud Messaging (FCM)**

O FCM é gratuito, confiável e tem SDK oficial para Flutter — o app do barbeiro já usa Flutter, então a integração é direta.

#### Como funciona

```
1. O app Flutter (barbeiro) inicializa o FCM ao abrir
2. O FCM gera um token único para aquele dispositivo
3. O app envia esse token para o backend via POST /api/auth/register-token
4. O backend salva o token na tabela push_tokens
5. Quando um novo agendamento é criado via /api/public/agendar,
   o backend busca o token salvo e envia a notificação via API do FCM
6. O celular do barbeiro recebe a notificação mesmo com o app fechado
```

#### Estrutura da notificação recebida no celular

```
📱 ──────────────────────────────
   💈 Ponto do Corte — Novo agendamento!
   
   João Silva agendou Corte de Cabelo
   para Sábado, 12/04 às 09:30
───────────────────────────────────
```

#### Nova tabela no banco de dados

```sql
CREATE TABLE IF NOT EXISTS push_tokens (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    token       TEXT NOT NULL UNIQUE,
    dispositivo TEXT,
    criado_em   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Nova rota no backend

```
POST /api/auth/register-token
Body: { "token": "fcm-token-aqui", "dispositivo": "Pixel 7" }
Headers: Authorization: Bearer <jwt>
```

#### Dependência Python a adicionar em `requirements.txt`

```
firebase-admin==6.5.0
```

#### Snippet da função de envio (backend)

```python
# utils/notifications.py
import firebase_admin
from firebase_admin import credentials, messaging

def inicializar_fcm():
    """Inicializa o SDK do Firebase. Chamar uma vez no app.py."""
    cred = credentials.Certificate('firebase-service-account.json')
    firebase_admin.initialize_app(cred)

def enviar_notificacao_agendamento(token, cliente_nome, servico_nome, data_hora_str):
    """Envia push notification para o dispositivo do barbeiro."""
    message = messaging.Message(
        notification=messaging.Notification(
            title='💈 Novo agendamento!',
            body=f'{cliente_nome} agendou {servico_nome} para {data_hora_str}',
        ),
        data={
            'tipo': 'novo_agendamento',
            'cliente': cliente_nome,
            'servico': servico_nome,
            'data_hora': data_hora_str,
        },
        token=token,
    )
    response = messaging.send(message)
    return response
```

---

### 3.3 App Flutter (Barbeiro) — Integração FCM

Adicionar ao `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
```

Inicializar no `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Solicita permissão de notificação (iOS obrigatório, Android recomendado)
  await FirebaseMessaging.instance.requestPermission();
  
  // Obtém o token do dispositivo e envia ao backend
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await ApiService().registrarPushToken(token);
  }
  
  await dotenv.load(fileName: ".env");
  runApp(const BarbeariaApp());
}
```

Adicionar em `api_service.dart`:

```dart
Future<void> registrarPushToken(String token) async {
  try {
    await http.post(
      Uri.parse('$_baseUrl/api/auth/register-token'),
      headers: _authHeaders,
      body: json.encode({'token': token, 'dispositivo': 'Flutter App'}),
    );
  } catch (_) {
    // Falha silenciosa — não bloqueia o login
  }
}
```

---

### 3.4 Interface Web do Cliente — Chat

A interface web do cliente será uma **página HTML/CSS/JS standalone** — sem necessidade de Flutter para o lado do cliente. Isso mantém leveza e compatibilidade total com qualquer navegador, inclusive mobile.

> **Por que não Flutter Web?** O Flutter Web atual gera bundles pesados (~3MB) com tempo de carregamento elevado, o que é ruim para o cliente acessando pelo celular. Uma página HTML/JS é instantânea e funciona em qualquer dispositivo sem instalação.

#### Estrutura de arquivos sugerida

```
barbearia-chat/
├── index.html          ← página única do chat
├── style.css           ← estilos do chat
├── chat.js             ← lógica do fluxo conversacional
└── config.js           ← URL base da API
```

#### Estrutura visual do chat

O chat ocupa toda a tela no mobile e é centralizado em desktop. Interface inspirada em WhatsApp/iMessage:

- Mensagens do sistema aparecem à **esquerda** (balão cinza com ícone 💈)
- Respostas do cliente aparecem à **direita** (balão escuro, após seleção)
- Botões de resposta rápida aparecem como **chips horizontais** abaixo da última mensagem

#### Servir a interface

A página pode ser servida diretamente pelo Flask, adicionando uma rota simples:

```python
# app.py — adicionar
from flask import send_from_directory

@app.route('/agendar')
def chat_cliente():
    """Página pública de agendamento via chat."""
    return send_from_directory('static/chat', 'index.html')
```

E o diretório `barbearia-backend/static/chat/` recebe os arquivos do chat.

---

## 4. Arquitetura Completa após a Implementação

```
┌─────────────────────────────────────────────────────────────────┐
│                        SISTEMA COMPLETO                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐         ┌────────────────────────────┐   │
│  │  Cliente (Web)   │         │      Backend Flask          │   │
│  │                  │         │                             │   │
│  │  /agendar        │◄───────►│  /api/public/servicos       │   │
│  │  Chat HTML/JS    │         │  /api/public/horarios       │   │
│  │  Sem login       │         │  /api/public/cliente        │   │
│  │                  │         │  /api/public/agendar   ──── ┼──►│
│  └──────────────────┘         │                             │  FCM
│                               │  /api/auth/login            │   │
│  ┌──────────────────┐         │  /api/auth/register-token   │   │
│  │  Barbeiro (App)  │◄───────►│  /api/agendamentos          │   │
│  │                  │         │  /api/clientes              │   │
│  │  Flutter + FCM   │         │  /api/servicos              │   │
│  │  Dashboard       │   Push  │  /api/agenda/dashboard      │   │
│  │  Notificações ◄──┼─────────┼─────────────────────────────┘   │
│  └──────────────────┘         │                                 │
│                               │  SQLite                         │
│                               │  clientes / servicos /          │
│                               │  agendamentos / usuarios /      │
│                               │  push_tokens                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. Roadmap de Implementação

### Fase 1 — Backend público (estimativa: 1–2 dias)
- [ ] Criar `routes/public.py` com os 4 endpoints públicos
- [ ] Implementar lógica de slots de horário disponíveis
- [ ] Implementar upsert de cliente por telefone
- [ ] Registrar o Blueprint em `app.py`
- [ ] Testar os endpoints com Postman ou curl

### Fase 2 — Notificações push (estimativa: 1–2 dias)
- [ ] Criar projeto no Firebase Console e baixar `firebase-service-account.json`
- [ ] Adicionar `firebase-admin` ao `requirements.txt`
- [ ] Criar `utils/notifications.py`
- [ ] Criar tabela `push_tokens` no banco (adicionar em `init_db_simple.py`)
- [ ] Criar rota `POST /api/auth/register-token`
- [ ] Integrar envio de notificação na rota `POST /api/public/agendar`

### Fase 3 — App Flutter (barbeiro) recebe push (estimativa: 1 dia)
- [ ] Adicionar `firebase_core` e `firebase_messaging` ao `pubspec.yaml`
- [ ] Inicializar Firebase no `main.dart`
- [ ] Solicitar permissão de notificação
- [ ] Registrar token no backend ao fazer login
- [ ] Testar notificação com app em primeiro plano e segundo plano

### Fase 4 — Interface de chat do cliente (estimativa: 2–3 dias)
- [ ] Criar `barbearia-backend/static/chat/index.html`
- [ ] Implementar a máquina de estados do chat em `chat.js`
- [ ] Adicionar rota `/agendar` no Flask
- [ ] Testar o fluxo completo ponta a ponta

### Fase 5 — Testes e ajustes (estimativa: 1 dia)
- [ ] Testar conflito de horário (dois clientes, mesmo slot)
- [ ] Testar com celular do barbeiro desligado e ligado
- [ ] Testar no mobile do cliente (iPhone e Android)
- [ ] Validar textos e mensagens de erro do chat

---

## 6. Dependências e Configurações Necessárias

### Firebase
- Criar conta em [https://console.firebase.google.com](https://console.firebase.google.com)
- Criar um projeto (ex: `ponto-do-corte`)
- Adicionar app Android/iOS para o Flutter
- Baixar o arquivo `google-services.json` (Android) ou `GoogleService-Info.plist` (iOS)
- Baixar `firebase-service-account.json` para o backend (em "Configurações do Projeto > Contas de serviço")
- **Nunca commitar** `firebase-service-account.json` no Git — adicionar ao `.gitignore`

### Variáveis de ambiente (`.env` do backend)
```
SECRET_KEY=sua-chave-secreta-forte-aqui
FIREBASE_CREDENTIALS=firebase-service-account.json
```

### `requirements.txt` atualizado
```
Flask==2.3.3
Flask-CORS==4.0.0
Flask-SQLAlchemy==3.1.1
SQLAlchemy==2.0.28
pytest==7.4.3
PyJWT==2.8.0
firebase-admin==6.5.0
python-dotenv==1.0.0
```

---

## 7. Pontos de Atenção

**Segurança das rotas públicas**
As rotas `/api/public/*` não exigem autenticação, mas devem ter rate limiting para evitar spam. Para o projeto acadêmico isso é opcional, mas vale mencionar no relatório. Uma solução simples é limitar por IP usando `Flask-Limiter`.

**Conflito de horário**
Dois clientes podem selecionar o mesmo horário quase simultaneamente. A rota `POST /api/public/agendar` deve verificar novamente a disponibilidade dentro de uma transação antes de confirmar. Isso já tem precedente no código atual (`try/except` com `conn.rollback()`).

**Token FCM expira**
O token do dispositivo pode mudar (reinstalação do app, por exemplo). O `OnTokenRefresh` do FCM deve atualizar o token no backend automaticamente.

**Fuso horário**
O SQLite armazena datas sem timezone. Garantir que o frontend web do cliente e o backend usem sempre o mesmo fuso (UTC ou horário de Brasília com offset fixo `-03:00`) para não haver desencontro de horários.

---

## 8. Resultado Esperado

Ao final desta implementação, o fluxo completo será:

1. Cliente acessa `http://seudominio.com/agendar` no celular
2. O chat guia o cliente em menos de 1 minuto até a confirmação
3. O barbeiro recebe uma notificação push no celular instantaneamente
4. O agendamento já aparece na agenda do app Flutter do barbeiro
5. Zero interação manual do barbeiro para criar o agendamento

Isso transforma o sistema de uma ferramenta de gestão interna (só o barbeiro usa) em um sistema completo de **autoatendimento digital** — o cliente agenda sozinho, o barbeiro só executa.
