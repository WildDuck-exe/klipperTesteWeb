# routes/configuracao.py
from flask import Blueprint, jsonify, request
from models import db, Configuracao
import datetime

config_bp = Blueprint('config', __name__)

@config_bp.route('/api/config', methods=['GET'])
def get_configs():
    """Retorna todas as configurações."""
    configs = Configuracao.query.all()
    return jsonify({c.chave: c.valor for c in configs})

@config_bp.route('/api/config', methods=['POST'])
def update_configs():
    """Atualiza múltiplas configurações."""
    data = request.get_json()
    if not data:
        return jsonify({'error': 'Dados não fornecidos'}), 400

    for chave, valor in data.items():
        config = Configuracao.query.filter_by(chave=chave).first()
        if config:
            config.valor = str(valor)
        else:
            config = Configuracao(chave=chave, valor=str(valor))
            db.session.add(config)
    
    try:
        db.session.commit()
        return jsonify({'message': 'Configurações atualizadas com sucesso'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500
