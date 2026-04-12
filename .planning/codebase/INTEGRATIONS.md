# Integrações

## Integrações Internas

### Frontend ↔ Backend
O frontend Flutter e o Chat Web se comunicam com o backend Flask via API REST.
- **Protocolo**: HTTP/HTTPS
- **Formato**: JSON
- **Autenticação**: Header `Authorization: Bearer <JWT_TOKEN>` (Exceto endpoints públicos).

### Endpoints da API

#### Autenticação (`/api/auth`)
- `POST /api/auth/login`: Realiza o login e retorna o token JWT.

#### Clientes (`/api/clientes`) [Privado]
- `GET /api/clientes`: Lista todos os clientes.
- `POST /api/clientes`: Cria um novo cliente.

#### Serviços (`/api/servicos`) [Privado/Público]
- `GET /api/servicos`: Lista privada de serviços.
- `GET /api/public/servicos`: Lista pública para o chat.

#### Agendamentos (`/api/agendamentos`) [Privado]
- `GET /api/agendamentos`: Lista total de agendamentos.
- `PUT /api/agendamentos/<id>/concluir`: Marca como concluído.

#### Chat Público (`/api/public`)
- `GET /api/public/horarios`: Verifica disponibilidade de slots de 30 min.
- `POST /api/public/agendar`: Cria agendamento via chat (Gera notificação push).

## Integrações Externas

### Firebase Cloud Messaging (FCM)
- **Objetivo**: Notificações em tempo real para o barbeiro sobre novos agendamentos.
- **Implementação**: SDK `firebase-admin` no backend enviando mensagens multicast para tokens registrados na tabela `push_tokens`.
- **Credenciais**: `firebase-service-account.json`.

### Chat do Cliente
- **Interface**: HTML estático em `static/chat/`.
- **Comunicação**: Chamadas diretas para `/api/public/` para evitar necessidade de autenticação pelo cliente final.
