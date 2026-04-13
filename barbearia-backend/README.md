# Barbearia API - Agenda Digital para Barbearia

API backend para sistema de agendamento de barbearia desenvolvido em Python/Flask.

## Funcionalidades

- ✅ Cadastro de clientes
- ✅ Cadastro de serviços
- ✅ Agendamento de horários
- ✅ Visualização da agenda do dia
- ✅ Marcar agendamentos como concluídos/cancelados

## Instalação Rápida

1. **Instalar dependências:**
```bash
pip install flask flask-cors
```

2. **Criar banco de dados:**
```bash
python init_db_simple.py
```

3. **Iniciar servidor:**
```bash
python run.py
```

## Endpoints da API

### Status da API
```
GET http://localhost:5000/
```

### Clientes
```
GET    /api/clientes          - Listar todos os clientes
GET    /api/clientes/{id}     - Obter cliente específico
POST   /api/clientes          - Criar novo cliente
```

**Exemplo POST /api/clientes:**
```json
{
  "nome": "João Silva",
  "telefone": "(11) 99999-9999"
}
```

### Serviços
```
GET    /api/servicos          - Listar todos os serviços
POST   /api/servicos          - Criar novo serviço
```

**Exemplo POST /api/servicos:**
```json
{
  "nome": "Corte de Cabelo",
  "descricao": "Corte tradicional",
  "duracao_minutos": 30,
  "preco": 30.00
}
```

### Agendamentos
```
GET    /api/agendamentos      - Listar todos os agendamentos
POST   /api/agendamentos      - Criar novo agendamento
PUT    /api/agendamentos/{id}/concluir - Marcar como concluído
PUT    /api/agendamentos/{id}/cancelar - Cancelar agendamento
GET    /api/agenda/hoje       - Agenda do dia atual
```

**Exemplo POST /api/agendamentos:**
```json
{
  "cliente_id": 1,
  "servico_id": 1,
  "data_hora": "2026-04-10 14:30:00",
  "observacoes": "Prefere tesoura",
  "status": "agendado"
}
```

## Estrutura do Banco de Dados

### Tabela: clientes
- id (INTEGER, PRIMARY KEY)
- nome (TEXT, NOT NULL)
- telefone (TEXT)
- data_cadastro (DATETIME, DEFAULT CURRENT_TIMESTAMP)

### Tabela: servicos
- id (INTEGER, PRIMARY KEY)
- nome (TEXT, NOT NULL)
- descricao (TEXT)
- duracao_minutos (INTEGER, DEFAULT 30)
- preco (DECIMAL(10,2))

### Tabela: agendamentos
- id (INTEGER, PRIMARY KEY)
- cliente_id (INTEGER, NOT NULL, FOREIGN KEY)
- servico_id (INTEGER, NOT NULL, FOREIGN KEY)
- data_hora (DATETIME, NOT NULL)
- observacoes (TEXT)
- status (TEXT, DEFAULT 'agendado')

## Testando a API

### Com curl:
```bash
# Listar clientes
curl http://localhost:5000/api/clientes

# Criar cliente
curl -X POST http://localhost:5000/api/clientes \
  -H "Content-Type: application/json" \
  -d '{"nome": "Novo Cliente", "telefone": "(11) 99999-9999"}'

# Listar agenda do dia
curl http://localhost:5000/api/agenda/hoje
```

### Com Postman/Insomnia:
Importar a coleção de endpoints disponível em `docs/postman_collection.json`

## Próximos Passos

1. Desenvolver frontend Flutter
2. Adicionar autenticação
3. Implementar relatórios
4. Adicionar notificações

## Tecnologias

- Python 3.x
- Flask (Microframework)
- SQLite (Banco de dados)
- Flask-CORS (Cross-Origin Resource Sharing)

## Licença

Projeto de Extensão II - Engenharia de Software