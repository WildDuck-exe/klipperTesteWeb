# routes/servicos.py
# Endpoints para gerenciamento de serviços usando SQLAlchemy

from flask import Blueprint, jsonify, request
from models import db, Servico
from utils.auth import login_required

servicos_bp = Blueprint('servicos', __name__)

@servicos_bp.route('/api/servicos', methods=['GET'])
@login_required
def get_servicos():
    """Retorna a lista de todos os serviços."""
    servicos = Servico.query.all()
    return jsonify([servico.to_dict() for servico in servicos])

@servicos_bp.route('/api/servicos', methods=['POST'])
@login_required
def create_servico():
    """Cria um novo serviço."""
    data = request.get_json()
    if not data or 'nome' not in data:
        return jsonify({'error': 'Nome é obrigatório'}), 400
    
    novo_servico = Servico(
        nome=data['nome'],
        descricao=data.get('descricao', ''),
        duracao_minutos=data.get('duracao_minutos', 30),
        preco=data.get('preco', 0.0),
        categoria=data.get('categoria', 'Geral')
    )
    
    db.session.add(novo_servico)
    try:
        db.session.commit()
        return jsonify({
            'id': novo_servico.id,
            'message': 'Serviço criado com sucesso'
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@servicos_bp.route('/api/servicos/<int:id>', methods=['PUT'])
@login_required
def update_servico(id):
    """Atualiza um serviço existente."""
    servico = Servico.query.get(id)
    if not servico:
        return jsonify({'error': 'Serviço não encontrado'}), 404
        
    data = request.get_json()
    servico.nome = data.get('nome', servico.nome)
    servico.descricao = data.get('descricao', servico.descricao)
    servico.duracao_minutos = data.get('duracao_minutos', servico.duracao_minutos)
    servico.preco = data.get('preco', servico.preco)
    servico.categoria = data.get('categoria', servico.categoria)
    
    db.session.commit()
    return jsonify({'message': 'Serviço atualizado com sucesso'})

@servicos_bp.route('/api/servicos/<int:id>', methods=['DELETE'])
@login_required
def delete_servico(id):
    """Exclui logicamente um serviço."""
    servico = Servico.query.get(id)
    if not servico:
        return jsonify({'error': 'Serviço não encontrado'}), 404
        
    # Soft Delete: apenas marca como inativo
    servico.ativo = False
    db.session.commit()
    return jsonify({'message': 'Serviço removido com sucesso'})
