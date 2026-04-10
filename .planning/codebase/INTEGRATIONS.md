# Integrations

## Internal Integrations

### Frontend ↔ Backend
The Flutter frontend communicates with the Flask backend via a REST API.
- **Communication Protocol**: HTTP/HTTPS
- **Data Format**: JSON
- **Base URL**: Configured via `.env` (default: `http://localhost:5000`)

### API Endpoints
- **Status Check**: `GET /` - Health check and version info.
- **Clients**:
  - `GET /api/clientes` - List all clients.
  - `GET /api/clientes/<id>` - Get specific client details.
  - `POST /api/clientes` - Create a new client.
- **Services**:
  - `GET /api/servicos` - List all services offered.
  - `POST /api/servicos` - Create a new service.
- **Appointments (Agendamentos)**:
  - `GET /api/agendamentos` - List all appointments.
  - `POST /api/agendamentos` - Create a new appointment.
  - `PUT /api/agendamentos/<id>/concluir` - Mark appointment as completed.
  - `PUT /api/agendamentos/<id>/cancelar` - Mark appointment as cancelled.
  - `GET /api/agenda/hoje` - Daily agenda for current date.

## External Integrations
- **None currently documented**: The application appears self-contained using local SQLite.
