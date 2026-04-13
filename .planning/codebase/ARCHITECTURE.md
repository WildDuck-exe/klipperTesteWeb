# ARCHITECTURE

## Overview

Sistema no padrão **Monolito API First + Single Page App/Native App**. Arquitetura em camadas com separação clara de responsabilidades entre backend (Python/Flask) e frontend (Flutter).

---

## Backend (Python/Flask)

### Camadas Arquiteturais

O backend segue um design de **camadas simples mas desacoplado**:

1. **`models/`** - Camada de Dados
   - SQLAlchemy ORM para mapeamento objeto-relacional
   - Modelos: Cliente, Servico, Agendamento, Despesa, Configuracao, PushToken, Usuario
   - Gerenciamento de banco SQLite em `database/barbearia.db`

2. **`routes/`** - Camada de Controle/Views da API
   - Blueprints REST para cada domínio: auth, clientes, servicos, agendamentos, public, configuracao, despesas
   - Endpoints padronizados com prefixo `/api`
   - Servidor de arquivos estáticos para chat em `/chat/`

3. **`utils/`** - Camada Cross-cutting
   - Auth: tratamento de tokens JWT
   - Notifications: envio via Firebase Cloud Messaging
   - Validation: validação de dados de entrada

### Stack Técnico Backend

- **Framework**: Flask 2.3.3
- **ORM**: Flask-SQLAlchemy 3.1.1 + SQLAlchemy 2.0.36
- **Auth**: PyJWT 2.8.0 para tokens de autenticação
- **CORS**: Flask-CORS 4.0.0
- **Push**: firebase-admin 6.5.0 para notificações
- **Config**: python-dotenv 1.0.0 para variáveis de ambiente

---

## Frontend (Flutter)

### Padrão Arquitetural

O frontend adota o padrão **Provider + Stateful Screens**:

1. **`screens/`** - Widgets estataiscreens.com estado de negócio
   - Cada tela é um StatefulWidget completo com lógica de negócio incorporada
   - Telas: HomeScreen, AgendamentosScreen, ClientesScreen, ServicosScreen, FinanceiroScreen, SettingsScreen, LoginScreen, AboutScreen

2. **`services/`** - Consumidores HTTP
   - ApiService centraliza todas as chamadas REST
   - Gerencia tokens de autenticação (SharedPreferences)
   - Modelo de dados (Cliente, Servico, Agendamento) integrado no serviço

3. **`widgets/`** - Componentização reutilizável
   - Componentes de UI compartilhados entre telas

### Stack Técnico Frontend

- **Framework**: Flutter 3.x (SDK >=3.0.0)
- **State Management**: Provider 6.1.1
- **HTTP**: http 1.1.0
- **Persistence**: shared_preferences 2.2.2
- **Push**: firebase_core 3.6.0 + firebase_messaging 15.1.3
- **UI**: google_fonts 6.1.0, animations 2.0.11, flutter_spinkit 5.2.0

---

## Fluxo de Dados

```
[Flutter App] <--HTTP/JSON--> [Flask API] <--SQLAlchemy--> [SQLite DB]
                                        |
                                        v
                                   [Firebase FCM]
                                   (Push Notifications)
```

---

## Autenticação

- JWT-based authentication
- Tokens armazenados no frontend via SharedPreferences
- Backend valida tokens em rotas protegidas
- Sistema de login/logout no frontend

---

## Padrões de API

- RESTful endpoints com prefixo `/api`
- Respostas JSON padronizadas
- CORS configurado para origens cruzadas
- Versionamento da API em `API_VERSION` (v1.0.0)

---

## Arquitetura de Notificações

- Firebase Admin SDK para envio de push notifications
- Push tokens armazenados no banco de dados
- Suporte multi-plataforma (Android, iOS, Windows)