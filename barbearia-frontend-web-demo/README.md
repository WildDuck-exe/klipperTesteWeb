# Barbearia Frontend - Ponto do Corte

Aplicativo Flutter para gerenciamento de barbearia com agendamento digital e notificações push.

## Requisitos

- **Flutter 3.x+** (testado com Flutter mais recente)
- **Dart SDK**
- **Windows SDK** (para build Windows)
- **Backend** rodando (Python/Flask)

## Plataformas Suportadas

- Windows (x64) — Build nativo desktop
- Android — Build móvel
- Web — Chat de autoatendimento

## Instalação

1. **Instalar dependências:**
```bash
cd barbearia-frontend
flutter pub get
```

2. **Configurar ambiente:**
```bash
cp .env.example .env  # Configure API_BASE_URL se necessário
```

3. **Iniciar o backend:**
```bash
cd ../barbearia-backend
pip install -r requirements.txt
python init_db_simple.py
python app.py
```

4. **Executar o app (Windows):**
```bash
flutter run -d windows
```

5. **Build de release (Windows):**
```bash
flutter build windows --release
```

O executável será gerado em: `build/windows/x64/runner/Release/barbearia_frontend.exe`

## Funcionalidades

- Dashboard com resumo financeiro e agenda do dia
- Navegação persistente (bottom nav bar) — sempre visível
- Gerenciamento de clientes
- Gerenciamento de serviços
- Visualização e filtros de agendamentos
- Notificações push em tempo real (FCM)
- Chat web de autoatendimento para clientes
- Feedback tátil (haptic feedback) em interações

## Arquitetura

```
barbearia-frontend/
├── lib/
│   ├── main.dart              # Entry point + Firebase init
│   ├── services/
│   │   └── api_service.dart   # Comunicação REST + FCM token
│   ├── screens/
│   │   ├── home_screen.dart   # Dashboard + IndexedStack nav
│   │   ├── clientes_screen.dart
│   │   ├── servicos_screen.dart
│   │   ├── agendamentos_screen.dart
│   │   ├── financeiro_screen.dart
│   │   ├── settings_screen.dart
│   │   └── about_screen.dart
│   └── widgets/
│       ├── magic_bottom_nav.dart  # Bottom nav flutuante
│       └── agenda_card.dart
├── pubspec.yaml
└── .env
```

## API Integration

O app se comunica com o backend via REST API:

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| POST | /api/auth/login | Login JWT |
| GET | /api/clientes | Listar clientes |
| GET | /api/agenda/hoje | Agenda do dia |
| GET | /api/dashboard/resumo | Dados financeiros |
| PUT | /api/agendamentos/{id}/concluir | Concluir serviço |

## Notificações Push

Firebase Cloud Messaging (FCM) envia notificações em tempo real quando um cliente faz um agendamento pelo chat web. O token FCM é registrado no login.

## Tecnologias

- Flutter + Provider (estado)
- Firebase Cloud Messaging
- Google Fonts (Outfit)
- HTTP + flutter_dotenv

## Credenciais de Teste

```
Usuário: admin
Senha: admin123
```

## Licença

Projeto de Extensão II - Engenharia de Software