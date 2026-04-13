# routes/clientes.py
# Endpoints para gerenciamento de clientes usando SQLAlchemy

from flask import Blueprint, jsonify, request
from models import db, Cliente
from utils.auth import login_required

clientes_bp = Blueprint('clientes', __name__)

@clientes_bp.route('/api/clientes', methods=['GET'])
@login_required
def get_clientes():
    """Retorna todos os clientes cadastrados."""
    clientes = Cliente.query.all()
    return jsonify([cliente.to_dict() for cliente in clientes])

@clientes_bp.route('/api/clientes/<int:id>', methods=['GET'])
@login_required
def get_cliente(id):
    """Busca um cliente específico pelo ID."""
    cliente = Cliente.query.get(id)
    if cliente is None:
        return jsonify({'error': 'Cliente não encontrado'}), 404
    return jsonify(cliente.to_dict())

@clientes_bp.route('/api/clientes', methods=['POST'])
@login_required
def create_cliente():
    """Cria um novo cliente."""
    data = request.get_json()
    if not data or 'nome' not in data:
        return jsonify({'error': 'Nome é obrigatório'}), 400
    
    telefone = limpar_telefone(data.get('telefone', ''))
    
    # Validação (opcional aqui se o barbeiro puder deixar sem telefone, mas se houver, deve ser válido)
    if telefone and not validar_telefone(telefone):
        return jsonify({'error': 'Telefone inválido. Use 11 dígitos.'}), 400

    novo_cliente = Cliente(
        nome=data['nome'],
        telefone=telefone
    )
    
    db.session.add(novo_cliente)
    try:
        db.session.commit()
        return jsonify({
            'id': novo_cliente.id,
            'message': 'Cliente criado com sucesso'
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500
