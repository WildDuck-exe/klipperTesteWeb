# tests/conftest.py
# Configuração do pytest para testes da Barbearia API

import os
import tempfile
import pytest
from datetime import datetime

from app import app as flask_app
from models import db, Cliente, Servico, Agendamento

@pytest.fixture
def app():
    """Cria uma aplicação Flask para testes."""
    # Cria um banco de dados temporário
    db_fd, db_path = tempfile.mkstemp(suffix='.db')

    flask_app.config.update({
        'TESTING': True,
        'SQLALCHEMY_DATABASE_URI': f'sqlite:///{db_path}',
        'SQLALCHEMY_TRACK_MODIFICATIONS': False
    })

    yield flask_app

    # Limpeza após os testes
    os.close(db_fd)
    os.unlink(db_path)

@pytest.fixture
def client(app):
    """Cria um cliente de teste para a aplicação."""
    return app.test_client()

@pytest.fixture
def runner(app):
    """Cria um runner de CLI para testes."""
    return app.test_cli_runner()

@pytest.fixture
def database(app):
    """Configura o banco de dados para testes."""
    with app.app_context():
        db.create_all()
        yield db
        db.session.remove()
        db.drop_all()

@pytest.fixture
def sample_cliente(database):
    """Cria um cliente de exemplo para testes."""
    cliente = Cliente(nome="Teste Cliente", telefone="(11) 99999-9999")
    db.session.add(cliente)
    db.session.commit()
    return cliente

@pytest.fixture
def sample_servico(database):
    """Cria um serviço de exemplo para testes."""
    servico = Servico(nome="Corte Teste", preco=30.00, descricao="Serviço de teste")
    db.session.add(servico)
    db.session.commit()
    return servico

@pytest.fixture
def sample_agendamento(database, sample_cliente, sample_servico):
    """Cria um agendamento de exemplo para testes."""
    agendamento = Agendamento(
        cliente_id=sample_cliente.id,
        servico_id=sample_servico.id,
        data_hora=datetime.now(),
        observacoes="Teste"
    )
    db.session.add(agendamento)
    db.session.commit()
    return agendamento