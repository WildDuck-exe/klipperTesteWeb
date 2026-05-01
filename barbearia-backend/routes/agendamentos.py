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
    _update_status_both_db(id, 'concluido')
    return jsonify({'message': 'OK'})

@agendamentos_bp.route('/api/agendamentos/<int:id>/cancelar', methods=['PUT'])
@login_required
def cancelar_agendamento(id):
    _update_status_both_db(id, 'cancelado')
    return jsonify({'message': 'OK'})


def _update_status_both_db(supabase_id, novo_status):
    """Atualiza o status tanto no Supabase quanto no SQLite.
       O frontend envia o ID do Supabase."""
    try:
        from supabase_client import get_supabase
        sb = get_supabase()

        # 1. Atualiza no Supabase
        result = sb.table('agendamentos').update({'status': novo_status}).eq('id', supabase_id).execute()
        
        data_hora_str = None
        if result.data:
            data_hora_str = result.data[0].get('data_hora')
            print(f"[Sync] Supabase ID {supabase_id} atualizado para {novo_status}.")
        else:
            print(f"[Sync] ⚠️ Supabase ID {supabase_id} não encontrado. Tentando como ID local...")
            # Fallback caso seja um ID do SQLite
            ag = Agendamento.query.get(supabase_id)
            if ag:
                data_hora_str = ag.data_hora.isoformat()
                ag.status = novo_status
                db.session.commit()
                print(f"[Sync] SQLite ID {supabase_id} atualizado via fallback.")
                return

        # 2. Atualiza no SQLite buscando pela data_hora
        if data_hora_str:
            # Parse da string do Supabase (ex: '2026-04-27T12:00:00+00:00')
            try:
                dt_str_clean = data_hora_str.replace('Z', '+00:00')
                if '+' in dt_str_clean:
                    dt_str_clean = dt_str_clean.split('+')[0]
                dt = datetime.fromisoformat(dt_str_clean)
                
                # Busca iterando para evitar problemas de fuso horário no SQLite
                local_ags = Agendamento.query.filter(Agendamento.status != novo_status).all()
                for a in local_ags:
                    if a.data_hora.strftime('%Y-%m-%d %H:%M') == dt.strftime('%Y-%m-%d %H:%M'):
                        a.status = novo_status
                        db.session.commit()
                        print(f"[Sync] SQLite ID {a.id} sincronizado para {novo_status}.")
                        break
            except Exception as e:
                print(f"[Sync] ⚠️ Erro ao buscar SQLite por data_hora: {e}")

    except Exception as e:
        print(f"[Sync] ⚠️ Erro geral na sincronização: {e}")

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
