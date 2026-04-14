# TESTING - Verification & Quality

## Overview

Quality assurance for **Klipper** combines automated unit tests (Backend) with manual User Acceptance Testing (UAT) for the interfaces.

---

## Backend Strategy (Python)

### Framework: Pytest
- **Location:** `barbearia-backend/tests/`
- **Focus:** Model integrity, relationship mapping, and service logic.

### Status
- **Models:** 🟢 Fully covered (CRUD operations for Clients, Services, Appointments).
- **API Endpoints:** 🟡 Partial (Auth and Basic CRUD tested, Public API needs more coverage).
- **Concurrency:** 🔴 Untested (Potential for double-booking).

---

## Frontend Strategy (Flutter)

### Framework: flutter_test
- **Location:** `barbearia-frontend/test/`
- **Focus:** Widget rendering and state transitions.

### Status
- **Unit/Widget Tests:** 🔴 Low coverage. Current tests are template-based smoke tests.
- **Manual UAT:** 🟢 High. Major features (Login, Schedule, Feed) are verified manually in the Windows Desktop build.

---

## Client Interface (Web Chat)

### Verification Method
- **Manual Walkthrough:** Verification of the conversational flow using real Slot data.
- **End-to-End:** Testing the full cycle from Web Booking → Backend Notification → App Alert.

---

## Continuous Verification (GSD)

Every phase in the **Klipper** mission includes a `Verification Plan`:
1. **Automated Check:** `python -m py_compile` for syntax parity.
2. **Review:** Cross-checking results against the `KLIPPER_EXECUCAO_FASEADA.md` benchmarks.

---

## Test Credentials

| Role | Username | Password |
| :--- | :--- | :--- |
| Admin | `admin` | `admin123` |
| Test Customer | `Cliente Teste` | N/A |

---

## Quality Priorities (Next Steps)

1. **UAT for Klipper Brand:** Manual verification of all screens for text/logo consistency.
2. **FCM Multicast Test:** Verify notification delivery to multiple devices simultaneously.
3. **Double-Booking Prevention:** Stress test the `/agendar` endpoint for concurrency issues.