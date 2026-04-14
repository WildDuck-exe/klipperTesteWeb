# models/usuario.py
# Modelo SQLAlchemy para a tabela usuarios

from . import db

class Usuario(db.Model):
    """Modelo para a tabela usuarios (Barbeiro)."""

    __tablename__ = 'usuarios'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(50), nullable=False, unique=True)
    email = db.Column(db.String(120), unique=True)
    nome_exibicao = db.Column(db.String(100))
    telefone = db.Column(db.String(20))
    senha_hash = db.Column(db.String(255), nullable=False)

    def __init__(self, username, senha_hash, email=None, nome_exibicao=None, telefone=None):
        """Inicializa um novo usuário."""
        self.username = username
        self.email = email
        self.nome_exibicao = nome_exibicao
        self.telefone = telefone
        self.senha_hash = senha_hash

    def to_dict(self):
        """Converte o objeto para dicionário."""
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email
        }

    def __repr__(self):
        """Representação do objeto."""
        return f'<Usuario {self.id}: {self.username}>'
