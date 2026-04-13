# STRUCTURE

## Pastas Raiz do Projeto

```
C:/Users/Ian/Desktop/Nova pasta/
├── barbearia-backend/       # API e Banco de dados Python/Flask
├── barbearia-frontend/      # Aplicação Cliente Flutter
├── .planning/               # Documentação e gestão GSD do projeto
├── .worktrees/              # Worktrees Git para trabalhos isolados
├── docs/                    # Documentação adicional
└── [arquivos raiz]          # Configs, READMEs, planos
```

---

## Backend (barbearia-backend/)

### Estrutura de Diretórios

```
barbearia-backend/
├── app.py                   # Entry point principal da aplicação Flask
├── run.py                   # Script de execução (alternativo)
├── config.py                # Configurações (dev/prod)
├── requirements.txt         # Dependências Python
├── init_db.py              # Script de inicialização do banco
├── init_db_simple.py       # Script simplificado de inicialização
├── .env                     # Variáveis de ambiente
├── .env.example            # Template de variáveis
├── firebase-service-account.json  # Credenciais Firebase
├── database/
│   └── barbearia.db         # Banco de dados SQLite
├── models/                  # Modelos SQLAlchemy
│   ├── __init__.py
│   ├── cliente.py
│   ├── servico.py
│   ├── agendamento.py
│   ├── despesa.py
│   ├── configuracao.py
│   ├── push_token.py
│   └── usuario.py
├── routes/                  # Blueprints da API
│   ├── __init__.py
│   ├── auth.py
│   ├── clientes.py
│   ├── servicos.py
│   ├── agendamentos.py
│   ├── public.py
│   ├── configuracao.py
│   └── despesas.py
├── utils/                   # Funções utilitárias
│   ├── auth.py
│   ├── notifications.py
│   └── validation.py
├── static/                  # Arquivos estáticos (chat HTML)
│   └── chat/
├── tests/                   # Suite de testes pytest
└── scratch/                 # Scripts de teste временários

```

### Ponto de Entrada

- **Principal**: `app.py` - cria a aplicação Flask e registra blueprints
- **Alternativo**: `run.py` - pode ser usado para executar o servidor

---

## Frontend (barbearia-frontend/)

### Estrutura de Diretórios

```
barbearia-frontend/
├── pubspec.yaml             # Configuração do projeto Flutter
├── pubspec.lock             # Lock de dependências
├── .env                     # Variáveis de ambiente
├── .env.example            # Template
├── README.md               # Documentação do frontend
├── analysis_options.yaml   # Regras linting
├── lib/
│   ├── main.dart           # Entry point da aplicação Flutter
│   ├── screens/            # Telas da aplicação
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   ├── agendamentos_screen.dart
│   │   ├── clientes_screen.dart
│   │   ├── servicos_screen.dart
│   │   ├── financeiro_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── about_screen.dart
│   │   └── novo_agendamento_screen.dart
│   ├── services/            # Serviços (API, etc)
│   │   └── api_service.dart
│   ├── widgets/            # Componentes reutilizáveis
│   └── theme/              # Temas visuais
│       └── app_theme.dart
├── assets/
│   └── images/             # Imagens da aplicação
├── test/                   # Testes Flutter
├── android/                # Configurações Android
├── windows/                # Configurações Windows
├── web/                    # Configurações Web
└── build/                  # Build outputs
```

### Telas (screens/)

Cada tela é um arquivo Dart independente que implementa um StatefulWidget completo com:
- Interface visual (build method)
- Lógica de negócio (métodos da classe)
- Gerenciamento de estado local

---

## Planejamento (.planning/)

```
.planning/
├── PROJECT.md              # Visão geral do projeto
├── REQUIREMENTS.md         # Requisitos levantados
├── ROADMAP.md              # Roadmap de fases
├── STATE.md                # Estado atual do projeto
├── config.json            # Configurações GSD
├── codebase/               # Documentação de arquitetura
│   ├── ARCHITECTURE.md
│   ├── STRUCTURE.md
│   ├── CONCERNS.md
│   ├── CONVENTIONS.md
│   ├── INTEGRATIONS.md
│   ├── STACK.md
│   └── TESTING.md
└── phases/                # Planos de fases GSD
```

---

## Worktrees (.worktrees/)

Contém worktrees Git isolados para trabalho paralelo:
- `agent-a19b68a4/`
- `agent-a27e33f0/`
- etc.

Cada worktree representa uma sessão de trabalho isolada.

---

## Arquivos de Configuração Principais

| Arquivo | Propósito |
|---------|-----------|
| `requirements.txt` | Dependências Python do backend |
| `pubspec.yaml` | Dependências Flutter do frontend |
| `.env` | Variáveis de ambiente (credenciais) |
| `config.py` | Configurações do Flask |
| `ROADMAP.md` | Fases do projeto |
| `PROJECT.md` | Visão geral |