# Frontend Flutter - Agenda Digital para Barbearia - Plano Simplificado

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development para implementar este plano task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Criar frontend Flutter minimalista para app de agendamento de barbearia que se conecta ao backend Python/Flask existente.

**Architecture:** App Flutter com 5 telas principais usando Material Design, comunicação REST com backend via HTTP, gerenciamento de estado simplificado com Provider.

**Tech Stack:** Flutter 3.x, Dart 3.x, http package, provider package, intl package para datas.

**Contexto:** Backend já está funcional em `app.py` com endpoints REST. Banco SQLite com dados de exemplo. Limitação de tokens (~$1) - focar em funcionalidade básica sem testes unitários.

---

## Task 1: Setup do projeto Flutter

**Files:**
- Create: `../barbearia-frontend/pubspec.yaml`
- Create: `../barbearia-frontend/lib/main.dart`
- Create: `../barbearia-frontend/lib/services/api_service.dart`

- [ ] **Step 1: Criar estrutura do projeto Flutter**

```bash
cd "C:\Users\Ian\Desktop\Nova pasta"
flutter create barbearia-frontend
cd barbearia-frontend
```

- [ ] **Step 2: Configurar pubspec.yaml com dependências**

```yaml
name: barbearia_frontend
description: App de agendamento para barbearia
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  provider: ^6.1.1
  intl: ^0.18.1
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

- [ ] **Step 3: Criar arquivo main.dart básico**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbearia_frontend/screens/home_screen.dart';
import 'package:barbearia_frontend/services/api_service.dart';

void main() {
  runApp(const BarbeariaApp());
}

class BarbeariaApp extends StatelessWidget {
  const BarbeariaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(baseUrl: 'http://10.0.2.2:5000'),
        ),
      ],
      child: MaterialApp(
        title: 'Barbearia Digital',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

- [ ] **Step 4: Criar ApiService básico**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<dynamic>> getClientes() async {
    final response = await http.get(Uri.parse('$baseUrl/api/clientes'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar clientes');
    }
  }

  Future<List<dynamic>> getServicos() async {
    final response = await http.get(Uri.parse('$baseUrl/api/servicos'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar serviços');
    }
  }

  Future<List<dynamic>> getAgendamentos() async {
    final response = await http.get(Uri.parse('$baseUrl/api/agendamentos'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar agendamentos');
    }
  }

  Future<List<dynamic>> getAgendaHoje() async {
    final response = await http.get(Uri.parse('$baseUrl/api/agenda/hoje'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar agenda de hoje');
    }
  }
}
```

- [ ] **Step 5: Verificar estrutura**

```bash
cd "C:\Users\Ian\Desktop\Nova pasta\barbearia-frontend"
flutter pub get
```

---

## Task 2: Tela Home (Dashboard)

**Files:**
- Create: `../barbearia-frontend/lib/screens/home_screen.dart`
- Create: `../barbearia-frontend/lib/widgets/agenda_card.dart`

- [ ] **Step 1: Criar HomeScreen básica**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbearia_frontend/services/api_service.dart';
import 'package:barbearia_frontend/screens/clientes_screen.dart';
import 'package:barbearia_frontend/screens/servicos_screen.dart';
import 'package:barbearia_frontend/screens/agendamentos_screen.dart';
import 'package:barbearia_frontend/screens/novo_agendamento_screen.dart';
import 'package:barbearia_frontend/widgets/agenda_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> agendaHoje = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgendaHoje();
  }

  Future<void> _loadAgendaHoje() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final data = await apiService.getAgendaHoje();
      setState(() {
        agendaHoje = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barbearia Digital'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAgendaHoje,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Agenda de Hoje',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: agendaHoje.isEmpty
        endamento'))
              : ListView.builder(
                  itemCount: agendamentos.length,
                  itemBuilder: (context, index) {
                    final agendamento = agendamentos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            agendamento['cliente_nome']?.substring(0, 1) ?? 'C',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(agendamento['cliente_nome'] ?? 'Cliente'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Serviço: ${agendamento['servico_nome']}'),
                            Text('Data: ${agendamento['data_hora']}'),
                            if (agendamento['observacoes'] != null &&
                                agendamento['observacoes'].isNotEmpty)
                              Text('Obs: ${agendamento['observacoes']}'),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(
                            agendamento['status'] == 'agendado'
                                ? 'Agendado'
                                : agendamento['status'] == 'concluido'
                                    ? 'Concluído'
                                    : 'Cancelado',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor:
                              agendamento['status'] == 'agendado'
                                  ? Colors.blue.shade100
                                  : agendamento['status'] == 'concluido'
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
```

- [ ] **Step 2: Criar NovoAgendamentoScreen**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbearia_frontend/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NovoAgendamentoScreen extends StatefulWidget {
  const NovoAgendamentoScreen({super.key});

  @override
  State<NovoAgendamentoScreen> createState() => _NovoAgendamentoScreenState();
}

class _NovoAgendamentoScreenState extends State<NovoAgendamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _observacoesController = TextEditingController();
  final _dataHoraController = TextEditingController();

  List<dynamic> clientes = [];
  List<dynamic> servicos = [];
  int? _selectedClienteId;
  int? _selectedServicoId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final clientesData = await apiService.getClientes();
      final servicosData = await apiService.getServicos();
      setState(() {
        clientes = clientesData;
        servicos = servicosData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  Future<void> _submitAgendamento() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClienteId == null || _selectedServicoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione cliente e serviço')),
        );
        return;
      }

      final agendamento = {
        'cliente_id': _selectedClienteId,
        'servico_id': _selectedServicoId,
        'data_hora': _dataHoraController.text,
        'observacoes': _observacoesController.text,
        'status': 'agendado',
      };

      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final response = await http.post(
          Uri.parse('${apiService.baseUrl}/api/agendamentos'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(agendamento),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agendamento criado com sucesso!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedClienteId,
                      items: clientes.map((cliente) {
                        return DropdownMenuItem<int>(
                          value: cliente['id'],
                          child: Text(cliente['nome']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClienteId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione um cliente';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Serviço',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedServicoId,
                      items: servicos.map((servico) {
                        return DropdownMenuItem<int>(
                          value: servico['id'],
                          child: Text('${servico['nome']} - R\$${servico['preco']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedServicoId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione um serviço';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dataHoraController,
                      decoration: const InputDecoration(
                        labelText: 'Data e Hora (YYYY-MM-DD HH:MM:SS)',
                        border: OutlineInputBorder(),
                        hintText: '2026-04-10 14:30:00',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe data e hora';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _observacoesController,
                      decoration: const InputDecoration(
                        labelText: 'Observações (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitAgendamento,
                      child: const Text('Criar Agendamento'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
```

- [ ] **Step 3: Criar estrutura de pastas**

```bash
cd "C:\Users\Ian\Desktop\Nova pasta\barbearia-frontend"
mkdir -p lib/screens lib/services lib/widgets
```

---

## Task 6: Testar aplicação completa

**Files:**
- Test: Backend Python
- Test: Frontend Flutter

- [ ] **Step 1: Iniciar backend**

```bash
cd "C:\Users\Ian\Desktop\Nova pasta\barbearia-backend"
python init_db_simple.py
python run.py
```

Verificar: Backend rodando em http://localhost:5000

- [ ] **Step 2: Testar endpoints com curl**

```bash
curl http://localhost:5000/api/clientes
curl http://localhost:5000/api/servicos
curl http://localhost:5000/api/agenda/hoje
```

- [ ] **Step 3: Iniciar app Flutter**

```bash
cd "C:\Users\Ian\Desktop\Nova pasta\barbearia-frontend"
flutter run
```

**Nota:** Para Android emulador, usar IP 10.0.2.2 para localhost.

- [ ] **Step 4: Testar funcionalidades**

1. Verificar se tela Home carrega agenda do dia
2. Navegar para tela de Clientes
3. Navegar para tela de Serviços
4. Navegar para tela de Agendamentos
5. Criar novo agendamento
6. Verificar se aparece na agenda

---

## Conclusão

App funcional com:
- Backend Python/Flask com API REST
- Frontend Flutter com 5 telas
- CRUD básico de agendamentos
- Visualização de agenda do dia
- Navegação entre telas
- Comunicação HTTP com backend

**Próximos passos (opcionais):**
1. Adicionar autenticação
2. Implementar notificações
3. Adicionar relatórios
4. Melhorar UI/UX
5. Adicionar testesendamento para hoje'))
                      : ListView.builder(
                          itemCount: agendaHoje.length,
                          itemBuilder: (context, index) {
                            final agendamento = agendaHoje[index];
                            return AgendaCard(agendamento: agendamento);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NovoAgendamentoScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Barbearia Digital',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Clientes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClientesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cut),
              title: const Text('Serviços'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ServicosScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Agendamentos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AgendamentosScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Criar AgendaCard widget**

```dart
import 'package:flutter/material.dart';

class AgendaCard extends StatelessWidget {
  final Map<String, dynamic> agendamento;

  const AgendaCard({super.key, required this.agendamento});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            agendamento['cliente_nome']?.substring(0, 1) ?? 'C',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(agendamento['cliente_nome'] ?? 'Cliente'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Serviço: ${agendamento['servico_nome'] ?? 'Serviço'}'),
            Text('Horário: ${agendamento['data_hora']?.substring(11, 16) ?? ''}'),
          ],
        ),
        trailing: Chip(
          label: Text(
            agendamento['status'] == 'agendado' ? 'Agendado' : 'Concluído',
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: agendamento['status'] == 'agendado'
              ? Colors.blue.shade100
              : Colors.green.shade100,
        ),
      ),
    );
  }
}
```

---

## Task 3: Tela de Clientes

**Files:**
- Create: `../barbearia-frontend/lib/screens/clientes_screen.dart`

- [ ] **Step 1: Criar ClientesScreen**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbearia_frontend/services/api_service.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<dynamic> clientes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final data = await apiService.getClientes();
      setState(() {
        clientes = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : clientes.isEmpty
              ? const Center(child: Text('Nenhum cliente cadastrado'))
              : ListView.builder(
                  itemCount: clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = clientes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            cliente['nome']?.substring(0, 1) ?? 'C',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(cliente['nome'] ?? 'Cliente'),
                        subtitle: Text(cliente['telefone'] ?? 'Sem telefone'),
                        trailing: Text(
                            'ID: ${cliente['id']}'),
                      ),
                    );
                  },
                ),
    );
  }
}
```

---

## Task 4: Tela de Serviços

**Files:**
- Create: `../barbearia-frontend/lib/screens/servicos_screen.dart`

- [ ] **Step 1: Criar ServicosScreen**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbearia_frontend/services/api_service.dart';

class ServicosScreen extends StatefulWidget {
  const ServicosScreen({super.key});

  @override
  State<ServicosScreen> createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
  List<dynamic> servicos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServicos();
  }

  Future<void> _loadServicos() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final data = await apiService.getServicos();
      setState(() {
        servicos = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : servicos.isEmpty
              ? const Center(child: Text('Nenhum serviço cadastrado'))
              : ListView.builder(
                  itemCount: servicos.length,
                  itemBuilder: (context, index) {
                    final servico = servicos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.cut, color: Colors.blue),
                        title: Text(servico['nome'] ?? 'Serviço'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(servico['descricao'] ?? 'Sem descrição'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Chip(
                                  label: Text(
                                    '${servico['duracao_minutos']} min',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(
                                    'R\$${servico['preco']?.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: Colors.green.shade100,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
```

---

## Task 5: Tela de Agendamentos e Novo Agendamento

**Files:**
- Create: `../barbearia-frontend/lib/screens/agendamentos_screen.dart`
- Create: `../barbearia-frontend/lib/screens/novo_agendamento_screen.dart`

- [ ] **Step 1: Criar AgendamentosScreen**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbearia_frontend/services/api_service.dart';

class AgendamentosScreen extends StatefulWidget {
  const AgendamentosScreen({super.key});

  @override
  State<AgendamentosScreen> createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  List<dynamic> agendamentos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgendamentos();
  }

  Future<void> _loadAgendamentos() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final data = await apiService.getAgendamentos();
      setState(() {
        agendamentos = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : agendamentos.isEmpty
endamento'))
              : ListView.builder(
                  itemCount: agendamentos.length,
                  itemBuilder: (context, index) {
                    final agendamento = agendamentos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            agendamento['cliente_nome']?.substring(0, 1) ?? 'C',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(agendamento['cliente_nome'] ?? 'Cliente'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Serviço: ${agendamento['servico_nome']}'),
                            Text('Data: ${agendamento['data_hora']}'),
                            if (agendamento['observacoes'] != null &&
                                agendamento['observacoes'].isNotEmpty)
                              Text('Obs: ${agendamento['observacoes']}'),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(
                            agendamento['status'] == 'agendado'
                                ? 'Agendado'
                                : agendamento['status'] == 'concluido'
                                    ? 'Concluído'
                                    : 'Cancelado',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor:
                              agendamento['status'] == 'agendado'
                                  ? Colors.blue.shade100
                                  : agendamento['status'] == 'concluido'
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
```

- [ ] **Step 2: Criar NovoAgendamentoScreen**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbearia_frontend/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NovoAgendamentoScreen extends StatefulWidget {
  const NovoAgendamentoScreen({super.key});

  @override
  State<NovoAgendamentoScreen> createState() => _NovoAgendamentoScreenState();
}

class _NovoAgendamentoScreenState extends State<NovoAgendamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _observacoesController = TextEditingController();
  final _dataHoraController = TextEditingController();

  List<dynamic> clientes = [];
  List<dynamic> servicos = [];
  int? _selectedClienteId;
  int? _selectedServicoId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final clientesData = await apiService.getClientes();
      final servicosData = await apiService.getServicos();
      setState(() {
        clientes = clientesData;
        servicos = servicosData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  Future<void> _submitAgendamento() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClienteId == null || _selectedServicoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione cliente e serviço')),
        );
        return;
      }

      final agendamento = {
        'cliente_id': _selectedClienteId,
        'servico_id': _selectedServicoId,
        'data_hora': _dataHoraController.text,
        'observacoes': _observacoesController.text,
        'status': 'agendado',
      };

      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final response = await http.post(
          Uri.parse('${apiService.baseUrl}/api/agendamentos'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(agendamento),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agendamento criado com sucesso!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedClienteId,
                      items: clientes.map((cliente) {
                        return DropdownMenuItem<int>(
                          value: cliente['id'],
                          child: Text(cliente['nome']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClienteId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione um cliente';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Serviço',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedServicoId,
                      items: servicos.map((servico) {
                        return DropdownMenuItem<int>(
                          value: servico['id'],
                          child: Text('${servico['nome']} - R\$${servico['preco']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedServicoId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione um serviço';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dataHoraController,
                      decoration: const InputDecoration(
                        labelText: 'Data e Hora (YYYY-MM-DD HH:MM:SS)',
                        border: OutlineInputBorder(),
                        hintText: '2026-04-10 14:30:00',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe data e hora';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _observacoesController,
                      decoration: const InputDecoration(
                        labelText: 'Observações (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitAgendamento,
                      child: const Text('Criar Agendamento'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
```

- [ ] **Step 3: Criar estrutura de pastas**

```bash
cd "C:\Users\Ian\Desktop\Nova pasta\barbearia-frontend"
mkdir -p lib/screens lib/services lib/widgets
```

---

## Task 6: Testar aplicação completa

**Files:**
- Test: Backend Python
- Test: Frontend Flutter

- [ ] **Step 1: Iniciar backend**

```bash
cd "C:\Users\Ian\Desktop\Nova pasta\barbearia-backend"
python init_db_simple.py
python run.py
```

Verificar: Backend rodando em http://localhost:5000

- [ ] **Step 2: Testar endpoints com curl**

```bash
curl http://localhost:5000/api/clientes
curl http://localhost:5000/api/servicos
curl http://localhost:5000/api/agenda/hoje
```

- [ ] **Step 3: Iniciar app Flutter**

```bash
cd "C:\Users\Ian\Desktop\Nova pasta\barbearia-frontend"
flutter run
```

**Nota:** Para Android emulador, usar IP 10.0.2.2 para localhost.

- [ ] **Step 4: Testar funcionalidades**

1. Verificar se tela Home carrega agenda do dia
2. Navegar para tela de Clientes
3. Navegar para tela de Serviços
4. Navegar para tela de Agendamentos
5. Criar novo agendamento
6. Verificar se aparece na agenda

---

## Conclusão

App funcional com:
- Backend Python/Flask com API REST
- Frontend Flutter com 5 telas
- CRUD básico de agendamentos
- Visualização de agenda do dia
- Navegação entre telas
- Comunicação HTTP com backend

**Próximos passos (opcionais):**
1. Adicionar autenticação
2. Implementar notificações
3. Adicionar relatórios
4. Melhorar UI/UX
5. Adicionar testes