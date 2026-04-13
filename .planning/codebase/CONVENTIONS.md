# Convenções de Código — Ponto do Corte

## Princípio Base

Todo código deve seguir estas convenções para manter consistência e legibilidade. A regra suprema (Minimizar Requisições API) exige que estas convenções sejam aplicadas de forma consciente: escrever código correto na primeira vez evita refatorações que geram chamadas extras.

## Python (Backend)

### Estilo e Formatação
- **Indentação**: 4 espaços (não tabs).
- **Linha máxima**: 120 caracteres.
- **Docstrings**: Formato Google Style para todos os módulos, classes e funções públicas.
- **Imports**: Ordem padronizada — stdlib → third-party → local (conforme PEP 8).

### Convenções de Nomenclatura
| Tipo | Convenção | Exemplo |
|------|-----------|---------|
| Variáveis/funções | `snake_case` | `buscar_agendamento()` |
| Classes | `PascalCase` | `AgendamentoService` |
| Constantes | `SCREAMING_SNAKE_CASE` | `MAX_RETRY_ATTEMPTS` |
| Arquivos | `snake_case` | `agendamentos_routes.py` |
| Métodos privados | `_snake_case` | `_validar_token()` |

### Arquitetura de Módulos
- **Models**: Definem estrutura SQLAlchemy. Um model por arquivo.
- **Routes**: Lógica de endpoints via Blueprints. Um Blueprint por domínio (`agendamentos`, `auth`, etc.).
- **Utils**: Funções auxiliares reutilizáveis (ex: `notifications.py`).
- **Nomenclatura de Blueprint**: `nome_plural_routes` (ex: `agendamentos_routes.py` → Blueprint `agendamentos`).

### API REST
- **Prefixos**: `/api/v1/<recurso>`.
- **Verbos HTTP**: GET (leitura), POST (criação), PUT (atualização), DELETE (remoção).
- **Respostas de erro**: JSON com `{"erro": "mensagem", "codigo": 400}`.
- **Status codes**: 200 (sucesso), 201 (criado), 400 (erro cliente), 401 (não autenticado), 404 (não encontrado), 500 (erro servidor).

### Validação e Segurança
- Validar todas as entradas antes de processar.
- Tokens JWT com expiração definida (configurável via `.env`).
- Nunca expor dados sensíveis em logs ou respostas de erro.
- Queries parametrizadas (SQLAlchemy ORM previne injeção por padrão).

## Dart/Flutter (Frontend)

### Estilo e Formatação
- **Indentação**: 2 espaços.
- **Linha máxima**: 100 caracteres.
- **Documentação**: Comentários `///` para APIs públicas, `//` para lógica interna.

### Convenções de Nomenclatura
| Tipo | Convenção | Exemplo |
|------|-----------|---------|
| Variáveis/funções | `camelCase` | `fetchAgendamentos()` |
| Classes/Types | `PascalCase` | `AgendamentoModel` |
| Constantes | `kCamelCase` | `kDefaultTimeout` |
| Arquivos | `snake_case` | `agendamento_model.dart` |

### Estrutura de diretórios (lib/)
```
lib/
  main.dart
  screens/        # Telas completas
  widgets/        # Componentes reutilizáveis
  models/         # Modelos de dados
  providers/      # Gerenciamento de estado (Provider)
  services/       # Comunicação API (ApiService)
  theme/          # Design System
```

### Estado e Ciclos de Vida
- Provider para estado global (autenticação, configurações).
- StatelessWidget quando possível.
- .dispose() implementado corretamente em StatefulWidgets.

### Requisições HTTP
- Uri completa em cada chamada (não hardcoded).
- Headers Authorization para endpoints protegidos: `Authorization: Bearer <token>`.
- Tratamento de erros em try-catch com fallback visual.

## JavaScript (Chat Web)

### Estilo e Formatação
- **Indentação**: 2 espaços.
- **Linha máxima**: 100 caracteres.

### Convenções de Nomenclatura
| Tipo | Convenção | Exemplo |
|------|-----------|---------|
| Variáveis/funções | `camelCase` | `formatDate()` |
| Constantes | `SCREAMING_SNAKE_CASE` | `API_BASE_URL` |
| Arquivos | `snake_case` | `chat_ui.js` |

### Estrutura
- Vanilla JS (sem frameworks).
- Arquivo único `chat_ui.js` para interface pública.
- Separation of concerns: DOM manipulation separada da lógica de negócio.

## Git e Versionamento

### Mensagens de Commit
- Formato: `tipo(escopo): descrição`
- Tipos: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
- Exemplo: `feat(agendamentos): adicionar endpoint de cancelamento`

### Branches
- `main`: código de produção.
- `feature/`: desenvolvimento de novas funcionalidades.
- `fix/`: correções de bugs.
- `docs/`: documentação.

## Validação Local (Pre-commit)

Antes de cada commit, garantir:
1. Python: `python -m py_compile <arquivo>` sem erros.
2. Dart: `flutter analyze` sem errors (warnings aceitáveis).
3. JS: Console do navegador sem erros.

Estas verificações locais evitam regressões e minimizam a necessidade de múltiplas rodadas de correção — alinhado à Regra Global Primária de minimizar chamadas API.