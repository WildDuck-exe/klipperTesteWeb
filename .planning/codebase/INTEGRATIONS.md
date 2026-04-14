# INTEGRATIONS - External Services and Dependencies

## Overview

The **Klipper** ecosystem relies on specialized integrations to provide real-time updates and seamless booking. This document details the connectivity between the core triad: Backend, Admin App, and Client Chat.

---

## Database Integration

### SQLite (Primary Store)
- **Engine:** SQLite 3.
- **ORM:** SQLAlchemy 2.0.36.
- **Status:** Stable.
- **Role:** High-integrity storage for Customers, Services, Appointments, and Push Tokens.
- **Transition Note:** The database models and logic are being audited for the rebranding from "Ponto do Corte" to "Klipper".

---

## Firebase Integration (FCM)

### Role
Providing real-time push notifications to the barber when a client schedules an appointment through the web chat.

### Components
- **Backend (Orchestrator):** Uses `firebase-admin` (Python) to send multicast messages to registered tokens.
- **Admin App (Consumer):** Flutter implementation using `firebase_messaging`.
- **Status:** 
    - **Android/Mobile:** Stable.
    - **Windows Native:** **In Progress**. FCM registration and display on Windows Desktop requires specific platform-channel configurations.

### Security
Credentials are stored in `firebase-service-account.json` (root of backend) and are excluded from version control via `.gitignore`.

---

## Authentication

### JWT Strategy
- **Library:** PyJWT.
- **Expiry:** 24 hours.
- **Payload:** Contains `user_id` and `identity`.
- **Implementation:** Custom `@token_required` decorators in the Flask backend protect all administrative API routes.

---

## Client Web Chat Integration

### Nature
A lightweight, dynamic interface that interacts with the public API routes.

### Flow
1. **Discovery:** Client enters the chat.
2. **Data Fetching:** Chat fetches available services and barbers/slots via public endpoints.
3. **Booking:** On confirmation, a `POST` is sent to the public booking API.
4. **Notification Trigger:** The backend receives the booking, saves it, and immediately triggers an FCM notification to the barber's registered devices.

---

## Technical Dependencies

### Backend (Python 3.14)
- `Flask`, `SQLAlchemy`, `firebase-admin`, `PyJWT`.

### Frontend (Flutter 3.x)
- `provider`, `http`, `firebase_messaging`, `intl`.

---

## Integration Health Status

| Service | Status | Risk Level |
| :--- | :--- | :--- |
| Core API | 🟢 Operational | Low |
| DB Integrity | 🟢 Operational | Low |
| FCM (Mobile) | 🟢 Operational | Low |
| FCM (Windows) | 🟡 Experimental | High |
| Web Chat Sync | 🟢 Operational | Low |