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
    """Calcula horários disponíveis para uma data e serviço específicos.
    Consulta AMBAS as fontes (SQLite + Supabase) para garantir consistência."""
    data_str = request.args.get('data') # Formato: YYYY-MM-DD
    servico_id = request.args.get('servico_id')

    if not data_str or not servico_id:
        return jsonify({'error': 'Parâmetros data e servico_id são obrigatórios'}), 400

    try:
        data_consulta = datetime.strptime(data_str, '%Y-%m-%d').date()
        servico = Servico.query.get(servico_id)
        duracao = servico.duracao_minutos if servico else 30
    except ValueError:
        return jsonify({'error': 'Formato de data inválido. Use YYYY-MM-DD'}), 400

    # Busca horários de início e fim nas configurações
    conf_inicio = Configuracao.query.filter_by(chave='horario_inicio').first()
    conf_fim = Configuracao.query.filter_by(chave='horario_fim').first()
    
    inicio_hora = int(conf_inicio.valor.split(':')[0]) if conf_inicio else 8
    fim_hora = int(conf_fim.valor.split(':')[0]) if conf_fim else 18
    
    # Gera slots (ex: de 30 em 30 minutos)
    slots = []
    atual = datetime.combine(data_consulta, datetime.min.time()).replace(hour=inicio_hora)
    fim = datetime.combine(data_consulta, datetime.min.time()).replace(hour=fim_hora)

    # ── Fonte 1: SQLite local (agendamentos do APK) ──────────────────────────
    agendamentos_existentes = Agendamento.query.filter(
        db.func.date(Agendamento.data_hora) == data_str,
        Agendamento.status == 'agendado'  # Só 'agendado' bloqueia — cancelado/concluído libera
    ).all()

    ocupados = []
    for ag in agendamentos_existentes:
        inicio_oc = ag.data_hora
        duracao_oc = ag.servico.duracao_minutos if ag.servico else 30
        fim_oc = inicio_oc + timedelta(minutes=duracao_oc)
        ocupados.append((inicio_oc, fim_oc))

    # ── Fonte 2: Supabase (agendamentos do ChatWeb) ──────────────────────────
    try:
        from supabase_client import get_supabase
        sb = get_supabase()
        result = sb.table('agendamentos').select('data_hora, servico_id').eq('status', 'agendado').execute()
        
        for row in (result.data or []):
            try:
                dt = datetime.fromisoformat(row['data_hora'].replace('Z', '+00:00').replace('+00:00', ''))
                if dt.date() == data_consulta:
                    # Busca duração do serviço diretamente do Supabase
                    sid = row.get('servico_id')
                    d_oc = 30
                    if sid:
                        s_result = sb.table('servicos').select('duracao_minutos').eq('id', sid).execute()
                        if s_result.data:
                            d_oc = s_result.data[0]['duracao_minutos']
                    f_oc = dt + timedelta(minutes=d_oc)
                    
                    # Evita duplicatas (mesmo horário já pode estar no SQLite)
                    ja_existe = any(abs((oc[0] - dt).total_seconds()) < 60 for oc in ocupados)
                    if not ja_existe:
                        ocupados.append((dt, f_oc))
            except Exception:
                continue
    except Exception as e:
        print(f"[Horários] ⚠️ Erro ao consultar Supabase: {e}")

    while atual < fim:
        agora = datetime.now()
        is_past = atual < agora

        if not is_past:
            # Verifica se o novo slot sobrepõe algum ocupado
            novo_inicio = atual
            novo_fim = atual + timedelta(minutes=duracao)
            
            sobrepoe = False
            for oc_inicio, oc_fim in ocupados:
                if novo_inicio < oc_fim and novo_fim > oc_inicio:
                    sobrepoe = True
                    break
            
            if not sobrepoe:
                slots.append(atual.strftime('%H:%M'))
        
        atual += timedelta(minutes=30)

    return jsonify({
        'data': data_str,
        'disponiveis': slots
    })

@public_bp.route('/api/public/agendar', methods=['POST'])
def post_agendar_public():
    """Cria um agendamento, sincroniza com Supabase e dispara notificação push."""
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
    
    # Fallback: se o serviço não existe no SQLite, busca no Supabase
    # (ChatWeb carrega serviços do Supabase, cujos IDs podem diferir do SQLite)
    duracao = 30
    servico_nome_fallback = None
    if not servico:
        try:
            from supabase_client import get_supabase
            sb = get_supabase()
            result = sb.table('servicos').select('*').eq('id', data['servico_id']).execute()
            if result.data:
                sup_servico = result.data[0]
                duracao = sup_servico.get('duracao_minutos', 30)
                servico_nome_fallback = sup_servico.get('nome', 'Serviço')
                print(f"[Agendar] Serviço ID {data['servico_id']} encontrado no Supabase: {servico_nome_fallback}")
            else:
                return jsonify({'error': 'Serviço não encontrado'}), 404
        except Exception as e:
            print(f"[Agendar] ⚠️ Erro ao buscar serviço no Supabase: {e}")
            return jsonify({'error': 'Serviço não encontrado'}), 404
    else:
        duracao = servico.duracao_minutos
    
    # Busca agendamentos para o mesmo dia e status 'agendado'
    agendamentos_dia = Agendamento.query.filter(
        db.func.date(Agendamento.data_hora) == data_hora.strftime('%Y-%m-%d'),
        Agendamento.status == 'agendado'
    ).all()
    
    for ag in agendamentos_dia:
        # Verifica sobreposição de horários
        duracao_ag_existente = ag.servico.duracao_minutos if ag.servico else 30
        if data_hora < ag.data_hora + timedelta(minutes=duracao_ag_existente) and \
           ag.data_hora < data_hora + timedelta(minutes=duracao):
            print(f"⚠️ CONFLITO DETECTADO: {data_hora} colide com agendamento ID {ag.id} às {ag.data_hora}")
            return jsonify({'error': 'Desculpe, este horário acabou de ser preenchido. Por favor, escolha outro.'}), 409

    # 3. Cria o agendamento no SQLite
    novo_agendamento = Agendamento(
        cliente_id=cliente.id,
        servico_id=data['servico_id'],
        data_hora=data_hora,
        observacoes=data.get('observacoes', '')
    )

    db.session.add(novo_agendamento)
    
    try:
        db.session.commit()
        
        # ── 4. Sincroniza com Supabase (mantém nuvem atualizada) ──────────
        try:
            from supabase_client import get_supabase
            sb = get_supabase()
            
            # Busca ou cria cliente no Supabase
            existing = sb.table('clientes').select('id').eq('telefone', data['telefone']).execute()
            if existing.data:
                supabase_cliente_id = existing.data[0]['id']
            else:
                result = sb.table('clientes').insert({
                    'nome': data['nome'],
                    'telefone': data['telefone']
                }).execute()
                supabase_cliente_id = result.data[0]['id']
            
            # Sincroniza agendamento usando o ID do Supabase (não o do SQLite)
            sb.table('agendamentos').insert({
                'cliente_id': supabase_cliente_id,
                'servico_id': data['servico_id'],
                'data_hora': data['data_hora'],
                'status': 'agendado'
            }).execute()
            print(f"[Supabase] ✅ Agendamento sincronizado com a nuvem.")
        except Exception as sync_err:
            # Não falha o endpoint se Supabase der erro — SQLite já salvou
            print(f"[Supabase] ⚠️ Erro ao sincronizar: {sync_err}")

        # ── 5. Dispara notificação Push (FCM) ─────────────────────────────
        from utils.notifications import enviar_notificacao_novo_agendamento
        
        nome_servico = servico.nome if servico else (servico_nome_fallback or 'Serviço')
        notificado = enviar_notificacao_novo_agendamento(
            cliente_nome=cliente.nome,
            servico_nome=nome_servico,
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

@public_bp.route('/api/public/config', methods=['GET'])
def get_config_public():
    """
    Retorna configurações públicas usadas pelo bot WhatsApp e pelo ChatWeb.
    Não expõe dados sensíveis — apenas mensagens e URLs configuráveis.
    """
    configuracoes = Configuracao.query.all()
    config_map = {c.chave: c.valor for c in configuracoes}

    return jsonify({
        'whatsapp_mensagem': config_map.get('whatsapp_mensagem', 'Olá! Para agendar um horário, acesse o link abaixo 👇'),
        'chatweb_url':       config_map.get('chatweb_url', 'https://chat.klipper.app'),
        'horario_inicio':    config_map.get('horario_inicio', '08:00'),
        'horario_fim':      config_map.get('horario_fim', '18:00'),
    })

@public_bp.route('/api/public/notificar-agendamento', methods=['POST'])
def notificar_agendamento():
    """Endpoint para o chat notificar o barbeiro via push (legado)."""
    data = request.get_json()
    if not data:
        return jsonify({'error': 'Dados não fornecidos'}), 400

    cliente_nome = data.get('cliente_nome', 'Cliente')
    servico_nome = data.get('servico_nome', 'Serviço')
    data_hora_fmt = data.get('data_hora_fmt', '')

    from utils.notifications import enviar_notificacao_novo_agendamento
    sucesso = enviar_notificacao_novo_agendamento(cliente_nome, servico_nome, data_hora_fmt)
    
    return jsonify({'success': sucesso}), 200
