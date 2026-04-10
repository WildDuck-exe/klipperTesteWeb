# Architecture

## System Overview
The system follows a classic **Client-Server Architecture** designed for a digital barber shop management system.

## Backend Architecture (Flask)
- **Pattern**: Monolithic REST API.
- **Data Access**: Direct logic in `app.py` and helpers in `database/`. Even though `models/` exists, the core API logic currently resides in `app.py` for simplicity.
- **Database**: Relational (SQLite) with tables for `clientes`, `servicos`, and `agendamentos`.
- **Integrations**: Cross-Origin Resource Sharing (CORS) enabled to allow Flutter app interaction.

## Frontend Architecture (Flutter)
- **Pattern**: Widget-based UI with Provider for state management.
- **Service Layer**: `api_service.dart` handles abstraction of HTTP calls.
- **Navigation**: Imperative routing between screens (Home, Clientes, Servicos, etc.).
- **Responsiveness**: Built using Flutter's layout system, suitable for mobile and potentially web/desktop.

## Data Flow
1. User interacts with Flutter UI.
2. Flutter service layer makes HTTP request to Python backend.
3. Backend processes request, interacts with SQLite, and returns JSON.
4. Flutter UI updates based on the response.
