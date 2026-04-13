# routes/public.py
# Endpoints públicos para o Chat de Agendamento (sem necessidade de login)

from flask import Blueprint, jsonify, request
from models import db, Cliente, Servico, Agendamento, Configuracao
from datetime import datetime, timedelta
from utils.validation import limpar_telefone, validar_telefone
import os

public_bp = Blueprint('public', __name__)

@public_bp.route('/api/public/validate-phone', methods=['GET'])
def validate_phone():
    """Valida se um número de telefone tem formato válido."""
    telefone_bruto = request.args.get('telefone', '').strip()
    telefone = limpar_telefone(telefone_bruto)
    valido = validar_telefone(telefone)
    return jsonify({'valid': valido})

@public_bp.route('/api/public/cliente', methods=['GET'])
def get_cliente_by_telefone():
    """
    Verifica se um número de telefone já possui cadastro.
    Usado pelo chat para reconhecer clientes recorrentes.
    Retorna apenas nome e telefone — nenhum dado sensível ou histórico.
    """
    telefone_bruto = request.args.get('telefone', '').strip()
    telefone = limpar_telefone(telefone_bruto)

    if not telefone:
        return jsonify({'error': 'Parâmetro telefone é obrigatório'}), 400

    cliente = Cliente.query.filter_by(telefone=telefone).first()

    if not cliente:
        return jsonify({'encontrado': False}), 404

    return jsonify({
        'encontrado': True,
        'nome': cliente.nome,
        'telefone': cliente.telefone
    })

@public_bp.route('/api/public/servicos', methods=['GET'])
def get_servicos_public():
    """Retorna a lista de serviços ativos para o chat do cliente."""
    servicos = Servico.query.filter_by(ativo=True).all()
    return jsonify([s.to_dict() for s in servicos])

@public_bp.route('/api/public/horarios', methods=['GET'])
def get_horarios_public():
    """Calcula horários disponíveis para uma data e serviço específicos."""
    data_str = request.args.get('data') # Formato: YYYY-MM-DD
    servico_id = request.args.get('servico_id')

    if not data_str or not servico_id:
        return jsonify({'error': 'Parâmetros data e servico_id são obrigatórios'}), 400

    try:
        data_consulta = datetime.strptime(data_str, '%Y-%m-%d').date()
        servico = Servico.query.get(servico_id)
        if not servico:
            return jsonify({'error': 'Serviço não encontrado'}), 404
        
        duracao = servico.duracao_minutos
    except ValueError:
        return jsonify({'error': 'Formato de data inválido. Use YYYY-MM-DD'}), 400

    # Busca horários de início e fim nas configurações
    conf_inicio = Configuracao.query.filter_by(chave='horario_inicio').first()
    conf_fim = Configuracao.query.filter_by(chave='horario_fim').first()
    
    inicio_hora = int(conf_inicio.valor.split(':')[0]) if conf_inicio else 8
    fim_hora = int(conf_fim.valor.split(':')[0]) if conf_fim else 18
    
    # Gera slots de 30 em 30 minutos
    slots = []
    atual = datetime.combine(data_consulta, datetime.min.time()).replace(hour=inicio_hora)
    fim = datetime.combine(data_consulta, datetime.min.time()).replace(hour=fim_hora)

    # Busca agendamentos já existentes para este dia
    agendamentos_existentes = Agendamento.query.filter(
        db.func.date(Agendamento.data_hora) == data_consulta,
        Agendamento.status == 'agendado'
    ).all()

    horarios_ocupados = [a.data_hora for a in agendamentos_existentes]

    while atual < fim:
        # Se o horário atual não estiver ocupado e não for no passado (se for hoje)
        agora = datetime.now()
        is_past = atual < agora

        if not is_past:
            # Verifica se o slot está livre
            ocupado = False
            for ocupado_dt in horarios_ocupados:
                # Se o novo agendamento começa durante um agendamento existente
                # ou se um agendamento existente começa durante o novo
                if atual < ocupado_dt + timedelta(minutes=duracao) and ocupado_dt < atual + timedelta(minutes=duracao):
                    ocupado = True
                    break
            
            if not ocupado:
                slots.append(atual.strftime('%H:%M'))
        
        atual += timedelta(minutes=30)

    return jsonify({
        'data': data_str,
        'disponiveis': slots
    })

@public_bp.route('/api/public/agendar', methods=['POST'])
def post_agendar_public():
    """Cria um agendamento e dispara notificação push."""
    data = request.get_json()

    campos_obrigatorios = ['nome', 'telefone', 'servico_id', 'data_hora']
    if not data or not all(k in data for k in campos_obrigatorios):
        return jsonify({'error': 'Campos obrigatórios: nome, telefone, servico_id, data_hora'}), 400

    try:
        data_hora = datetime.fromisoformat(data['data_hora'])
    except ValueError:
        return jsonify({'error': 'Formato de data_hora inválido. Use ISO 8601'}), 400

    # 1. Busca ou cria o cliente pelo telefone
    cliente = Cliente.query.filter_by(telefone=data['telefone']).first()
    if not cliente:
        cliente = Cliente(nome=data['nome'], telefone=data['telefone'])
        db.session.add(cliente)
        db.session.commit()

    # 2. Verifica se o horário ainda está disponível (Proteção de Concorrência)
    servico = Servico.query.get(data['servico_id'])
    if not servico:
        return jsonify({'error': 'Serviço não encontrado'}), 404
        
    duracao = servico.duracao_minutos
    
    # Busca agendamentos para o mesmo dia e status 'agendado'
    agendamentos_dia = Agendamento.query.filter(
        db.func.date(Agendamento.data_hora) == data_hora.date(),
        Agendamento.status == 'agendado'
    ).all()
    
    for ag in agendamentos_dia:
        # Verifica sobreposição de horários
        duracao_ag_existente = ag.servico.duracao_minutos
        if data_hora < ag.data_hora + timedelta(minutes=duracao_ag_existente) and \
           ag.data_hora < data_hora + timedelta(minutes=duracao):
            print(f"⚠️ CONFLITO DETECTADO: Tentativa de agendamento em {data_hora} (Serviço {servico.nome}) colide com agendamento ID {ag.id} às {ag.data_hora}")
            return jsonify({'error': 'Desculpe, este horário acabou de ser preenchido. Por favor, escolha outro.'}), 409


    # 3. Cria o agendamento
    novo_agendamento = Agendamento(
        cliente_id=cliente.id,
        servico_id=data['servico_id'],
        data_hora=data_hora,
        observacoes=data.get('observacoes', '')
    )

    db.session.add(novo_agendamento)
    
    try:
        db.session.commit()
        
        # 3. Dispara notificação Push (Fase de implementação)
        from utils.notifications import enviar_notificacao_novo_agendamento
        
        servico = Servico.query.get(data['servico_id'])
        notificado = enviar_notificacao_novo_agendamento(
            cliente_nome=cliente.nome,
            servico_nome=servico.nome,
            data_hora_str=data_hora.strftime('%d/%m às %H:%M')
        )

        return jsonify({
            'message': 'Agendamento realizado com sucesso!',
            'agendamento_id': novo_agendamento.id,
            'notificacao_enviada': notificado
        }), 201

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Erro ao processar agendamento: {str(e)}'}), 500
