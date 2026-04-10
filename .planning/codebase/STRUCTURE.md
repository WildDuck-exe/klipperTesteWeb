# Codebase Structure

## Root
- `barbearia-backend/`: The Python Flask API.
- `barbearia-frontend/`: The Flutter Mobile/Web app.
- `docs/`: Project documentation (Postman collections, etc.).
- `.planning/`: GSD system directory (contains this map).

## Backend (`barbearia-backend/`)
- `app.py`: Main application entry point and API routes.
- `run.py`: Script to start the development server.
- `config.py`: Configuration settings.
- `init_db_simple.py`: Basic database initialization script.
- `models/`: Data models for Clientes, Servicos, and Agendamentos.
- `database/`: Contains the SQLite `.db` file (post-initialization).
- `routes/`: (Placeholder) Currently empty; routes reside in `app.py`.
- `tests/`: Pytest suite for API verification.
- `utils/`: Common utilities.

## Frontend (`barbearia-frontend/`)
- `lib/`: Main source code.
  - `main.dart`: Application entry point.
  - `services/`: API communication layer.
  - `screens/`: Application pages (Home, Clientes, etc.).
  - `widgets/`: Reusable UI components.
- `pubspec.yaml`: Dependency management.
- `assets/`: Image and font assets.
- `.env`: Environment variables (API URLs).
