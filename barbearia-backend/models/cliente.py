# models/cliente.py
# Modelo SQLAlchemy para a tabela clientes

from datetime import datetime
from . import db

class Cliente(db.Model):
    """Modelo para a tabela clientes."""

    __tablename__ = 'clientes'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    nome = db.Column(db.String(100), nullable=False)
    telefone = db.Column(db.String(20))
    data_cadastro = db.Column(db.DateTime, default=datetime.utcnow)

    # Relacionamento com agendamentos
    agendamentos = db.relationship('Agendamento', backref='cliente', lazy=True, cascade='all, delete-orphan')

    def __init__(self, nome, telefone=None):
        """Inicializa um novo cliente."""
        self.nome = nome
        self.telefone = telefone

    def to_dict(self):
        """Converte o objeto para dicionário."""
        return {
            'id': self.id,
            'nome': self.nome,
            'telefone': self.telefone,
            'data_cadastro': self.data_cadastro.isoformat() if self.data_cadastro else None
        }

    def __repr__(self):
        """Representação do objeto."""
        return f'<Cliente {self.id}: {self.nome}>'