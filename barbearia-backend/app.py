# app.py - Barbearia API Backend
"""
Aplicação Flask para API da Agenda Digital de Barbearia.
Fornece endpoints para gerenciamento de clientes, serviços e agendamentos.
"""

from flask import Flask, jsonify, send_from_directory
from flask_cors import CORS
import os
from config import Config
from models import db
from routes import register_blueprints

# Inicialização da aplicação Flask
app = Flask(__name__, static_folder='static')
app.config.from_object(Config)

# Configuração do CORS
CORS(app, resources=app.config['CORS_RESOURCES'])

# Inicializa o SQLAlchemy com o App
db.init_app(app)

# Configurações do App
app.config['SECRET_KEY'] = 'dev-secret-key-barbearia-2026'

# Registro de Blueprints
register_blueprints(app)

@app.route('/')
def hello():
    """Endpoint raiz da API."""
    return jsonify({
        'message': 'Barbearia API is running',
        'version': app.config['API_VERSION'],
        'endpoints': {
            'api_docs': '/api/',
            'chat_do_cliente': '/chat/',
            'clientes': '/api/clientes',
            'servicos': '/api/servicos',
            'agendamentos': '/api/agendamentos'
        }
    })

@app.route('/chat/')
def serve_chat():
    """Serve a interface de chat do cliente."""
    return send_from_directory('static/chat', 'index.html')

@app.route('/chat/<path:path>')
def serve_chat_assets(path):
    """Serve os assets do chat (JS, CSS)."""
    return send_from_directory('static/chat', path)

@app.route('/api/')
def api_info():
    """Endpoint de informações da API."""
    return jsonify({
        'name': 'Barbearia API',
        'description': 'API para Agenda Digital de Barbearia',
        'version': app.config['API_VERSION'],
        'author': 'Projeto de Extensão II - Engenharia de Software'
    })


# Execução do Servidor
if __name__ == '__main__':
    # Cria as tabelas se não existirem (Útil para desenvolvimento inicial)
    with app.app_context():
        db.create_all()
        print("Tabelas verificadas/criadas com sucesso.")

    # Em produção, debug deve ser False
    app.run(debug=app.config['DEBUG'], port=5000)