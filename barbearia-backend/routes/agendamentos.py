# routes/agendamentos.py
from flask import Blueprint, jsonify, request
from datetime import datetime, timedelta
from models import db, Agendamento, Cliente, Servico
from utils.auth import login_required
from sqlalchemy import func

agendamentos_bp = Blueprint('agendamentos', __name__)

@agendamentos_bp.route('/api/agendamentos', methods=['GET'])
@login_required
def get_agendamentos():
    results = db.session.query(
        Agendamento, Cliente.nome, Servico.nome, Servico.ativo
    ).join(Cliente, Agendamento.cliente_id == Cliente.id)\
     .outerjoin(Servico, Agendamento.servico_id == Servico.id)\
     .order_by(Agendamento.data_hora.desc()).all()

    output = []
    for ag, cliente_nome, servico_nome, servico_ativo in results:
        d = ag.to_dict()
        d['cliente_nome'] = cliente_nome
        
        # Lógica para serviço excluído
        if servico_nome is None:
            d['servico_nome'] = "Serviço Removido"
        elif servico_ativo is False:
            d['servico_nome'] = f"{servico_nome} [Excluído]"
        else:
            d['servico_nome'] = servico_nome
            
        output.append(d)
        
    return jsonify(output)

@agendamentos_bp.route('/api/agendamentos', methods=['POST'])
@login_required
def create_agendamento():
    data = request.get_json()
    try:
        data_hora_str = data['data_hora'].replace('Z', '')
        data_appt = datetime.fromisoformat(data_hora_str)
    except:
        return jsonify({'error': 'Data inválida'}), 400

    novo = Agendamento(
        cliente_id=data['cliente_id'],
        servico_id=data['servico_id'],
        data_hora=data_appt,
        observacoes=data.get('observacoes', ''),
        status='agendado'
    )
    db.session.add(novo)
    db.session.commit()
    return jsonify({'id': novo.id, 'message': 'Criado'}), 201

@agendamentos_bp.route('/api/agendamentos/<int:id>/concluir', methods=['PUT'])
@login_required
def concluir_agendamento(id):
    ag = Agendamento.query.get(id)
    if not ag: return jsonify({'error': '404'}), 404
    ag.status = 'concluido'
    db.session.commit()
    return jsonify({'message': 'OK'})

@agendamentos_bp.route('/api/agendamentos/<int:id>/cancelar', methods=['PUT'])
@login_required
def cancelar_agendamento(id):
    ag = Agendamento.query.get(id)
    if not ag: return jsonify({'error': '404'}), 404
    ag.status = 'cancelado'
    db.session.commit()
    return jsonify({'message': 'OK'})

@agendamentos_bp.route('/api/agenda/hoje', methods=['GET'])
@login_required
def get_agenda_hoje():
    hoje_str = datetime.now().strftime('%Y-%m-%d')
    results = db.session.query(
        Agendamento, Cliente.nome, Servico.nome, Cliente.telefone, Servico.ativo
    ).join(Cliente, Agendamento.cliente_id == Cliente.id)\
     .outerjoin(Servico, Agendamento.servico_id == Servico.id)\
     .filter(func.date(Agendamento.data_hora) == hoje_str)\
     .filter(Agendamento.status == 'agendado')\
     .order_by(Agendamento.data_hora).all()

    output = []
    for ag, c_nome, s_nome, c_tel, s_ativo in results:
        d = ag.to_dict()
        d['cliente_nome'] = c_nome
        d['cliente_telefone'] = c_tel
        
        if s_nome is None:
            d['servico_nome'] = "Serviço Removido"
        elif s_ativo is False:
            d['servico_nome'] = f"{s_nome} [Excluído]"
        else:
            d['servico_nome'] = s_nome
            
        output.append(d)
    return jsonify(output)

@agendamentos_bp.route('/api/agenda/dashboard', methods=['GET'])
@login_required
def get_dashboard():
    period = request.args.get('period', 'today')
    hoje = datetime.now().date()
    hoje_str = hoje.strftime('%Y-%m-%d')
    
    # Busca os dados base
    query = db.session.query(Agendamento, Servico.preco).join(Servico)
    
    if period == 'weekly':
        uma_semana_atras = hoje - timedelta(days=7)
        uma_semana_str = uma_semana_atras.strftime('%Y-%m-%d')
        query = query.filter(func.date(Agendamento.data_hora) >= uma_semana_str)
    else:
        query = query.filter(func.date(Agendamento.data_hora) == hoje_str)

    results = query.filter(Agendamento.status != 'cancelado').all()
    
    # Processa os totais manualmente para evitar conflitos do Python 3.14 com SQLAlchemy Core
    total = len(results)
    concluidos = sum(1 for r in results if r[0].status == 'concluido')
    f_estimado = sum(r[1] for r in results)
    f_real = sum(r[1] for r in results if r[0].status == 'concluido')
    
    return jsonify({
        'total_agendamentos': total,
        'agendamentos_concluidos': concluidos,
        'faturamento_estimado': float(f_estimado),
        'faturamento_real': float(f_real),
        'period': period
    })
