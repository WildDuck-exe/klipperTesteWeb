# models/despesa.py
from . import db
from datetime import datetime

class Despesa(db.Model):
    __tablename__ = 'despesas'
    
    id = db.Column(db.Integer, primary_key=True)
    descricao = db.Column(db.String(100), nullable=False)
    valor = db.Column(db.Float, nullable=False)
    data = db.Column(db.Date, nullable=False, default=datetime.utcnow().date)
    categoria = db.Column(db.String(50), default='Geral')
    criado_em = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'descricao': self.descricao,
            'valor': self.valor,
            'data': self.data.isoformat(),
            'categoria': self.categoria,
            'criado_em': self.criado_em.isoformat()
        }
