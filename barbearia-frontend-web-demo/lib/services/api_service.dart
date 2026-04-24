import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mock_data.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'data_cadastro': dataCadastro,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'duracao_minutos': duracaoMinutos,
      'preco': preco,
      'categoria': categoria,
      'ativo': ativo,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'servico_id': servicoId,
      'data_hora': dataHora,
      'observacoes': observacoes,
      'status': status,
      'cliente_nome': clienteNome,
      'servico_nome': servicoNome,
      'cliente_telefone': clienteTelefone,
    };
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

  bool _isDemoMode = false;
  bool _isLoading = false;
  String? _error;
  String? _token;
  bool _isAuthenticated = false;

  bool get isDemoMode => _isDemoMode;
  List<Cliente> get clientes => _clientes;
  List<Servico> get servicos => _servicos;
  List<Agendamento> get agendamentos => _agendamentos;
  List<Agendamento> get agendaHoje => _agendaHoje;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isDemoMode ? true : _isAuthenticated;

  DashboardData? _dashboardData;
  DashboardData? get dashboardData => _dashboardData;

  List<Despesa> _despesas = [];
  List<Despesa> get despesas => _despesas;

  Map<String, String> _configs = {};
  Map<String, String> get configs => _configs;

  /// Carrega token salvo do dispositivo e inicializa estado da demo
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Verifica se ja estava em modo demo
    _isDemoMode = prefs.getBool('is_demo_mode') ?? false;
    
    _token = prefs.getString('auth_token');
    _isAuthenticated = (_token != null) || _isDemoMode;
    
    // Se estiver em modo demo, carrega os dados locais
    if (_isDemoMode) {
      await _loadDemoDataLocally();
    }

    if (_isAuthenticated && !_isDemoMode) {
      // Tenta registrar o token de push se ja estiver logado (modo real)
      registrarPushToken();
    }
    
    notifyListeners();
  }

  /// Salva os dados atuais da demo no SharedPreferences
  Future<void> _saveDemoDataLocally() async {
    if (!_isDemoMode) return;
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('demo_clientes', json.encode(_clientes.map((e) => e.toJson()).toList()));
    await prefs.setString('demo_servicos', json.encode(_servicos.map((e) => e.toJson()).toList()));
    await prefs.setString('demo_agendamentos', json.encode(_agendamentos.map((e) => e.toJson()).toList()));
    await prefs.setBool('is_demo_mode', true);
    debugPrint('Dados da demo persistidos localmente.');
  }

  /// Carrega os dados da demo do SharedPreferences
  Future<void> _loadDemoDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    
    final clientesJson = prefs.getString('demo_clientes');
    if (clientesJson != null) {
      final List<dynamic> decoded = json.decode(clientesJson);
      _clientes = decoded.map((e) => Cliente.fromJson(e)).toList();
    } else {
      _clientes = MockData.getClientes();
    }

    final servicosJson = prefs.getString('demo_servicos');
    if (servicosJson != null) {
      final List<dynamic> decoded = json.decode(servicosJson);
      _servicos = decoded.map((e) => Servico.fromJson(e)).toList();
    } else {
      _servicos = MockData.getServicos();
    }

    final agendamentosJson = prefs.getString('demo_agendamentos');
    if (agendamentosJson != null) {
      final List<dynamic> decoded = json.decode(agendamentosJson);
      _agendamentos = decoded.map((e) => Agendamento.fromJson(e)).toList();
    } else {
      _agendamentos = MockData.getAgendamentosHoje();
    }
    
    // Agenda de hoje é filtrada dos agendamentos gerais para a demo
    _agendaHoje = _agendamentos; 
    
    debugPrint('Dados da demo carregados do armazenamento local.');
  }

  /// Limpa todos os dados da demo e restaura o estado original
  Future<void> resetDemo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('demo_clientes');
    await prefs.remove('demo_servicos');
    await prefs.remove('demo_agendamentos');
    await prefs.remove('onboarding_done');
    
    _clientes = MockData.getClientes();
    _servicos = MockData.getServicos();
    _agendamentos = MockData.getAgendamentosHoje();
    _agendaHoje = _agendamentos;
    _isOnboardingDone = false;
    
    await _saveDemoDataLocally();
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
    // MODO DEMO: Se o usuário for 'demo' ou 'admin', entra no modo mock
    if (username.toLowerCase() == 'demo' || username.toLowerCase() == 'admin' || username.toLowerCase() == 'visitante') {
      _isDemoMode = true;
      _isAuthenticated = true;
      notifyListeners();
      return {'success': true, 'message': 'Entrando em Modo Demonstração'};
    }

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
    _isDemoMode = false;
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

      if (_isDemoMode) {
        _profileData = ProfileData(
          id: 999,
          username: "demo",
          email: "demo@klipper.com",
          nomeExibicao: nomeExibicao ?? "Usuário Demo",
          telefone: telefone ?? "(11) 99999-9999",
          barbearia: BarbeariaData(
            id: 1,
            nome: barbearia != null ? barbearia['nome'] : "Klipper Barber",
            telefone: barbearia != null ? barbearia['telefone'] : "(11) 3333-4444",
            endereco: barbearia != null ? barbearia['endereco'] : "Av. Demo, 123",
          ),
        );
        notifyListeners();
        return {'success': true, 'message': 'Perfil Demo atualizado'};
      }

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
    if (_isDemoMode && _agendaHoje.isEmpty) {
      _dashboardData = DashboardData(
        totalAgendamentos: 0,
        agendamentosConcluidos: 0,
        faturamentoEstimado: 0,
        faturamentoReal: 0,
        period: 'Hoje',
      );
      notifyListeners();
    }
    
    try {
      final supabase = Supabase.instance.client;
      
      // Busca estatísticas básicas do Supabase
      final List<dynamic> agendamentos = await supabase
          .from('agendamentos')
          .select('status, servicos(preco)');

      int total = agendamentos.length;
      int concluidos = agendamentos.where((a) => a['status'] == 'concluido').length;
      double estimado = 0;
      double real = 0;

      for (var a in agendamentos) {
        double preco = (a['servicos']['preco'] ?? 0).toDouble();
        estimado += preco;
        if (a['status'] == 'concluido') real += preco;
      }

      _dashboardData = DashboardData(
        totalAgendamentos: total,
        agendamentosConcluidos: concluidos,
        faturamentoEstimado: estimado,
        faturamentoReal: real,
        period: 'Geral (Supabase)',
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar dashboard do Supabase: $e');
      // Fallback para demo
      if (_isDemoMode && _dashboardData == null) {
        _dashboardData = DashboardData(
          totalAgendamentos: 12,
          agendamentosConcluidos: 8,
          faturamentoEstimado: 450.0,
          faturamentoReal: 320.0,
          period: 'Hoje (Demo)',
        );
        notifyListeners();
      }
    }
  }

  Future<void> fetchClientes() async {
    if (_isDemoMode) {
      if (_clientes.isEmpty) await _loadDemoDataLocally();
      notifyListeners();
      return;
    }
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
    if (_isDemoMode) {
      if (_servicos.isEmpty) await _loadDemoDataLocally();
      notifyListeners();
      return;
    }
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
    if (_isDemoMode) {
      if (_agendamentos.isEmpty) await _loadDemoDataLocally();
      notifyListeners();
      return;
    }
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
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;
      
      // Busca agendamentos com nomes de clientes e serviços
      final List<dynamic> data = await supabase
          .from('agendamentos')
          .select('''
            *,
            clientes (nome, telefone),
            servicos (nome)
          ''')
          .order('data_hora', ascending: true);

      _agendaHoje = data.map((item) {
        return Agendamento(
          id: item['id'],
          clienteId: item['cliente_id'],
          servicoId: item['servico_id'],
          dataHora: item['data_hora'],
          observacoes: item['observacoes'] ?? '',
          status: item['status'] ?? 'agendado',
          clienteNome: item['clientes']['nome'] ?? 'Cliente',
          servicoNome: item['servicos']['nome'] ?? 'Serviço',
          clienteTelefone: item['clientes']['telefone'] ?? '',
        );
      }).toList();

      debugPrint('Agenda carregada do Supabase: ${_agendaHoje.length} itens.');
      _error = null;
    } catch (e) {
      debugPrint('Erro ao buscar agenda no Supabase: $e');
      _error = 'Erro ao carregar agenda: $e';
      
      // Fallback para demo se falhar o Supabase
      if (_isDemoMode) {
        _agendaHoje = _agendamentos;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> criarCliente(String nome, String telefone) async {
    if (_isDemoMode) {
      final novoId = _clientes.isEmpty ? 1 : _clientes.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
      final novo = Cliente(
        id: novoId,
        nome: nome,
        telefone: telefone,
        dataCadastro: DateTime.now().toString().split(' ')[0],
      );
      _clientes.add(novo);
      await _saveDemoDataLocally();
      notifyListeners();
      return {'success': true, 'message': 'Cliente Demo criado', 'id': novoId};
    }
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
    if (_isDemoMode) {
      final novoId = _agendamentos.isEmpty ? 101 : _agendamentos.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
      _agendamentos.add(Agendamento(
        id: novoId,
        clienteId: clienteId,
        servicoId: servicoId,
        dataHora: dataHora,
        observacoes: observacoes,
        status: 'agendado',
        clienteNome: _clientes.firstWhere((e) => e.id == clienteId, orElse: () => Cliente(id:0, nome:'Anonimo', telefone:'', dataCadastro:'')).nome,
        servicoNome: _servicos.firstWhere((e) => e.id == servicoId, orElse: () => Servico(id:0, nome:'Servico', descricao:'', duracaoMinutos:30, preco:0, categoria:'', ativo:true)).nome,
        clienteTelefone: '',
      ));
      await _saveDemoDataLocally();
      notifyListeners();
      return {'success': true, 'message': 'Agendamento Demo criado', 'id': novoId};
    }
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
    if (_isDemoMode) {
      final index = _agendamentos.indexWhere((e) => e.id == id);
      if (index != -1) {
        final a = _agendamentos[index];
        _agendamentos[index] = Agendamento(
          id: a.id,
          clienteId: a.clienteId,
          servicoId: a.servicoId,
          dataHora: a.dataHora,
          observacoes: a.observacoes,
          status: 'concluido',
          clienteNome: a.clienteNome,
          servicoNome: a.servicoNome,
          clienteTelefone: a.clienteTelefone,
        );
        await _saveDemoDataLocally();
        notifyListeners();
      }
      return {'success': true, 'message': 'Agendamento concluído (Demo)'};
    }
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
    if (_isDemoMode) {
      final index = _agendamentos.indexWhere((e) => e.id == id);
      if (index != -1) {
        final a = _agendamentos[index];
        _agendamentos[index] = Agendamento(
          id: a.id,
          clienteId: a.clienteId,
          servicoId: a.servicoId,
          dataHora: a.dataHora,
          observacoes: a.observacoes,
          status: 'cancelado',
          clienteNome: a.clienteNome,
          servicoNome: a.servicoNome,
          clienteTelefone: a.clienteTelefone,
        );
        await _saveDemoDataLocally();
        notifyListeners();
      }
      return {'success': true, 'message': 'Agendamento cancelado (Demo)'};
    }
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
    if (_isDemoMode) {
      final novoId = _servicos.isEmpty ? 1 : _servicos.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
      _servicos.add(Servico(
        id: novoId,
        nome: nome,
        descricao: descricao,
        duracaoMinutos: duracao,
        preco: preco,
        categoria: categoria,
        ativo: true,
      ));
      await _saveDemoDataLocally();
      notifyListeners();
      return {'success': true, 'message': 'Serviço Demo criado'};
    }
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
    if (_isDemoMode) {
      final index = _servicos.indexWhere((e) => e.id == id);
      if (index != -1) {
        _servicos[index] = Servico(
          id: id,
          nome: nome,
          descricao: descricao,
          duracaoMinutos: duracao,
          preco: preco,
          categoria: categoria,
          ativo: true,
        );
        await _saveDemoDataLocally();
        notifyListeners();
      }
      return {'success': true, 'message': 'Serviço atualizado (Demo)'};
    }
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
    if (_isDemoMode) {
      notifyListeners();
      return;
    }
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
    if (_isDemoMode) {
      return {'success': true, 'message': 'Despesa Demo registrada'};
    }
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
    if (_isDemoMode) {
      _servicos.removeWhere((e) => e.id == id);
      await _saveDemoDataLocally();
      notifyListeners();
      return {'success': true, 'message': 'Serviço removido (Demo)'};
    }
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
    if (_isDemoMode) {
      _despesas.removeWhere((e) => e.id == id);
      notifyListeners();
      return {'success': true, 'message': 'Despesa removida (Demo)'};
    }
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
    if (_isDemoMode) {
      _configs = {
        'nome_fantasia': 'Klipper Demo',
        'cor_primaria': '#0F172A',
      };
      notifyListeners();
      return;
    }
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
    if (_isDemoMode) {
      _configs.addAll(novasConfigs);
      notifyListeners();
      return {'success': true, 'message': 'Configurações atualizadas (Demo)'};
    }
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

  // ---- Supabase Realtime Integration ----

  RealtimeChannel? _agendamentosChannel;

  /// Inicializa o listener de tempo real para novos agendamentos no Supabase
  void initSupabaseRealtime(Function(String title, String body) onNotification) {
    debugPrint('Iniciando listener Supabase Realtime...');
    
    try {
      final supabase = Supabase.instance.client;
      
      _agendamentosChannel = supabase.channel('public:agendamentos')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'agendamentos',
          callback: (payload) async {
            debugPrint('Novo agendamento detectado via Supabase Realtime!');
            
            // Busca dados complementares (nome do cliente) para a notificação
            final clienteId = payload.newRecord['cliente_id'];
            final clienteData = await supabase
                .from('clientes')
                .select('nome')
                .eq('id', clienteId)
                .maybeSingle();

            final nomeCliente = clienteData?['nome'] ?? 'Um cliente';
            
            onNotification(
              'Novo Agendamento! 💈',
              '$nomeCliente acabou de agendar um horário pelo chat.'
            );
            
            // Atualiza a agenda localmente
            fetchAgendaHoje();
            fetchDashboard();
          },
        ).subscribe();
        
      debugPrint('Canal Supabase Realtime assinado com sucesso.');
    } catch (e) {
      debugPrint('Erro ao inicializar Supabase Realtime: $e');
    }
  }

  @override
  void dispose() {
    _agendamentosChannel?.unsubscribe();
    super.dispose();
  }
}