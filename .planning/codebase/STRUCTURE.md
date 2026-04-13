# Estrutura do Projeto - Ponto do Corte

## Raiz do Projeto

```
C:/Users/Ian/Desktop/Nova pasta/
├── barbearia-backend/          # API Flask (Python)
├── barbearia-frontend/         # App Flutter (Dart)
├── .planning/                  # Documentação GSD
│   ├── codebase/
│   │   ├── ARCHITECTURE.md     # Arquitetura do sistema
│   │   ├── STACK.md            # Stack de tecnologia
│   │   ├── CONCERNS.md         # Riscos e preocupações
│   │   ├── CONVENTIONS.md      # Convenções de código
│   │   ├── INTEGRATIONS.md     # Integrações externas
│   │   ├── TESTING.md          # Estratégia de testes
│   │   └── STRUCTURE.md        # (este arquivo)
│   ├── phases/                 # Planos de fase GSD
│   ├── config.json             # Configuração GSD
│   ├── PROJECT.md              # Estado do projeto
│   ├── REQUIREMENTS.md         # Requisitos
│   ├── ROADMAP.md              # Roadmap de fases
│   └── STATE.md                # Estado atual
├── REGRA_GLOBAL_PRIMARIA.md    # Regra suprema (minimizar APIs)
└── INSTRUCOES*.md              # Instruções do projeto
```

## Backend (barbearia-backend/)

```
barbearia-backend/
├── app.py                      # Aplicação Flask principal
├── config.py                   # Configurações (DB, CORS, JWT)
├── run.py                      # Entry point (para produção)
├── init_db.py                  # Script de inicialização do banco
├── init_db_simple.py           # Script simplificado
├── requirements.txt            # Dependências Python
├── .env.example                # Template de variáveis de ambiente
├── .gitignore                  # Ignora .env, *.db, firebase-*.json
├── firebase-service-account.json  # Credenciais FCM (NUNCA COMITAR)
├── database/
│   └── barbearia.db           # Banco SQLite
├── models/                     # Modelos SQLAlchemy
│   ├── __init__.py            # db = SQLAlchemy() + exports
│   ├── cliente.py             # Cliente (nome, telefone, obs)
│   ├── servico.py             # Servico (nome, duracao, preco)
│   ├── agendamento.py         # Agendamento (fk cliente, servico, datetime)
│   ├── push_token.py          # PushToken (token FCM, dispositivo)
│   ├── usuario.py             # Usuario (login, senha hash)
│   ├── configuracao.py         # Configuracao (horario funcionamento, etc)
│   └── despesa.py             # Despesa (descricao, valor, categoria)
├── routes/                     # Blueprints Flask
│   ├── __init__.py            # register_blueprints()
│   ├── auth.py                # /api/auth/* (login, register, refresh)
│   ├── clientes.py            # /api/clientes/*
│   ├── servicos.py            # /api/servicos/*
│   ├── agendamentos.py        # /api/agendamentos/*
│   ├── public.py              # /api/public/* (chat - sem auth)
│   ├── configuracao.py         # /api/configuracao/*
│   └── despesas.py            # /api/despesas/*
├── utils/                      # Utilitários compartilhados
│   ├── __init__.py
│   ├── auth.py                # JWT encode/decode, require_auth
│   ├── notifications.py       # Firebase FCM multicast
│   └── validation.py         # Validação de telefone, campos
├── static/chat/                # Interface web do cliente
│   ├── index.html             # Página principal do chat
│   ├── chat.js                # Lógica do chat (fetch API)
│   └── chat.css               # Estilos
├── tests/                      # Suite pytest
│   ├── conftest.py            # Fixtures (db, client)
│   ├── test_agendamento.py
│   ├── test_cliente.py
│   ├── test_servico.py
│   └── test_init_db.py
└── scratch/                    # Scripts temporários
    ├── cleanup_phones.py
    ├── load_test.py
    └── migrate_servicos.py
```

## Frontend (barbearia-frontend/)

```
barbearia-frontend/
├── lib/
│   ├── main.dart              # Entry point Flutter
│   ├── app.dart               # Widget principal
│   ├── config/
│   │   ├── api_config.dart   # URLs da API, timeouts
│   │   └── firebase_config.dart
│   ├── models/
│   │   ├── cliente.dart
│   │   ├── servico.dart
│   │   ├── agendamento.dart
│   │   └── despesa.dart
│   ├── providers/
│   │   ├── auth_provider.dart      # JWT token state
│   │   ├── cliente_provider.dart
│   │   ├── agendamento_provider.dart
│   │   └── configuracao_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── clientes_screen.dart
│   │   ├── agenda_screen.dart
│   │   ├── configuracao_screen.dart
│   │   └── login_screen.dart
│   ├── widgets/
│   │   └── ... (componentes reutilizáveis)
│   └── services/
│       └── api_service.dart   # HTTP client centralizado
├── pubspec.yaml               # Dependências Dart
├── .env / .env.example        # Variáveis de ambiente
└── android/                   # Projeto Android (FCM)
    └── app/google-services.json
```

## Frontend Web (Chat - estático no backend)

```
barbearia-backend/static/chat/
├── index.html                 # SPA do chat do cliente
├── chat.js                   # Fetch API → /api/public/*
└── chat.css                  # Estilos
```

## Arquivos de Configuração

| Arquivo | Propósito |
|---------|-----------|
| `.env.example` | Template de variáveis (JWT_SECRET, DATABASE_URL, FCM_KEY_PATH) |
| `firebase-service-account.json` | Credenciais Google Cloud (NUNCA COMMITAR) |
| `.gitignore` | Ignora `.env`, `*.db`, `firebase-*.json`, `.dart_tool/build` |
| `pubspec.yaml` | Dependências Flutter (provider, firebase_core, http, etc) |
| `requirements.txt` | Dependências Python (flask, sqlalchemy, firebase-admin, etc) |

## Convenções de Nomeação

| Tipo | Convenção | Exemplo |
|------|-----------|---------|
| Modelos Python | PascalCase | `class Cliente(db.Model)` |
| Rotas Flask | snake_case | `/api/clientes`, `agendamentos_bp` |
| Tabelas DB | snake_case | `agendamentos`, `push_tokens` |
| Campos Flutter | camelCase | `nome`, `telefone`, `createdAt` |
| Endpoints públicos | `/api/public/*` | `/api/public/horarios`, `/api/public/agendar` |

## Fluxo de Requisição Típica

```
Cliente Chat:
GET /chat/ → index.html
  → chat.js → GET /api/public/horarios?data=YYYY-MM-DD
  → chat.js → POST /api/public/agendar {nome, telefone, servico_id, horario}
    → Validação → db.create_all() → FCM multicast → JSON response

App Flutter:
POST /api/auth/login {login, senha} → JWT token
  → Provider armazena token
  → GET /api/clientes → Provider → ListView
  → CRUD em /api/* com Bearer JWT header
```

## Dados Sensíveis (Protegidos)

- `barbearia-backend/.env` — contém segredos (NUNCA no repo)
- `barbearia-backend/firebase-service-account.json` — credenciais FCM
- `barbearia-frontend/.env` — API URL, configs
- `barbearia-frontend/android/app/google-services.json` — FCM Android

## Conformidade com REGRA_GLOBAL_PRIMARIA

A estrutura foi organizada para **minimizar APIs**:
- **Chat público**: apenas 2 chamadas por agendamento (GET + POST)
- **App Flutter**: providers consomem endpoints REST consolidados
- **Blueprints**: separação por domínio, sem redundância
- **Arquivos estáticos**: chat servidos diretamente (sem framework adicional)
