# CONCERNS

## Bugs Criticos e Blockers Atuais
- **Windows Build Crash (Firebase):** Ao rodar `flutter build windows --release`, há falhas relacionadas com arquivos C++ e dependências. Erro principal: `C1083: Não é possível abrir arquivo incluir: 'flutter_plugin_registrar.h'`. Isso denota falha no linking ou versionamento na pasta `windows/flutter/ephemeral/.plugin_symlinks/firebase_core`.

## Riscos de Arquitetura Menores
- **Configurações em HardCode/Ambiente Oculto:** Presença de arquivos `.env.example` indica que senhas ou chaves são estáticas ou carregadas via env. Mas é preciso atenção máxima às Secret Keys do JWT se migrar para produção cloud real.

---

## Technical Debt and Concerns

### Security Issues

1. **Hardcoded JWT Secret Keys**
   - Multiple locations use hardcoded secret: `'dev-secret-key-barbearia-2026'`
   - Files affected: `app.py` (line 25), `utils/auth.py` (line 8), `routes/auth.py` (line 15), `config.py` (line 8)
   - Production deployment must use environment variables with proper secret management
   - No secret rotation strategy in place

2. **CORS Wildcard in Production**
   - `config.py` line 17-18: `CORS_ORIGINS = "*"` and `CORS_RESOURCES = {r"/api/*": {"origins": "*"}}`
   - Allows any origin to make API requests
   - Should restrict to specific domains in production

3. **Unauthenticated Public Endpoints**
   - `routes/public.py` has no authentication decorator on any route
   - Endpoints: `/api/public/validate-phone`, `/api/public/cliente`, `/api/public/servicos`, `/api/public/horarios`, `/api/public/agendar`
   - While intentional for customer-facing chat, there is no rate limiting or abuse prevention
   - The `/api/public/cliente` returns partial customer data based on phone number

4. **No Rate Limiting**
   - Public endpoints have no rate limiting
   - Vulnerable to brute force attacks on phone validation
   - No protection against scheduling spam/automated booking

5. **No Token Blacklisting on Logout**
   - `api_service.dart` line 277-283: logout simply removes token from local storage
   - JWT tokens remain valid until expiration (24 hours)
   - No server-side invalidation of tokens

6. **Password Hash Iteration**
   - Uses default werkzeug.security (pbkdf2:sha256)
   - Should explicitly set `method='pbkdf2:sha256'` and increase iterations for production

### Input Validation Gaps

1. **Phone Number Validation Too Permissive**
   - `utils/validation.py` line 18-20: only checks if phone has exactly 11 digits
   - Does not validate actual Brazilian phone format (DDD prefixes, valid area codes)
   - No protection against sequential/fake numbers

2. **Weak Input Sanitization on Public Agendamento**
   - `routes/public.py` line 117-188: POST creates cliente without validating name content
   - Allows any string for `nome` field (could contain scripts or malformed data)
   - No length limits enforced

3. **Missing Null Checks on Relationships**
   - `routes/public.py` line 150: `ag.servico.duracao_minutos` assumes servico exists
   - If a service was soft-deleted but scheduling logic races, this could cause AttributeError
   - N+1 query potential on line 150 (accessing `ag.servico` triggers a query per item)

4. **No Pagination**
   - All list endpoints (`/api/clientes`, `/api/agendamentos`, `/api/servicos`) return all records
   - No `limit`/`offset` parameters
   - Will degrade with large datasets

5. **Magic Strings for Status Values**
   - Status values 'agendado', 'concluido', 'cancelado' are hardcoded in multiple places
   - Should use an Enum or constants to prevent typos and allow IDE autocomplete

### Error Handling Deficiencies

1. **Generic Exception Catching**
   - `routes/clientes.py` line 52-54, `routes/servicos.py` line 40-42, `routes/despesas.py` line 33-35
   - Catches `Exception as e` and returns `str(e)` to client
   - Exposes internal implementation details
   - Should log errors server-side, return generic message to client

2. **Bare Except Clauses**
   - `routes/agendamentos.py` line 43: `except:` without specific exception type
   - Catches keyboard interrupts and system exit events
   - Should be `except Exception:` or specific types

3. **No Graceful Degradation for Firebase**
   - `utils/notifications.py` line 36-37: silently returns False when Firebase not initialized
   - No alerting/monitoring when push notifications fail
   - Business logic in `routes/public.py` line 170-178 ignores the `notificado` result

4. **Silent Failures in API Service**
   - `barbearia-frontend/lib/services/api_service.dart` line 337-340, 363-368
   - Catches errors but only sets `_error` string, no retry logic
   - No exponential backoff for transient failures

### Database/Schema Issues

1. **No Database Migration System**
   - Uses `db.create_all()` in `app.py` line 70
   - No Alembic or similar migration tool
   - Schema changes require database recreation and data loss

2. **Nullable telefone in Cliente Model**
   - `models/cliente.py` line 14: `telefone = db.Column(db.String(20))` - nullable=True
   - Customer can be created without phone number
   - Public API (`/api/public/cliente`) lookup by phone fails if phone is null

3. **No Unique Constraint on telefone**
   - Database allows duplicate phones for different customers
   - `routes/public.py` line 129 checks only first match

4. **Hardcoded Database Path**
   - `config.py` line 12: `DATABASE_PATH = os.path.join(...)`
   - No environment-based path override
   - Working directory assumptions may break in production

### Concurrency and Race Conditions

1. **Race Condition in Public Scheduling**
   - `routes/public.py` line 135-154: time-of-check to time-of-use (TOCTOU) race
   - Checks availability, then creates appointment in separate transaction
   - Two simultaneous requests for same slot could both succeed
   - Should use database-level locking or atomic operations

2. **No Transaction Isolation**
   - Multiple session operations in `routes/public.py` line 128-155
   - If commit fails after client creation, no rollback of partial state
   - Should wrap entire operation in a transaction

### Code Organization Issues

1. **Duplicate Init Scripts**
   - Both `init_db.py` and `init_db_simple.py` exist
   - Unclear which is the source of truth
   - `init_db.py` references `scratch/cleanup_phones.py` etc

2. **Scratch Scripts in Repo**
   - `scratch/` directory contains `cleanup_phones.py`, `load_test.py`, `migrate_servicos.py`
   - These should be in a separate scripts directory or removed from repo

3. **Hardcoded Port 5000**
   - `app.py` line 74: `app.run(debug=app.config['DEBUG'], port=5000)`
   - No environment variable override for port
   - Incompatible with containerized deployments expecting PORT env var

4. **No Request/Response Logging**
   - No middleware logging requests
   - Difficult to audit API usage or debug issues
   - No correlation IDs for troubleshooting

5. **API Version Not Enforced**
   - `config.py` defines `API_PREFIX = '/api'` and `API_VERSION = '1.0.0'`
   - No version validation in routes
   - Cannot deprecate old API versions gracefully

### Dependency and Build Issues

1. **Firebase Fallback Chain**
   - `utils/notifications.py` line 19: checks for `firebase-service-account.json`
   - If file missing, silently disables push notifications
   - No health check or alerting when push is degraded

2. **No Dependency Pinning**
   - No `requirements.txt` with version pins shown in code
   - Could break on library updates
   - Python 3.14 compatibility mentioned but not verified

3. **Flutter Build Complexity**
   - Firebase plugins require native dependencies
   - Windows build needs special configuration
   - No documented pre-build steps for Windows

### Missing Test Coverage

1. **No Tests for Public Endpoints**
   - `tests/` directory has no tests for `routes/public.py`
   - Critical booking flow has no automated validation

2. **No Integration Tests**
   - No tests that span multiple layers (API to DB)
   - No tests for concurrent booking scenarios

3. **Missing Error Path Tests**
   - Happy paths exist in `test_agendamento.py`, `test_cliente.py`, `test_servico.py`
   - Error cases and edge cases not covered

### Logging and Monitoring Gaps

1. **No Structured Logging**
   - Uses `print()` statements (`app.py` line 71, `utils/notifications.py` lines 26, 30, 44, 63, 66)
   - No centralized log collection
   - In production, print statements may be stripped

2. **No Error Tracking Service**
   - No Sentry, Rollbar, or similar integration
   - Unhandled exceptions lost in production

3. **No Health Check Endpoint**
   - No `/health` or `/status` endpoint for load balancer probes
   - Difficult to verify API is running

### Potential Memory/Leak Issues

1. **FCM Token Registration on Every Login**
   - `api_service.dart` line 262: `registrarPushToken()` called on every login
   - Could accumulate duplicate tokens if user logs in multiple times
   - `routes/auth.py` line 54-64: only updates existing or creates new, but never cleans up stale tokens

2. **No Connection Pooling Config**
   - SQLAlchemy defaults may not be optimal
   - No evidence of connection pool tuning for production load

---

## Priority Recommendations

1. **HIGH: Fix hardcoded JWT secrets** - Move to environment variables
2. **HIGH: Add rate limiting** - Especially on public endpoints
3. **HIGH: Implement database migrations** - Before schema changes cause data loss
4. **MEDIUM: Add structured logging** - Replace print statements
5. **MEDIUM: Implement token blacklisting** - Or use short-lived tokens
6. **MEDIUM: Add pagination** - Before list endpoints scale issues
7. **MEDIUM: Fix race conditions** - Use database locks or atomic operations
8. **LOW: Clean up scratch directory** - Move or remove temp scripts
9. **LOW: Add health check endpoint** - For production monitoring
10. **LOW: Document Windows build process** - For Firebase integration