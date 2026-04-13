import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

import '../services/api_service.dart';
import '../widgets/agenda_card.dart';
import 'clientes_screen.dart';
import 'servicos_screen.dart';
import 'agendamentos_screen.dart';
import 'novo_agendamento_screen.dart';

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'settings_screen.dart';
import 'financeiro_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _setupRealtimeUpdate();
    });
  }

  void _setupRealtimeUpdate() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isWindows)) {
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop) _buildNavigationRail(),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'Dashboard',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _refreshData,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              drawer: !isDesktop ? _buildDrawer() : null,
              body: _buildMainContent(),
              floatingActionButton: OpenContainer(
                transitionType: ContainerTransitionType.fade,
                openBuilder: (context, _) => const NovoAgendamentoScreen(),
                closedElevation: 6.0,
                closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                closedColor: Theme.of(context).colorScheme.primary,
                closedBuilder: (context, openContainer) => FloatingActionButton(
                  onPressed: openContainer,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() => _selectedIndex = index);
        _handleNavigation(index);
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Image.asset('assets/images/logo.png', width: 40),
      ),
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
        NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: Text('Clientes')),
        NavigationRailDestination(icon: Icon(Icons.cut_outlined), selectedIcon: Icon(Icons.cut), label: Text('Serviços')),
        NavigationRailDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: Text('Agenda')),
        NavigationRailDestination(icon: Icon(Icons.monetization_on_outlined), selectedIcon: Icon(Icons.monetization_on), label: Text('Vendas')),
        NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Ajustes')),
        NavigationRailDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: Text('Sobre')),
      ],
    );
  }

  void _handleNavigation(int index) {
    Widget screen;
    switch (index) {
      case 1: screen = const ClientesScreen(); break;
      case 2: screen = const ServicosScreen(); break;
      case 3: screen = const AgendamentosScreen(); break;
      case 4: screen = const FinanceiroScreen(); break;
      case 5: screen = const SettingsScreen(); break;
      case 6: screen = const AboutScreen(); break;
      default: return;
    }
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
    ));
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
            decoration: const BoxDecoration(color: Color(0xFF0F172A)),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset('assets/images/logo.png', width: 60, height: 60, fit: BoxFit.contain),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text('Ponto do Corte', 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', 0, () => Navigator.pop(context)),
          _buildDrawerItem(Icons.people, 'Clientes', 1, () => _handleNavigation(1)),
          _buildDrawerItem(Icons.cut, 'Serviços', 2, () => _handleNavigation(2)),
          _buildDrawerItem(Icons.calendar_today, 'Agenda Completa', 3, () => _handleNavigation(3)),
          _buildDrawerItem(Icons.monetization_on, 'Financeiro', 4, () => _handleNavigation(4)),
          _buildDrawerItem(Icons.settings, 'Configurações', 5, () => _handleNavigation(5)),
          _buildDrawerItem(Icons.info, 'Sobre', 6, () => _handleNavigation(6)),
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
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : null),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : null)),
      selected: isSelected,
      onTap: onTap,
    );
  }
}