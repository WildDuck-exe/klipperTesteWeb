# models/barbearia.py
# Modelo para dados do estabelecimento (barbearia/salão)

from . import db

class Barbearia(db.Model):
    """Modelo para dados da barbearia do usuário admin."""

    __tablename__ = 'barbearias'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    usuario_id = db.Column(db.Integer, db.ForeignKey('usuarios.id'), nullable=False, unique=True)
    nome = db.Column(db.String(100), nullable=False)
    telefone = db.Column(db.String(20))
    endereco = db.Column(db.String(255))
    logo_path = db.Column(db.String(255))
    criado_em = db.Column(db.DateTime, default=db.func.current_timestamp())
    atualizado_em = db.Column(db.DateTime, default=db.func.current_timestamp(), onupdate=db.func.current_timestamp())

    def to_dict(self):
        return {
            'id': self.id,
            'usuario_id': self.usuario_id,
            'nome': self.nome,
            'telefone': self.telefone,
            'endereco': self.endereco,
            'logo_path': self.logo_path,
            'criado_em': self.criado_em.isoformat() if self.criado_em else None,
            'atualizado_em': self.atualizado_em.isoformat() if self.atualizado_em else None,
        }

    def __repr__(self):
        return f'<Barbearia {self.id}: {self.nome}>'