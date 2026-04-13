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

#### Gerenciamento de Dados [Privado]
- **Clientes** (`/api/clientes`): CRUD de clientes da barbearia.
- **Serviços** (`/api/servicos`): CRUD de catálogo de serviços (preços, durações).
- **Agendamentos** (`/api/agendamentos`): Controle administrativo de horários.
- **Configurações** (`/api/configuracoes`): Horários de funcionamento e dados da empresa.
- **Despesas** (`/api/despesas`): Registro de custos operacionais.

#### Chat Público (`/api/public`)
- `GET /api/public/horarios`: Verifica disponibilidade de slots baseado nas configurações de funcionamento.
- `GET /api/public/servicos`: Retorna a lista de serviços ativos para seleção no chat.
- `POST /api/public/agendar`: Cria agendamento via chat (Gera notificação push para o admin).

## Integrações Externas

### Firebase Cloud Messaging (FCM)
- **Objetivo**: Notificações em tempo real para o barbeiro sobre novos agendamentos e lembretes.
- **Implementação**:
  - **Backend**: SDK `firebase-admin` enviando mensagens multicast.
  - **Frontend**: `firebase_messaging` registrando tokens e lidando com mensagens em background/foreground.
- **Credenciais**: `firebase-service-account.json` (projeto: `ponto-do-corte`).

### Google Fonts (CDN)
- **Objetivo**: Tipografia customizada no frontend Flutter.
- **Implementação**: Pacote `google_fonts` carrega fontes diretamente do Google Fonts CDN.

### Chat do Cliente
- **Interface**: HTML estático em `static/chat/`.
- **Comunicação**: Chamadas diretas para `/api/public/` para evitar necessidade de autenticação pelo cliente final.
