# Barbearia Frontend - App de Agendamento

Aplicativo Flutter para agendamento de barbearia.

## Funcionalidades

- ✅ Visualizar agenda do dia
- ✅ Gerenciar clientes (listar, adicionar)
- ✅ Gerenciar serviços (listar)
- ✅ Gerenciar agendamentos (listar, filtrar por status)
- ✅ Criar novos agendamentos
- ✅ Concluir/cancelar agendamentos

## Instalação

### Pré-requisitos

- Flutter SDK (versão 3.0.0 ou superior)
- Dart SDK
- Backend da Barbearia rodando (ver `../barbearia-backend/README.md`)

### Passos

1. **Instalar dependências:**
```bash
cd barbearia-frontend
flutter pub get
```

2. **Configurar URL da API:**
   - O arquivo `.env` já está configurado com `API_BASE_URL=http://localhost:5000`
   - Se necessário, altere para a URL do seu backend

3. **Iniciar o backend:**
```bash
cd ../barbearia-backend
python init_db_simple.py
python run.py
```

4. **Executar o app:**
```bash
cd barbearia-frontend
flutter run
```

## Estrutura do Projeto

```
barbearia-frontend/
├── lib/
│   ├── main.dart              # Ponto de entrada do app
│   ├── services/
│   │   └── api_service.dart   # Serviço de comunicação com API
│   ├── screens/
│   │   ├── home_screen.dart   # Tela inicial com agenda do dia
│   │   ├── clientes_screen.dart
│   │   ├── servicos_screen.dart
│   │   ├── agendamentos_screen.dart
│   │   └── novo_agendamento_screen.dart
│   └── widgets/
│       └── agenda_card.dart   # Widget de card de agendamento
├── pubspec.yaml              # Dependências do projeto
└── .env                      # Configurações de ambiente
```

## Telas do App

### 1. Home Screen
- Agenda do dia atual
- Atualização em tempo real
- Menu lateral para navegação
- Botão para novo agendamento

### 2. Clientes Screen
- Lista de clientes cadastrados
- Formulário para adicionar novo cliente
- Atualização automática após cadastro

### 3. Serviços Screen
- Lista de serviços disponíveis
- Preços e durações
- Informações detalhadas

### 4. Agendamentos Screen
- Lista completa de agendamentos
- Filtros por status (todos, agendados, concluídos, cancelados)
- Ações para concluir/cancelar agendamentos

### 5. Novo Agendamento Screen
- Formulário para criar novo agendamento
- Seleção de cliente, serviço, data e hora
- Campo para observações

## Dependências

- `http`: Comunicação com API REST
- `provider`: Gerenciamento de estado
- `intl`: Formatação de datas
- `flutter_dotenv`: Configurações de ambiente

## Testando

### Com emulador/dispositivo físico
```bash
flutter run
```

### Verificar build
```bash
flutter build apk --debug
```

## Próximos Passos

1. Adicionar autenticação
2. Implementar notificações push
3. Adicionar relatórios
4. Suporte offline
5. Exportar agenda

## Licença

Projeto de Extensão II - Engenharia de Software