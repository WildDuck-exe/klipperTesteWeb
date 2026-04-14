# STRUCTURE - Project Organization

## Root Architecture

The **Klipper** workspace is organized into a modular structure separating concerns between backend, frontend, and planning.

```
D:/IA/Projeto_Klipper/
├── barbearia-backend/       # Python/Flask API + Web Chat static files
├── barbearia-frontend/      # Flutter native/web administrator application
├── .planning/               # GSD Project Management & Intelligence
├── .worktrees/              # Isolated Git work environments
├── docs/                    # Active documentation and historical archives
└── [root files]             # Core mission docs (Klipper, primary rules)
```

---

## Backend Structure (barbearia-backend/)

Modular Flask organization using Blueprints and SQLAlchemy.

```
barbearia-backend/
├── app.py                   # Application factory & entry point
├── requirements.txt         # Dependency manifest
├── database/                # SQLite instance storage
├── models/                  # SQLAlchemy ORM definitions
│   ├── cliente.py
│   ├── servico.py
│   ├── agendamento.py
│   └── ...
├── routes/                  # API endpoints grouped by focus
│   ├── auth.py              # Login & tokens
│   ├── public.py            # Public booking endpoints
│   └── ...
├── static/                  # Web Chat client
│   └── chat/                # JS, CSS, HTML for client booking
├── utils/                   # Shared logic (notificaions, auth)
└── tests/                   # Pytest suite
```

---

## Frontend Structure (barbearia-frontend/)

Standard Flutter production layout.

```
barbearia-frontend/
├── lib/
│   ├── main.dart           # App bootstrap
│   ├── screens/            # State-managed page widgets
│   ├── services/            # ApiService logic
│   ├── theme/              # Klipper design tokens
│   └── widgets/            # Reusable UI components
├── assets/                  # Images and fonts
├── pubspec.yaml             # Flutter metadata
└── windows/                 # Desktop-specific build configs
```

---

## Intelligence & Planning (.planning/)

Structure for Get Shit Done (GSD) workflow.

```
.planning/
├── codebase/               # System documentation (You are here)
├── milestones/             # [NEW] Archived phase history
│   └── v1.0-phases/         # Archived legacy phases
├── phases/                 # Active phase focus
├── PROJECT.md              # Project constitution
├── ROADMAP.md              # Phase timeline
└── STATE.md                # Real-time state tracking
```

---

## Documentation Archives (docs/)

```
docs/
├── archive/                 # [NEW] Redundant root files and drafts
└── superpowers/             # Specialized GSD intelligence
```

---

## Entry Points

- **Backend Backend**: `app.py`
- **Admin App**: `lib/main.dart`
- **Client Chat**: `static/chat/index.html`
- **Mission Master**: `KLIPPER_EXECUCAO_FASEADA.md`