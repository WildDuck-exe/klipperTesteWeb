# INTEGRATIONS - External Services and Dependencies

## Overview

The Barbearia system integrates with several external services for authentication, notifications, and data storage. This document details all external integrations, their purpose, implementation status, and configuration requirements.

---

## Database Integration

### SQLite (Development Database)
- **Type:** Embedded RDBMS
- **Location:** `barbearia-backend/database/barbearia.db`
- **ORM:** SQLAlchemy 2.0.36 with Flask-SQLAlchemy 3.1.1
- **Connection String:** `sqlite:///database/barbearia.db`
- **Purpose:** Primary data storage for all business entities
- **Status:** Fully implemented and operational

**Entities Managed:**
- `clientes` - Customer records
- `servicos` - Service offerings
- `agendamentos` - Appointments
- `usuarios` - User accounts (barbers)
- `despesas` - Expenses
- `configuracao` - Application settings
- `push_tokens` - FCM device tokens

---

## Firebase Integration

### Firebase Cloud Messaging (FCM)

#### Frontend Integration
- **Package:** `firebase_core: ^3.6.0` + `firebase_messaging: ^15.1.3`
- **Platforms:** Android, iOS, Windows (limited)
- **Purpose:** Push notifications for appointment reminders
- **Implementation:**
  - Request notification permissions on app startup
  - Register device FCM token with backend
  - Handle incoming notifications when app is foregrounded

#### Backend Integration
- **Package:** `firebase-admin: 6.5.0`
- **Purpose:** Server-side FCM token management and notification sending
- **Implementation:** `utils/notifications.py`
- **Service Account:** `firebase-service-account.json` (stored in backend root)
- **Status:** Configured but reported issues on Windows platform

#### Push Notification Flow
1. Client app initializes Firebase and obtains FCM token
2. Token is sent to backend via `POST /api/auth/register-token`
3. Token stored in `push_tokens` table
4. On appointment events (create/update/cancel), backend sends FCM notification
5. Client app displays notification based on authorization status

#### Configuration Required
```json
{
  "type": "service_account",
  "project_id": "barbearia-...",
  "private_key_id": "...",
  "private_key": "...",
  "client_email": "...",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token"
}
```

---

## Authentication Integration

### JWT-Based Authentication
- **Library:** PyJWT 2.8.0
- **Algorithm:** HS256
- **Token Expiry:** 24 hours
- **Storage:** Flutter `shared_preferences` (frontend), in-memory decode (backend)

#### Login Flow
1. User submits credentials to `POST /api/auth/login`
2. Backend validates against `Usuario` model (password hashed with Werkzeug)
3. On success, returns JWT token and username
4. Frontend stores token in `shared_preferences`
5. Subsequent API requests include `Authorization: Bearer <token>` header

#### Protected Endpoints
All `/api/*` routes except:
- `POST /api/auth/login`
- `POST /api/auth/register-token` (requires valid auth)
- `GET /api/public/*`

---

## HTTP API Integration

### Backend API
- **Base URL:** `http://localhost:5000` (development)
- **Framework:** Flask REST API with Blueprint routing
- **Format:** JSON request/response
- **CORS:** Enabled for all origins in development

#### API Endpoints

| Endpoint | Methods | Purpose |
|----------|---------|---------|
| `/api/auth/login` | POST | User authentication |
| `/api/auth/register-token` | POST | Register FCM push token |
| `/api/clientes` | GET, POST | List/create customers |
| `/api/clientes/<id>` | GET, PUT, DELETE | Customer CRUD |
| `/api/servicos` | GET, POST | List/create services |
| `/api/servicos/<id>` | GET, PUT, DELETE | Service CRUD |
| `/api/agendamentos` | GET, POST | List/create appointments |
| `/api/agendamentos/<id>` | GET, PUT, DELETE | Appointment CRUD |
| `/api/agendamentos/dashboard` | GET | Dashboard statistics |
| `/api/despesas` | GET, POST | List/create expenses |
| `/api/configuracao` | GET, PUT | App configuration |
| `/chat/` | GET | Serve chat interface |

---

## Frontend-Backend Communication

### ApiService (Flutter)
- **Class:** `ApiService extends ChangeNotifier`
- **HTTP Client:** `package:http/http.dart` (v1.1.0)
- **Base URL Config:** Loaded from `.env` via `flutter_dotenv`

#### Data Models
- `Cliente` - Customer data model
- `Servico` - Service data model
- `Agendamento` - Appointment data model
- `Despesa` - Expense data model
- `DashboardData` - Dashboard statistics

#### State Management
- Provider pattern for global state
- Token persisted in `shared_preferences`
- Automatic re-authentication check on app start

---

## External URL Handling

### url_launcher (^6.2.1)
- **Purpose:** Launch external URLs (phone calls, email, maps)
- **Usage:** Click-to-call for customer phone numbers
- **Platforms:** Android, iOS, Web, Windows

---

## UI/UX Integrations

### google_fonts (^6.1.0)
- **Purpose:** Custom typography beyond system fonts
- **Usage:** App-wide font styling

### animations (^2.0.11)
- **Purpose:** Material motion animations for transitions
- **Usage:** Page transitions, widget animations

### flutter_spinkit (^5.2.0)
- **Purpose:** Loading indicator animations
- **Usage:** API call loading states

### intl (^0.19.0)
- **Purpose:** Date/time formatting and internationalization
- **Usage:** Formatting appointment dates, currency display

---

## Environment Configuration

### Environment Variables

#### Backend (.env)
| Variable | Description | Default |
|----------|-------------|---------|
| `FLASK_APP` | Application entry point | `app.py` |
| `FLASK_ENV` | Environment mode | `development` |
| `SECRET_KEY` | JWT signing key | `dev-secret-key-barbearia-2026` |
| `API_VERSION` | API version | `1.0.0` |
| `DEBUG` | Debug mode | `True` |

#### Frontend (.env)
| Variable | Description | Default |
|----------|-------------|---------|
| `API_BASE_URL` | Backend API URL | `http://localhost:5000` |

---

## Third-Party Dependencies Summary

### Backend Dependencies (requirements.txt)
```
Flask==2.3.3
Flask-CORS==4.0.0
Flask-SQLAlchemy==3.1.1
SQLAlchemy==2.0.36
pytest==7.4.3
PyJWT==2.8.0
firebase-admin==6.5.0
python-dotenv==1.0.0
```

### Frontend Dependencies (pubspec.yaml)
```
http: ^1.1.0
provider: ^6.1.1
intl: ^0.19.0
flutter_dotenv: ^5.1.0
shared_preferences: ^2.2.2
firebase_core: ^3.6.0
firebase_messaging: ^15.1.3
url_launcher: ^6.2.1
google_fonts: ^6.1.0
animations: ^2.0.11
flutter_spinkit: ^5.2.0
```

---

## Integration Status

| Integration | Status | Notes |
|-------------|--------|-------|
| SQLite Database | Operational | Full CRUD working |
| JWT Authentication | Operational | 24hr tokens |
| Firebase (Android/iOS) | Partial | FCM token registration works |
| Firebase (Windows) | Issues | Reported problems on Windows platform |
| Push Notifications | Partial | Token stored, sending has issues |
| HTTP API | Operational | RESTful JSON API complete |
| Environment Config | Operational | .env files in use |