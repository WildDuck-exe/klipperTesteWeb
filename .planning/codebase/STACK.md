# STACK - Technology Stack

## Overview

The **Klipper** project (formerly *Ponto do Corte*) is a comprehensive barbershop management system. It is currently in a **rebranding transition phase**. The system consists of a Python/Flask backend and a cross-platform Flutter application for administrative tasks, plus a Web Chat interface for client bookings.

---

## Backend Stack

### Core Framework
- **Flask 2.3.3** - Selected for its lightweight modular architecture.
  - Serves REST API (`/api/*`).
  - Serves Client Web Chat (`/static/chat/*`).
- **Python 3.14.x** - The target runtime for the current project phase, ensuring long-term compatibility.

### Database Layer
- **SQLAlchemy 2.0.36** - Core ORM for data persistence and relationship mapping.
- **Flask-SQLAlchemy 3.1.1** - Bridge for Flask integration.
- **Database Engine:** SQLite (`barbearia.db`).
  - Located in `barbearia-backend/database/`.
  - Migrated from legacy direct SQL to full ORM.

### Authentication & Security
- **PyJWT 2.8.0** - Handles stateless token-based authentication.
- **Werkzeug Security** - Password hashing and verification.
- **CORS** - Configured via `Flask-CORS 4.0.0` for multi-client access.

### Push Notifications
- **Firebase Admin SDK 6.5.0** - Server-side orchestration for FCM notifications.

---

## Frontend Stack

### Admin App (Flutter)
- **Flutter 3.x** - Cross-platform SDK for Windows, Android, and Web.
- **Provider ^6.1.1** - State management for API services and app logic.
- **Firebase Core & Messaging (FCM)** - Native integration for push alerts.

### Web Demo (Flutter Web)
- **Flutter 3.x** - Specialized build for zero-backend presentation.
- **Animations / Google Fonts** - Enhanced visuals for premium presentation.
- **Mock Data Layer** - Custom service layer for isolated functionality.

### Client Interface (Web Chat)
- **Vanilla JS / CSS / HTML** - Minimalist, high-performance conversational UI.
- **Design System:** Glassmorphism with a focus on ease of use for mobile/web clients.

---

## Environment & Tooling

- **Environment Management:** `python-dotenv` and `flutter_dotenv`.
- **Testing:** `pytest` (Backend) and `flutter_test` (Frontend).
- **CI/CD / Deployment:** 
  - **Netlify:** Automated builds and hosting for the Web Demo.
- **Version Control:** Git, following the **GSD Unified Flow**.

---

## Version Matrix

| Library | Version | Role |
| :--- | :--- | :--- |
| Python | 3.14.x | Runtime |
| Flask | 2.3.3 | Web Framework |
| SQLAlchemy | 2.0.36 | ORM |
| Flutter SDK | 3.x | Frontend Core |
| firebase-admin| 6.5.0 | Server Notifications |
| PyJWT | 2.8.0 | Auth |
| Netlify | Managed | Deployment |