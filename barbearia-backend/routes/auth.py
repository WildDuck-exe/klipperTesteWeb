# routes/auth.py
# Rota de autenticação e registro de tokens de push

from flask import Blueprint, jsonify, request
from models import db, Usuario, PushToken
from werkzeug.security import check_password_hash
import jwt
import datetime
import os

auth_bp = Blueprint('auth', __name__)

def _get_secret_key():
    """Get SECRET_KEY from environment or app config, with fallback for development."""
    return os.environ.get('SECRET_KEY') or 'dev-secret-key-barbearia-2026'

@auth_bp.route('/api/auth/login', methods=['POST'])
def login():
    """Endpoint de login. Retorna token JWT."""
    data = request.get_json()

    if not data or 'username' not in data or 'password' not in data:
        return jsonify({'error': 'Username e password são obrigatórios'}), 400

    user = Usuario.query.filter_by(username=data['username']).first()

    if user is None:
        return jsonify({'error': 'Credenciais inválidas'}), 401

    if not check_password_hash(user.senha_hash, data['password']):
        return jsonify({'error': 'Credenciais inválidas'}), 401

    token = jwt.encode({
        'user_id': user.id,
        'username': user.username,
        'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)
    }, _get_secret_key(), algorithm='HS256')

    return jsonify({
        'token': token,
        'username': user.username,
        'message': 'Login realizado com sucesso'
    })

@auth_bp.route('/api/auth/register-token', methods=['POST'])
def register_token():
    """Registra um token FCM para o dispositivo do barbeiro."""
    data = request.get_json()
    
    if not data or 'token' not in data:
        return jsonify({'error': 'Token é obrigatório'}), 400
    
    # Verifica se o token já existe
    push_token = PushToken.query.filter_by(token=data['token']).first()
    
    if not push_token:
        push_token = PushToken(
            token=data['token'],
            dispositivo=data.get('dispositivo', 'Desconhecido')
        )
        db.session.add(push_token)
    else:
        push_token.dispositivo = data.get('dispositivo', 'Desconhecido')
        push_token.atualizado_em = datetime.datetime.utcnow()
    
    try:
        db.session.commit()
        return jsonify({'message': 'Token registrado com sucesso'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500
