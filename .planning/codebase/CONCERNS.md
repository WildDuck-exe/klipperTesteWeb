# CONCERNS - Technical Debt & Risks

## 1. Critical Branding Debt (Highest Priority)

The core mission currently is transitioning from **Ponto do Corte** to **Klipper**.
- **Issue:** Approximately 70% of the codebase (down from 90%) still uses legacy naming. Folder names (`barbearia-frontend`) and backend paths remain legacy.
- **Risk:** Brand fragmentation and maintenance overhead when syncing logic between the main app and the Web Demo.
- **Action:** Continuous string replacement and modular service implementation to isolate branding tokens.

---

## 2. Infrastructure Concerns

### FCM Windows Integration
- **Status:** The backend correctly sends multicast messages, but the **Windows Desktop Frontend** often fails to register or display notifications due to platform-specific limitations in the current Flutter plugins.
- **Risk:** The barber missing appointments if they rely solely on the Windows application.

### Python 3.14 Compatibility
- **Status:** The project target is Python 3.14. While the core logic is compatible, some peripheral libraries in `requirements.txt` may require patches or updates as 3.x evolves.
- **Action:** Manual audit of `models/` and `routes/` for compatibility.

---

## 3. Security & Stability Debt

### JWT Secret Management
- **Issue:** Security keys are still largely managed via local `.env` files with fallback values in code.
- **Risk:** Potential for accidental exposure of the `dev-secret-key-barbearia-2026`.
- **Target:** Transition to a central `config.py` that strictly enforces environment-only keys for production.

### Data Integrity & Race Conditions
- **Issue:** The public booking slot check (`routes/public.py`) uses a "Check then Act" pattern which is vulnerable to race conditions.
- **Risk:** Double-booking if two clients schedule the same slot at the exact same millisecond.
- **Target:** Implementation of database-level locks or status-aware atomic transactions.

---

## 4. Maintenance & Operations

### Workspace Fragments
- **Cleanup:** I recently performed a major cleanup moving redundant `.md` files to `docs/archive/` and archiving old phases in `.planning/milestones/`. 
- **Legacy Artifacts:** There are still scratch scripts in `barbearia-backend/scratch/` that should be audited.

### Missing Automation
- **Migrations:** No Alembic/DB migration system. Schema changes currently require manual recreation.
- **Linting:** No automated linting checks (flake8/black) enforced in CI/GSD.

### Cross-Frontend Logic Sync (Web Demo vs. Admin App)
- **Issue:** Changes in the main `barbearia-frontend` screens must be manually ported to `barbearia-frontend-web-demo` as they share no common UI library yet.
- **Risk:** The Demo version becoming outdated or misrepresenting the actual product's current look and feel.
- **Action:** Future plan to extract a common `klipper_ui_core` package.

---

## 5. Priority Matrix for Upcoming Phases

| Concern | Category | Urgency |
| :--- | :--- | :--- |
| **Branding Inconsistency** | Brand | 🔴 Critical |
| **FCM Windows Display** | Feature | 🔴 Critical |
| **Double-Booking Prevention** | Logic | 🟡 High |
| **Frontend Logic Sync** | Maintenance| 🟡 High |
| **JWT Secret Rotation** | Security | 🟢 Medium |
| **DB Migration System** | Infra | 🟢 Medium |