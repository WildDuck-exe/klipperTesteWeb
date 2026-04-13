# models/configuracao.py
from . import db
from datetime import datetime

class Configuracao(db.Model):
    __tablename__ = 'configuracoes'
    
    id = db.Column(db.Integer, primary_key=True)
    chave = db.Column(db.String(50), unique=True, nullable=False)
    valor = db.Column(db.String(255), nullable=False)
    descricao = db.Column(db.String(255))
    atualizado_em = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            'chave': self.chave,
            'valor': self.valor,
            'descricao': self.descricao,
            'atualizado_em': self.atualizado_em.isoformat() if self.atualizado_em else None
        }
