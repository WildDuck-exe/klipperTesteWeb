# Stack de Tecnologia

## Backend
- **Linguagem**: Python 3.x (Meta: Compatibilidade total com Python 3.14)
- **Framework**: Flask 2.3.3
- **Banco de Dados**: SQLite gerenciado via SQLAlchemy 2.0.36
- **Extensões e Bibliotecas**:
  - `Flask-SQLAlchemy` (3.1.1): ORM para interação com banco de dados.
  - `Flask-CORS` (4.0.0): Para Compartilhamento de Recursos de Origem Cruzada.
  - `PyJWT` (2.8.0): Para autenticação via tokens JWT.
  - `firebase-admin` (6.5.0): SDK do Firebase para notificações push (FCM).
  - `python-dotenv` (1.0.0): Gerenciamento de variáveis de ambiente.
  - `pytest` (7.4.3): Framework de testes.

## Frontend (Desktop/Mobile)
- **Framework**: Flutter 3.x
- **Linguagem**: Dart
- **Gerenciamento de Estado**: Provider 6.1.1
- **FCM**: `firebase_core` (3.6.0) e `firebase_messaging` (15.1.3)
- **Rede**: `http` (1.1.0) para chamadas REST API
- **UI/UX**:
  - `google_fonts` (6.1.0): Tipografia customizada.
  - `animations` (2.0.11): Transições e animações de interface.
  - `flutter_spinkit` (5.2.0): Indicadores de carregamento.
- **Utilitários**:
  - `intl` (0.19.0): Internacionalização e formatação de datas.
  - `flutter_dotenv` (5.1.0): Gerenciamento de variáveis de ambiente.
  - `shared_preferences` (2.2.2): Persistência local de tokens.
  - `url_launcher` (6.2.1): Abertura de links externos (ex: WhatsApp).

## Chat do Cliente (Web)
- **Tecnologia**: HTML/JavaScript (Vanilla)
- **Integração**: Interface estática servida pelo Flask que se comunica com endpoints públicos.

## Ferramentas de Desenvolvimento
- **Gerenciadores de Pacotes**: `pip` (Python), `pub` (Dart/Flutter)
- **Testes**: `pytest` (Backend), `flutter_test` (Frontend)
- **GSD**: Sistema de Gestão de Desenvolvimento para automação e planejamento.
