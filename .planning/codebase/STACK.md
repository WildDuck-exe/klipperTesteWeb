# STACK - Technology Stack

## Overview

This project is a **barbershop appointment management system** (Ponto do Corte) consisting of a Python/Flask backend API and a Flutter cross-platform frontend application. The system follows an **API-first architecture** with clear separation between backend (Flask + SQLAlchemy) and frontend (Flutter + Provider).

---

## Backend Stack

### Core Framework
- **Flask 2.3.3** - Lightweight WSGI web application framework
  - Used for REST API endpoints and static file serving
  - Serves both JSON API (`/api/*`) and chat interface (`/chat/*`)

### Database Layer
- **SQLAlchemy 2.0.36** - SQL toolkit and ORM
  - Provides database abstraction and model management
- **Flask-SQLAlchemy 3.1.1** - Flask integration for SQLAlchemy
- **Database Engine:** SQLite (`barbearia.db`)
  - File-based relational database stored in `barbearia-backend/database/`
  - Initialized via `init_db.py`

### Authentication & Security
- **PyJWT 2.8.0** - JSON Web Token implementation
  - Used for API authentication (24-hour token expiry)
  - Tokens encode `user_id` and `username` claims
- **Werkzeug** - Password hashing (via `check_password_hash`)
- **SECRET_KEY** - Environment-based secret key management

### API Architecture
- **Flask-CORS 4.0.0** - Cross-Origin Resource Sharing
  - Configured for `/*/api/*` endpoints with wildcard origins
- **Blueprint Pattern** - Modular route organization
  - Auth Blueprint, Clientes Blueprint, Servicos Blueprint, Agendamentos Blueprint, etc.

### Additional Backend Libraries
- **python-dotenv 1.0.0** - Environment variable management from `.env` files
- **firebase-admin 6.5.0** - Firebase Admin SDK (server-side)
  - Used for push notification orchestration

### Testing
- **pytest 7.4.3** - Python testing framework
  - Tests located in `barbearia-backend/tests/`

---

## Frontend Stack

### Framework & SDK
- **Flutter 3.x** - Cross-platform UI framework
  - SDK constraint: `>=3.0.0 <4.0.0`
  - Target platforms: Android, iOS, Web, Windows

### State Management
- **provider ^6.1.1** - State management solution
  - Used for global state (ApiService) via `MultiProvider`
  - `ChangeNotifier` pattern for reactive UI updates

### HTTP & Networking
- **http ^1.1.0** - HTTP client for API communication
  - Used in `ApiService` for REST API calls to backend
- **flutter_dotenv ^5.1.0** - Environment variable loading from `.env`

### Data Persistence
- **shared_preferences ^2.2.2** - Local key-value storage
  - Used for storing auth token on device

### Firebase Integration
- **firebase_core ^3.6.0** - Firebase core SDK
- **firebase_messaging ^15.1.3** - Firebase Cloud Messaging (FCM)
  - Push notification support
  - Platform-specific initialization (Android/iOS/Windows)

### UI Components & Theming
- **google_fonts ^6.1.0** - Typography
- **animations ^2.0.11** - Built-in Flutter animations
- **flutter_spinkit ^5.2.0** - Loading spinners
- **url_launcher ^6.2.1** - URL launching (calls, emails)
- **intl ^0.19.0** - Internationalization and date formatting

### Flutter Architecture
- Material Design 3 with custom theming
- `screens/` - Full-page StatefulWidgets
- `services/` - API communication layer (`ApiService`)
- `widgets/` - Reusable UI components
- `theme/` - App-wide theme configuration

---

## Development Tools

### Backend
- **Python** - Runtime environment
- **Flask Development Server** - Local development on port 5000
- **sqlite3** - Database engine (bundled with Python)

### Frontend
- **Dart** - Language runtime
- **Flutter CLI** - Build and development tools

---

## File Structure Summary

```
barbearia-backend/
├── app.py              # Flask application entry point
├── config.py           # Configuration classes
├── init_db.py          # Database initialization script
├── requirements.txt    # Python dependencies
├── models/             # SQLAlchemy models
├── routes/             # Flask blueprints (API endpoints)
├── utils/              # Utility functions (auth, notifications)
├── database/           # SQLite database files
├── static/             # Static assets (chat UI)
└── tests/              # pytest tests

barbearia-frontend/
├── pubspec.yaml        # Flutter dependencies
├── lib/
│   ├── main.dart      # App entry point
│   ├── screens/       # Page widgets
│   ├── services/      # API service layer
│   ├── widgets/       # Reusable components
│   └── theme/         # Theme definitions
└── assets/             # Images and static assets
```

---

## Environment Configuration

### Backend (.env)
```
FLASK_APP=app.py
FLASK_ENV=development
SECRET_KEY=<secret-key>
API_VERSION=1.0.0
DEBUG=True
```

### Frontend (.env)
```
API_BASE_URL=http://localhost:5000
```

---

## Version Information

| Component | Version |
|-----------|---------|
| Flask | 2.3.3 |
| SQLAlchemy | 2.0.36 |
| Flask-SQLAlchemy | 3.1.1 |
| Flask-CORS | 4.0.0 |
| PyJWT | 2.8.0 |
| firebase-admin | 6.5.0 |
| Flutter SDK | 3.x (>=3.0.0 <4.0.0) |
| provider | 6.1.1 |
| firebase_core | 3.6.0 |
| firebase_messaging | 15.1.3 |