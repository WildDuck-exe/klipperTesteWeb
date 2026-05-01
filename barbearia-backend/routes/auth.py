# routes/auth.py
from flask import Blueprint, jsonify, request
from models import db, Usuario, PushToken
from werkzeug.security import check_password_hash, generate_password_hash
import re
import jwt
import datetime
import os

auth_bp = Blueprint('auth', __name__)

def _get_secret_key():
    return os.environ.get('SECRET_KEY') or 'dev-secret-key-barbearia-2026'


@auth_bp.route('/api/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data or 'username' not in data or 'password' not in data:
        return jsonify({'error': 'Username e password são obrigatórios'}), 400

    user = Usuario.query.filter_by(username=data['username']).first()
    if user is None or not check_password_hash(user.senha_hash, data['password']):
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


@auth_bp.route('/api/auth/register', methods=['POST'])
def register():
    data = request.get_json()
    if not data:
        return jsonify({'error': 'Dados obrigatórios'}), 400

    username = data.get('username', '').strip()
    email    = data.get('email', '').strip()
    password = data.get('password', '')

    if not username: return jsonify({'error': 'Username é obrigatório'}), 400
    if not email:    return jsonify({'error': 'Email é obrigatório'}), 400
    if not password: return jsonify({'error': 'Senha é obrigatória'}), 400

    if not re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', email):
        return jsonify({'error': 'Formato de email inválido'}), 400
    if Usuario.query.filter_by(username=username).first():
        return jsonify({'error': 'Username já está em uso'}), 409
    if Usuario.query.filter_by(email=email).first():
        return jsonify({'error': 'Email já está cadastrado'}), 409

    novo_usuario = Usuario(
        username=username,
        email=email,
        senha_hash=generate_password_hash(password)
    )
    db.session.add(novo_usuario)
    db.session.commit()

    token = jwt.encode({
        'user_id': novo_usuario.id,
        'username': novo_usuario.username,
        'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)
    }, _get_secret_key(), algorithm='HS256')

    return jsonify({
        'token': token,
        'username': novo_usuario.username,
        'message': 'Cadastro realizado com sucesso'
    }), 201


@auth_bp.route('/api/auth/register-token', methods=['POST'])
def register_token():
    """
    Registra token FCM do dispositivo do barbeiro.
    Salva no SQLite (legado) E no Supabase (usado por notifications.py para enviar push).
    """
    data = request.get_json()
    if not data or 'token' not in data:
        return jsonify({'error': 'Token é obrigatório'}), 400

    fcm_token  = data['token']
    dispositivo = data.get('dispositivo', 'Desconhecido')

    # ── 1. Salvar no SQLite (mantém compatibilidade) ──────────────────────────
    try:
        push_token = PushToken.query.filter_by(token=fcm_token).first()
        if not push_token:
            push_token = PushToken(token=fcm_token, dispositivo=dispositivo)
            db.session.add(push_token)
        else:
            push_token.dispositivo  = dispositivo
            push_token.atualizado_em = datetime.datetime.utcnow()
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        print(f'[Token] Erro SQLite: {e}')

    # ── 2. Salvar no Supabase (usado por notifications.py) ────────────────────
    try:
        from supabase_client import get_supabase
        sb = get_supabase()
        sb.table('push_tokens').upsert(
            {
                'token':      fcm_token,
                'dispositivo': dispositivo,
                'updated_at': datetime.datetime.utcnow().isoformat(),
            },
            on_conflict='token'
        ).execute()
        print(f'[Token] ✅ Registrado no Supabase: {fcm_token[:30]}...')
    except Exception as e:
        # Não falha o endpoint se Supabase der erro — SQLite já salvou
        print(f'[Token] ⚠️  Erro ao salvar no Supabase: {e}')

    return jsonify({'message': 'Token registrado com sucesso'}), 200