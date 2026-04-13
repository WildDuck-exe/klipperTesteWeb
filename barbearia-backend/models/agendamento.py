# models/agendamento.py
# Modelo SQLAlchemy para a tabela agendamentos

from datetime import datetime
from . import db

class Agendamento(db.Model):
    """Modelo para a tabela agendamentos."""

    __tablename__ = 'agendamentos'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    cliente_id = db.Column(db.Integer, db.ForeignKey('clientes.id'), nullable=False)
    servico_id = db.Column(db.Integer, db.ForeignKey('servicos.id'), nullable=False)
    data_hora = db.Column(db.DateTime, nullable=False)
    observacoes = db.Column(db.Text)
    status = db.Column(db.String(20), default='agendado')

    def __init__(self, cliente_id, servico_id, data_hora, observacoes=None, status='agendado'):
        """Inicializa um novo agendamento."""
        self.cliente_id = cliente_id
        self.servico_id = servico_id
        self.data_hora = data_hora
        self.observacoes = observacoes
        self.status = status

    def to_dict(self):
        """Converte o objeto para dicionário."""
        return {
            'id': self.id,
            'cliente_id': self.cliente_id,
            'servico_id': self.servico_id,
            'data_hora': self.data_hora.isoformat() if self.data_hora else None,
            'observacoes': self.observacoes,
            'status': self.status
        }

    def __repr__(self):
        """Representação do objeto."""
        return f'<Agendamento {self.id}: cliente={self.cliente_id}, servico={self.servico_id}, data={self.data_hora}>'