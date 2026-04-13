# Arquitetura - Ponto do Corte

## Visão Geral

Sistema completo de gestão para barbearias em arquitetura **3 camadas** com componentes independentes:

```
┌─────────────────────────────────────────────────────────────┐
│                     CLIENTE (Browser)                        │
│              Chat Web — Interface Pública                    │
│              HTML/JavaScript Vanilla                         │
└─────────────────────────┬───────────────────────────────────┘
                          │ HTTP REST (público)
┌─────────────────────────▼───────────────────────────────────┐
│                  BACKEND (Flask)                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Blueprints │  │  SQLAlchemy  │  │  Firebase    │     │
│  │  (RotAS)     │  │    ORM       │  │  FCM SDK     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                            │
│  auth │ clientes │ servicos │ agendamentos │ public        │
│  configuracao │ despesas                                       │
└─────────────────────────┬───────────────────────────────────┘
                          │ SQLite (barbearia.db)
┌─────────────────────────▼───────────────────────────────────┐
│            FRONTEND (Flutter/Provider)                       │
│  App Desktop/Windows + Mobile                                │
│  Home │ Clientes │ Agenda │ Configurações                    │
└─────────────────────────────────────────────────────────────┘
```

## Padrões Arquiteturais

### 1. Modularização via Blueprints (Flask)
Cada domínio funcional é um **Blueprint** registrado independentemente:
- `auth_bp` — Autenticação JWT
- `clientes_bp` — CRUD de clientes
- `servicos_bp` — Catálogo de serviços
- `agendamentos_bp` — Gestão de horários
- `public_bp` — Endpoints públicos (chat do cliente)
- `configuracao_bp` — Configurações do barbearia
- `despesas_bp` — Controle financeiro

### 2. ORM com SQLAlchemy 2.0
Todos os modelos herdam de `db.Model` e utilizam:
- Tipos declarativos Python
- Relacionamentos definidos via `db.relationship`
- Integridade referencial no banco
- Migração futura para PostgreSQL facilitada

### 3. Autenticação JWT
- Tokens signed com `PyJWT`
- Middleware `require_auth` em rotas protegidas
- Tokens persistidos localmente via `shared_preferences` no Flutter

### 4. Push Notifications via FCM
- Backend: `firebase-admin` SDK com multicast para múltiplos dispositivos
- Frontend: `firebase_messaging` para registro de tokens
- Modelo `PushToken` associa tokens a dispositivos do barbeiro

### 5. Interface Pública sem Autenticação (Chat)
- Clientes acessam `/chat/` via browser
- Agendamentos criados via `/api/public/horarios` e `/api/public/agendar` sem login
- Remove barreira de cadastro para maior conversão

## Componentes do Sistema

| Componente | Tecnologia | Responsabilidade |
|-----------|------------|------------------|
| API Backend | Flask + Blueprints | Endpoints REST, lógica de negócio |
| Banco de Dados | SQLite + SQLAlchemy | Persistência de dados |
| Chat Web | HTML/JS Vanilla | Interface do cliente |
| App Desktop | Flutter + Provider | Painel administrativo |
| Notificações | Firebase FCM | Alertas push cross-device |
| Autenticação | PyJWT | Tokens JWT para API |

## Fluxo de Dados Principal

### Agendamento via Chat (Cliente)
```
Cliente abre /chat/ 
  → GET /api/public/horarios (horários disponíveis)
  → POST /api/public/agendar (nome, telefone, horário, serviço)
    → Validação de telefone
    → Verificação de slot disponível
    → Criação do Agendamento
    → FCM multicast para todos PushTokens do barbeiro
    → Resposta JSON com confirmação
```

### Gestão (Barbeiro via App Flutter)
```
App faz login com JWT
  → GET/POST/PUT/DELETE em /api/clientes, /api/servicos, /api/agendamentos
  → Notificações FCM para atualizações
```

## Decisões Arquiteturais Chave

| Decisão | Racional |
|---------|----------|
| SQLAlchemy ORM | Abstrai banco para migração futura (PostgreSQL) |
| Chat Público | Maior conversão — cliente não precisa criar conta |
| FCM Multicast | Um agendamento notifica todos os dispositivos do barbeiro |
| Blueprints | Separação clara de responsabilidades por domínio |
| Flutter/Provider | Estado simples sem complexidade de BLoC para app desktop |

## Segurança

- **JWT**: Tokens com expiração para sessões seguras
- **FCM Credentials**: `firebase-service-account.json` em `.gitignore`
- **CORS**: Configurado por rota (público vs. autenticado)
- **Validação**: Phone validation em `utils/validation.py`
- **Rate Limiting**: Recomendado para `/api/public` antes do deploy

## Escalabilidade e Limitações

- **SQLite**: Trava em alta concorrência — migração para PostgreSQL se volume crescer
- **Race Condition**: Verificação atômica de slot recomendada (atualmente em lógica de aplicação)
- **FCM Windows**: Suporte Flutter desktop limitado — polling como fallback

## Conformidade com REGRA_GLOBAL_PRIMARIA

A arquitetura foi desenhada para **minimizar chamadas API**:
- Chat web faz **2 chamadas** por agendamento (GET horarios + POST agendar)
- App Flutter usa endpoints REST consolidados por domínio
- Blueprints permitem organizacao modular sem redundancia de codigo
- Arquivos estaticos servidos diretamente sem framework adicional
