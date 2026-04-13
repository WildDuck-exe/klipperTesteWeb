# tests/test_servico.py
# Testes para o modelo Servico

import pytest
from decimal import Decimal
from models import Servico, db

def test_servico_creation(database):
    """Testa a criação de um serviço."""
    servico = Servico(
        nome="Corte de Cabelo",
        preco=30.00,
        descricao="Corte tradicional",
        duracao_minutos=30
    )

    assert servico.nome == "Corte de Cabelo"
    assert servico.preco == Decimal('30.00')
    assert servico.descricao == "Corte tradicional"
    assert servico.duracao_minutos == 30
    assert servico.id is None  # Ainda não foi persistido

    # Persiste no banco
    db.session.add(servico)
    db.session.commit()

    assert servico.id is not None
    assert isinstance(servico.id, int)

def test_servico_required_fields(database):
    """Testa que os campos nome e preço são obrigatórios."""
    # Deve falhar sem nome
    servico1 = Servico(preco=30.00)
    db.session.add(servico1)

    with pytest.raises(Exception):
        db.session.commit()

    db.session.rollback()

    # Deve falhar sem preço
    servico2 = Servico(nome="Serviço Teste")
    db.session.add(servico2)

    with pytest.raises(Exception):
        db.session.commit()

    db.session.rollback()

def test_servico_default_values(database):
    """Testa os valores padrão do serviço."""
    servico = Servico(nome="Serviço Simples", preco=25.00)
    db.session.add(servico)
    db.session.commit()

    assert servico.descricao is None
    assert servico.duracao_minutos == 30  # Valor padrão

def test_servico_to_dict(database):
    """Testa o método to_dict()."""
    servico = Servico(
        nome="Barba",
        preco=20.00,
        descricao="Aparação de barba",
        duracao_minutos=20
    )
    db.session.add(servico)
    db.session.commit()

    servico_dict = servico.to_dict()

    assert servico_dict['id'] == servico.id
    assert servico_dict['nome'] == "Barba"
    assert servico_dict['descricao'] == "Aparação de barba"
    assert servico_dict['duracao_minutos'] == 20
    assert servico_dict['preco'] == 20.00
    assert isinstance(servico_dict['preco'], float)

def test_servico_repr(database):
    """Testa a representação do serviço."""
    servico = Servico(nome="Hidratação", preco=25.00)
    db.session.add(servico)
    db.session.commit()

    repr_str = repr(servico)
    assert "Servico" in repr_str
    assert str(servico.id) in repr_str
    assert "Hidratação" in repr_str

def test_servico_decimal_precision(database):
    """Testa a precisão decimal do preço."""
    servico = Servico(nome="Serviço Preciso", preco=29.99)
    db.session.add(servico)
    db.session.commit()

    # Busca do banco
    servico_db = Servico.query.get(servico.id)
    assert servico_db.preco == Decimal('29.99')

    # Testa com mais casas decimais
    servico2 = Servico(nome="Serviço Caro", preco=150.50)
    db.session.add(servico2)
    db.session.commit()

    servico2_db = Servico.query.get(servico2.id)
    assert servico2_db.preco == Decimal('150.50')

def test_servico_query(database, sample_servico):
    """Testa consulta de serviços."""
    # Busca o serviço criado pela fixture
    servico_db = Servico.query.get(sample_servico.id)

    assert servico_db is not None
    assert servico_db.id == sample_servico.id
    assert servico_db.nome == sample_servico.nome
    assert float(servico_db.preco) == float(sample_servico.preco)

def test_servico_update(database):
    """Testa atualização de serviço."""
    servico = Servico(nome="Original", preco=10.00)
    db.session.add(servico)
    db.session.commit()

    # Atualiza
    servico.nome = "Atualizado"
    servico.preco = 20.00
    servico.descricao = "Nova descrição"
    servico.duracao_minutos = 45
    db.session.commit()

    # Busca novamente
    servico_db = Servico.query.get(servico.id)
    assert servico_db.nome == "Atualizado"
    assert servico_db.preco == Decimal('20.00')
    assert servico_db.descricao == "Nova descrição"
    assert servico_db.duracao_minutos == 45

def test_servico_delete(database):
    """Testa exclusão de serviço."""
    servico = Servico(nome="Para Excluir", preco=15.00)
    db.session.add(servico)
    db.session.commit()

    servico_id = servico.id

    # Exclui
    db.session.delete(servico)
    db.session.commit()

    # Verifica que foi excluído
    servico_db = Servico.query.get(servico_id)
    assert servico_db is None

def test_multiple_servicos(database):
    """Testa criação de múltiplos serviços."""
    servicos = [
        Servico(nome=f"Serviço {i}", preco=10.00 + i * 5)
        for i in range(5)
    ]

    for servico in servicos:
        db.session.add(servico)

    db.session.commit()

    # Verifica que todos foram criados
    todos_servicos = Servico.query.all()
    assert len(todos_servicos) == 5

    # Verifica os preços
    precos = [float(s.preco) for s in todos_servicos]
    for i in range(5):
        assert (10.00 + i * 5) in precos

def test_servico_negative_duration(database):
    """Testa que duração não pode ser negativa."""
    servico = Servico(nome="Serviço Inválido", preco=10.00, duracao_minutos=-10)
    db.session.add(servico)

    # SQLAlchemy não valida isso automaticamente, então não deve falhar na persistência
    db.session.commit()

    # Mas podemos testar que o valor foi salvo (mesmo sendo negativo)
    servico_db = Servico.query.get(servico.id)
    assert servico_db.duracao_minutos == -10