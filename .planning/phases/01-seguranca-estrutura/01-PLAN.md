---
phase: 1
plan: 1
title: "Refatoração de Rotas do Backend com Blueprints"
wave: 1
depends_on: []
files_modified:
  - barbearia-backend/app.py
  - barbearia-backend/routes/__init__.py
  - barbearia-backend/routes/clientes.py
  - barbearia-backend/routes/servicos.py
  - barbearia-backend/routes/agendamentos.py
requirements_addressed: [ARCH-01]
autonomous: true
---

<objective>
Refatorar o `app.py` monolítico extraindo todas as rotas para módulos Blueprint separados na pasta `routes/`. Após esta tarefa, `app.py` conterá apenas a inicialização do Flask, registro de Blueprints e a função utilitária `get_db_connection()`.
</objective>

<must_haves>
- Todas as rotas de clientes devem funcionar via Blueprint em `routes/clientes.py`
- Todas as rotas de serviços devem funcionar via Blueprint em `routes/servicos.py`
- Todas as rotas de agendamentos (incluindo `/agenda/hoje`) devem funcionar via Blueprint em `routes/agendamentos.py`
- `app.py` não deve conter definições `@app.route` para `/api/clientes`, `/api/servicos`, `/api/agendamentos`
- O servidor deve iniciar sem erros via `python run.py`
- Todos os endpoints existentes devem retornar os mesmos dados de antes
</must_haves>

## Tarefa 1: Criar `routes/__init__.py`

<read_first>
- barbearia-backend/routes/ (verificar que está vazia)
- barbearia-backend/app.py (entender função get_db_connection e rotas existentes)
</read_first>

<action>
Criar o arquivo `barbearia-backend/routes/__init__.py` com o seguinte conteúdo:

```python
# routes/__init__.py
# Registro de Blueprints da aplicação

from .clientes import clientes_bp
from .servicos import servicos_bp
from .agendamentos import agendamentos_bp

def register_blueprints(app):
    """Registra todos os Blueprints no app Flask."""
    app.register_blueprint(clientes_bp)
    app.register_blueprint(servicos_bp)
    app.register_blueprint(agendamentos_bp)
```
</action>

<acceptance_criteria>
- `routes/__init__.py` existe e contém `def register_blueprints(app):`
- `routes/__init__.py` contém `from .clientes import clientes_bp`
- `routes/__init__.py` contém `from .servicos import servicos_bp`
- `routes/__init__.py` contém `from .agendamentos import agendamentos_bp`
</acceptance_criteria>

## Tarefa 2: Criar `routes/clientes.py`

<read_first>
- barbearia-backend/app.py (linhas 57-90, funções get_clientes, get_cliente, create_cliente)
</read_first>

<action>
Criar `barbearia-backend/routes/clientes.py`:

```python
# routes/clientes.py
from flask import Blueprint, jsonify, request
from app import get_db_connection

clientes_bp = Blueprint('clientes', __name__)

@clientes_bp.route('/api/clientes', methods=['GET'])
def get_clientes():
    conn = get_db_connection()
    clientes = conn.execute('SELECT * FROM clientes').fetchall()
    conn.close()
    return jsonify([dict(cliente) for cliente in clientes])

@clientes_bp.route('/api/clientes/<int:id>', methods=['GET'])
def get_cliente(id):
    conn = get_db_connection()
    cliente = conn.execute('SELECT * FROM clientes WHERE id = ?', (id,)).fetchone()
    conn.close()
    if cliente is None:
        return jsonify({'error': 'Cliente não encontrado'}), 404
    return jsonify(dict(cliente))

@clientes_bp.route('/api/clientes', methods=['POST'])
def create_cliente():
    data = request.get_json()
    if not data or 'nome' not in data:
        return jsonify({'error': 'Nome é obrigatório'}), 400
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        'INSERT INTO clientes (nome, telefone) VALUES (?, ?)',
        (data['nome'], data.get('telefone', ''))
    )
    conn.commit()
    cliente_id = cursor.lastrowid
    conn.close()
    return jsonify({'id': cliente_id, 'message': 'Cliente criado com sucesso'}), 201
```
</action>

<acceptance_criteria>
- `routes/clientes.py` existe e contém `clientes_bp = Blueprint('clientes', __name__)`
- `routes/clientes.py` contém `def get_clientes():`
- `routes/clientes.py` contém `def get_cliente(id):`
- `routes/clientes.py` contém `def create_cliente():`
- Cada rota usa o prefixo `/api/clientes`
</acceptance_criteria>

## Tarefa 3: Criar `routes/servicos.py`

<read_first>
- barbearia-backend/app.py (linhas 92-116, funções get_servicos, create_servico)
</read_first>

<action>
Criar `barbearia-backend/routes/servicos.py`:

```python
# routes/servicos.py
from flask import Blueprint, jsonify, request
from app import get_db_connection

servicos_bp = Blueprint('servicos', __name__)

@servicos_bp.route('/api/servicos', methods=['GET'])
def get_servicos():
    conn = get_db_connection()
    servicos = conn.execute('SELECT * FROM servicos').fetchall()
    conn.close()
    return jsonify([dict(servico) for servico in servicos])

@servicos_bp.route('/api/servicos', methods=['POST'])
def create_servico():
    data = request.get_json()
    if not data or 'nome' not in data:
        return jsonify({'error': 'Nome é obrigatório'}), 400
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        'INSERT INTO servicos (nome, descricao, duracao_minutos, preco) VALUES (?, ?, ?, ?)',
        (data['nome'], data.get('descricao', ''), data.get('duracao_minutos', 30), data.get('preco', 0))
    )
    conn.commit()
    servico_id = cursor.lastrowid
    conn.close()
    return jsonify({'id': servico_id, 'message': 'Serviço criado com sucesso'}), 201
```
</action>

<acceptance_criteria>
- `routes/servicos.py` existe e contém `servicos_bp = Blueprint('servicos', __name__)`
- `routes/servicos.py` contém `def get_servicos():`
- `routes/servicos.py` contém `def create_servico():`
</acceptance_criteria>

## Tarefa 4: Criar `routes/agendamentos.py`

<read_first>
- barbearia-backend/app.py (linhas 118-203, rotas de agendamentos e agenda/hoje)
</read_first>

<action>
Criar `barbearia-backend/routes/agendamentos.py`:

```python
# routes/agendamentos.py
from flask import Blueprint, jsonify, request
from app import get_db_connection

agendamentos_bp = Blueprint('agendamentos', __name__)

@agendamentos_bp.route('/api/agendamentos', methods=['GET'])
def get_agendamentos():
    conn = get_db_connection()
    agendamentos = conn.execute('''
        SELECT a.*, c.nome as cliente_nome, s.nome as servico_nome
        FROM agendamentos a
        LEFT JOIN clientes c ON a.cliente_id = c.id
        LEFT JOIN servicos s ON a.servico_id = s.id
        ORDER BY a.data_hora
    ''').fetchall()
    conn.close()
    return jsonify([dict(ag) for ag in agendamentos])

@agendamentos_bp.route('/api/agendamentos', methods=['POST'])
def create_agendamento():
    data = request.get_json()
    required_fields = ['cliente_id', 'servico_id', 'data_hora']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'{field} é obrigatório'}), 400
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        '''INSERT INTO agendamentos
           (cliente_id, servico_id, data_hora, observacoes, status)
           VALUES (?, ?, ?, ?, ?)''',
        (data['cliente_id'], data['servico_id'], data['data_hora'],
         data.get('observacoes', ''), data.get('status', 'agendado'))
    )
    conn.commit()
    agendamento_id = cursor.lastrowid
    conn.close()
    return jsonify({'id': agendamento_id, 'message': 'Agendamento criado com sucesso'}), 201

@agendamentos_bp.route('/api/agendamentos/<int:id>/concluir', methods=['PUT'])
def concluir_agendamento(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('UPDATE agendamentos SET status = ? WHERE id = ?', ('concluido', id))
    conn.commit()
    affected = cursor.rowcount
    conn.close()
    if affected == 0:
        return jsonify({'error': 'Agendamento não encontrado'}), 404
    return jsonify({'message': 'Agendamento concluído com sucesso'})

@agendamentos_bp.route('/api/agendamentos/<int:id>/cancelar', methods=['PUT'])
def cancelar_agendamento(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('UPDATE agendamentos SET status = ? WHERE id = ?', ('cancelado', id))
    conn.commit()
    affected = cursor.rowcount
    conn.close()
    if affected == 0:
        return jsonify({'error': 'Agendamento não encontrado'}), 404
    return jsonify({'message': 'Agendamento cancelado com sucesso'})

@agendamentos_bp.route('/api/agenda/hoje', methods=['GET'])
def get_agenda_hoje():
    conn = get_db_connection()
    agendamentos = conn.execute('''
        SELECT a.*, c.nome as cliente_nome, s.nome as servico_nome
        FROM agendamentos a
        LEFT JOIN clientes c ON a.cliente_id = c.id
        LEFT JOIN servicos s ON a.servico_id = s.id
        WHERE DATE(a.data_hora) = DATE('now')
        AND a.status = 'agendado'
        ORDER BY a.data_hora
    ''').fetchall()
    conn.close()
    return jsonify([dict(ag) for ag in agendamentos])
```
</action>

<acceptance_criteria>
- `routes/agendamentos.py` existe e contém `agendamentos_bp = Blueprint('agendamentos', __name__)`
- `routes/agendamentos.py` contém `def get_agendamentos():`
- `routes/agendamentos.py` contém `def create_agendamento():`
- `routes/agendamentos.py` contém `def concluir_agendamento(id):`
- `routes/agendamentos.py` contém `def cancelar_agendamento(id):`
- `routes/agendamentos.py` contém `def get_agenda_hoje():`
</acceptance_criteria>

## Tarefa 5: Refatorar `app.py`

<read_first>
- barbearia-backend/app.py (arquivo completo — entender o que manter vs remover)
- barbearia-backend/routes/__init__.py (recém-criado)
</read_first>

<action>
Reescrever `barbearia-backend/app.py` para conter APENAS:
1. Inicialização do Flask
2. Configuração do CORS
3. A função `get_db_connection()`
4. Os endpoints raiz `/` e `/api/`
5. Registro dos Blueprints via `register_blueprints(app)`
6. O bloco `if __name__ == '__main__':`

Remover todos os `@app.route` de `/api/clientes`, `/api/servicos`, `/api/agendamentos` e `/api/agenda/hoje`.

Novo conteúdo de `app.py`:

```python
# app.py - Barbearia API Backend
"""
Aplicação Flask para API da Agenda Digital de Barbearia.
Fornece endpoints para gerenciamento de clientes, serviços e agendamentos.
"""

from flask import Flask, jsonify
from flask_cors import CORS
import sqlite3
import os

# Inicialização da aplicação Flask
app = Flask(__name__)

# Configuração do CORS para aplicativo Flutter
CORS(app, resources={r"/api/*": {"origins": "*"}})

# Configurações
DATABASE_PATH = 'database/barbearia.db'

def get_db_connection():
    """Retorna uma conexão com o banco de dados SQLite."""
    conn = sqlite3.connect(DATABASE_PATH)
    conn.row_factory = sqlite3.Row
    return conn

@app.route('/')
def hello():
    """Endpoint raiz da API."""
    return jsonify({
        'message': 'Barbearia API is running',
        'version': '1.0.0',
        'endpoints': {
            'api_docs': '/api/',
            'clientes': '/api/clientes',
            'servicos': '/api/servicos',
            'agendamentos': '/api/agendamentos'
        }
    })

@app.route('/api/')
def api_info():
    """Endpoint de informações da API."""
    return jsonify({
        'name': 'Barbearia API',
        'description': 'API para Agenda Digital de Barbearia',
        'version': '1.0.0',
        'author': 'Projeto de Extensão II - Engenharia de Software'
    })

# Registra todos os Blueprints
from routes import register_blueprints
register_blueprints(app)

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```
</action>

<acceptance_criteria>
- `app.py` contém `def get_db_connection():`
- `app.py` contém `from routes import register_blueprints`
- `app.py` contém `register_blueprints(app)`
- `app.py` NÃO contém `def get_clientes`
- `app.py` NÃO contém `def create_agendamento`
- `python run.py` inicia sem erros
- `GET /api/clientes` retorna HTTP 200
- `GET /api/agendamentos` retorna HTTP 200
- `GET /api/servicos` retorna HTTP 200
</acceptance_criteria>

<verification>
```bash
cd barbearia-backend
python -c "from app import app; print('App importado com sucesso')"
python -c "from routes import register_blueprints; print('Blueprints importados com sucesso')"
```
</verification>
