# Stack de Tecnologia

## Backend
- **Linguagem**: Python 3.x (Meta: Compatibilidade total com Python 3.14)
- **Framework**: Flask (Microframework)
- **Banco de Dados**: SQLite (Baseado em arquivo, gerenciado via SQLAlchemy)
- **Extensões e Bibliotecas**:
  - `Flask-SQLAlchemy`: ORM para interação com banco de dados.
  - `flask-cors`: Para Compartilhamento de Recursos de Origem Cruzada.
  - `PyJWT`: Para autenticação via tokens JWT.
  - `firebase-admin`: SDK do Firebase para notificações push (FCM).
  - `python-dotenv`: Gerenciamento de variáveis de ambiente.

## Frontend (Desktop/Mobile)
- **Framework**: Flutter (Cross-platform UI toolkit)
- **Linguagem**: Dart
- **Gerenciamento de Estado**: Provider
- **Rede**: pacote `http` para chamadas REST API
- **Utilitários**:
  - `intl`: Internacionalização e formatação de datas
  - `flutter_dotenv`: Gerenciamento de variáveis de ambiente
  - `firebase_messaging`: (Planejado/Integrado) Recebimento de notificações push

## Chat do Cliente (Web)
- **Tecnologia**: HTML/JavaScript (Vanilla)
- **Integração**: Interface estática servida pelo Flask que se comunica com endpoints públicos.

## Ferramentas de Desenvolvimento
- **Gerenciadores de Pacotes**: `pip` (Python), `pub` (Dart/Flutter)
- **Testes**: `pytest` (Backend)
- **GSD**: Sistema de Gestão de Desenvolvimento para automação e planejamento.
