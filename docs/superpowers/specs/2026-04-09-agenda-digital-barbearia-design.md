# Especificação: Agenda Digital para Barbearia

## 1. Visão Geral

**Projeto:** Agenda Digital para Barbearia  
**Tipo:** Projeto de Extensão II - Engenharia de Software  
**Parceiro:** Barbearia local  
**Abordagem:** MVP Focado  
**Stack:** Flutter (frontend mobile) + Python/Flask (backend) + SQLite (banco)

## 2. Contexto e Justificativa

Muitas barbearias ainda utilizam métodos manuais para agendamentos (caderno, WhatsApp, anotações), o que gera:
- Conflitos de horário
- Perda de informações de clientes
- Dificuldade para localizar marcações anteriores
- Desorganização da rotina de trabalho

Esta solução digital visa melhorar a organização dos agendamentos e registros de atendimento através de uma aplicação móvel simples e funcional.

## 3. Objetivos

### 3.1 Objetivo Geral
Desenvolver uma aplicação móvel para organizar agendamentos, registrar clientes e melhorar o controle dos atendimentos em uma barbearia.

### 3.2 Objetivos Específicos
- Cadastrar clientes com informações básicas
- Registrar serviços oferecidos pela barbearia
- Agendar atendimentos por data e horário
- Visualizar agenda do dia
- Marcar atendimentos como concluídos
- Listar agendamentos futuros

## 4. Arquitetura do Sistema

### 4.1 Stack Tecnológica
- **Frontend:** Flutter (Dart) - aplicação móvel cross-platform
- **Backend:** Python + Flask - API REST
- **Banco de Dados:** SQLite (desenvolvimento), PostgreSQL (produção opcional)
- **Comunicação:** HTTP/JSON

### 4.2 Diagrama de Arquitetura
```
App Flutter (Mobile) → API Flask (Python) → SQLite Database
       ↑                       ↑
    Interface              Processamento
    Usuário                   Dados
```

## 5. Modelos de Dados

### 5.1 Cliente
```sql
CREATE TABLE clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    telefone TEXT,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### 5.2 Serviço
```sql
CREATE TABLE servicos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    descricao TEXT,
    duracao_minutos INTEGER DEFAULT 30,
    preco DECIMAL(10,2)
);
```

### 5.3 Agendamento
```sql
CREATE TABLE agendamentos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cliente_id INTEGER NOT NULL,
    servico_id INTEGER NOT NULL,
    data_hora DATETIME NOT NULL,
    observacoes TEXT,
    status TEXT DEFAULT 'agendado', -- 'agendado', 'concluido', 'cancelado'
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (servico_id) REFERENCES servicos(id)
);
```

## 6. Backend (Python/Flask)

### 6.1 Estrutura do Projeto
```
barbearia-backend/
├── app.py
├── requirements.txt
├── database/
│   ├── init_db.py
│   └── barbearia.db
├── models/
│   ├── cliente.py
│   ├── agendamento.py
│   └── servico.py
├── routes/
│   ├── clientes.py
│   ├── agendamentos.py
│   └── servicos.py
└── utils/
    └── validators.py
```

### 6.2 Endpoints da API

#### Clientes
- `GET /api/clientes` - Listar todos os clientes
- `GET /api/clientes/{id}` - Obter cliente específico
- `POST /api/clientes` - Criar novo cliente
- `PUT /api/clientes/{id}` - Atualizar cliente
- `DELETE /api/clientes/{id}` - Excluir cliente

#### Agendamentos
- `GET /api/agendamentos` - Listar agendamentos (com filtro por data)
- `GET /api/agendamentos/{id}` - Obter agendamento específico
- `POST /api/agendamentos` - Criar novo agendamento
- `PUT /api/agendamentos/{id}/concluir` - Marcar como concluído
- `PUT /api/agendamentos/{id}/cancelar` - Cancelar agendamento
- `DELETE /api/agendamentos/{id}` - Excluir agendamento

#### Serviços
- `GET /api/servicos` - Listar serviços
- `POST /api/servicos` - Criar novo serviço

## 7. Frontend (Flutter)

### 7.1 Estrutura do Projeto
```
barbearia-app/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── cliente.dart
│   │   ├── agendamento.dart
│   │   └── servico.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── cliente_service.dart
│   │   └── agendamento_service.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── clientes_screen.dart
│   │   ├── agendamentos_screen.dart
│   │   ├── novo_agendamento_screen.dart
│   │   └── agenda_dia_screen.dart
│   ├── widgets/
│   │   ├── cliente_card.dart
│   │   ├── agendamento_card.dart
│   │   └── date_picker.dart
│   └── utils/
│       └── constants.dart
├── pubspec.yaml
└── assets/
```

### 7.2 Telas Principais

#### 7.2.1 Tela Inicial (HomeScreen)
- Menu com opções principais
- Acesso rápido às funcionalidades
- Visão geral do dia (próximos agendamentos)

#### 7.2.2 Tela de Clientes (ClientesScreen)
- Lista de clientes cadastrados
- Botão "Novo Cliente"
- Busca por nome/telefone
- Edição/exclusão de clientes

#### 7.2.3 Tela de Agendamentos (AgendamentosScreen)
- Lista de agendamentos futuros
- Filtro por data
- Botão "Novo Agendamento"
- Visualização em lista ou calendário

#### 7.2.4 Tela Novo Agendamento (NovoAgendamentoScreen)
- Formulário com:
  - Seleção de cliente (dropdown ou busca)
  - Seleção de serviço
  - Seleção de data e hora
  - Campo de observações
- Validação de conflitos de horário

#### 7.2.5 Tela Agenda do Dia (AgendaDiaScreen)
- Lista dos agendamentos do dia atual
- Agrupamento por horário
- Botão para marcar como concluído
- Visualização rápida do fluxo do dia

## 8. Fluxo de Dados

### 8.1 Comunicação
- **Protocolo:** HTTP/HTTPS
- **Formato:** JSON
- **Autenticação:** Simples (sem auth para MVP)
- **CORS:** Configurado para permitir requests do app

### 8.2 Exemplo: Criar Agendamento
1. App coleta dados do formulário
2. Converte para JSON
3. Envia POST para `/api/agendamentos`
4. Backend valida e insere no banco
5. Retorna resposta com ID criado
6. App atualiza interface

### 8.3 Tratamento de Erros
- Validação no frontend (campos obrigatórios)
- Validação no backend (conflitos de horário)
- Mensagens de erro amigáveis
- Tratamento de offline (tentar novamente)

## 9. Plano de Desenvolvimento

### Fase 1: Setup e Backend Básico (1-2 semanas)
- Configurar ambiente Python/Flask
- Criar estrutura do banco SQLite
- Desenvolver endpoints CRUD básicos
- Testar API com Postman

### Fase 2: Frontend Básico (2-3 semanas)
- Configurar projeto Flutter
- Criar modelos Dart
- Desenvolver serviço de API
- Criar telas principais

### Fase 3: Funcionalidades Principais (2-3 semanas)
- Tela de cadastro de cliente
- Tela de novo agendamento
- Tela de agenda do dia
- Marcar agendamento como concluído

### Fase 4: Integração e Testes (1-2 semanas)
- Conectar frontend com backend
- Testar fluxo completo
- Corrigir bugs
- Testar em dispositivo físico

### Fase 5: Validação e Ajustes (1 semana)
- Apresentar para o parceiro
- Coletar feedback
- Fazer ajustes necessários
- Documentar resultados

## 10. Requisitos Não-Funcionais

### 10.1 Usabilidade
- Interface simples e intuitiva
- Navegação fácil entre telas
- Feedback visual para ações
- Mensagens claras de erro/sucesso

### 10.2 Performance
- Tempo de resposta da API < 2 segundos
- App responsivo (60 FPS)
- Cache local para melhor experiência

### 10.3 Manutenibilidade
- Código bem estruturado e documentado
- Separação clara de responsabilidades
- Facilidade para adicionar novas funcionalidades

### 10.4 Compatibilidade
- Android 8.0+ (API 26+)
- iOS 12.0+
- Resoluções de tela comuns

## 11. Riscos e Mitigações

### 11.1 Riscos Técnicos
- **Conflitos de horário:** Validação no backend
- **Perda de dados:** Backup regular do banco
- **Problemas de conexão:** Cache local no app

### 11.2 Riscos de Projeto
- **Escopo muito amplo:** Foco no MVP
- **Tempo insuficiente:** Priorizar funcionalidades essenciais
- **Feedback do parceiro:** Validação contínua

## 12. Critérios de Aceitação

### 12.1 Funcionais
- [ ] Cadastrar novo cliente
- [ ] Listar clientes cadastrados
- [ ] Criar novo agendamento
- [ ] Visualizar agendamentos do dia
- [ ] Marcar agendamento como concluído
- [ ] Listar agendamentos futuros

### 12.2 Não-Funcionais
- [ ] App responsivo e fluido
- [ ] API com tempo de resposta aceitável
- [ ] Interface intuitiva
- [ ] Tratamento adequado de erros

## 13. Próximos Passos

1. **Aprovação desta especificação**
2. **Criação do plano de implementação detalhado**
3. **Início do desenvolvimento (Fase 1)**
4. **Validações periódicas com o parceiro**

---

*Documento criado em: 2026-04-09*  
*Projeto: Agenda Digital para Barbearia*  
*Contexto: Projeto de Extensão II - Engenharia de Software*