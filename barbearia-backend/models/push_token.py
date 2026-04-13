# models/push_token.py
# Modelo SQLAlchemy para a tabela push_tokens

from datetime import datetime
from . import db

class PushToken(db.Model):
    """Modelo para a tabela push_tokens (FCM)."""

    __tablename__ = 'push_tokens'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    token = db.Column(db.String(255), nullable=False, unique=True)
    dispositivo = db.Column(db.String(100))
    criado_em = db.Column(db.DateTime, default=datetime.utcnow)
    atualizado_em = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __init__(self, token, dispositivo=None):
        """Inicializa um novo token de push."""
        self.token = token
        self.dispositivo = dispositivo

    def to_dict(self):
        """Converte o objeto para dicionário."""
        return {
            'id': self.id,
            'token': self.token,
            'dispositivo': self.dispositivo,
            'criado_em': self.criado_em.isoformat() if self.criado_em else None
        }

    def __repr__(self):
        """Representação do objeto."""
        return f'<PushToken {self.id}: {self.dispositivo}>'
