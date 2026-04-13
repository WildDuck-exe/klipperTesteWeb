# routes/despesas.py
from flask import Blueprint, jsonify, request
from models import db, Despesa
from datetime import datetime

despesas_bp = Blueprint('despesas', __name__)

@despesas_bp.route('/api/despesas', methods=['GET'])
def get_despesas():
    """Lista todas as despesas."""
    despesas = Despesa.query.order_by(Despesa.data.desc()).all()
    return jsonify([d.to_dict() for d in despesas])

@despesas_bp.route('/api/despesas', methods=['POST'])
def create_despesa():
    """Cria uma nova despesa."""
    data = request.get_json()
    if not data or 'descricao' not in data or 'valor' not in data:
        return jsonify({'error': 'Descrição e valor são obrigatórios'}), 400

    try:
        data_obj = datetime.strptime(data.get('data'), '%Y-%m-%d').date() if data.get('data') else datetime.utcnow().date()
        
        nova_despesa = Despesa(
            descricao=data['descricao'],
            valor=float(data['valor']),
            data=data_obj,
            categoria=data.get('categoria', 'Geral')
        )
        db.session.add(nova_despesa)
        db.session.commit()
        return jsonify({'message': 'Despesa cadastrada!', 'id': nova_despesa.id}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@despesas_bp.route('/api/despesas/<int:id>', methods=['DELETE'])
def delete_despesa(id):
    """Remove uma despesa."""
    despesa = Despesa.query.get(id)
    if not despesa:
        return jsonify({'error': 'Despesa não encontrada'}), 404
    
    db.session.delete(despesa)
    db.session.commit()
    return jsonify({'message': 'Despesa removida'}), 200
