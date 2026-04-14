---
phase: 1
plan: 3
title: "Autenticação no Frontend Flutter (Login e Token)"
wave: 2
depends_on: [2]
files_modified:
  - barbearia-frontend/lib/services/api_service.dart
  - barbearia-frontend/lib/screens/login_screen.dart
  - barbearia-frontend/lib/main.dart
  - barbearia-frontend/pubspec.yaml
requirements_addressed: [AUTH-01]
autonomous: true
---

<objective>
Adicionar tela de Login ao app Flutter e integrar autenticação JWT em todas as requisições HTTP. O app deve pedir login antes de acessar qualquer funcionalidade. O token será armazenado com `shared_preferences`.
</objective>

<must_haves>
- Tela de Login funcional com campos Usuário e Senha
- Ao fazer login com sucesso, token JWT é salvo no dispositivo
- Todas as requisições HTTP incluem o header `Authorization: Bearer <token>`
- Se o token não existe ou está expirado, o app redireciona para tela de Login
- App inicia na tela de Login (se não houver token salvo)
- App inicia na tela Home (se houver token válido salvo)
</must_haves>

## Tarefa 1: Adicionar `shared_preferences` ao `pubspec.yaml`

<read_first>
- barbearia-frontend/pubspec.yaml
</read_first>

<action>
No `pubspec.yaml`, na seção `dependencies:`, adicionar:
```yaml
  shared_preferences: ^2.2.2
```

Conteúdo final de `dependencies`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  provider: ^6.0.5
  intl: ^0.18.1
  flutter_dotenv: ^5.1.0
  shared_preferences: ^2.2.2
```
</action>

<acceptance_criteria>
- `pubspec.yaml` contém `shared_preferences: ^2.2.2`
</acceptance_criteria>

## Tarefa 2: Atualizar `api_service.dart` para incluir token nas requisições

<read_first>
- barbearia-frontend/lib/services/api_service.dart (completo — 291 linhas)
</read_first>

<action>
Modificar `api_service.dart`:

1. Adicionar import no topo:
```dart
import 'package:shared_preferences/shared_preferences.dart';
```

2. Adicionar campo `_token` e métodos de autenticação na classe `ApiService`:
```dart
  String? _token;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  /// Carrega token salvo do dispositivo
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _isAuthenticated = _token != null;
    notifyListeners();
  }

  /// Headers com autenticação
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// Faz login e salva token
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _isAuthenticated = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);

        notifyListeners();
        return {'success': true, 'message': 'Login realizado com sucesso'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['error'] ?? 'Erro no login'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  /// Faz logout e remove token
  Future<void> logout() async {
    _token = null;
    _isAuthenticated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }
```

3. Atualizar TODOS os métodos `http.get`, `http.post` e `http.put` para usar `_authHeaders`:

Em `fetchClientes()`:
```dart
final response = await http.get(
  Uri.parse('$_baseUrl/api/clientes'),
  headers: _authHeaders,
);
```

Em `fetchServicos()`:
```dart
final response = await http.get(
  Uri.parse('$_baseUrl/api/servicos'),
  headers: _authHeaders,
);
```

Em `fetchAgendamentos()`:
```dart
final response = await http.get(
  Uri.parse('$_baseUrl/api/agendamentos'),
  headers: _authHeaders,
);
```

Em `fetchAgendaHoje()`:
```dart
final response = await http.get(
  Uri.parse('$_baseUrl/api/agenda/hoje'),
  headers: _authHeaders,
);
```

Em `criarCliente()`:
```dart
final response = await http.post(
  Uri.parse('$_baseUrl/api/clientes'),
  headers: _authHeaders,
  body: json.encode({...}),
);
```

Em `criarAgendamento()`:
```dart
final response = await http.post(
  Uri.parse('$_baseUrl/api/agendamentos'),
  headers: _authHeaders,
  body: json.encode({...}),
);
```

Em `concluirAgendamento()`:
```dart
final response = await http.put(
  Uri.parse('$_baseUrl/api/agendamentos/$id/concluir'),
  headers: _authHeaders,
);
```

Em `cancelarAgendamento()`:
```dart
final response = await http.put(
  Uri.parse('$_baseUrl/api/agendamentos/$id/cancelar'),
  headers: _authHeaders,
);
```

4. Adicionar tratamento de 401 em cada método: se `response.statusCode == 401`, chamar `logout()` e retornar mensagem de sessão expirada.
</action>

<acceptance_criteria>
- `api_service.dart` contém `import 'package:shared_preferences/shared_preferences.dart';`
- `api_service.dart` contém `Future<Map<String, dynamic>> login(`
- `api_service.dart` contém `Future<void> logout() async`
- `api_service.dart` contém `Map<String, String> get _authHeaders`
- `api_service.dart` contém `'Authorization': 'Bearer $_token'`
- `api_service.dart` contém `Future<void> loadToken() async`
</acceptance_criteria>

## Tarefa 3: Criar `login_screen.dart`

<read_first>
- barbearia-frontend/lib/screens/home_screen.dart (entender padrão de telas existentes)
- barbearia-frontend/lib/services/api_service.dart (método login)
</read_first>

<action>
Criar `barbearia-frontend/lib/screens/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final apiService = Provider.of<ApiService>(context, listen: false);
    final result = await apiService.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (result['success'] == true) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.content_cut,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                'Barbearia',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Agenda Digital',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Usuário',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Entrar', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```
</action>

<acceptance_criteria>
- `login_screen.dart` existe e contém `class LoginScreen extends StatefulWidget`
- `login_screen.dart` contém `_usernameController`
- `login_screen.dart` contém `_passwordController`
- `login_screen.dart` contém `apiService.login(`
- `login_screen.dart` contém `Navigator.of(context).pushReplacement`
</acceptance_criteria>

## Tarefa 4: Atualizar `main.dart` para verificar autenticação

<read_first>
- barbearia-frontend/lib/main.dart (completo)
</read_first>

<action>
Reescrever `main.dart` para checar o token ao iniciar:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/api_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const BarbeariaApp());
}

class BarbeariaApp extends StatelessWidget {
  const BarbeariaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ApiService(),
        ),
      ],
      child: MaterialApp(
        title: 'Barbearia Agenda',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    await apiService.loadToken();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final apiService = Provider.of<ApiService>(context);
    return apiService.isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}
```
</action>

<acceptance_criteria>
- `main.dart` contém `import 'screens/login_screen.dart';`
- `main.dart` contém `class AuthWrapper extends StatefulWidget`
- `main.dart` contém `apiService.loadToken()`
- `main.dart` contém `apiService.isAuthenticated ? const HomeScreen() : const LoginScreen()`
- `main.dart` contém `home: const AuthWrapper(),`
</acceptance_criteria>

<verification>
```bash
cd barbearia-frontend
flutter pub get
flutter analyze
```
</verification>
