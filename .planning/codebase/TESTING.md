# Estratégia de Testes — Ponto do Corte

## Princípio Base

A Regra Global Primária (Minimizar Requisições API) impacta diretamente a estratégia de testes: testes bem escritos na primeira execução evitam ciclos de correção que geram múltiplas requisições. Priorizar cobertura abrangente com execução eficiente.

## Stack de Ferramentas

| Camada | Ferramenta | Propósito |
|--------|------------|-----------|
| Backend | `pytest` | Testes unitários e integração |
| Backend | `pytest-cov` | Métrica de cobertura |
| Frontend | `flutter_test` | Testes unitários e de widgets |
| Frontend | `flutter_driver` (opcional) | Testes de integração |

## Backend (Python/Flask/SQLAlchemy)

### Estrutura de Testes
```
barbearia-backend/
  tests/
    __init__.py
    conftest.py          # Fixtures compartilhadas
    test_models/         # Testes de models SQLAlchemy
    test_routes/         # Testes de endpoints/Blueprints
    test_utils/          # Testes de utilitários
```

### Fixtures Principais (conftest.py)
- `client`: Cliente de teste Flask.
- `db_session`: Sessão SQLAlchemy isolada (rollback após cada teste).
- `auth_token`: Token JWT válido para endpoints protegidos.
- `app`: Instância configurada do app Flask em modo teste.

### O que Testar

#### Models
- Atributos de cada model (colunas, tipos, restrições).
- Relacionamentos (ForeignKey, backref).
- Validações (ex: horário não no passado).

#### Routes/Blueprints
- Cada endpoint: sucesso e falha.
- Autenticação: endpoints protegidos rejeitam token inválido.
- Validação de entrada: dados mal formatados retornam 400.
- Respostas JSON: estrutura e status code corretos.

### Exemplo de Teste de Model
```python
def test_agendamento_criacao(db_session):
    agendamento = Agendamento(
        cliente_id=1,
        servico_id=1,
        data_hora=datetime(2025, 1, 15, 10, 0),
        status="confirmado"
    )
    db_session.add(agendamento)
    db_session.commit()
    assert agendamento.id is not None
    assert agendamento.status == "confirmado"
```

### Exemplo de Teste de Route
```python
def test_listar_servicos(client, auth_token):
    response = client.get(
        "/api/v1/servicos",
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    assert response.status_code == 200
    data = response.get_json()
    assert isinstance(data, list)
```

### Cobertura Mínima
- **Models**: 90% dos atributos e métodos.
- **Routes**: 80% dos endpoints (todos os verbos HTTP).
- **Utils**: 70% (priorizar funções críticas como `notifications.py`).

### Execução
```bash
cd barbearia-backend
pytest tests/ -v --cov=. --cov-report=term-missing
```

## Frontend (Flutter)

### Estrutura de Testes
```
barbearia-frontend/
  test/
    unit/                 # Testes de lógica/negócio
    widget/               # Testes de componentes visuais
```

### O que Testar

#### Unit Tests
- Models: Serialização/deserialização JSON.
- Providers: Lógica de estado e transições.
- Services: Parsing de respostas API.

#### Widget Tests
- Componentes principais: `AgendaCard`, formulários.
- Estados: carregamento, erro, vazio, sucesso.
- Interações do usuário: taps, inputs.

### Exemplo de Teste de Widget
```dart
testWidgets('AgendaCard exibe informações corretas', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: AgendaCard(agendamento: mockAgendamento)),
  );
  expect(find.text('João Silva'), findsOneWidget);
  expect(find.text('Corte'), findsOneWidget);
});
```

### Execução
```bash
cd barbearia-frontend
flutter test --coverage
```

## API Contract Testing

### Validação de Contrato
Antes de declarar endpoint como "funcionando", verificar:
1. Status code esperado.
2. Estrutura JSON (campos presentes e tipos).
3. Dados sensíveis não expostos em erro.

### Ferramenta Recomendada
- `curl` ou Postman para testes manuais rápidos.
- Scripts Python com `requests` para regressão automática.

## Testes de Integração (Chat Web)

### O que Testar
- Fluxo completo: seleção de serviço → escolha de horário → confirmação.
- Interface com backend: respostas da API renderizadas corretamente.
- Estados de erro: timeout, servidor indisponível.

### Execução
- Teste manual via navegador (Chrome DevTools).
- Scripts Selenium/opcionais para regressão (se necessário).

## Execução Contínua

### CI/CD (Futuro)
Ao configurar pipeline:
1. Backend: `pytest` deve passar antes de merge.
2. Frontend: `flutter test` deve passar antes de merge.
3. Cobertura mínima: 70% combinada.

### Ordem de Execução (auditoria)
1. Testes de models (isolados, rápidos).
2. Testes de routes (integração, requerem DB).
3. Testes de utils (isolados).
4. Testes de frontend (widgets).

## Boas Práticas

- **Testes atômicos**: Cada teste é independente (sem dependência entre si).
- **Nomes descritivos**: `test_agendamento_nao_pode_ser_no_passado`.
- **Setup/Teardown**: Limpar estado entre testes.
- **Mockar externos**: Firebase Admin SDK em testes de notificação (não enviar notificações reais).

## Reforço da Regra Global Primária

Testes bem estruturados reduzem ciclos de debug e retrabalho, minimizando chamadas API desnecessárias. Investir tempo em cobertura abrangente na primeira execução evita retrabalho que multiplica requisições.