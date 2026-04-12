# Estrutura da Base de Código

## Raiz
- `barbearia-backend/`: API Flask em Python.
- `barbearia-frontend/`: Aplicativo Flutter.
- `docs/`: Documentação e ativos do projeto.
- `.planning/`: Sistema GSD (Contratos, Roadmap, Estado).

## Backend (`barbearia-backend/`)
- `app.py`: Inicialização do app e rotas estáticas para o chat.
- `config.py`: Configurações de ambiente (Database, JWT, Firebase).
- `firebase-service-account.json`: Credenciais privadas do Firebase.
- `models/`: Definições SQLAlchemy.
  - `push_token.py`: Armazenamento de tokens FCM.
  - `agendamento.py`, `cliente.py`, `servico.py`, `usuario.py`.
- `routes/`: Lógica de endpoints (Blueprints).
  - `public.py`: Endpoints para o chat de agendamento.
  - `auth.py`, `clientes.py`, `servicos.py`, `agendamentos.py`.
- `static/chat/`: Frontend web simplificado para clientes.
- `utils/notifications.py`: Wrapper para o Firebase Admin SDK.
- `database/`: Diretório do banco SQLite.

## Frontend (`barbearia-frontend/`)
- `lib/`:
  - `main.dart`: Ponto de entrada.
  - `services/api_service.dart`: Comunicação com o backend.
  - `providers/`: Gerenciamento de estado.
  - `screens/`: Telas (Login, Dashboard, Agendamentos).
- `assets/`: Logos e imagens do "Ponto do Corte".
- `web/`, `windows/`: Pastas de build específicas de plataforma.
