---
phase: 1
plan: 2
title: "Autenticação JWT no Backend"
wave: 2
depends_on: [1]
files_modified:
  - barbearia-backend/routes/auth.py
  - barbearia-backend/utils/auth.py
  - barbearia-backend/app.py
  - barbearia-backend/init_db_simple.py
  - barbearia-backend/requirements.txt
  - barbearia-backend/routes/__init__.py
requirements_addressed: [AUTH-01, AUTH-02]
autonomous: true
---

<objective>
Implementar autenticação JWT no backend Flask: criar tabela de usuários, endpoint de login (`/api/auth/login`), e decorator `@login_required` que protege todos os endpoints da API.
</objective>

<must_haves>
- Endpoint `POST /api/auth/login` retorna token JWT com credenciais corretas
- Endpoint `POST /api/auth/login` retorna 401 com credenciais inválidas
- Endpoints `/api/clientes`, `/api/servicos`, `/api/agendamentos` retornam 401 sem token
- Endpoints `/api/clientes`, `/api/servicos`, `/api/agendamentos` funcionam normalmente com token válido
- Usuário padrão criado pelo `init_db_simple.py`: username=`admin`, senha=`admin123`
- `PyJWT` adicionado ao `requirements.txt`
</must_haves>

## Tarefa 1: Adicionar `PyJWT` ao `requirements.txt`

<read_first>
- barbearia-backend/requirements.txt
</read_first>

<action>
Adicionar a linha `PyJWT==2.8.0` ao arquivo `barbearia-backend/requirements.txt`.

Conteúdo final:
```
# requirements.txt
Flask==2.3.3
Flask-CORS==4.0.0
Flask-SQLAlchemy==3.1.1
SQLAlchemy==2.0.28
pytest==7.4.3
PyJWT==2.8.0
```
</action>

<acceptance_criteria>
- `requirements.txt` contém `PyJWT==2.8.0`
</acceptance_criteria>

## Tarefa 2: Criar `utils/auth.py` com o decorator `login_required`

<read_first>
- barbearia-backend/utils/ (verificar se existe)
- barbearia-backend/config.py (SECRET_KEY = 'dev-secret-key-barbearia-2026')
</read_first>

<action>
Criar `barbearia-backend/utils/__init__.py` (arquivo vazio se não existir).

Criar `barbearia-backend/utils/auth.py`:

```python
# utils/auth.py
# Utilitários de autenticação JWT

import jwt
from functools import wraps
from flask import request, jsonify

SECRET_KEY = 'dev-secret-key-barbearia-2026'

def login_required(f):
    """Decorator que verifica se o token JWT é válido."""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            if auth_header.startswith('Bearer '):
                token = auth_header.split(' ')[1]

        if not token:
            return jsonify({'error': 'Token não fornecido'}), 401

        try:
            data = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
            request.user_id = data['user_id']
            request.username = data['username']
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token expirado'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Token inválido'}), 401

        return f(*args, **kwargs)
    return decorated
```
</action>

<acceptance_criteria>
- `utils/auth.py` existe e contém `def login_required(f):`
- `utils/auth.py` contém `jwt.decode(token, SECRET_KEY, algorithms=['HS256'])`
- `utils/auth.py` contém `return jsonify({'error': 'Token não fornecido'}), 401`
- `utils/auth.py` contém `return jsonify({'error': 'Token expirado'}), 401`
- `utils/__init__.py` existe
</acceptance_criteria>

## Tarefa 3: Criar `routes/auth.py` com endpoint de login

<read_first>
- barbearia-backend/app.py (get_db_connection)
- barbearia-backend/utils/auth.py (SECRET_KEY)
</read_first>

<action>
Criar `barbearia-backend/routes/auth.py`:

```python
# routes/auth.py
# Rota de autenticação

from flask import Blueprint, jsonify, request
from werkzeug.security import check_password_hash
import jwt
import datetime

auth_bp = Blueprint('auth', __name__)

SECRET_KEY = 'dev-secret-key-barbearia-2026'

@auth_bp.route('/api/auth/login', methods=['POST'])
def login():
    """Endpoint de login. Retorna token JWT."""
    data = request.get_json()

    if not data or 'username' not in data or 'password' not in data:
        return jsonify({'error': 'Username e password são obrigatórios'}), 400

    from app import get_db_connection
    conn = get_db_connection()
    user = conn.execute(
        'SELECT * FROM usuarios WHERE username = ?',
        (data['username'],)
    ).fetchone()
    conn.close()

    if user is None:
        return jsonify({'error': 'Credenciais inválidas'}), 401

    if not check_password_hash(user['senha_hash'], data['password']):
        return jsonify({'error': 'Credenciais inválidas'}), 401

    token = jwt.encode({
        'user_id': user['id'],
        'username': user['username'],
        'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)
    }, SECRET_KEY, algorithm='HS256')

    return jsonify({
        'token': token,
        'username': user['username'],
        'message': 'Login realizado com sucesso'
    })
```
</action>

<acceptance_criteria>
- `routes/auth.py` existe e contém `auth_bp = Blueprint('auth', __name__)`
- `routes/auth.py` contém `@auth_bp.route('/api/auth/login', methods=['POST'])`
- `routes/auth.py` contém `jwt.encode(`
- `routes/auth.py` contém `check_password_hash(`
</acceptance_criteria>

## Tarefa 4: Atualizar `routes/__init__.py` para incluir `auth_bp`

<read_first>
- barbearia-backend/routes/__init__.py (estado atual após Plano 1)
</read_first>

<action>
Atualizar `barbearia-backend/routes/__init__.py` para importar e registrar `auth_bp`:

```python
# routes/__init__.py
from .clientes import clientes_bp
from .servicos import servicos_bp
from .agendamentos import agendamentos_bp
from .auth import auth_bp

def register_blueprints(app):
    """Registra todos os Blueprints no app Flask."""
    app.register_blueprint(auth_bp)
    app.register_blueprint(clientes_bp)
    app.register_blueprint(servicos_bp)
    app.register_blueprint(agendamentos_bp)
```
</action>

<acceptance_criteria>
- `routes/__init__.py` contém `from .auth import auth_bp`
- `routes/__init__.py` contém `app.register_blueprint(auth_bp)`
</acceptance_criteria>

## Tarefa 5: Adicionar `@login_required` nas rotas protegidas

<read_first>
- barbearia-backend/routes/clientes.py
- barbearia-backend/routes/servicos.py
- barbearia-backend/routes/agendamentos.py
- barbearia-backend/utils/auth.py
</read_first>

<action>
Nos arquivos `routes/clientes.py`, `routes/servicos.py` e `routes/agendamentos.py`:

1. Adicionar no início de cada arquivo: `from utils.auth import login_required`
2. Adicionar o decorator `@login_required` em cada rota, logo APÓS o `@<bp>.route(...)`.

Exemplo para `routes/clientes.py`:
```python
from utils.auth import login_required

@clientes_bp.route('/api/clientes', methods=['GET'])
@login_required
def get_clientes():
    ...
```

Repetir para TODAS as rotas em `servicos.py` e `agendamentos.py`.
</action>

<acceptance_criteria>
- `routes/clientes.py` contém `from utils.auth import login_required`
- `routes/clientes.py` contém `@login_required` (3 ocorrências — uma por rota)
- `routes/servicos.py` contém `@login_required` (2 ocorrências)
- `routes/agendamentos.py` contém `@login_required` (5 ocorrências)
</acceptance_criteria>

## Tarefa 6: Atualizar `init_db_simple.py` para criar tabela `usuarios`

<read_first>
- barbearia-backend/init_db_simple.py (entender estrutura existente de criação de tabelas)
</read_first>

<action>
No `init_db_simple.py`, na função `criar_banco()`, APÓS a criação da tabela `agendamentos` e ANTES do `conn.commit()`:

Adicionar criação da tabela `usuarios`:
```python
    # Cria tabela de usuarios
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            senha_hash TEXT NOT NULL
        )
    ''')
```

Na função `adicionar_dados_exemplo()`, APÓS os serviços e ANTES do `conn.commit()`:

Adicionar usuário padrão:
```python
    from werkzeug.security import generate_password_hash

    # Verifica se usuario admin já existe
    cursor.execute("SELECT COUNT(*) FROM usuarios")
    if cursor.fetchone()[0] == 0:
        senha_hash = generate_password_hash('admin123')
        cursor.execute(
            "INSERT INTO usuarios (username, senha_hash) VALUES (?, ?)",
            ('admin', senha_hash)
        )
        print("  - Usuário admin criado (senha: admin123)")
```
</action>

<acceptance_criteria>
- `init_db_simple.py` contém `CREATE TABLE IF NOT EXISTS usuarios`
- `init_db_simple.py` contém `username TEXT NOT NULL UNIQUE`
- `init_db_simple.py` contém `generate_password_hash('admin123')`
- `init_db_simple.py` contém `INSERT INTO usuarios`
</acceptance_criteria>

<verification>
```bash
cd barbearia-backend
pip install PyJWT
python init_db_simple.py
python -c "from app import app; print('App com auth importado com sucesso')"
curl -X POST http://localhost:5000/api/auth/login -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}'
```
</verification>
