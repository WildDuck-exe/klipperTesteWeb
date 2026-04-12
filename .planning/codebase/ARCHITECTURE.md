# Arquitetura

## Visão Geral do Sistema
O sistema "Ponto do Corte" utiliza uma arquitetura descentralizada com um backend centralizador que serve tanto uma aplicação administrativa (Flutter) quanto uma interface de agendamento rápido (Chat Web).

## Arquitetura do Backend (Flask)
- **Monolito Modular**: Uso de Blueprints para separação de preocupações (auth, clientes, servicos, agendamentos, public).
- **Camada de Modelos**: SQLAlchemy ORM gerenciando o banco SQLite.
- **Notificações**: Módulo de notificações desacoplado que utiliza o SDK do Firebase.
- **Serviço Estático**: O Flask serve a interface de chat (`/chat`) diretamente do diretório `static/`.

## Arquitetura do Frontend (Flutter)
- **Gerenciamento de Estado**: Provider para propagação de dados de autenticação e estados da agenda.
- **Abstração de API**: `ApiService` centraliza o tratamento de requisições e tokens.
- **Plataforma**: Foco em Desktop (Windows) e Web.

## Fluxo de Agendamento via Chat
1. **Interação**: Cliente acessa `/chat` e seleciona serviço e data.
2. **Consulta**: O frontend do chat chama `/api/public/horarios` para ver slots vazios.
3. **Criação**: Cliente envia dados para `/api/public/agendar`.
4. **Persistência**: Backend salva o cliente (se novo) e o agendamento via SQLAlchemy.
5. **Notificação**: O backend recupera todos os `push_tokens` e envia uma notificação FCM para o app do barbeiro.

## Fluxo Administrativo
1. **Autenticação**: Barbeiro faz login no Flutter (JWT).
2. **Gestão**: Visualiza e modifica agendamentos e serviços.
3. **Push Registration**: O app Flutter registra seu token FCM no backend para receber alertas de novos agendamentos do chat.
