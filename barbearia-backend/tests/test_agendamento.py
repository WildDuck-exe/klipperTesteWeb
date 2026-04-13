# tests/test_agendamento.py
# Testes para o modelo Agendamento

import pytest
from datetime import datetime, timedelta
from models import Agendamento, Cliente, Servico, db

def test_agendamento_creation(database, sample_cliente, sample_servico):
    """Testa a criação de um agendamento."""
    data_hora = datetime.now() + timedelta(days=1)

    agendamento = Agendamento(
        cliente_id=sample_cliente.id,
        servico_id=sample_servico.id,
        data_hora=data_hora,
        observacoes="Cliente preferencial",
        status="agendado"
    )

    assert agendamento.cliente_id == sample_cliente.id
    assert agendamento.servico_id == sample_servico.id
    assert agendamento.data_hora == data_hora
    assert agendamento.observacoes == "Cliente preferencial"
    assert agendamento.status == "agendado"
    assert agendamento.id is None  # Ainda não foi persistido

    # Persiste no banco
    db.session.add(agendamento)
    db.session.commit()

    assert agendamento.id is not None
    assert isinstance(agendamento.id, int)

def test_agendamento_required_fields(database, sample_cliente, sample_servico):
    """Testa que os campos obrigatórios são validados."""
    data_hora = datetime.now()

    # Deve falhar sem cliente_id
    agendamento1 = Agendamento(
        servico_id=sample_servico.id,
        data_hora=data_hora
    )
    db.session.add(agendamento1)

    with pytest.raises(Exception):
        db.session.commit()

    db.session.rollback()

    # Deve falhar sem servico_id
    agendamento2 = Agendamento(
        cliente_id=sample_cliente.id,
        data_hora=data_hora
    )
    db.session.add(agendamento2)

    with pytest.raises(Exception):
        db.session.commit()

    db.session.rollback()

    # Deve falhar sem data_hora
    agendamento3 = Agendamento(
        cliente_id=sample_cliente.id,
        servico_id=sample_servico.id
    )
    db.session.add(agendamento3)

    with pytest.raises(Exception):
        db.session.commit()

    db.session.rollback()

def test_agendamento_default_values(database, sample_cliente, sample_servico):
    """Testa os valores padrão do agendamento."""
    data_hora = datetime.now()

    agendamento = Agendamento(
        cliente_id=sample_cliente.id,
        servico_id=sample_servico.id,
        data_hora=data_hora
    )
    db.session.add(agendamento)
    db.session.commit()

    assert agendamento.observacoes is None
    assert agendamento.status == "agendado"  # Valor padrão

def test_agendamento_to_dict(database, sample_cliente, sample_servico):
    """Testa o método to_dict()."""
    data_hora = datetime.now()

    agendamento = Agendamento(
        cliente_id=sample_cliente.id,
        servico_id=sample_servico.id,
        data_hora=data_hora,
        observacoes="Teste",
        status="concluido"
    )
    db.session.add(agendamento)
    db.session.commit()

    agendamento_dict = agendamento.to_dict()

    assert agendamento_dict['id'] == agendamento.id
    assert agendamento_dict['cliente_id'] == sample_cliente.id
    assert agendamento_dict['servico_id'] == sample_servico.id
    assert agendamento_dict['observacoes'] == "Teste"
    assert agendamento_dict['status'] == "concluido"
    assert 'data_hora' in agendamento_dict
    assert agendamento_dict['data_hora'] is not None

def test_agendamento_repr(database, sample_cliente, sample_servico):
    """Testa a representação do agendamento."""
    data_hora = datetime.now()

    agendamento = Agendamento(
        cliente_id=sample_cliente.id,
        servico_id=sample_servico.id,
        data_hora=data_hora
    )
    db.session.add(agendamento)
    db.session.commit()

    repr_str = repr(agendamento)
    assert "Agendamento" in repr_str
    assert str(agendamento.id) in repr_str
    assert str(sample_cliente.id) in repr_str
    assert str(sample_servico.id) in repr_str

def test_agendamento_status_values(database, sample_cliente, sample_servico):
    """Testa diferentes valores de status."""
    data_hora = datetime.now()

    status_values = ['agendado', 'concluido', 'cancelado']

    for status in status_values:
        agendamento = Agendamento(
            cliente_id=sample_cliente.id,
            servico_id=sample_servico.id,
            data_hora=data_hora,
            status=status
        )
        db.session.add(agendamento)

    db.session.commit()

    # Verifica que todos foram criados
    agendamentos = Agendamento.query.all()
    assert len(agendamentos) == len(status_values)

    # Verifica os status
    status_salvos = [a.status for a in agendamentos]
    for status in status_values:
        assert status in status_salvos

def test_agendamento_query(database, sample_agendamento):
    """Testa consulta de agendamentos."""
    # Busca o agendamento criado pela fixture
    agendamento_db = Agendamento.query.get(sample_agendamento.id)

    assert agendamento_db is not None
    assert agendamento_db.id == sample_agendamento.id
    assert agendamento_db.cliente_id == sample_agendamento.cliente_id
    assert agendamento_db.servico_id == sample_agendamento.servico_id
    assert agendamento_db.data_hora == sample_agendamento.data_hora

def test_agendamento_update(database, sample_cliente, sample_servico):
    """Testa atualização de agendamento."""
    data_hora = datetime.now()

    agendamento = Agendamento(
        cliente_id=sample_cliente.id,
        servico_id=sample_servico.id,
        data_hora=data_hora
    )
    db.session.add(agendamento)
    db.session.commit()

    # Atualiza
    nova_data = data_hora + timedelta(days=2)
    agendamento.data_hora = nova_data
    agendamento.observacoes = "Remarcado"
    agendamento.status = "cancelado"
    db.session.commit()

    # Busca novamente
    agendamento_db = Agendamento.query.get(agendamento.id)
    assert agendamento_db.data_hora == nova_data
    assert agendamento_db.observacoes == "Remarcado"
    assert agendamento_db.status == "cancelado"

def test_agendamento_delete(database, sample_cliente, sample_servico):
    """Testa exclusão de agendamento."""
    data_hora = datetime.now()

    agendamento = Agendamento(
        cliente_id=sample_cliente.id,
        servico_id=sample_servico.id,
        data_hora=data_hora
    )
    db.session.add(agendamento)
    db.session.commit()

    agendamento_id = agendamento.id

    # Exclui
    db.session.delete(agendamento)
    db.session.commit()

    # Verifica que foi excluído
    agendamento_db = Agendamento.query.get(agendamento_id)
    assert agendamento_db is None

def test_agendamento_relationships(database):
    """Testa os relacionamentos do agendamento."""
    # Cria cliente e serviço
    cliente = Cliente(nome="Cliente Relacionamento", telefone="(11) 99999-9999")
    servico = Servico(nome="Serviço Relacionamento", preco=25.00)
    db.session.add(cliente)
    db.session.add(servico)
    db.session.commit()

    # Cria agendamento
    data_hora = datetime.now()
    agendamento = Agendamento(
        cliente_id=cliente.id,
        servico_id=servico.id,
        data_hora=data_hora
    )
    db.session.add(agendamento)
    db.session.commit()

    # Testa acesso através do relacionamento
    assert agendamento.cliente == cliente
    assert agendamento.servico == servico

    # Testa que o cliente tem o agendamento na lista
    assert len(cliente.agendamentos) == 1
    assert cliente.agendamentos[0] == agendamento

    # Testa que o serviço tem o agendamento na lista
    assert len(servico.agendamentos) == 1
    assert servico.agendamentos[0] == agendamento

def test_agendamento_cascade_delete(database):
    """Testa exclusão em cascata quando cliente é excluído."""
    # Cria cliente, serviço e agendamento
    cliente = Cliente(nome="Cliente Cascade", telefone="(11) 88888-8888")
    servico = Servico(nome="Serviço Cascade", preco=30.00)
    db.session.add(cliente)
    db.session.add(servico)
    db.session.commit()

    data_hora = datetime.now()
    agendamento = Agendamento(
        cliente_id=cliente.id,
        servico_id=servico.id,
        data_hora=data_hora
    )
    db.session.add(agendamento)
    db.session.commit()

    agendamento_id = agendamento.id

    # Exclui o cliente (deve excluir o agendamento em cascata)
    db.session.delete(cliente)
    db.session.commit()

    # Verifica que o agendamento foi excluído
    agendamento_db = Agendamento.query.get(agendamento_id)
    assert agendamento_db is None

    # Verifica que o serviço ainda existe
    servico_db = Servico.query.get(servico.id)
    assert servico_db is not None

def test_multiple_agendamentos(database, sample_cliente, sample_servico):
    """Testa criação de múltiplos agendamentos."""
    data_base = datetime.now()

    agendamentos = [
        Agendamento(
            cliente_id=sample_cliente.id,
            servico_id=sample_servico.id,
            data_hora=data_base + timedelta(hours=i),
            observacoes=f"Observação {i}"
        )
        for i in range(5)
    ]

    for agendamento in agendamentos:
        db.session.add(agendamento)

    db.session.commit()

    # Verifica que todos foram criados
    todos_agendamentos = Agendamento.query.all()
    assert len(todos_agendamentos) == 5

    # Verifica as observações
    observacoes = [a.observacoes for a in todos_agendamentos]
    for i in range(5):
        assert f"Observação {i}" in observacoes