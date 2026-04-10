# System Concerns

## Security
- **Authentication**: No authentication or authorization is currently implemented in the API. Any user can create/modify clients and appointments.
- **CORS**: `CORS(app, resources={r"/api/*": {"origins": "*" }})` allows requests from any origin, which is safe for development but requires lockdown for production.
- **Data Privacy**: Telephones and names are stored in plain text with no encryption or access control.

## Architecture
- **Fat Entrypoint**: Most of the API logic is currently in `app.py`. As the project grows, this should be refactored into the existing but empty `routes/` directory.
- **Database Scalability**: SQLite is used. While excellent for development and small-scale use, migration to a production database (e.g., PostgreSQL) will be necessary for multi-user or high-traffic environments.
- **Concurrency**: SQLite has limitations with concurrent write access, which might affect multiple barbers using the system simultaneously in the future.

## Maintenance
- **Dependency Versioning**: `requirements.txt` contains loose dependencies (e.g., `flask`, `flask-cors`). Specific versions should be pinned for stability.
- **Frontend State**: While `provider` is used, complex state transitions (like conflict detection for schedules) may require more robust state management or dedicated backend validation.
- **Error Handling**: API error handling is basic. More descriptive error messages and consistent JSON error envelopes would improve frontend resilience.
