# CONVENTIONS

## Visão Geral

Este documento estabelece as convenções de codificação usadas no projeto Barbearia (Ponto do Corte), um sistema de agendamento digital com backend Flask e frontend Flutter.

## Linguagens e Nomenclatura

### Backend (Python)
- **Arquivos:** `snake_case.py`
- **Variáveis e funções:** `snake_case`
- **Classes:** `PascalCase`
- **Constantes:** `SCREAMING_SNAKE_CASE`
- **Imports:** Relative imports via `from .module import symbol`

### Frontend (Dart)
- **Arquivos:** `snake_case.dart`
- **Variáveis e métodos:** `camelCase`
- **Classes e tipos:** `PascalCase`
- **Constantes:** `camelCase` (Flutter convention)
- **Imports:** Package imports preferidos (`package:barbearia_frontend/...`)

### Idioma do Código
- **Entidades de negócio:** Português BR (`cliente.py`, `agendamento.py`, `ServicosScreen`)
- **Infraestrutura e nativo:** Inglês (`auth.py`, `api_service.dart`, `validation.py`)
- **Mix permitted** em utilitários quando faz sentido semântico

## Arquitetura Backend

### Estrutura de Diretórios
```
barbearia-backend/
├── app.py              # Entry point da aplicação Flask
├── config.py           # Configurações (Dev/Prod)
├── models/             # Modelos SQLAlchemy
│   ├── __init__.py     # db instance + exports
│   ├── cliente.py
│   ├── servico.py
│   ├── agendamento.py
│   └── [outros modelos]
├── routes/             # Blueprints Flask
│   ├── __init__.py     # register_blueprints()
│   ├── auth.py
│   ├── clientes.py
│   ├── agendamentos.py
│   └── public.py
├── utils/              # Utilitários
│   ├── auth.py         # Decorator @login_required
│   ├── validation.py   # Validação de telefone
│   └── notifications.py
└── tests/              # Suite pytest
```

### Padrões SQLAlchemy
```python
# Modelo padrão
class Entidade(db.Model):
    __tablename__ = 'entidades'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    nome = db.Column(db.String(100), nullable=False)
    # ... outros campos

    def __init__(self, nome, ...):
        self.nome = nome

    def to_dict(self):
        """Converte para dicionário (serialização)."""
        return {'id': self.id, 'nome': self.nome, ...}

    def __repr__(self):
        return f'<Entidade {self.id}: {self.nome}>'
```

### Padrão Blueprint
```python
# routes/entidade.py
entidade_bp = Blueprint('entidade', __name__)

@entidade_bp.route('/api/entidade', methods=['GET'])
@login_required
def get_entidade():
    """Retorna todas as entidades."""
    entidades = Entidade.query.all()
    return jsonify([e.to_dict() for e in entidades])
```

### Decorator de Autenticação
```python
# utils/auth.py
def login_required(f):
    """Verifica token JWT no header Authorization: Bearer <token>."""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = extract_token(request)
        if not token:
            return jsonify({'error': 'Token não fornecido'}), 401
        # decode and validate...
        return f(*args, **kwargs)
    return decorated
```

### Respostas de Erro Padronizadas
```python
# Sucesso
return jsonify({'message': 'Sucesso', 'data': result}), 200
return jsonify({'id': new_id, 'message': 'Criado'}), 201

# Erro
return jsonify({'error': 'Descrição do erro'}), 400
return jsonify({'error': 'Não encontrado'}), 404
return jsonify({'error': str(e)}), 500
```

## Arquitetura Frontend

### Estrutura de Diretórios
```
barbearia-frontend/lib/
├── main.dart              # Entry point + Firebase init
├── services/
│   └── api_service.dart   # Comunicação REST + state
├── screens/
│   ├── home_screen.dart   # Dashboard + IndexedStack
│   ├── clientes_screen.dart
│   ├── servicos_screen.dart
│   └── [outras telas]
├── widgets/
│   ├── magic_bottom_nav.dart
│   └── agenda_card.dart
└── theme/
    └── app_theme.dart     # Material theme builder
```

### Padrões Flutter
```dart
// StatelessWidget padrão
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SomeWidget();
  }
}

// StatefulWidget com lifecycle
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  @override
  void initState() {
    super.initState();
    // inicialização
  }

  @override
  Widget build(BuildContext context) {
    return SomeWidget();
  }
}
```

### Provider para Estado
```dart
// ApiService como ChangeNotifier
class ApiService extends ChangeNotifier {
  // estado...

  Future<void> loadData() async {
    // ...
    notifyListeners();
  }
}

// Uso
return MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ApiService()),
  ],
  child: MaterialApp(...)
);
```

### Classes de Modelo
```dart
class Entidade {
  final int id;
  final String nome;

  Entidade({required this.id, required this.nome});

  factory Entidade.fromJson(Map<String, dynamic> json) {
    return Entidade(
      id: json['id'],
      nome: json['nome'],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nome': nome};
}
```

## REST API Conventions

### Endpoints Backend
- **Prefixo:** `/api/`
- **Autenticação:** Token JWT no header `Authorization: Bearer <token>`
- **Formato resposta:** JSON
- **Autenticação opcional:** `/api/public/*`

### Endpoints Públicos (sem auth)
```
GET  /api/public/servicos
GET  /api/public/horarios
POST /api/public/cliente
POST /api/public/agendar
```

### Endpoints Protegidos (JWT required)
```
POST /api/auth/login
GET  /api/clientes
POST /api/clientes
GET  /api/agendamentos
PUT  /api/agendamentos/{id}/concluir
PUT  /api/agendamentos/{id}/cancelar
GET  /api/agenda/hoje
GET  /api/dashboard/resumo
```

## Formatação e Estilo

### Python
- 4 espaços para indentação (não tabs)
- Linhas máximo 120 caracteres
- Imports agrupados: stdlib → third-party → local
- Docstrings em todas as funções pública

### Dart
- 2 espaços para indentação
- Linhas máximo 80 caracteres (Flutter convention)
- `const` para widgets e valores imutáveis quando possível
- Trailing commas em collections

## Configurações de Linting

### Python (requirements.txt tooling)
```
flask
flask-cors
flask-sqlalchemy
flask-jwt-extended
pytest
```

### Flutter (analysis_options.yaml)
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # custom rules as needed
```

## Credentials de Teste
```
Usuário: admin
Senha: admin123
```