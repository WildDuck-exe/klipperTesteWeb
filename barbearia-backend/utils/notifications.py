# utils/notifications.py
# Utilitário para envio de notificações push via Firebase Cloud Messaging (FCM)

import firebase_admin
from firebase_admin import credentials, messaging
from models import PushToken
import os
from flask import current_app

# Global para rastrear se o Firebase foi inicializado
_firebase_initialized = False

def init_firebase():
    """Inicializa o SDK do Firebase Admin."""
    global _firebase_initialized
    if _firebase_initialized:
        return
    
    cred_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'firebase-service-account.json')
    
    if os.path.exists(cred_path):
        try:
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            _firebase_initialized = True
            print("Firebase inicializado com sucesso.")
        except Exception as e:
            print(f"Erro ao inicializar Firebase: {e}")
    else:
        print(f"Aviso: Arquivo de credenciais não encontrado em {cred_path}. Notificações push estarão desativadas.")

def enviar_notificacao_novo_agendamento(cliente_nome, servico_nome, data_hora_str):
    """Envia uma notificação push para todos os dispositivos registrados."""
    init_firebase()
    
    if not _firebase_initialized:
        return False

    # Busca todos os tokens registrados
    tokens_records = PushToken.query.all()
    tokens = [t.token for t in tokens_records]

    if not tokens:
        print("Nenhum token de push registrado no banco de dados.")
        return False

    message = messaging.MulticastMessage(
        notification=messaging.Notification(
            title='💈 Novo Agendamento!',
            body=f'{cliente_nome} agendou {servico_nome} para {data_hora_str}',
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
        response = messaging.send_multicast(message)
        print(f"Notificações enviadas: {response.success_count} sucesso, {response.failure_count} falha.")
        return response.success_count > 0
    except Exception as e:
        print(f"Erro ao enviar notificação multicast: {e}")
        return False
