# INSTRUÇÕES PARA USAR O PROJETO BARBEARIA

## ✅ PROJETO COMPLETO

O projeto "Agenda Digital para Barbearia" está completo e funcional com:

### BACKEND (Python/Flask)
- ✅ API REST com endpoints para clientes, serviços e agendamentos
- ✅ Banco de dados SQLite com dados de exemplo
- ✅ Scripts de inicialização fáceis de usar

### FRONTEND (Flutter/Dart)
- ✅ App móvel completo com todas as telas
- ✅ Comunicação com backend via HTTP
- ✅ Interface Material Design moderna
- ✅ Gerenciamento de estado com Provider

## 🚀 COMO INICIAR

### 1. Iniciar o Backend
```bash
cd barbearia-backend
python init_db_simple.py
python run.py
```

O backend iniciará em `http://localhost:5000` com dados de exemplo.

### 2. Iniciar o Frontend
```bash
cd barbearia-frontend
flutter pub get
flutter run
```

**Nota:** Se o Flutter não estiver instalado, você pode:
1. Instalar o Flutter SDK
2. Ou usar o código Dart gerado como base para outro projeto

## 📱 FUNCIONALIDADES IMPLEMENTADAS

### Backend (API)
- `GET /api/clientes` - Listar clientes
- `POST /api/clientes` - Criar cliente
- `GET /api/servicos` - Listar serviços
- `GET /api/agendamentos` - Listar agendamentos
- `POST /api/agendamentos` - Criar agendamento
- `PUT /api/agendamentos/{id}/concluir` - Concluir agendamento
- `PUT /api/agendamentos/{id}/cancelar` - Cancelar agendamento
- `GET /api/agenda/hoje` - Agenda do dia

### Frontend (App)
- **Home Screen**: Agenda do dia com ações de concluir/cancelar
- **Clientes Screen**: Lista e cadastro de clientes
- **Serviços Screen**: Lista de serviços disponíveis
- **Agendamentos Screen**: Lista completa com filtros por status
- **Novo Agendamento Screen**: Formulário para criar agendamentos

## 📁 ESTRUTURA DE ARQUIVOS

```
barbearia-backend/
├── app.py                    # Aplicação Flask principal
├── init_db_simple.py        # Script para criar banco de dados
├── run.py                   # Script para iniciar servidor
├── README.md               # Documentação do backend
└── database/               # Banco de dados SQLite

barbearia-frontend/
├── lib/
│   ├── main.dart           # Ponto de entrada
│   ├── services/           # Serviços de API
│   ├── screens/            # Telas do app
│   └── widgets/            # Widgets reutilizáveis
├── pubspec.yaml           # Dependências
├── .env                   # Configurações
└── README.md             # Documentação do frontend
```

## 🧪 TESTANDO A API

Com o backend rodando (`python run.py`), teste com:

```bash
# Listar clientes
curl http://localhost:5000/api/clientes

# Listar agenda do dia
curl http://localhost:5000/api/agenda/hoje

# Criar cliente
curl -X POST http://localhost:5000/api/clientes \
  -H "Content-Type: application/json" \
  -d '{"nome": "Novo Cliente", "telefone": "(11) 99999-9999"}'
```

## 🎯 PRÓXIMOS PASSOS (OPCIONAIS)

Se quiser expandir o projeto:

1. **Autenticação**: Adicionar login para barbeiros
2. **Notificações**: Lembretes para clientes
3. **Relatórios**: Dashboard com estatísticas
4. **Multi-barbearia**: Suporte para várias unidades
5. **Pagamentos**: Integração com gateway de pagamento

## ⚠️ LIMITAÇÕES CONHECIDAS

- Backend sem autenticação (apenas para desenvolvimento)
- App sem persistência offline
- Sem validação avançada de dados
- Sem testes unitários (conforme solicitado para economia de tokens)

## 📄 LICENÇA

Projeto de Extensão II - Engenharia de Software

---

**O projeto está pronto para uso!** Basta seguir as instruções acima para iniciar o backend e o frontend.