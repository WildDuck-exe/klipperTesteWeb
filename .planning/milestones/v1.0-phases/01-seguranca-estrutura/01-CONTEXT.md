# Fase 1: Segurança e Estrutura - Contexto

**Reunido:** 10/04/2026
**Status:** Pronto para planejamento
**Fonte:** Análise do código fonte existente e documentação acadêmica

<domain>
## Limite da Fase

Esta fase entrega:
1. Sistema de autenticação básica (login do barbeiro) no backend Flask.
2. Proteção dos endpoints da API com verificação de token.
3. Tela de Login no app Flutter.
4. Refatoração das rotas do `app.py` para módulos separados em `/routes`.

</domain>

<decisions>
## Decisões de Implementação

### Autenticação
- Usar JWT (JSON Web Tokens) com a biblioteca `PyJWT` para autenticação.
- Criar uma tabela `usuarios` no SQLite com campos `id`, `username`, `senha_hash`.
- A senha será armazenada com hash usando `werkzeug.security` (já disponível como dependência do Flask).
- O login retornará um token JWT que expira em 24 horas.
- Todos os endpoints `/api/*` (exceto `/api/auth/login`) exigirão o header `Authorization: Bearer <token>`.
- Um decorator `@login_required` será criado para verificar o token nos endpoints.
- Um usuário padrão (`admin` / `admin123`) será criado no script `init_db_simple.py`.

### Refatoração de Rotas
- Mover as rotas de `app.py` para módulos Blueprint no Flask:
  - `routes/clientes.py` — rotas de clientes
  - `routes/servicos.py` — rotas de serviços
  - `routes/agendamentos.py` — rotas de agendamentos
  - `routes/auth.py` — rota de login
- `app.py` ficará apenas com a inicialização do app, registro de Blueprints e a função `get_db_connection()`.

### Frontend (Flutter)
- Criar tela de Login com campos de usuário e senha.
- Salvar o token JWT no `SharedPreferences` do dispositivo.
- Enviar o token em todas as requisições HTTP via header `Authorization`.
- Se o token estiver ausente ou expirado, redirecionar automaticamente para a tela de Login.

### Critério de Discretion
- Detalhes de estilos visuais da tela de login ficam a critério da implementação.

</decisions>

<canonical_refs>
## Referências Canônicas

**Os agentes devem ler estes arquivos antes de planejar ou implementar.**

### Backend
- `barbearia-backend/app.py` — Arquivo principal atual com todas as rotas
- `barbearia-backend/config.py` — Configurações existentes (já possui SECRET_KEY)
- `barbearia-backend/models/__init__.py` — SQLAlchemy init com modelos existentes
- `barbearia-backend/init_db_simple.py` — Script de inicialização de DB com dados de exemplo
- `barbearia-backend/requirements.txt` — Dependências atuais

### Frontend
- `barbearia-frontend/lib/main.dart` — Entrada do app Flutter
- `barbearia-frontend/lib/services/api_service.dart` — Serviço de comunicação com API
- `barbearia-frontend/lib/screens/home_screen.dart` — Tela principal atual

</canonical_refs>

<specifics>
## Ideias Específicas

- O `config.py` já tem um `SECRET_KEY` configurado — reutilizar para assinar os tokens JWT.
- A pasta `routes/` já existe mas está vazia — ideal para receber os Blueprints.
- A conexão com banco usa `sqlite3` diretamente em `app.py` (não SQLAlchemy) — manter este padrão na refatoração.

</specifics>

<deferred>
## Ideias Adiadas

- Dashboard de relatórios — Fase 2
- Notificações — Fase 2
- Múltiplos níveis de acesso (admin vs barbeiro) — Fora de escopo

</deferred>

---

*Fase: 01-seguranca-estrutura*
*Contexto reunido: 10/04/2026 via análise de codebase*
