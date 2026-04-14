# routes/profile.py
# Rotas para perfil do usuário logado

from flask import Blueprint, jsonify, request
from models import db, Usuario, Barbearia
from utils.auth import token_required

profile_bp = Blueprint('profile', __name__)

@profile_bp.route('/api/profile', methods=['GET'])
@token_required
def get_profile():
    """Retorna dados do perfil do usuário logado."""
    user_id = request.user_id
    current_user = Usuario.query.get(user_id)

    if not current_user:
        return jsonify({'error': 'Usuário não encontrado'}), 404

    barbearia = Barbearia.query.filter_by(usuario_id=user_id).first()

    return jsonify({
        'id': current_user.id,
        'username': current_user.username,
        'email': current_user.email,
        'nome_exibicao': current_user.nome_exibicao or '',
        'telefone': current_user.telefone or '',
        'barbearia': barbearia.to_dict() if barbearia else None,
    })

@profile_bp.route('/api/profile', methods=['PUT'])
@token_required
def update_profile():
    """Atualiza dados do perfil do usuário logado."""
    user_id = request.user_id
    current_user = Usuario.query.get(user_id)

    if not current_user:
        return jsonify({'error': 'Usuário não encontrado'}), 404

    data = request.get_json()

    if not data:
        return jsonify({'error': 'Dados obrigatórios'}), 400

    # Atualiza dados pessoais do usuário
    if 'nome_exibicao' in data:
        current_user.nome_exibicao = data['nome_exibicao'].strip() or None
    if 'telefone' in data:
        current_user.telefone = data['telefone'].strip() or None

    # Atualiza dados da barbearia se vierem
    barbearia_data = data.get('barbearia')
    if barbearia_data:
        barbearia = Barbearia.query.filter_by(usuario_id=user_id).first()
        if not barbearia:
            barbearia = Barbearia(usuario_id=user_id)
            db.session.add(barbearia)

        if 'nome' in barbearia_data:
            barbearia.nome = barbearia_data['nome'].strip()
        if 'telefone' in barbearia_data:
            barbearia.telefone = barbearia_data['telefone'].strip() or None
        if 'endereco' in barbearia_data:
            barbearia.endereco = barbearia_data['endereco'].strip() or None

    try:
        db.session.commit()
        return jsonify({'message': 'Perfil atualizado com sucesso'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500
