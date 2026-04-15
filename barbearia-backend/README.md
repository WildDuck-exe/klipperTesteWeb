# Barbearia Backend - Klipper

API backend para sistema de agendamento de barbearia desenvolvido em Python/Flask com SQLAlchemy.

## Requisitos

- **Python 3.14+** (testado com Python 3.14.3)
- **pip** (gerenciador de pacotes Python)

## Instalação

1. **Instalar dependências:**
```bash
pip install -r requirements.txt
```

2. **Configurar variáveis de ambiente:**
Crie um arquivo `.env` na raiz do projeto com as chaves do Firebase:
```
FIREBASE_CREDENTIALS_PATH=./firebase-credentials.json
```

3. **Iniciar o servidor:**
```bash
python app.py
```

O servidor inicia em `http://localhost:5000`

## Funcionalidades

- Cadastro de clientes
- Cadastro de serviços
- Agendamento de horários
- Visualização da agenda do dia
- Autenticação JWT para endpoints admin
- Notificações push via Firebase Cloud Messaging
- Chat web de autoatendimento para clientes

## API Pública (sem autenticação)

```
GET  /api/public/servicos          - Listar serviços disponíveis
GET  /api/public/horarios          - Listar horários disponíveis
GET  /api/public/validate-phone    - Validar telefone brasileiro
POST /api/public/cliente           - Criar/buscar cliente por telefone
POST /api/public/agendar           - Criar agendamento via chat
```

## API Admin (requer token JWT)

```
POST /api/auth/login               - Login (retorna token JWT)
GET  /api/clientes                 - Listar clientes
POST /api/clientes                 - Criar cliente
GET  /api/agendamentos            - Listar agendamentos
PUT  /api/agendamentos/{id}/concluir - Marcar como concluído
PUT  /api/agendamentos/{id}/cancelar - Cancelar agendamento
GET  /api/agenda/hoje              - Agenda do dia
GET  /api/dashboard/resumo         - Resumo financeiro
```

## Estrutura do Projeto

```
barbearia-backend/
├── app.py              # Entry point
├── config.py           # Configurações
├── requirements.txt    # Dependências Python
├── routes/             # Rotas modularizadas (Blueprints)
│   ├── auth.py
│   ├── clientes.py
│   ├── agendamentos.py
│   └── public.py
├── models/             # Modelos SQLAlchemy
├── utils/              # Utilitários (notificações FCM)
└── static/chat/        # Interface web do chat
```

## Testes

```bash
cd barbearia-backend
python -m pytest
```

## Tecnologias

- Python 3.14+ (Flask, SQLAlchemy)
- Firebase Admin SDK (notificações push)
- JWT (autenticação)
- SQLite (banco de dados)

## Credenciais de Teste

```
Usuário: admin
Senha: admin123
```

## Licença

Projeto de Extensão II - Engenharia de Software