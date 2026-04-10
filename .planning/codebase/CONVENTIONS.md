# Coding Conventions

## Language Standards
- **Backend (Python)**:
  - Adheres to PEP 8 standards.
  - Docstrings used for function and module descriptions.
  - Variable and function naming: `snake_case`.
  - Class naming: `PascalCase`.
- **Frontend (Dart/Flutter)**:
  - Adheres to the official Dart Style Guide.
  - Variable and function naming: `camelCase`.
  - Class and component naming: `PascalCase`.
  - File naming: `snake_case.dart`.

## API Conventions
- **Naming Pattern**: `snake_case` for JSON keys (e.g., `cliente_id`, `data_hora`).
- **RESTful Principles**: Uses standard methods (`GET`, `POST`, `PUT`).
- **Status Codes**:
  - `200 OK`: Success.
  - `201 Created`: Successful creation.
  - `400 Bad Request`: Missing fields or invalid data.
  - `404 Not Found`: Resource non-existent.

## Database Conventions
- Table names use plurals: `clientes`, `servicos`, `agendamentos`.
- Primary keys are integers named `id`.
- Foreign keys follow the pattern `<singular_table_name>_id` (e.g., `cliente_id`).
