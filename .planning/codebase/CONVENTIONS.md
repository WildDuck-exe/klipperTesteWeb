# CONVENTIONS - Coding Standards

## Overview

This document defines the coding standards for **Klipper**. The project is currently transitioning from its legacy name ("Ponto do Corte"), and these conventions aim to harmonize the codebase under the new brand.

---

## 1. Naming Conventions

### Project Meta
- **Brand Name:** Klipper.
- **Legacy Name:** Ponto do Corte (To be phased out).
- **Organization:** `D:/IA/Projeto_Klipper/`.

### Language Split
- **Domain/Business Entities:** Portuguese (BR) – *e.g., `Cliente`, `Agendamento`, `Servico`*.
- **Infrastructure/Plumbing:** English – *e.g., `AuthService`, `NotificationManager`, `AppTheme`*.

---

## 2. Backend (Python/Flask)

- **Style:** PEP 8.
- **Variables/Functions:** `snake_case`.
- **Classes:** `PascalCase`.
- **Blueprints:** Grouped by business domain in `routes/`.
- **Models:** Defined using SQLAlchemy declarative base in `models/`.

### Target Nomenclature (Klipper Era)
- When creating new features, prioritize names that align with "Klipper":
    - *Good:* `KlipperAuth`, `KlipperConfig`.
    - *Avoid:* `BarbeariaAuth`, `PontoDoCorteConfig`.

---

## 3. Frontend (Flutter/Dart)

- **Style:** Effective Dart.
- **Variables/Methods:** `camelCase`.
- **Classes:** `PascalCase`.
- **File Names:** `snake_case.dart`.

### Design Patterns
- **Provider:** Use `ChangeNotifierProvider` for global services (`ApiService`).
- **Stateful Management:** Use `StatefulWidgets` for screens requiring complex lifecycle management.
- **Magic Navigation:** Maintain the core logic of the custom bottom navigation bar without fragmentation.

---

## 4. API Standards

- **RESTful Endpoints:** Plural nouns for resources (`/api/clientes`, `/api/agendamentos`).
- **Version Header:** Include `X-API-Version` or similar if protocol changes.
- **Response Format:**
    ```json
    {
      "status": "success",
      "data": { ... },
      "message": "Action completed"
    }
    ```

---

## 5. Development Workflow (GSD)

- **Execution:** Always follow the **GSD Unified Flow** (Research → Plan → Execute).
- **Commit Messages:** Should be atomic and descriptive.
- **Documentation:** Maintain `.planning/` files as the source of truth for project state.

---

## 6. Target Refactoring Standards

As part of the rebranding missions:
1. **Logo Assets:** Use `assets/images/logo_klipper.png`.
2. **Text Displays:** Replace all "Ponto do Corte" hardcoded strings with "Klipper" (or better, use a `AppConstants` class).
3. **Themes:** Use the primary Klipper palette (Klipper Navy & Crimson).