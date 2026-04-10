# Testing

## Backend Testing (Python/Pytest)
The backend features an automated test suite located in `barbearia-backend/tests/`.
- **Framework**: `pytest`.
- **Configuration**: Uses `conftest.py` for shared fixtures (temporary database setup, app context).
- **Test Coverage**:
  - `test_init_db.py`: Verifies database schema creation and initial state.
  - `test_cliente.py`: CRUD operations for clients.
  - `test_servico.py`: CRUD operations for services.
  - `test_agendamento.py`: Lifecycle of an appointment (Creation, Conclude, Cancel).

## Frontend Testing (Flutter)
- **Framework**: Standard Flutter testing framework (Widget tests, Unit tests).
- **Status**: While the project structure supports `tests/` and uses `provider`, no extensive external test files were found in the root directories during the initial scan. Standard Flutter `test/` directory is expected in any scaffolded project.

## Running Tests
- **Backend**:
  ```bash
  cd barbearia-backend
  pytest
  ```
- **Frontend**:
  ```bash
  cd barbearia-frontend
  flutter test
  ```
