# Agenda Digital para Barbearia Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a mobile appointment scheduling app for barbershops with client management, service catalog, and daily agenda views.

**Architecture:** Flutter mobile frontend communicates via REST API with Python/Flask backend, storing data in SQLite database. Frontend follows MVVM pattern with service layers, backend follows RESTful design with clear separation of concerns.

**Tech Stack:** Flutter/Dart (frontend), Python/Flask (backend), SQLite (database), HTTP/JSON (communication), pytest (backend testing)

---

## File Structure

### Backend (`barbearia-backend/`)
```
barbearia-backend/
├── app.py                    # Flask application entry point
├── requirements.txt          # Python dependencies
├── database/
│   ├── init_db.py           # Database initialization
│   └── barbearia.db         # SQLite database file
├── models/
│   ├── cliente.py           # Cliente model class
│   ├── agendamento.py       # Agendamento model class
│   └── servico.py           # Servico model class
├── routes/
│   ├── clientes.py          # Cliente API endpoints
│   ├── agendamentos.py      # Agendamento API endpoints
│   └── servicos.py          # Servico API endpoints
├── tests/
│   ├── test_clientes.py     # Cliente API tests
│   ├── test_agendamentos.py # Agendamento API tests
│   └── test_servicos.py     # Servico API tests
└── utils/
    └── validators.py        # Input validation utilities
```

### Frontend (`barbearia-app/`)
```
barbearia-app/
├── lib/
│   ├── main.dart            # Application entry point
│   ├── models/
│   │   ├── cliente.dart     # Cliente data model
│   │   ├── agendamento.dart # Agendamento data model
│   │   └── servico.dart     # Servico data model
│   ├── services/
│   │   ├── api_service.dart # Base API service
│   │   ├── cliente_service.dart # Cliente API service
│   │   └── agendamento_service.dart # Agendamento API service
│   ├── screens/
│   │   ├── home_screen.dart # Main navigation screen
│   │   ├── clientes_screen.dart # Client list screen
│   │   ├── agendamentos_screen.dart # Appointment list screen
│   │   ├── novo_agendamento_screen.dart # New appointment form
│   │   └── agenda_dia_screen.dart # Daily agenda screen
│   ├── widgets/
│   │   ├── cliente_card.dart # Client list item widget
│   │   ├── agendamento_card.dart # Appointment list item widget
│   │   └── date_picker.dart # Custom date picker widget
│   └── utils/
│       └── constants.dart   # App constants (colors, API URL, etc.)
├── pubspec.yaml             # Flutter dependencies
└── assets/                  # Images, fonts, etc.
```

---

## Phase 1: Backend Setup and Basic API

### Task 1: Backend Project Structure

**Files:**
- Create: `barbearia-backend/`
- Create: `barbearia-backend/requirements.txt`
- Create: `barbearia-backend/app.py`

- [ ] **Step 1: Create project directory and requirements**

```bash
mkdir -p barbearia-backend
```

```txt
# requirements.txt
Flask==2.3.3
Flask-CORS==4.0.0
pytest==7.4.3
```

- [ ] **Step 2: Create basic Flask app**

```python
# app.py
from flask import Flask
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

@app.route('/')
def hello():
    return {'message': 'Barbearia API is running'}

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

- [ ] **Step 3: Test the app runs**

```bash
cd barbearia-backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

Expected: Server starts on http://127.0.0.1:5000 with JSON response

- [ ] **Step 4: Commit**

```bash
git add barbearia-backend/
git commit -m "feat: create backend project structure"
```

### Task 2: Database Setup

**Files:**
- Create: `barbearia-backend/database/init_db.py`
- Create: `barbearia-backend/database/__init__.py`

- [ ] **Step 1: Create database initialization script**

```python
# database/init_db.py
import sqlite3

def init_db():
    conn = sqlite3.connect('database/barbearia.db')
    cursor = conn.cursor()
    
    # Create clientes table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS clientes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            telefone TEXT,
            data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Create servicos table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS servicos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            descricao TEXT,
            duracao_minutos INTEGER DEFAULT 30,
            preco DECIMAL(10,2)
        )
    ''')
    
    # Create agendamentos table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS agendamentos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente_id INTEGER NOT NULL,
            servico_id INTEGER NOT NULL,
            data_hora DATETIME NOT NULL,
            observacoes TEXT,
            status TEXT DEFAULT 'agendado',
            FOREIGN KEY (cliente_id) REFERENCES clientes(id),
            FOREIGN KEY (servico_id) REFERENCES servicos(id)
        )
    ''')
    
    conn.commit()
    conn.close()
    print("Database initialized successfully")

if __name__ == '__main__':
    init_db()
```

- [ ] **Step 2: Create database directory init file**

```python
# database/__init__.py
from .init_db import init_db
```

- [ ] **Step 3: Initialize database**

```bash
mkdir -p barbearia-backend/database
python barbearia-backend/database/init_db.py
```

Expected: "Database initialized successfully" and barbearia.db file created

- [ ] **Step 4: Commit**

```bash
git add barbearia-backend/database/
git commit -m "feat: create database schema"
```

### Task 3: Cliente Model

**Files:**
- Create: `barbearia-backend/models/cliente.py`
- Create: `barbearia-backend/tests/test_clientes.py`

- [ ] **Step 1: Write failing test for Cliente model**

```python
# tests/test_clientes.py
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from models.cliente import Cliente

def test_cliente_creation():
    cliente = Cliente(1, "João Silva", "11999999999")
    assert cliente.id == 1
    assert cliente.nome == "João Silva"
    assert cliente.telefone == "11999999999"
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd barbearia-backend
python -m pytest tests/test_clientes.py -v
```

Expected: FAIL with "ModuleNotFoundError: No module named 'models.cliente'"

- [ ] **Step 3: Create Cliente model**

```python
# models/cliente.py
class Cliente:
    def __init__(self, id=None, nome=None, telefone=None, data_cadastro=None):
        self.id = id
        self.nome = nome
        self.telefone = telefone
        self.data_cadastro = data_cadastro
    
    def to_dict(self):
        return {
            'id': self.id,
            'nome': self.nome,
            'telefone': self.telefone,
            'data_cadastro': self.data_cadastro
        }
    
    @classmethod
    def from_dict(cls, data):
        return cls(
            id=data.get('id'),
            nome=data.get('nome'),
            telefone=data.get('telefone'),
            data_cadastro=data.get('data_cadastro')
        )
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd barbearia-backend
python -m pytest tests/test_clientes.py -v
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add barbearia-backend/models/ barbearia-backend/tests/
git commit -m "feat: add Cliente model"
```

### Task 4: Cliente API Endpoints

**Files:**
- Create: `barbearia-backend/routes/clientes.py`
- Modify: `barbearia-backend/app.py`
- Modify: `barbearia-backend/tests/test_clientes.py`

- [ ] **Step 1: Write failing test for GET /api/clientes**

```python
# tests/test_clientes.py (add to existing file)
import json
from app import app

def test_get_clientes_empty():
    with app.test_client() as client:
        response = client.get('/api/clientes')
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data == []
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd barbearia-backend
python -m pytest tests/test_clientes.py::test_get_clientes_empty -v
```

Expected: FAIL with "404 Not Found"

- [ ] **Step 3: Create clientes routes**

```python
# routes/clientes.py
from flask import Blueprint, request, jsonify
import sqlite3
import os

clientes_bp = Blueprint('clientes', __name__)

def get_db_connection():
    conn = sqlite3.connect('database/barbearia.db')
    conn.row_factory = sqlite3.Row
    return conn

@clientes_bp.route('/api/clientes', methods=['GET'])
def get_clientes():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM clientes ORDER BY nome')
    clientes = cursor.fetchall()
    conn.close()
    
    result = []
    for cliente in clientes:
        result.append(dict(cliente))
    
    return jsonify(result)

@clientes_bp.route('/api/clientes/<int:id>', methods=['GET'])
def get_cliente(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM clientes WHERE id = ?', (id,))
    cliente = cursor.fetchone()
    conn.close()
    
    if cliente is None:
        return jsonify({'error': 'Cliente not found'}), 404
    
    return jsonify(dict(cliente))

@clientes_bp.route('/api/clientes', methods=['POST'])
def create_cliente():
    data = request.get_json()
    
    if not data or 'nome' not in data:
        return jsonify({'error': 'Nome is required'}), 400
    
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        'INSERT INTO clientes (nome, telefone) VALUES (?, ?)',
        (data['nome'], data.get('telefone', ''))
    )
    conn.commit()
    cliente_id = cursor.lastrowid
    conn.close()
    
    return jsonify({'id': cliente_id, 'message': 'Cliente created'}), 201
```

- [ ] **Step 4: Register blueprint in app.py**

```python
# app.py (modify)
from flask import Flask
from flask_cors import CORS
from routes.clientes import clientes_bp

app = Flask(__name__)
CORS(app)

app.register_blueprint(clientes_bp)

@app.route('/')
def hello():
    return {'message': 'Barbearia API is running'}

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

- [ ] **Step 5: Run test to verify it passes**

```bash
cd barbearia-backend
python -m pytest tests/test_clientes.py::test_get_clientes_empty -v
```

Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add barbearia-backend/routes/ barbearia-backend/app.py barbearia-backend/tests/
git commit -m "feat: add Cliente API endpoints"
```

### Task 5: Servico and Agendamento Models

**Files:**
- Create: `barbearia-backend/models/servico.py`
- Create: `barbearia-backend/models/agendamento.py`
- Create: `barbearia-backend/tests/test_servicos.py`
- Create: `barbearia-backend/tests/test_agendamentos.py`

- [ ] **Step 1: Create Servico model**

```python
# models/servico.py
class Servico:
    def __init__(self, id=None, nome=None, descricao=None, duracao_minutos=None, preco=None):
        self.id = id
        self.nome = nome
        self.descricao = descricao
        self.duracao_minutos = duracao_minutos
        self.preco = preco
    
    def to_dict(self):
        return {
            'id': self.id,
            'nome': self.nome,
            'descricao': self.descricao,
            'duracao_minutos': self.duracao_minutos,
            'preco': str(self.preco) if self.preco else None
        }
    
    @classmethod
    def from_dict(cls, data):
        return cls(
            id=data.get('id'),
            nome=data.get('nome'),
            descricao=data.get('descricao'),
            duracao_minutos=data.get('duracao_minutos'),
            preco=data.get('preco')
        )
```

- [ ] **Step 2: Create Agendamento model**

```python
# models/agendamento.py
class Agendamento:
    def __init__(self, id=None, cliente_id=None, servico_id=None, data_hora=None, observacoes=None, status='agendado'):
        self.id = id
        self.cliente_id = cliente_id
        self.servico_id = servico_id
        self.data_hora = data_hora
        self.observacoes = observacoes
        self.status = status
    
    def to_dict(self):
        return {
            'id': self.id,
            'cliente_id': self.cliente_id,
            'servico_id': self.servico_id,
            'data_hora': self.data_hora,
            'observacoes': self.observacoes,
            'status': self.status
        }
    
    @classmethod
    def from_dict(cls, data):
        return cls(
            id=data.get('id'),
            cliente_id=data.get('cliente_id'),
            servico_id=data.get('servico_id'),
            data_hora=data.get('data_hora'),
            observacoes=data.get('observacoes'),
            status=data.get('status', 'agendado')
        )
```

- [ ] **Step 3: Write basic tests for models**

```python
# tests/test_servicos.py
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from models.servico import Servico

def test_servico_creation():
    servico = Servico(1, "Corte", "Corte de cabelo", 30, 25.00)
    assert servico.id == 1
    assert servico.nome == "Corte"
    assert servico.duracao_minutos == 30
    assert servico.preco == 25.00
```

```python
# tests/test_agendamentos.py
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from models.agendamento import Agendamento

def test_agendamento_creation():
    agendamento = Agendamento(1, 1, 1, "2024-04-10 10:00:00", "Observação")
    assert agendamento.id == 1
    assert agendamento.cliente_id == 1
    assert agendamento.servico_id == 1
    assert agendamento.data_hora == "2024-04-10 10:00:00"
    assert agendamento.status == "agendado"
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
cd barbearia-backend
python -m pytest tests/test_servicos.py -v
python -m pytest tests/test_agendamentos.py -v
```

Expected: Both PASS

- [ ] **Step 5: Commit**

```bash
git add barbearia-backend/models/ barbearia-backend/tests/
git commit -m "feat: add Servico and Agendamento models"
```

### Task 6: Servico and Agendamento API Endpoints

**Files:**
- Create: `barbearia-backend/routes/servicos.py`
- Create: `barbearia-backend/routes/agendamentos.py`
- Modify: `barbearia-backend/app.py`
- Modify: `barbearia-backend/tests/test_servicos.py`
- Modify: `barbearia-backend/tests/test_agendamentos.py`

- [ ] **Step 1: Write failing test for GET /api/servicos**

```python
# tests/test_servicos.py (add to existing file)
import json
from app import app

def test_get_servicos_empty():
    with app.test_client() as client:
        response = client.get('/api/servicos')
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data == []
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd barbearia-backend
python -m pytest tests/test_servicos.py::test_get_servicos_empty -v
```

Expected: FAIL with "404 Not Found"

- [ ] **Step 3: Create servicos routes**

```python
# routes/servicos.py
from flask import Blueprint, request, jsonify
import sqlite3

servicos_bp = Blueprint('servicos', __name__)

def get_db_connection():
    conn = sqlite3.connect('database/barbearia.db')
    conn.row_factory = sqlite3.Row
    return conn

@servicos_bp.route('/api/servicos', methods=['GET'])
def get_servicos():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM servicos ORDER BY nome')
    servicos = cursor.fetchall()
    conn.close()
    
    result = []
    for servico in servicos:
        result.append(dict(servico))
    
    return jsonify(result)

@servicos_bp.route('/api/servicos', methods=['POST'])
def create_servico():
    data = request.get_json()
    
    if not data or 'nome' not in data:
        return jsonify({'error': 'Nome is required'}), 400
    
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        'INSERT INTO servicos (nome, descricao, duracao_minutos, preco) VALUES (?, ?, ?, ?)',
        (data['nome'], data.get('descricao', ''), data.get('duracao_minutos', 30), data.get('preco', 0))
    )
    conn.commit()
    servico_id = cursor.lastrowid
    conn.close()
    
    return jsonify({'id': servico_id, 'message': 'Servico created'}), 201
```

- [ ] **Step 4: Write failing test for GET /api/agendamentos**

```python
# tests/test_agendamentos.py (add to existing file)
import json
from app import app

def test_get_agendamentos_empty():
    with app.test_client() as client:
        response = client.get('/api/agendamentos')
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data == []
```

- [ ] **Step 5: Run test to verify it fails**

```bash
cd barbearia-backend
python -m pytest tests/test_agendamentos.py::test_get_agendamentos_empty -v
```

Expected: FAIL with "404 Not Found"

- [ ] **Step 6: Create agendamentos routes**

```python
# routes/agendamentos.py
from flask import Blueprint, request, jsonify
import sqlite3
from datetime import datetime

agendamentos_bp = Blueprint('agendamentos', __name__)

def get_db_connection():
    conn = sqlite3.connect('database/barbearia.db')
    conn.row_factory = sqlite3.Row
    return conn

@agendamentos_bp.route('/api/agendamentos', methods=['GET'])
def get_agendamentos():
    date_filter = request.args.get('date')
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    if date_filter:
        cursor.execute('''
            SELECT a.*, c.nome as cliente_nome, s.nome as servico_nome 
            FROM agendamentos a
            LEFT JOIN clientes c ON a.cliente_id = c.id
            LEFT JOIN servicos s ON a.servico_id = s.id
            WHERE DATE(a.data_hora) = ?
            ORDER BY a.data_hora
        ''', (date_filter,))
    else:
        cursor.execute('''
            SELECT a.*, c.nome as cliente_nome, s.nome as servico_nome 
            FROM agendamentos a
            LEFT JOIN clientes c ON a.cliente_id = c.id
            LEFT JOIN servicos s ON a.servico_id = s.id
            ORDER BY a.data_hora
        ''')
    
    agendamentos = cursor.fetchall()
    conn.close()
    
    result = []
    for agendamento in agendamentos:
        result.append(dict(agendamento))
    
    return jsonify(result)

@agendamentos_bp.route('/api/agendamentos', methods=['POST'])
def create_agendamento():
    data = request.get_json()
    
    required_fields = ['cliente_id', 'servico_id', 'data_hora']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'{field} is required'}), 400
    
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        'INSERT INTO agendamentos (cliente_id, servico_id, data_hora, observacoes) VALUES (?, ?, ?, ?)',
        (data['cliente_id'], data['servico_id'], data['data_hora'], data.get('observacoes', ''))
    )
    conn.commit()
    agendamento_id = cursor.lastrowid
    conn.close()
    
    return jsonify({'id': agendamento_id, 'message': 'Agendamento created'}), 201

@agendamentos_bp.route('/api/agendamentos/<int:id>/concluir', methods=['PUT'])
def concluir_agendamento(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('UPDATE agendamentos SET status = ? WHERE id = ?', ('concluido', id))
    conn.commit()
    affected = cursor.rowcount
    conn.close()
    
    if affected == 0:
        return jsonify({'error': 'Agendamento not found'}), 404
    
    return jsonify({'message': 'Agendamento marked as completed'})

@agendamentos_bp.route('/api/agendamentos/<int:id>/cancelar', methods=['PUT'])
def cancelar_agendamento(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('UPDATE agendamentos SET status = ? WHERE id = ?', ('cancelado', id))
    conn.commit()
    affected = cursor.rowcount
    conn.close()
    
    if affected == 0:
        return jsonify({'error': 'Agendamento not found'}), 404
    
    return jsonify({'message': 'Agendamento canceled'})
```

- [ ] **Step 7: Register blueprints in app.py**

```python
# app.py (modify)
from flask import Flask
from flask_cors import CORS
from routes.clientes import clientes_bp
from routes.servicos import servicos_bp
from routes.agendamentos import agendamentos_bp

app = Flask(__name__)
CORS(app)

app.register_blueprint(clientes_bp)
app.register_blueprint(servicos_bp)
app.register_blueprint(agendamentos_bp)

@app.route('/')
def hello():
    return {'message': 'Barbearia API is running'}

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

- [ ] **Step 8: Run tests to verify they pass**

```bash
cd barbearia-backend
python -m pytest tests/test_servicos.py::test_get_servicos_empty -v
python -m pytest tests/test_agendamentos.py::test_get_agendamentos_empty -v
```

Expected: Both PASS

- [ ] **Step 9: Commit**

```bash
git add barbearia-backend/routes/ barbearia-backend/app.py barbearia-backend/tests/
git commit -m "feat: add Servico and Agendamento API endpoints"
```

---
## Phase 2: Frontend Basic Setup

### Task 7: Flutter Project Structure

**Files:**
- Create: `barbearia-app/`
- Create: `barbearia-app/pubspec.yaml`
- Create: `barbearia-app/lib/main.dart`

- [ ] **Step 1: Create Flutter project directory**

```bash
mkdir -p barbearia-app
```

- [ ] **Step 2: Create pubspec.yaml**

```yaml
# pubspec.yaml
name: barbearia_app
description: Agenda Digital para Barbearia
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  intl: ^0.19.0
  provider: ^6.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

- [ ] **Step 3: Create main.dart**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const BarbeariaApp());
}

class BarbeariaApp extends StatelessWidget {
  const BarbeariaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Barbearia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Agenda Digital para Barbearia'),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Test Flutter app runs**

```bash
cd barbearia-app
flutter run
```

Expected: App compiles and shows "Agenda Digital para Barbearia" text

- [ ] **Step 5: Commit**

```bash
git add barbearia-app/
git commit -m "feat: create Flutter project structure"
```

### Task 8: Data Models

**Files:**
- Create: `barbearia-app/lib/models/cliente.dart`
- Create: `barbearia-app/lib/models/servico.dart`
- Create: `barbearia-app/lib/models/agendamento.dart`

- [ ] **Step 1: Create Cliente model**

```dart
// lib/models/cliente.dart
class Cliente {
  final int? id;
  final String nome;
  final String? telefone;
  final String? dataCadastro;

  Cliente({
    this.id,
    required this.nome,
    this.telefone,
    this.dataCadastro,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nome: json['nome'],
      telefone: json['telefone'],
      dataCadastro: json['data_cadastro'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'data_cadastro': dataCadastro,
    };
  }
}
```

- [ ] **Step 2: Create Servico model**

```dart
// lib/models/servico.dart
class Servico {
  final int? id;
  final String nome;
  final String? descricao;
  final int duracaoMinutos;
  final double preco;

  Servico({
    this.id,
    required this.nome,
    this.descricao,
    this.duracaoMinutos = 30,
    required this.preco,
  });

  factory Servico.fromJson(Map<String, dynamic> json) {
    return Servico(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      duracaoMinutos: json['duracao_minutos'] ?? 30,
      preco: (json['preco'] is String) ? double.parse(json['preco']) : (json['preco'] ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'duracao_minutos': duracaoMinutos,
      'preco': preco,
    };
  }
}
```

- [ ] **Step 3: Create Agendamento model**

```dart
// lib/models/agendamento.dart
class Agendamento {
  final int? id;
  final int clienteId;
  final int servicoId;
  final String dataHora;
  final String? observacoes;
  final String status;
  final String? clienteNome;
  final String? servicoNome;

  Agendamento({
    this.id,
    required this.clienteId,
    required this.servicoId,
    required this.dataHora,
    this.observacoes,
    this.status = 'agendado',
    this.clienteNome,
    this.servicoNome,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'],
      clienteId: json['cliente_id'],
      servicoId: json['servico_id'],
      dataHora: json['data_hora'],
      observacoes: json['observacoes'],
      status: json['status'] ?? 'agendado',
      clienteNome: json['cliente_nome'],
      servicoNome: json['servico_nome'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'servico_id': servicoId,
      'data_hora': dataHora,
      'observacoes': observacoes,
      'status': status,
    };
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add barbearia-app/lib/models/
git commit -m "feat: add data models"
```

### Task 9: API Service

**Files:**
- Create: `barbearia-app/lib/utils/constants.dart`
- Create: `barbearia-app/lib/services/api_service.dart`

- [ ] **Step 1: Create constants**

```dart
// lib/utils/constants.dart
class Constants {
  static const String apiBaseUrl = 'http://10.0.2.2:5000'; // Android emulator
  // static const String apiBaseUrl = 'http://localhost:5000'; // iOS simulator
  
  static const String primaryColor = '#2196F3';
  static const String secondaryColor = '#FF9800';
  static const String successColor = '#4CAF50';
  static const String errorColor = '#F44336';
}
```

- [ ] **Step 2: Create base API service**

```dart
// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  final String baseUrl;
  
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? Constants.apiBaseUrl;
  
  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: headers);
  }
  
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final jsonBody = jsonEncode(body ?? {});
    final finalHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };
    return await http.post(url, body: jsonBody, headers: finalHeaders);
  }
  
  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final jsonBody = jsonEncode(body ?? {});
    final finalHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };
    return await http.put(url, body: jsonBody, headers: finalHeaders);
  }
  
  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(url, headers: headers);
  }
}
```

- [ ] **Step 3: Test API service**

```dart
// Create a simple test file to verify API service works
// lib/test_api.dart (temporary)
import 'package:http/http.dart' as http;
import 'services/api_service.dart';

void testApiService() async {
  final api = ApiService();
  try {
    final response = await api.get('/');
    print('API Response: ${response.statusCode}');
    print('API Body: ${response.body}');
  } catch (e) {
    print('API Error: $e');
  }
}
```

- [ ] **Step 4: Run test to verify API service works**

```bash
cd barbearia-app
dart lib/test_api.dart
```

Expected: Prints API response or error

- [ ] **Step 5: Commit**

```bash
git add barbearia-app/lib/utils/ barbearia-app/lib/services/
git commit -m "feat: add API service and constants"
```

### Task 10: Specific Service Classes

**Files:**
- Create: `barbearia-app/lib/services/cliente_service.dart`
- Create: `barbearia-app/lib/services/agendamento_service.dart`

- [ ] **Step 1: Create ClienteService**

```dart
// lib/services/cliente_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cliente.dart';
import 'api_service.dart';

class ClienteService {
  final ApiService _apiService;

  ClienteService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<List<Cliente>> getClientes() async {
    final response = await _apiService.get('/api/clientes');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Cliente.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load clientes');
    }
  }

  Future<Cliente> createCliente(Cliente cliente) async {
    final response = await _apiService.post('/api/clientes', body: cliente.toJson());
    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Cliente(
        id: data['id'],
        nome: cliente.nome,
        telefone: cliente.telefone,
      );
    } else {
      throw Exception('Failed to create cliente');
    }
  }
}
```

- [ ] **Step 2: Create AgendamentoService**

```dart
// lib/services/agendamento_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agendamento.dart';
import 'api_service.dart';

class AgendamentoService {
  final ApiService _apiService;

  AgendamentoService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<List<Agendamento>> getAgendamentos({String? date}) async {
    String endpoint = '/api/agendamentos';
    if (date != null) {
      endpoint += '?date=$date';
    }
    
    final response = await _apiService.get(endpoint);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Agendamento.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load agendamentos');
    }
  }

  Future<Agendamento> createAgendamento(Agendamento agendamento) async {
    final response = await _apiService.post('/api/agendamentos', body: agendamento.toJson());
    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Agendamento(
        id: data['id'],
        clienteId: agendamento.clienteId,
        servicoId: agendamento.servicoId,
        dataHora: agendamento.dataHora,
        observacoes: agendamento.observacoes,
      );
    } else {
      throw Exception('Failed to create agendamento');
    }
  }

  Future<void> concluirAgendamento(int id) async {
    final response = await _apiService.put('/api/agendamentos/$id/concluir');
    if (response.statusCode != 200) {
      throw Exception('Failed to mark agendamento as completed');
    }
  }

  Future<void> cancelarAgendamento(int id) async {
    final response = await _apiService.put('/api/agendamentos/$id/cancelar');
    if (response.statusCode != 200) {
      throw Exception('Failed to cancel agendamento');
    }
  }
}
```

- [ ] **Step 3: Test service classes**

```dart
// Create a simple test file to verify services work
// lib/test_services.dart (temporary)
import 'services/cliente_service.dart';
import 'services/agendamento_service.dart';

void testServices() async {
  print('Testing ClienteService...');
  final clienteService = ClienteService();
  try {
    final clientes = await clienteService.getClientes();
    print('Clientes loaded: ${clientes.length}');
  } catch (e) {
    print('ClienteService error: $e');
  }

  print('Testing AgendamentoService...');
  final agendamentoService = AgendamentoService();
  try {
    final agendamentos = await agendamentoService.getAgendamentos();
    print('Agendamentos loaded: ${agendamentos.length}');
  } catch (e) {
    print('AgendamentoService error: $e');
  }
}
```

- [ ] **Step 4: Run test to verify services work**

```bash
cd barbearia-app
dart lib/test_services.dart
```

Expected: Prints service responses or errors

- [ ] **Step 5: Commit**

```bash
git add barbearia-app/lib/services/
git commit -m "feat: add specific service classes"
```

---
## Phase 3: Main Functionalities

### Task 11: Home Screen

**Files:**
- Create: `barbearia-app/lib/screens/home_screen.dart`

- [ ] **Step 1: Create HomeScreen widget**

```dart
// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda Barbearia'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bem-vindo à Agenda Digital',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/clientes');
              },
              child: const Text('Clientes'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/agendamentos');
              },
              child: const Text('Agendamentos'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/agenda-dia');
              },
              child: const Text('Agenda do Dia'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Update main.dart with navigation**

```dart
// lib/main.dart (modify)
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/clientes_screen.dart';
import 'screens/agendamentos_screen.dart';
import 'screens/agenda_dia_screen.dart';

void main() {
  runApp(const BarbeariaApp());
}

class BarbeariaApp extends StatelessWidget {
  const BarbeariaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Barbearia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/clientes': (context) => const ClientesScreen(),
        '/agendamentos': (context) => const AgendamentosScreen(),
        '/agenda-dia': (context) => const AgendaDiaScreen(),
      },
    );
  }
}
```

- [ ] **Step 3: Test home screen navigation**

```bash
cd barbearia-app
flutter run
```

Expected: App shows home screen with buttons, navigation works

- [ ] **Step 4: Commit**

```bash
git add barbearia-app/lib/screens/ barbearia-app/lib/main.dart
git commit -m "feat: add home screen and navigation"
```

### Task 12: Clientes Screen

**Files:**
- Create: `barbearia-app/lib/screens/clientes_screen.dart`
- Create: `barbearia-app/lib/widgets/cliente_card.dart`

- [ ] **Step 1: Create ClienteCard widget**

```dart
// lib/widgets/cliente_card.dart
import 'package:flutter/material.dart';
import '../models/cliente.dart';

class ClienteCard extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback? onTap;

  const ClienteCard({
    super.key,
    required this.cliente,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(cliente.nome),
        subtitle: cliente.telefone != null ? Text(cliente.telefone!) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
```

- [ ] **Step 2: Create ClientesScreen**

```dart
// lib/screens/clientes_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cliente.dart';
import '../services/cliente_service.dart';
import '../widgets/cliente_card.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  late ClienteService _clienteService;
  List<Cliente> _clientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _clienteService = ClienteService();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final clientes = await _clienteService.getClientes();
      setState(() {
        _clientes = clientes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar clientes: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClientes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clientes.isEmpty
              ? const Center(child: Text('Nenhum cliente cadastrado'))
              : ListView.builder(
                  itemCount: _clientes.length,
                  itemBuilder: (context, index) {
                    return ClienteCard(cliente: _clientes[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new cliente form
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Novo cliente - em desenvolvimento')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

- [ ] **Step 3: Test clientes screen**

```bash
cd barbearia-app
flutter run
```

Expected: Navigate to clientes screen, shows loading, then clientes list or empty state

- [ ] **Step 4: Commit**

```bash
git add barbearia-app/lib/screens/clientes_screen.dart barbearia-app/lib/widgets/
git commit -m "feat: add clientes screen with list view"
```

### Task 13: Agendamentos Screen

**Files:**
- Create: `barbearia-app/lib/screens/agendamentos_screen.dart`
- Create: `barbearia-app/lib/widgets/agendamento_card.dart`

- [ ] **Step 1: Create AgendamentoCard widget**

```dart
// lib/widgets/agendamento_card.dart
import 'package:flutter/material.dart';
import '../models/agendamento.dart';

class AgendamentoCard extends StatelessWidget {
  final Agendamento agendamento;
  final VoidCallback? onTap;

  const AgendamentoCard({
    super.key,
    required this.agendamento,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildStatusIcon(),
        title: Text(agendamento.clienteNome ?? 'Cliente ${agendamento.clienteId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(agendamento.servicoNome ?? 'Serviço ${agendamento.servicoId}'),
            Text(agendamento.dataHora),
            if (agendamento.observacoes != null && agendamento.observacoes!.isNotEmpty)
              Text('Obs: ${agendamento.observacoes}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (agendamento.status) {
      case 'concluido':
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.check, color: Colors.white),
        );
      case 'cancelado':
        return const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.close, color: Colors.white),
        );
      default:
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.schedule, color: Colors.white),
        );
    }
  }
}
```

- [ ] **Step 2: Create AgendamentosScreen**

```dart
// lib/screens/agendamentos_screen.dart
import 'package:flutter/material.dart';
import '../models/agendamento.dart';
import '../services/agendamento_service.dart';
import '../widgets/agendamento_card.dart';

class AgendamentosScreen extends StatefulWidget {
  const AgendamentosScreen({super.key});

  @override
  State<AgendamentosScreen> createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  late AgendamentoService _agendamentoService;
  List<Agendamento> _agendamentos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _agendamentoService = AgendamentoService();
    _loadAgendamentos();
  }

  Future<void> _loadAgendamentos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final agendamentos = await _agendamentoService.getAgendamentos();
      setState(() {
        _agendamentos = agendamentos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar agendamentos: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAgendamentos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _agendamentos.isEmpty
              ? const Center(child: Text('Nenhum agendamento cadastrado'))
              : ListView.builder(
                  itemCount: _agendamentos.length,
                  itemBuilder: (context, index) {
                    return AgendamentoCard(agendamento: _agendamentos[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/novo-agendamento');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

- [ ] **Step 3: Add novo-agendamento route to main.dart**

```dart
// lib/main.dart (modify - add import and route)
import 'screens/novo_agendamento_screen.dart';

// In routes map, add:
'/novo-agendamento': (context) => const NovoAgendamentoScreen(),
```

- [ ] **Step 4: Test agendamentos screen**

```bash
cd barbearia-app
flutter run
```

Expected: Navigate to agendamentos screen, shows loading, then agendamentos list or empty state

- [ ] **Step 5: Commit**

```bash
git add barbearia-app/lib/screens/agendamentos_screen.dart barbearia-app/lib/widgets/agendamento_card.dart barbearia-app/lib/main.dart
git commit -m "feat: add agendamentos screen with list view"
```

### Task 14: Agenda Dia Screen

**Files:**
- Create: `barbearia-app/lib/screens/agenda_dia_screen.dart`

- [ ] **Step 1: Create AgendaDiaScreen**

```dart
// lib/screens/agenda_dia_screen.dart
import 'package:flutter/material.dart';
import '../models/agendamento.dart';
import '../services/agendamento_service.dart';
import '../widgets/agendamento_card.dart';

class AgendaDiaScreen extends StatefulWidget {
  const AgendaDiaScreen({super.key});

  @override
  State<AgendaDiaScreen> createState() => _AgendaDiaScreenState();
}

class _AgendaDiaScreenState extends State<AgendaDiaScreen> {
  late AgendamentoService _agendamentoService;
  List<Agendamento> _agendamentos = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _agendamentoService = AgendamentoService();
    _loadAgendamentosDoDia();
  }

  Future<void> _loadAgendamentosDoDia() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      final agendamentos = await _agendamentoService.getAgendamentos(date: dateStr);
      setState(() {
        _agendamentos = agendamentos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar agenda do dia: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _concluirAgendamento(int id) async {
    try {
      await _agendamentoService.concluirAgendamento(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento marcado como concluído')),
      );
      _loadAgendamentosDoDia();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao concluir agendamento: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda do Dia - ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAgendamentosDoDia,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
                _loadAgendamentosDoDia();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _agendamentos.isEmpty
              ? const Center(child: Text('Nenhum agendamento para hoje'))
              : ListView.builder(
                  itemCount: _agendamentos.length,
                  itemBuilder: (context, index) {
                    final agendamento = _agendamentos[index];
                    return Dismissible(
                      key: Key('agendamento-${agendamento.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Concluir Agendamento'),
                            content: const Text('Marcar este agendamento como concluído?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Concluir'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        _concluirAgendamento(agendamento.id!);
                      },
                      child: AgendamentoCard(agendamento: agendamento),
                    );
                  },
                ),
    );
  }
}
```

- [ ] **Step 2: Test agenda dia screen**

```bash
cd barbearia-app
flutter run
```

Expected: Navigate to agenda dia screen, shows today's appointments, swipe to mark as completed

- [ ] **Step 3: Commit**

```bash
git add barbearia-app/lib/screens/agenda_dia_screen.dart
git commit -m "feat: add agenda do dia screen with swipe to complete"
```

### Task 15: Novo Agendamento Screen

**Files:**
- Create: `barbearia-app/lib/screens/novo_agendamento_screen.dart`

- [ ] **Step 1: Create NovoAgendamentoScreen**

```dart
// lib/screens/novo_agendamento_screen.dart
import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../models/servico.dart';
import '../models/agendamento.dart';
import '../services/cliente_service.dart';
import '../services/agendamento_service.dart';

class NovoAgendamentoScreen extends StatefulWidget {
  const NovoAgendamentoScreen({super.key});

  @override
  State<NovoAgendamentoScreen> createState() => _NovoAgendamentoScreenState();
}

class _NovoAgendamentoScreenState extends State<NovoAgendamentoScreen> {
  late ClienteService _clienteService;
  late AgendamentoService _agendamentoService;
  List<Cliente> _clientes = [];
  List<Servico> _servicos = [];
  bool _isLoading = true;

  int? _selectedClienteId;
  int? _selectedServicoId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _observacoesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clienteService = ClienteService();
    _agendamentoService = AgendamentoService();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // TODO: Load servicos from API when available
      // For now, create some sample services
      _servicos = [
        Servico(id: 1, nome: 'Corte de Cabelo', preco: 30.0),
        Servico(id: 2, nome: 'Barba', preco: 20.0),
        Servico(id: 3, nome: 'Corte + Barba', preco: 45.0),
      ];
      
      final clientes = await _clienteService.getClientes();
      setState(() {
        _clientes = clientes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createAgendamento() async {
    if (_selectedClienteId == null || _selectedServicoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione cliente e serviço')),
      );
      return;
    }

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final dateTimeStr = dateTime.toIso8601String();

    final agendamento = Agendamento(
      clienteId: _selectedClienteId!,
      servicoId: _selectedServicoId!,
      dataHora: dateTimeStr,
      observacoes: _observacoesController.text,
    );

    try {
      await _agendamentoService.createAgendamento(agendamento);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento criado com sucesso')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar agendamento: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cliente selection
                  DropdownButtonFormField<int>(
                    value: _selectedClienteId,
                    decoration: const InputDecoration(
                      labelText: 'Cliente',
                      border: OutlineInputBorder(),
                    ),
                    items: _clientes.map((cliente) {
                      return DropdownMenuItem<int>(
                        value: cliente.id,
                        child: Text(cliente.nome),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClienteId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) return 'Selecione um cliente';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Serviço selection
                  DropdownButtonFormField<int>(
                    value: _selectedServicoId,
                    decoration: const InputDecoration(
                      labelText: 'Serviço',
                      border: OutlineInputBorder(),
                    ),
                    items: _servicos.map((servico) {
                      return DropdownMenuItem<int>(
                        value: servico.id,
                        child: Text('${servico.nome} - R\$${servico.preco.toStringAsFixed(2)}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedServicoId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) return 'Selecione um serviço';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date selection
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Data',
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(
                            text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                          readOnly: true,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null && picked != _selectedDate) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Hora',
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(
                            text: _selectedTime.format(context),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (picked != null && picked != _selectedTime) {
                              setState(() {
                                _selectedTime = picked;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Observações
                  TextFormField(
                    controller: _observacoesController,
                    decoration: const InputDecoration(
                      labelText: 'Observações (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  ElevatedButton(
                    onPressed: _createAgendamento,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Criar Agendamento'),
                  ),
                ],
              ),
            ),
    );
  }
}
```

- [ ] **Step 2: Test novo agendamento screen**

```bash
cd barbearia-app
flutter run
```

Expected: Navigate to novo agendamento screen, fill form, create appointment

- [ ] **Step 3: Commit**

```bash
git add barbearia-app/lib/screens/novo_agendamento_screen.dart
git commit -m "feat: add novo agendamento screen with form"
```

---
## Phase 4: Integration and Testing

### Task 16: Backend-Frontend Integration

**Files:**
- Modify: `barbearia-backend/app.py` (CORS configuration)
- Modify: `barbearia-app/lib/utils/constants.dart` (API URL)
- Create: `barbearia-backend/seed_data.py` (sample data)

- [ ] **Step 1: Configure CORS for all origins**

```python
# barbearia-backend/app.py (modify CORS configuration)
from flask import Flask
from flask_cors import CORS
from routes.clientes import clientes_bp
from routes.servicos import servicos_bp
from routes.agendamentos import agendamentos_bp

app = Flask(__name__)
CORS(app, origins=["*"])  # Allow all origins for development

app.register_blueprint(clientes_bp)
app.register_blueprint(servicos_bp)
app.register_blueprint(agendamentos_bp)

@app.route('/')
def hello():
    return {'message': 'Barbearia API is running'}

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)  # Listen on all interfaces
```

- [ ] **Step 2: Update API URL for your environment**

```dart
// barbearia-app/lib/utils/constants.dart (modify)
class Constants {
  // For Android emulator
  static const String apiBaseUrl = 'http://10.0.2.2:5000';
  
  // For iOS simulator (uncomment if needed)
  // static const String apiBaseUrl = 'http://localhost:5000';
  
  // For physical device on same network
  // static const String apiBaseUrl = 'http://<your-computer-ip>:5000';
  
  static const String primaryColor = '#2196F3';
  static const String secondaryColor = '#FF9800';
  static const String successColor = '#4CAF50';
  static const String errorColor = '#F44336';
}
```

- [ ] **Step 3: Create seed data script**

```python
# barbearia-backend/seed_data.py
import sqlite3
import sys
import os

def seed_database():
    # Connect to database
    conn = sqlite3.connect('database/barbearia.db')
    cursor = conn.cursor()
    
    # Clear existing data
    cursor.execute('DELETE FROM agendamentos')
    cursor.execute('DELETE FROM clientes')
    cursor.execute('DELETE FROM servicos')
    
    # Insert sample clientes
    clientes = [
        ('João Silva', '(11) 99999-9999'),
        ('Maria Santos', '(11) 98888-8888'),
        ('Pedro Oliveira', '(11) 97777-7777'),
        ('Ana Costa', '(11) 96666-6666'),
    ]
    
    for nome, telefone in clientes:
        cursor.execute(
            'INSERT INTO clientes (nome, telefone) VALUES (?, ?)',
            (nome, telefone)
        )
    
    # Insert sample servicos
    servicos = [
        ('Corte de Cabelo', 'Corte tradicional', 30, 30.0),
        ('Barba', 'Aparar e modelar barba', 20, 20.0),
        ('Corte + Barba', 'Corte completo', 50, 45.0),
        ('Hidratação', 'Hidratação capilar', 30, 25.0),
    ]
    
    for nome, descricao, duracao, preco in servicos:
        cursor.execute(
            'INSERT INTO servicos (nome, descricao, duracao_minutos, preco) VALUES (?, ?, ?, ?)',
            (nome, descricao, duracao, preco)
        )
    
    # Insert sample agendamentos (tomorrow at various times)
    import datetime
    tomorrow = datetime.datetime.now() + datetime.timedelta(days=1)
    
    agendamentos = [
        (1, 1, tomorrow.replace(hour=9, minute=0).strftime('%Y-%m-%d %H:%M:%S'), 'Preferência por João'),
        (2, 2, tomorrow.replace(hour=10, minute=30).strftime('%Y-%m-%d %H:%M:%S'), 'Barba completa'),
        (3, 3, tomorrow.replace(hour=14, minute=0).strftime('%Y-%m-%d %H:%M:%S'), 'Corte e barba'),
        (4, 4, tomorrow.replace(hour=16, minute=30).strftime('%Y-%m-%d %H:%M:%S'), 'Hidratação especial'),
    ]
    
    for cliente_id, servico_id, data_hora, observacoes in agendamentos:
        cursor.execute(
            'INSERT INTO agendamentos (cliente_id, servico_id, data_hora, observacoes) VALUES (?, ?, ?, ?)',
            (cliente_id, servico_id, data_hora, observacoes)
        )
    
    conn.commit()
    conn.close()
    print("Database seeded successfully!")

if __name__ == '__main__':
    seed_database()
```

- [ ] **Step 4: Run seed script**

```bash
cd barbearia-backend
python seed_data.py
```

Expected: "Database seeded successfully!"

- [ ] **Step 5: Test API endpoints with curl**

```bash
# Test clientes endpoint
curl http://localhost:5000/api/clientes

# Test servicos endpoint  
curl http://localhost:5000/api/servicos

# Test agendamentos endpoint
curl http://localhost:5000/api/agendamentos
```

Expected: JSON responses with sample data

- [ ] **Step 6: Commit**

```bash
git add barbearia-backend/app.py barbearia-backend/seed_data.py barbearia-app/lib/utils/constants.dart
git commit -m "feat: configure backend-frontend integration with sample data"
```

### Task 17: End-to-End Testing

**Files:**
- Create: `barbearia-app/test/widget_test.dart`
- Modify: `barbearia-app/pubspec.yaml` (add test dependencies)
- Create: `barbearia-backend/tests/test_integration.py`

- [ ] **Step 1: Add test dependencies to Flutter**

```yaml
# barbearia-app/pubspec.yaml (modify dev_dependencies)
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

- [ ] **Step 2: Create basic widget test**

```dart
// barbearia-app/test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barbearia_app/main.dart';

void main() {
  testWidgets('App loads and shows title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BarbeariaApp());

    // Verify that our app shows the title
    expect(find.text('Agenda Digital para Barbearia'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Run Flutter widget test**

```bash
cd barbearia-app
flutter test
```

Expected: Test passes

- [ ] **Step 4: Create backend integration test**

```python
# barbearia-backend/tests/test_integration.py
import json
import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_full_flow(client):
    # Create a cliente
    response = client.post('/api/clientes', json={
        'nome': 'Teste Integração',
        'telefone': '(11) 95555-5555'
    })
    assert response.status_code == 201
    cliente_data = json.loads(response.data)
    cliente_id = cliente_data['id']
    
    # Get servicos
    response = client.get('/api/servicos')
    assert response.status_code == 200
    servicos = json.loads(response.data)
    servico_id = servicos[0]['id']
    
    # Create agendamento
    response = client.post('/api/agendamentos', json={
        'cliente_id': cliente_id,
        'servico_id': servico_id,
        'data_hora': '2024-04-11 10:00:00',
        'observacoes': 'Teste integração'
    })
    assert response.status_code == 201
    
    # Get agendamentos for today
    response = client.get('/api/agendamentos?data=2024-04-11')
    assert response.status_code == 200
    agendamentos = json.loads(response.data)
    assert len(agendamentos) > 0
```

- [ ] **Step 5: Run backend integration test**

```bash
cd barbearia-backend
python -m pytest tests/test_integration.py -v
```

Expected: Test passes

- [ ] **Step 6: Commit**

```bash
git add barbearia-app/pubspec.yaml barbearia-app/test/widget_test.dart barbearia-backend/tests/test_integration.py
git commit -m "test: add end-to-end testing"
```

---
## Phase 5: Validation and Adjustments

### Task 18: Final Testing and Bug Fixes

**Files:**
- All modified files from previous tasks

- [ ] **Step 1: Run all backend tests**

```bash
cd barbearia-backend
python -m pytest tests/ -v
```

Expected: All tests pass

- [ ] **Step 2: Run Flutter tests**

```bash
cd barbearia-app
flutter test
```

Expected: All tests pass

- [ ] **Step 3: Manual testing flow**

1. Start backend:
```bash
cd barbearia-backend
python app.py
```

2. Start Flutter app:
```bash
cd barbearia-app
flutter run
```

3. Test complete flow:
   - Open app
   - Navigate to Clientes screen
   - Add a new cliente
   - Navigate to Agendamentos screen  
   - Create a new agendamento
   - Check Agenda do Dia screen
   - Mark agendamento as concluído

Expected: All screens work correctly, data persists

- [ ] **Step 4: Fix any bugs found**

Check for and fix:
- API connection issues
- Date/time formatting problems
- Navigation errors
- State management issues
- UI rendering problems

- [ ] **Step 5: Commit fixes**

```bash
git add .
git commit -m "fix: address issues from final testing"
```

### Task 19: Documentation and Final Polish

**Files:**
- Create: `README.md`
- Create: `barbearia-backend/README.md`
- Create: `barbearia-app/README.md`
- Modify: `docs/superpowers/specs/2026-04-09-agenda-digital-barbearia-design.md` (add implementation notes)

- [ ] **Step 1: Create main README**

```markdown
# Agenda Digital para Barbearia

Projeto de Extensão II - Engenharia de Software

Aplicação móvel para organização de agendamentos em barbearias.

## Funcionalidades

- Cadastro de clientes
- Catálogo de serviços
- Agendamento por data e horário
- Visualização da agenda do dia
- Marcação de atendimentos como concluídos
- Listagem de agendamentos futuros

## Tecnologias

- **Frontend:** Flutter (Dart)
- **Backend:** Python/Flask
- **Banco de Dados:** SQLite
- **Comunicação:** REST API (HTTP/JSON)

## Instalação

### Backend
```bash
cd barbearia-backend
pip install -r requirements.txt
python database/init_db.py
python app.py
```

### Frontend
```bash
cd barbearia-app
flutter pub get
flutter run
```

## Uso

1. Inicie o backend na porta 5000
2. Execute o app Flutter
3. Cadastre clientes e serviços
4. Crie agendamentos
5. Consulte a agenda do dia

## Desenvolvimento

Projeto desenvolvido como parte do Projeto de Extensão II da disciplina de Engenharia de Software, seguindo metodologia PDCA e abordagem MVP Focado.
```

- [ ] **Step 2: Create backend README**

```markdown
# Barbearia Backend

API REST para Agenda Digital de Barbearia.

## Endpoints

### Clientes
- `GET /api/clientes` - Listar clientes
- `GET /api/clientes/{id}` - Obter cliente
- `POST /api/clientes` - Criar cliente
- `PUT /api/clientes/{id}` - Atualizar cliente
- `DELETE /api/clientes/{id}` - Excluir cliente

### Serviços
- `GET /api/servicos` - Listar serviços
- `POST /api/servicos` - Criar serviço

### Agendamentos
- `GET /api/agendamentos` - Listar agendamentos (filtro por data)
- `GET /api/agendamentos/{id}` - Obter agendamento
- `POST /api/agendamentos` - Criar agendamento
- `PUT /api/agendamentos/{id}/concluir` - Marcar como concluído
- `PUT /api/agendamentos/{id}/cancelar` - Cancelar agendamento
- `DELETE /api/agendamentos/{id}` - Excluir agendamento

## Desenvolvimento

```bash
# Instalar dependências
pip install -r requirements.txt

# Inicializar banco
python database/init_db.py

# Popular dados de teste
python seed_data.py

# Executar testes
python -m pytest tests/ -v

# Iniciar servidor
python app.py
```
```

- [ ] **Step 3: Create frontend README**

```markdown
# Barbearia App

Aplicativo Flutter para Agenda Digital de Barbearia.

## Telas

### HomeScreen
Menu principal com acesso às funcionalidades.

### ClientesScreen
Lista de clientes cadastrados com busca e cadastro.

### AgendamentosScreen
Lista de agendamentos futuros com filtro por data.

### NovoAgendamentoScreen
Formulário para criar novo agendamento.

### AgendaDiaScreen
Visualização dos agendamentos do dia atual.

## Desenvolvimento

```bash
# Instalar dependências
flutter pub get

# Executar testes
flutter test

# Executar aplicativo
flutter run

# Gerar build
flutter build apk
```

## Configuração

Editar `lib/utils/constants.dart` para configurar URL da API:

```dart
static const String apiBaseUrl = 'http://10.0.2.2:5000'; // Android emulator
// static const String apiBaseUrl = 'http://localhost:5000'; // iOS simulator
// static const String apiBaseUrl = 'http://<ip>:5000'; // Dispositivo físico
```
```

- [ ] **Step 4: Update spec with implementation notes**

```markdown
# docs/superpowers/specs/2026-04-09-agenda-digital-barbearia-design.md
# Add at the end:

## 14. Implementação Concluída

**Data de conclusão:** 2026-04-09

**Status:** MVP funcional completo

**Funcionalidades implementadas:**
- [x] Cadastro de clientes
- [x] Catálogo de serviços  
- [x] Agendamento por data/horário
- [x] Visualização agenda do dia
- [x] Marcação como concluído
- [x] Listagem de agendamentos futuros

**Tecnologias utilizadas:**
- Frontend: Flutter 3.0+ (Dart)
- Backend: Python 3.9+, Flask 3.0+
- Banco: SQLite
- Testes: pytest, flutter_test

**Arquitetura:**
- Frontend: MVVM com Provider
- Backend: REST API com blueprints
- Comunicação: HTTP/JSON com CORS

**Próximos passos (opcional):**
- Autenticação de usuários
- Notificações push
- Relatórios de atendimento
- Integração com pagamentos
```

- [ ] **Step 5: Commit documentation**

```bash
git add README.md barbearia-backend/README.md barbearia-app/README.md docs/superpowers/specs/2026-04-09-agenda-digital-barbearia-design.md
git commit -m "docs: add comprehensive documentation"
```

### Task 20: Final Validation and Project Completion

**Files:**
- All project files

- [ ] **Step 1: Final system test**

```bash
# Start backend
cd barbearia-backend
python app.py &
BACKEND_PID=$!

# Wait for backend to start
sleep 3

# Test API is running
curl http://localhost:5000/
echo ""

# Run Flutter app in test mode
cd ../barbearia-app
flutter test

# Kill backend
kill $BACKEND_PID
```

Expected: Backend responds, Flutter tests pass

- [ ] **Step 2: Create final project structure verification**

```bash
# Check project structure
find . -type f -name "*.py" | wc -l
find . -type f -name "*.dart" | wc -l
find . -type f -name "*.md" | wc -l

# Check git status
git status
```

Expected: Clean working tree, all files committed

- [ ] **Step 3: Create final commit**

```bash
git add .
git commit -m "chore: finalize project - Agenda Digital para Barbearia MVP completo"
```

- [ ] **Step 4: Tag release**

```bash
git tag -a v1.0.0 -m "Versão 1.0.0 - MVP Agenda Digital para Barbearia"
```

- [ ] **Step 5: Create project summary**

```markdown
# Resumo do Projeto

**Projeto:** Agenda Digital para Barbearia
**Tipo:** Projeto de Extensão II - Engenharia de Software
**Status:** Concluído ✅

**Funcionalidades implementadas (8/8):**
1. ✅ Cadastro de clientes
2. ✅ Registro de telefone/contato  
3. ✅ Seleção do serviço desejado
4. ✅ Agendamento por data e horário
5. ✅ Campo de observações
6. ✅ Listagem dos agendamentos do dia
7. ✅ Visualização dos atendimentos futuros
8. ✅ Marcação de atendimento concluído

**Tecnologias:**
- Frontend: Flutter/Dart (aplicativo móvel)
- Backend: Python/Flask (API REST)
- Banco: SQLite
- Testes: pytest, flutter_test

**Arquitetura:**
- Frontend: MVVM com Provider para gerenciamento de estado
- Backend: REST API com separação clara de responsabilidades
- Comunicação: HTTP/JSON com CORS configurado

**Metodologia:** PDCA (Plan-Do-Check-Act) com MVP Focado

**ODS relacionados:**
- ODS 8: Trabalho decente e crescimento econômico
- ODS 9: Indústria, inovação e infraestrutura

**Próximos passos (opcionais):**
- Implementar autenticação
- Adicionar notificações
- Gerar relatórios
- Publicar nas lojas de aplicativos
```

---
## Execution Options

**Plan complete and saved to `docs/superpowers/plans/2026-04-09-agenda-digital-barbearia-implementation.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**