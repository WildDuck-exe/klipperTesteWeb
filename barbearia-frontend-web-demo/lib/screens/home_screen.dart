import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
import '../widgets/agenda_card.dart';
import '../widgets/magic_bottom_nav.dart';
import 'clientes_screen.dart';
import 'servicos_screen.dart';
import 'agendamentos_screen.dart';
import 'financeiro_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';
import 'profile_screen.dart';
import 'novo_agendamento_screen.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _setupRealtimeUpdate();
    });
  }

  void _checkInitialRoute() {
    final path = Uri.base.path;
    if (path.contains('/clientes')) {
      _selectedIndex = 1;
    } else if (path.contains('/agendamentos')) {
      _selectedIndex = 2;
    } else if (path.contains('/servicos')) {
      _selectedIndex = 3;
    } else if (path.contains('/financeiro')) {
      _selectedIndex = 4;
    } else {
      _selectedIndex = 0;
    }
  }

  void _setupRealtimeUpdate() {
    if (kIsWeb) return; // Blindagem total na Web

    if (defaultTargetPlatform == TargetPlatform.android || 
        defaultTargetPlatform == TargetPlatform.iOS || 
        defaultTargetPlatform == TargetPlatform.windows) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _refreshData();
        if (mounted) {
          _showNewBookingDialog(
            message.notification?.title ?? 'Novo Agendamento',
            message.notification?.body ?? 'Um cliente acabou de agendar via chat.'
          );
        }
      });
    }
  }

  void _showNewBookingDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.blue),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _refreshData();
            },
            child: const Text('Ver Agenda'),
          ),
        ],
      ),
    );
  }

  void _loadData() {
    _refreshData();
  }

  void _refreshData() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.fetchAgendaHoje();
    apiService.fetchDashboard(period: _selectedPeriod);
  }

  String _selectedPeriod = 'today';

  void _onTabSelected(int index) {
    if (_selectedIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() => _selectedIndex = index);
    
    if (kIsWeb) {
      final paths = ['/home', '/clientes', '/agendamentos', '/servicos', '/financeiro'];
      html.window.history.pushState(null, 'Klipper', paths[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          if (isDesktop) _buildNavigationRail(),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildDashboardStack(MediaQuery.of(context).size.width > 900),
                const ClientesScreen(),
                const AgendamentosScreen(),
                const ServicosScreen(),
                const FinanceiroScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : MagicBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
      floatingActionButton: [0, 2, 4].contains(_selectedIndex) ? FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          if (_selectedIndex == 4) {
            // Financeiro — open Nova Despesa bottom sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (ctx) => _buildNovaDespesaSheet(ctx),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NovoAgendamentoScreen()),
            );
          }
        },
        backgroundColor: _selectedIndex == 4 ? Colors.redAccent : Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        heroTag: 'home_fab',
        child: Icon(_selectedIndex == 4 ? Icons.remove : Icons.add),
      ) : null,
      drawer: isDesktop ? null : _buildDrawer(),
    );
  }

  Widget _buildDashboardStack(bool isDesktop) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        leading: isDesktop ? null : Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            );
          }
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildMainContent(),
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onTabSelected,
      backgroundColor: Theme.of(context).colorScheme.surface,
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Image.asset('assets/images/layout/logo_klipper.png', width: 40, fit: BoxFit.contain),
      ),
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
        NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: Text('Clientes')),
        NavigationRailDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: Text('Agenda')),
        NavigationRailDestination(icon: Icon(Icons.cut_outlined), selectedIcon: Icon(Icons.cut), label: Text('Serviços')),
        NavigationRailDestination(icon: Icon(Icons.monetization_on_outlined), selectedIcon: Icon(Icons.monetization_on), label: Text('Vendas')),
      ],
    );
  }

  Widget _buildMainContent() {
    return Consumer<ApiService>(
      builder: (context, apiService, child) {
        if (apiService.isLoading && apiService.agendaHoje.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async => _refreshData(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Resumo Geral',
                            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          _buildPeriodSelector(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (apiService.dashboardData != null) _buildDashboard(apiService),
                      const SizedBox(height: 32),
                      Text(
                        'Agenda de Hoje',
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${apiService.agendaHoje.length} compromissos marcados',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              if (apiService.agendaHoje.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final agendamento = apiService.agendaHoje[index];
                      return AgendaCard(
                        agendamento: agendamento,
                        onConcluir: () => _concluirBooking(apiService, agendamento),
                        onCancelar: () => _cancelarBooking(apiService, agendamento),
                      );
                    },
                    childCount: apiService.agendaHoje.length,
                  ),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'today', label: Text('Hoje')),
          ButtonSegment(value: 'weekly', label: Text('Semana')),
        ],
        selected: {_selectedPeriod},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() => _selectedPeriod = newSelection.first);
          _refreshData();
        },
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          side: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDashboard(ApiService apiService) {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            'Agendados',
            apiService.dashboardData!.totalAgendamentos.toString(),
            Icons.calendar_today,
            const [Color(0xFF6366F1), Color(0xFF4F46E5)],
          ),
          _buildStatCard(
            'Concluídos',
            apiService.dashboardData!.agendamentosConcluidos.toString(),
            Icons.check_circle,
            const [Color(0xFF22C55E), Color(0xFF16A34A)],
          ),
          _buildStatCard(
            'Receita Confirmada',
            'R\$ ${apiService.dashboardData!.faturamentoReal.toStringAsFixed(0)}',
            Icons.monetization_on,
            const [Color(0xFFF59E0B), Color(0xFFD97706)],
          ),
          _buildStatCard(
            'Receita Prevista',
            'R\$ ${apiService.dashboardData!.faturamentoEstimado.toStringAsFixed(0)}',
            Icons.trending_up,
            const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, List<Color> colors) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: colors.last.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10, top: -10,
            child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                FittedBox(
                  child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_available_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          Text('Tudo tranquilo!', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Nenhum agendamento pendente para agora.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _concluirBooking(ApiService api, Agendamento ag) async {
    HapticFeedback.mediumImpact();
    final res = await api.concluirAgendamento(ag.id);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: Colors.green));
  }

  Future<void> _cancelarBooking(ApiService api, Agendamento ag) async {
    final res = await api.cancelarAgendamento(ag.id);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: Colors.red));
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/images/layout/logo_klipper.png', width: 60, height: 60, fit: BoxFit.contain),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text('Klipper', 
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItemRoute(Icons.person, 'Meu Perfil', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          }),
          _buildDrawerItemRoute(Icons.settings, 'Configurações', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          }),
          _buildDrawerItemRoute(Icons.info, 'Sobre o app', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
          }),
          _buildDrawerItemRoute(Icons.help_outline, 'Ajuda', () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Ajuda'),
                content: const Text('Funcionalidade em desenvolvimento.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () => Provider.of<ApiService>(context, listen: false).logout(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: _selectedIndex == index ? Theme.of(context).primaryColor : null),
      title: Text(title, style: TextStyle(fontWeight: _selectedIndex == index ? FontWeight.bold : null)),
      selected: _selectedIndex == index,
      onTap: onTap,
    );
  }

  Widget _buildDrawerItemRoute(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildNovaDespesaSheet(BuildContext ctx) {
    final descController = TextEditingController();
    final valorController = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nova Despesa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: descController,
            decoration: const InputDecoration(labelText: 'Descrição (Ex: Luz, Aluguel)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: valorController,
            decoration: const InputDecoration(labelText: 'Valor (R\$)', border: OutlineInputBorder(), prefixText: 'R\$ '),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                if (descController.text.isEmpty || valorController.text.isEmpty) return;

                final apiService = Provider.of<ApiService>(context, listen: false);
                final valor = double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0.0;
                final dataHoje = DateFormat('yyyy-MM-dd').format(DateTime.now());

                await apiService.criarDespesa(descController.text, valor, dataHoje);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Despesa criada!')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
              child: const Text('Salvar Despesa'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}