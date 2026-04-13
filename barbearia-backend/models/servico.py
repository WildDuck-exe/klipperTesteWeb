# models/servico.py
# Modelo SQLAlchemy para a tabela servicos

from . import db

class Servico(db.Model):
    """Modelo para a tabela servicos."""

    __tablename__ = 'servicos'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    nome = db.Column(db.String(100), nullable=False)
    descricao = db.Column(db.Text)
    duracao_minutos = db.Column(db.Integer, default=30)
    preco = db.Column(db.Numeric(10, 2), nullable=False)
    categoria = db.Column(db.String(50), default='Geral')
    ativo = db.Column(db.Boolean, default=True)

    # Relacionamento com agendamentos
    agendamentos = db.relationship('Agendamento', backref='servico', lazy=True, cascade='all, delete-orphan')

    def __init__(self, nome, preco, descricao=None, duracao_minutos=30, categoria='Geral', ativo=True):
        """Inicializa um novo serviço."""
        self.nome = nome
        self.preco = preco
        self.descricao = descricao
        self.duracao_minutos = duracao_minutos
        self.categoria = categoria
        self.ativo = ativo

    def to_dict(self):
        """Converte o objeto para dicionário."""
        return {
            'id': self.id,
            'nome': self.nome,
            'descricao': self.descricao,
            'duracao_minutos': self.duracao_minutos,
            'preco': float(self.preco) if self.preco else None,
            'categoria': self.categoria,
            'ativo': self.ativo
        }

    def __repr__(self):
        """Representação do objeto."""
        return f'<Servico {self.id}: {self.nome}>'