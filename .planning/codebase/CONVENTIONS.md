# Convenções de Codificação

## Backend (Python)
- **Padrão**: PEP 8.
- **Identação**: 4 espaços.
- **ORM**: Uso obrigatório de SQLAlchemy para todas as consultas ao banco (evitar SQL puro em rotas).
- **Docstrings**: Obrigatórias para todos os módulos e endpoints de API.
- **Nomenclatura**: `snake_case` para variáveis/funções, `PascalCase` para Classes.
- **Tipagem**: Uso de Type Hints onde aplicável para melhor manutenção.

## Frontend (Dart/Flutter)
- **Padrão**: Official Dart Style Guide.
- **Gerenciamento de Estado**: Usar `Provider` e `Consumer` para evitar rebuilds desnecessários.
- **Componentização**: Widgets grandes devem ser decompostos em arquivos menores em `widgets/`.
- **Nomenclatura**: `camelCase` para instâncias/métodos, `PascalCase` para Widgets.

## Banco de Dados
- **Tabelas**: Plural (`clientes`, `agendamentos`).
- **Campos**: `snake_case`.
- **Campos de Auditoria**: `criado_em` e `atualizado_em` em todas as tabelas principais.

## Segurança
- **JWT**: Tokens devem ser passados via header `Authorization: Bearer <token>`.
- **Endpoints Públicos**: Devem estar no Blueprint `public` e não exigir o decorador `token_required`.
