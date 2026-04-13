# tests/test_cliente.py
# Testes para o modelo Cliente

import pytest
from datetime import datetime
from models import Cliente, db

def test_cliente_creation(database):
    """Testa a criação de um cliente."""
    cliente = Cliente(nome="João Silva", telefone="(11) 99999-9999")

    assert cliente.nome == "João Silva"
    assert cliente.telefone == "(11) 99999-9999"
    assert cliente.id is None  # Ainda não foi persistido

    # Persiste no banco
    db.session.add(cliente)
    db.session.commit()

    assert cliente.id is not None
    assert isinstance(cliente.id, int)
    assert cliente.data_cadastro is not None
    assert isinstance(cliente.data_cadastro, datetime)

def test_cliente_required_fields(database):
    """Testa que o campo nome é obrigatório."""
    # Deve falhar sem nome
    cliente = Cliente(telefone="(11) 99999-9999")
    db.session.add(cliente)

    with pytest.raises(Exception):
        db.session.commit()

    db.session.rollback()

def test_cliente_to_dict(database):
    """Testa o método to_dict()."""
    cliente = Cliente(nome="Maria Santos", telefone="(11) 98888-8888")
    db.session.add(cliente)
    db.session.commit()

    cliente_dict = cliente.to_dict()

    assert cliente_dict['id'] == cliente.id
    assert cliente_dict['nome'] == "Maria Santos"
    assert cliente_dict['telefone'] == "(11) 98888-8888"
    assert 'data_cadastro' in cliente_dict
    assert cliente_dict['data_cadastro'] is not None

def test_cliente_repr(database):
    """Testa a representação do cliente."""
    cliente = Cliente(nome="Pedro Oliveira", telefone="(11) 97777-7777")
    db.session.add(cliente)
    db.session.commit()

    repr_str = repr(cliente)
    assert "Cliente" in repr_str
    assert str(cliente.id) in repr_str
    assert "Pedro Oliveira" in repr_str

def test_cliente_without_phone(database):
    """Testa criação de cliente sem telefone."""
    cliente = Cliente(nome="Ana Costa")
    db.session.add(cliente)
    db.session.commit()

    assert cliente.nome == "Ana Costa"
    assert cliente.telefone is None
    assert cliente.id is not None

def test_cliente_query(database, sample_cliente):
    """Testa consulta de clientes."""
    # Busca o cliente criado pela fixture
    cliente_db = Cliente.query.get(sample_cliente.id)

    assert cliente_db is not None
    assert cliente_db.id == sample_cliente.id
    assert cliente_db.nome == sample_cliente.nome
    assert cliente_db.telefone == sample_cliente.telefone

def test_cliente_update(database):
    """Testa atualização de cliente."""
    cliente = Cliente(nome="Original", telefone="(11) 11111-1111")
    db.session.add(cliente)
    db.session.commit()

    # Atualiza
    cliente.nome = "Atualizado"
    cliente.telefone = "(11) 22222-2222"
    db.session.commit()

    # Busca novamente
    cliente_db = Cliente.query.get(cliente.id)
    assert cliente_db.nome == "Atualizado"
    assert cliente_db.telefone == "(11) 22222-2222"

def test_cliente_delete(database):
    """Testa exclusão de cliente."""
    cliente = Cliente(nome="Para Excluir", telefone="(11) 33333-3333")
    db.session.add(cliente)
    db.session.commit()

    cliente_id = cliente.id

    # Exclui
    db.session.delete(cliente)
    db.session.commit()

    # Verifica que foi excluído
    cliente_db = Cliente.query.get(cliente_id)
    assert cliente_db is None

def test_multiple_clientes(database):
    """Testa criação de múltiplos clientes."""
    clientes = [
        Cliente(nome=f"Cliente {i}", telefone=f"(11) 99999-{i:04d}")
        for i in range(5)
    ]

    for cliente in clientes:
        db.session.add(cliente)

    db.session.commit()

    # Verifica que todos foram criados
    todos_clientes = Cliente.query.all()
    assert len(todos_clientes) == 5

    # Verifica os nomes
    nomes = [c.nome for c in todos_clientes]
    for i in range(5):
        assert f"Cliente {i}" in nomes