import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Cliente {
  final int id;
  final String nome;
  final String telefone;
  final String dataCadastro;

  Cliente({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.dataCadastro,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nome: json['nome'],
      telefone: json['telefone'] ?? '',
      dataCadastro: json['data_cadastro'] ?? '',
    );
  }
}

class Servico {
  final int id;
  final String nome;
  final String descricao;
  final int duracaoMinutos;
  final double preco;
  final String categoria;
  final bool ativo;

  Servico({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.duracaoMinutos,
    required this.preco,
    required this.categoria,
    required this.ativo,
  });

  factory Servico.fromJson(Map<String, dynamic> json) {
    return Servico(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'] ?? '',
      duracaoMinutos: json['duracao_minutos'] ?? 30,
      preco: (json['preco'] ?? 0.0).toDouble(),
      categoria: json['categoria'] ?? 'Geral',
      ativo: json['ativo'] ?? true,
    );
  }
}

class Agendamento {
  final int id;
  final int clienteId;
  final int servicoId;
  final String dataHora;
  final String observacoes;
  final String status;
  final String clienteNome;
  final String servicoNome;
  final String clienteTelefone;

  Agendamento({
    required this.id,
    required this.clienteId,
    required this.servicoId,
    required this.dataHora,
    required this.observacoes,
    required this.status,
    required this.clienteNome,
    required this.servicoNome,
    required this.clienteTelefone,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'],
      clienteId: json['cliente_id'],
      servicoId: json['servico_id'],
      dataHora: json['data_hora'],
      observacoes: json['observacoes'] ?? '',
      status: json['status'] ?? 'agendado',
      clienteNome: json['cliente_nome'] ?? '',
      servicoNome: json['servico_nome'] ?? '',
      clienteTelefone: json['cliente_telefone'] ?? '',
    );
  }
}

class Despesa {
  final int id;
  final String descricao;
  final double valor;
  final String data;
  final String categoria;

  Despesa({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.categoria,
  });

  factory Despesa.fromJson(Map<String, dynamic> json) {
    return Despesa(
      id: json['id'],
      descricao: json['descricao'],
      valor: (json['valor'] ?? 0.0).toDouble(),
      data: json['data'],
      categoria: json['categoria'] ?? 'Geral',
    );
  }
}

class DashboardData {
  final int totalAgendamentos;
  final int agendamentosConcluidos;
  final double faturamentoEstimado;
  final double faturamentoReal;
  final String period;

  DashboardData({
    required this.totalAgendamentos,
    required this.agendamentosConcluidos,
    required this.faturamentoEstimado,
    required this.faturamentoReal,
    required this.period,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalAgendamentos: json['total_agendamentos'],
      agendamentosConcluidos: json['agendamentos_concluidos'],
      faturamentoEstimado: (json['faturamento_estimado'] ?? 0.0).toDouble(),
      faturamentoReal: (json['faturamento_real'] ?? 0.0).toDouble(),
      period: json['period'],
    );
  }
}

class BarbeariaData {
  final int? id;
  final String? nome;
  final String? telefone;
  final String? endereco;
  final String? logoPath;

  BarbeariaData({
    this.id,
    this.nome,
    this.telefone,
    this.endereco,
    this.logoPath,
  });

  factory BarbeariaData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BarbeariaData();
    return BarbeariaData(
      id: json['id'],
      nome: json['nome'],
      telefone: json['telefone'],
      endereco: json['endereco'],
      logoPath: json['logo_path'],
    );
  }
}

class ProfileData {
  final int id;
  final String username;
  final String email;
  final String nomeExibicao;
  final String telefone;
  final BarbeariaData? barbearia;

  ProfileData({
    required this.id,
    required this.username,
    required this.email,
    required this.nomeExibicao,
    required this.telefone,
    this.barbearia,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      nomeExibicao: json['nome_exibicao'] ?? '',
      telefone: json['telefone'] ?? '',
      barbearia: json['barbearia'] != null ? BarbeariaData.fromJson(json['barbearia']) : null,
    );
  }
}

class ApiService extends ChangeNotifier {
  // Use a getter for baseUrl to ensure safe fallback and avoid crash if dotenv fails early
  String get _baseUrl {
    try {
      return dotenv.get('API_BASE_URL', fallback: 'http://localhost:5000');
    } catch (_) {
      return 'http://localhost:5000';
    }
  }

  List<Cliente> _clientes = [];
  List<Servico> _servicos = [];
  List<Agendamento> _agendamentos = [];
  List<Agendamento> _agendaHoje = [];

  bool _isLoading = false;
  String? _error;
  String? _token;
  bool _isAuthenticated = false;

  List<Cliente> get clientes => _clientes;
  List<Servico> get servicos => _servicos;
  List<Agendamento> get agendamentos => _agendamentos;
  List<Agendamento> get agendaHoje => _agendaHoje;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  DashboardData? _dashboardData;
  DashboardData? get dashboardData => _dashboardData;

  List<Despesa> _despesas = [];
  List<Despesa> get despesas => _despesas;

  Map<String, String> _configs = {};
  Map<String, String> get configs => _configs;

  /// Carrega token salvo do dispositivo
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _isAuthenticated = _token != null;
    
    if (_isAuthenticated) {
      // Tenta registrar o token de push se ja estiver logado
      registrarPushToken();
    }
    
    notifyListeners();
  }

  /// Headers com autenticação
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// Registra o token de push do dispositivo no backend
  Future<void> registrarPushToken() async {
    if (_token == null) return;
    
    debugPrint('Iniciando processo de registro de token de notificação...');

    try {
      String currentPlatform = 'Web';
      if (!kIsWeb) {
        if (defaultTargetPlatform == TargetPlatform.android) currentPlatform = 'Android';
        else if (defaultTargetPlatform == TargetPlatform.iOS) currentPlatform = 'iOS';
        else if (defaultTargetPlatform == TargetPlatform.windows) currentPlatform = 'Windows';
        else currentPlatform = defaultTargetPlatform.name;
      }

      // Tenta obter o token. Em plataformas não suportadas nativamente pela lib oficial,
      // isso pode lançar uma exceção ou retornar nulo.
      String? fcmToken;
      
      // Tenta obter o token independente da plataforma (aproveita suporte experimental/estável de plugins)
      try {
        if (!kIsWeb && 
            (defaultTargetPlatform == TargetPlatform.android || 
             defaultTargetPlatform == TargetPlatform.iOS)) {
          fcmToken = await FirebaseMessaging.instance.getToken();
        }
      } catch (fcmError) {
        debugPrint('Erro ao obter token FCM na plataforma $currentPlatform: $fcmError');
      }

      if (fcmToken != null) {
        debugPrint('Registrando FCM Token no Backend para $currentPlatform: $fcmToken');

        final response = await http.post(
          Uri.parse('$_baseUrl/api/auth/register-token'),
          headers: _authHeaders,
          body: json.encode({
            'token': fcmToken,
            'dispositivo': currentPlatform,
          }),
        );
        
        if (response.statusCode == 200) {
          debugPrint('Token registrado com sucesso no servidor.');
        } else {
          debugPrint('Falha ao registrar token no servidor: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Erro no fluxo de registro de push token: $e');
    }
  }

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

        // Registra o token de push após login bem sucedido
        await registrarPushToken();

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
    _dashboardData = null; // Limpa o dashboard no logout
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }

  /// Faz registro de novo usuário com email
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _token = data['token'];
        _isAuthenticated = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);

        notifyListeners();
        return {'success': true, 'message': data['message'] ?? 'Cadastro realizado com sucesso'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['error'] ?? 'Erro no cadastro'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  // ---- Perfil e Onboarding ----

  bool _isOnboardingDone = false;
  bool get isOnboardingDone => _isOnboardingDone;

  ProfileData? _profileData;
  ProfileData? get profileData => _profileData;

  /// Verifica se o onboarding foi completado
  Future<void> loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isOnboardingDone = prefs.getBool('onboarding_done') ?? false;
    notifyListeners();
  }

  /// Marca o onboarding como concluído
  Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    _isOnboardingDone = true;
    notifyListeners();
  }

  /// Busca dados do perfil do usuário logado
  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/profile'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _profileData = ProfileData.fromJson(data);
        notifyListeners();
        return {'success': true};
      } else if (response.statusCode == 401) {
        await logout();
        return {'success': false, 'message': 'Sessão expirada'};
      } else {
        return {'success': false, 'message': 'Erro ao carregar perfil'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  /// Atualiza dados do perfil
  Future<Map<String, dynamic>> updateProfile({
    String? nomeExibicao,
    String? telefone,
    Map<String, dynamic>? barbearia,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nomeExibicao != null) body['nome_exibicao'] = nomeExibicao;
      if (telefone != null) body['telefone'] = telefone;
      if (barbearia != null) body['barbearia'] = barbearia;

      final response = await http.put(
        Uri.parse('$_baseUrl/api/profile'),
        headers: _authHeaders,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        await fetchProfile();
        return {'success': true, 'message': 'Perfil atualizado com sucesso'};
      } else if (response.statusCode == 401) {
        await logout();
        return {'success': false, 'message': 'Sessão expirada'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['error'] ?? 'Erro ao atualizar perfil'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  Future<void> fetchDashboard({String period = 'today'}) async {
    _isLoading = true;
    _error = null;
    _dashboardData = null; // Limpa dados antigos para forçar atualização visual
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/agenda/dashboard?period=$period'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _dashboardData = DashboardData.fromJson(data);
      } else if (response.statusCode == 401) {
        await logout();
        _error = 'Sessão expirada. Por favor, faça login novamente.';
      } else {
        _error = 'Erro ao carregar dashboard: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchClientes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/clientes'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _clientes = data.map((json) => Cliente.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await logout();
        _error = 'Sessão expirada. Por favor, faça login novamente.';
      } else {
        _error = 'Erro ao carregar clientes: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchServicos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/servicos'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _servicos = data.map((json) => Servico.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await logout();
        _error = 'Sessão expirada. Por favor, faça login novamente.';
      } else {
        _error = 'Erro ao carregar serviços: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAgendamentos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/agendamentos'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _agendamentos = data.map((json) => Agendamento.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await logout();
        _error = 'Sessão expirada. Por favor, faça login novamente.';
      } else {
        _error = 'Erro ao carregar agendamentos: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAgendaHoje() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/agenda/hoje'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _agendaHoje = data.map((json) => Agendamento.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await logout();
        _error = 'Sessão expirada. Por favor, faça login novamente.';
      } else {
        _error = 'Erro ao carregar agenda do dia: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> criarCliente(String nome, String telefone) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/clientes'),
        headers: _authHeaders,
        body: json.encode({
          'nome': nome,
          'telefone': telefone,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        await fetchClientes();
        return {'success': true, 'message': data['message'], 'id': data['id']};
      } else {
        return {'success': false, 'message': 'Erro: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  Future<Map<String, dynamic>> criarAgendamento(
    int clienteId,
    int servicoId,
    String dataHora,
    String observacoes,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/agendamentos'),
        headers: _authHeaders,
        body: json.encode({
          'cliente_id': clienteId,
          'servico_id': servicoId,
          'data_hora': dataHora,
          'observacoes': observacoes,
          'status': 'agendado',
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        await fetchAgendamentos();
        await fetchAgendaHoje();
        return {'success': true, 'message': data['message'], 'id': data['id']};
      } else {
        return {'success': false, 'message': 'Erro: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  Future<Map<String, dynamic>> concluirAgendamento(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/agendamentos/$id/concluir'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        await fetchAgendamentos();
        await fetchAgendaHoje();
        return {'success': true, 'message': 'Agendamento concluído com sucesso'};
      } else {
        return {'success': false, 'message': 'Erro: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  Future<Map<String, dynamic>> cancelarAgendamento(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/agendamentos/$id/cancelar'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        await fetchAgendamentos();
        await fetchAgendaHoje();
        return {'success': true, 'message': 'Agendamento cancelado com sucesso'};
      } else {
        return {'success': false, 'message': 'Erro: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  Future<Map<String, dynamic>> criarServico(String nome, double preco, int duracao, String descricao, String categoria) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/servicos'),
        headers: _authHeaders,
        body: json.encode({
          'nome': nome,
          'preco': preco,
          'duracao_minutos': duracao,
          'descricao': descricao,
          'categoria': categoria,
        }),
      );

      if (response.statusCode == 201) {
        await fetchServicos();
        return {'success': true, 'message': 'Serviço cadastrado'};
      } else {
        return {'success': false, 'message': 'Erro ao criar serviço'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  Future<Map<String, dynamic>> updateServico(int id, String nome, double preco, int duracao, String descricao, String categoria) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/servicos/$id'),
        headers: _authHeaders,
        body: json.encode({
          'nome': nome,
          'preco': preco,
          'duracao_minutos': duracao,
          'descricao': descricao,
          'categoria': categoria,
        }),
      );

      if (response.statusCode == 200) {
        await fetchServicos();
        return {'success': true, 'message': 'Serviço atualizado'};
      } else {
        return {'success': false, 'message': 'Erro ao atualizar'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  Future<void> fetchDespesas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/despesas'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _despesas = data.map((json) => Despesa.fromJson(json)).toList();
      } else {
        _error = 'Erro ao carregar despesas: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> criarDespesa(String descricao, double valor, String data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/despesas'),
        headers: _authHeaders,
        body: json.encode({
          'descricao': descricao,
          'valor': valor,
          'data': data,
        }),
      );

      if (response.statusCode == 201) {
        await fetchDespesas();
        return {'success': true, 'message': 'Despesa cadastrada'};
      } else {
        return {'success': false, 'message': 'Erro ao criar despesa'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteServico(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/servicos/$id'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        await fetchServicos();
        return {'success': true, 'message': 'Serviço removido'};
      } else {
        return {'success': false, 'message': 'Erro ao remover'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteDespesa(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/despesas/$id'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        await fetchDespesas();
        return {'success': true, 'message': 'Despesa removida'};
      } else {
        return {'success': false, 'message': 'Erro ao remover'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  Future<void> fetchConfigs() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/config'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _configs = data.map((key, value) => MapEntry(key, value.toString()));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao carregar configurações: $e');
    }
  }

  Future<Map<String, dynamic>> updateConfigs(Map<String, String> novasConfigs) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/config'),
        headers: _authHeaders,
        body: json.encode(novasConfigs),
      );

      if (response.statusCode == 200) {
        await fetchConfigs();
        return {'success': true, 'message': 'Configurações atualizadas'};
      } else {
        return {'success': false, 'message': 'Erro ao atualizar'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}