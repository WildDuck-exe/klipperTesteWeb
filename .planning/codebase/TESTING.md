# TESTING

## Visão Geral

Este documento descreve a estratégia de testes do projeto Barbearia (Ponto do Corte), incluindo frameworks, localizações de testes e práticas adotadas.

## Backend Testing (Python/Flask)

### Framework
- **Framework:** pytest
- **Localização:** `barbearia-backend/tests/`
- **Execução:** `cd barbearia-backend && python -m pytest`

### Estrutura de Testes
```
barbearia-backend/tests/
├── conftest.py           # Fixtures pytest compartilhadas
├── test_agendamento.py   # Testes para modelo Agendamento
├── test_cliente.py       # Testes para modelo Cliente
├── test_servico.py       # Testes para modelo Servico
└── test_init_db.py       # Testes para script de inicialização
```

### Fixtures (conftest.py)

O arquivo `conftest.py` define fixtures pytest para criação de ambiente de testes isolado:

```python
@pytest.fixture
def app():
    """Cria aplicação Flask com banco temporário."""
    # Cria banco SQLite temporário
    db_fd, db_path = tempfile.mkstemp(suffix='.db')
    flask_app.config.update({
        'TESTING': True,
        'SQLALCHEMY_DATABASE_URI': f'sqlite:///{db_path}',
    })
    yield flask_app
    # Limpeza
    os.close(db_fd)
    os.unlink(db_path)

@pytest.fixture
def client(app):
    """Cliente HTTP para testes de API."""
    return app.test_client()

@pytest.fixture
def database(app):
    """Banco de dados com schema criado."""
    with app.app_context():
        db.create_all()
        yield db
        db.session.remove()
        db.drop_all()

@pytest.fixture
def sample_cliente(database):
    """Cliente de exemplo para testes."""
    cliente = Cliente(nome="Teste Cliente", telefone="(11) 99999-9999")
    db.session.add(cliente)
    db.session.commit()
    return cliente

@pytest.fixture
def sample_servico(database):
    """Serviço de exemplo para testes."""
    servico = Servico(nome="Corte Teste", preco=30.00, descricao="Serviço de teste")
    db.session.add(servico)
    db.session.commit()
    return servico

@pytest.fixture
def sample_agendamento(database, sample_cliente, sample_servico):
    """Agendamento de exemplo para testes."""
    agendamento = Agendamento(
        cliente_id=sample_cliente.id,
        servico_id=sample_servico.id,
        data_hora=datetime.now(),
        observacoes="Teste"
    )
    db.session.add(agendamento)
    db.session.commit()
    return agendamento
```

### Testes de Modelo

#### Testes em test_cliente.py
- `test_cliente_creation` - Criação básica de cliente
- `test_cliente_required_fields` - Validação de campos obrigatórios
- `test_cliente_to_dict` - Serialização para dicionário
- `test_cliente_repr` - Representação string do objeto
- `test_cliente_without_phone` - Criação sem telefone
- `test_cliente_query` - Busca no banco
- `test_cliente_update` - Atualização de dados
- `test_cliente_delete` - Exclusão
- `test_multiple_clientes` - Criação em massa

#### Testes em test_servico.py
- `test_servico_creation` - Criação básica
- `test_servico_required_fields` - Validação
- `test_servico_default_values` - Valores padrão (duracao_minutos=30)
- `test_servico_to_dict` - Serialização
- `test_servico_decimal_precision` - Precisão decimal do preço
- `test_servico_update` - Atualização
- `test_servico_delete` - Exclusão
- `test_servico_negative_duration` - Validação de duração negativa

#### Testes em test_agendamento.py
- `test_agendamento_creation` - Criação básica
- `test_agendamento_required_fields` - Campos obrigatórios (cliente_id, servico_id, data_hora)
- `test_agendamento_default_values` - Status padrão ("agendado")
- `test_agendamento_to_dict` - Serialização

#### Testes em test_init_db.py
- `test_init_db_script_structure` - Verifica estrutura do script
- `test_init_db_imports` - Testa imports do módulo
- `test_init_database_function` - Testa função com mocks

### Exemplo de Teste
```python
def test_cliente_creation(database):
    """Testa a criação de um cliente."""
    cliente = Cliente(nome="João Silva", telefone="(11) 99999-9999")

    assert cliente.nome == "João Silva"
    assert cliente.telefone == "(11) 99999-9999"
    assert cliente.id is None  # Ainda não foi persistido

    db.session.add(cliente)
    db.session.commit()

    assert cliente.id is not None
    assert isinstance(cliente.id, int)
    assert cliente.data_cadastro is not None
```

### Execução de Testes Backend
```bash
# Todos os testes
cd barbearia-backend
python -m pytest

# Com verbose
python -m pytest -v

# Teste específico
python -m pytest tests/test_cliente.py -v

# Com coverage (requer pytest-cov)
python -m pytest --cov=. --cov-report=html
```

## Frontend Testing (Flutter)

### Framework
- **Framework:** flutter_test (incluído no SDK)
- **Localização:** `barbearia-frontend/test/`
- **Execução:** `cd barbearia-frontend && flutter test`

### Estrutura de Testes
```
barbearia-frontend/test/
└── widget_test.dart   # Teste placeholder (smoke test padrão)
```

### Teste Atual (widget_test.dart)
O projeto contém apenas o teste placeholder padrão do Flutter:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barbearia_frontend/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BarbeariaApp());

    // Verifica estado inicial
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Interage com widget
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verifica resultado
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
```

### Estado Atual dos Testes Frontend
- **Cobertura:** Mínima (apenas smoke test do template)
- **Necessário:** Implementar testes para:
  - Screens individuais (home_screen, clientes_screen, etc.)
  - Widgets customizados (agenda_card, magic_bottom_nav)
  - ApiService (mock de HTTP)
  - Fluxos de autenticação
  - Integração com Provider

### Execução de Testes Frontend
```bash
# Todos os testes
cd barbearia-frontend
flutter test

# Com verbose
flutter test --verbose

# Teste específico
flutter test test/widget_test.dart
```

## Scripts de Suporte ao Desenvolvimento

### Backend (barbearia-backend/scratch/)
Scripts auxiliares para teste e migração:
- `load_test.py` - Dados de teste
- `migrate_servicos.py` - Migração de dados

### Scripts Utilitários Disponíveis
```bash
# Inicializar banco com dados de exemplo
cd barbearia-backend
python init_db_simple.py

# Reset completo do banco
python init_db.py  # opções de reset
```

## Boas Práticas de Teste

### Backend
1. Cada fixture deve criar dadoslimpos (create_all no início, drop_all no fim)
2. Testes devem ser independentes (não dependem de ordem)
3. Usar `db.session.rollback()` após falhas esperadas
4. Nomes de testes descritivos: `test_<model>_<action>_<scenario>`

### Frontend
1. Usar `WidgetTester` para testes de widget
2. Mockar `ApiService` com `ChangeNotifierProvider`
3. Testar estados de loading, erro e sucesso
4. Testar interações do usuário (tap, scroll, input)

## Métricas e Cobertura

### Backend
- Testes de modelo cobrem CRUD completo
- Falta: testes de rotas/API (integração)
- Falta: testes de validação

### Frontend
- Cobertura muito baixa (apenas smoke test)
- Prioridade: testar screens e widgets principais

## Credenciais de Teste
```
Usuário: admin
Senha: admin123
```