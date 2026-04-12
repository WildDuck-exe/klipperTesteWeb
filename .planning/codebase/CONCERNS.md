# Preocupações e Riscos

## Segurança
- **FCM Credentials**: O arquivo `firebase-service-account.json` contém chaves privadas e **NUNCA** deve ser commitado no repositório público (deve estar no `.gitignore`).
- **CORS**: Atualmente permite `*`. Deve ser restrito para o domínio de produção no futuro.
- **Exposição de Endpoints Públicos**: `/api/public` permite criação de agendamentos sem login. Implementar rate-limiting para evitar spam de agendamentos falsos.

## Arquitetura e Escalabilidade
- **Concorrência de Horários**: Slots de 30 min podem sofrer condições de corrida se dois clientes agendarem ao mesmo tempo via chat. Implementar bloqueio pessimista ou validação rigorosa pré-commit.
- **Migração SQLite**: Para produção real com muitos acessos simultâneos, o SQLite pode apresentar `Database is locked`. Migrar para PostgreSQL via SQLAlchemy no momento oportuno.

## Tecnológico
- **Python 3.14**: Acompanhar mudanças na linguagem para garantir que o uso de `async` ou mudanças no Global Interpreter Lock (GIL) não afetem o comportamento da API Flask.
- **Build Flutter Windows**: Garantir que as dependências nativas para notificações push funcionem corretamente no ambiente Windows Desktop.

## Experiência do Usuário
- **Chat Sem Estado**: Se o cliente fechar o chat, ele perde o contexto. Considerar salvar temporariamente no localStorage se o fluxo for longo.
