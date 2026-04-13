# models/__init__.py
# Inicialização do pacote de modelos

from flask_sqlalchemy import SQLAlchemy

# Inicializa o objeto SQLAlchemy
db = SQLAlchemy()

# Importa os modelos para que sejam registrados com SQLAlchemy
from .cliente import Cliente
from .servico import Servico
from .agendamento import Agendamento
from .push_token import PushToken
from .usuario import Usuario
from .configuracao import Configuracao
from .despesa import Despesa

__all__ = ['db', 'Cliente', 'Servico', 'Agendamento', 'PushToken', 'Usuario', 'Configuracao', 'Despesa']