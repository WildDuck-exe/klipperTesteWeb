# utils/notifications.py
# Utilitário para envio de notificações push via Firebase Cloud Messaging (FCM)

import firebase_admin
from firebase_admin import credentials, messaging
import os

# Global para rastrear se o Firebase foi inicializado
_firebase_initialized = False

def init_firebase():
    """Inicializa o SDK do Firebase Admin."""
    global _firebase_initialized
    if _firebase_initialized:
        return True

    cred_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'firebase-service-account.json')

    if os.path.exists(cred_path):
        try:
            if not firebase_admin._apps:
                cred = credentials.Certificate(cred_path)
                firebase_admin.initialize_app(cred)
            _firebase_initialized = True
            print("[FCM] Firebase inicializado com sucesso.")
            return True
        except Exception as e:
            print(f"[FCM] Erro ao inicializar Firebase: {e}")
            return False
    else:
        print(f"[FCM] Aviso: Arquivo de credenciais não encontrado em {cred_path}.")
        return False

def enviar_notificacao_novo_agendamento(cliente_nome, servico_nome, data_hora_str):
    """Envia uma notificação push para todos os dispositivos registrados."""
    print(f"\n[FCM] 🔔 Iniciando tentativa de envio: {cliente_nome} - {servico_nome}")
    
    init_firebase()
    
    if not _firebase_initialized:
        print("[FCM] ❌ Falha: Firebase não inicializado.")
        return False

    # ✅ Busca tokens no Supabase
    try:
        from supabase_client import get_supabase
        result = get_supabase().table('push_tokens').select('token').execute()
        tokens = [r['token'] for r in result.data] if result.data else []
        print(f"[FCM] Tokens encontrados no Supabase: {len(tokens)}")
    except Exception as e:
        print(f'[FCM] ❌ Erro ao buscar tokens no Supabase: {e}')
        tokens = []

    if not tokens:
        print("[FCM] ⚠️ Nenhum token de dispositivo encontrado. O APK está logado?")
        return False

    message = messaging.MulticastMessage(
        notification=messaging.Notification(
            title='💈 Novo Agendamento!',
            body=f'{cliente_nome} agendou {servico_nome} para {data_hora_str}',
        ),
        android=messaging.AndroidConfig(
            priority='high',
            notification=messaging.AndroidNotification(
                channel_id='high_importance_channel',
                icon='stock_ticker_update',
                color='#007BFF'
            ),
        ),
        data={
            'tipo': 'novo_agendamento',
            'cliente': cliente_nome,
            'servico': servico_nome,
            'data_hora': data_hora_str,
        },
        tokens=tokens,
    )

    try:
        print(f"[FCM] Enviando para {len(tokens)} dispositivo(s)...")
        resp = messaging.send_multicast(message)
        print(f"[FCM] ✅ Resultado: {resp.success_count} sucesso, {resp.failure_count} falha.")
        
        # Coletar tokens mortos para limpeza
        tokens_mortos = []
        if resp.failure_count > 0:
            for i, res in enumerate(resp.responses):
                if not res.success:
                    erro_str = str(res.exception).lower()
                    print(f"[FCM] ⚠️ Falha no token {i}: {res.exception}")
                    # Token inválido/expirado — marcar para remoção
                    if any(k in erro_str for k in ['not found', 'unregistered', 'invalid', 'not a valid']):
                        tokens_mortos.append(tokens[i])
                        print(f"[FCM] 🗑️ Token {i} marcado para remoção (inválido).")

        # Limpar tokens mortos do Supabase
        if tokens_mortos:
            try:
                from supabase_client import get_supabase
                sb = get_supabase()
                for t in tokens_mortos:
                    sb.table('push_tokens').delete().eq('token', t).execute()
                print(f"[FCM] 🧹 {len(tokens_mortos)} token(s) morto(s) removido(s) do Supabase.")
            except Exception as cleanup_err:
                print(f"[FCM] ⚠️ Erro ao limpar tokens mortos: {cleanup_err}")
                    
        return resp.success_count > 0
    except Exception as e:
        print(f"[FCM] ❌ Erro crítico no envio: {e}")
        return False
