import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_service.dart';
import '../widgets/agenda_card.dart';

class AgendamentosScreen extends StatefulWidget {
  const AgendamentosScreen({super.key});

  @override
  State<AgendamentosScreen> createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  String _filtroStatus = 'todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAgendamentos();
    });
  }

  void _loadAgendamentos() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.fetchAgendamentos();
  }

  void _refreshAgendamentos() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.fetchAgendamentos();
  }

  List<Agendamento> _filtrarAgendamentos(List<Agendamento> agendamentos) {
    if (_filtroStatus == 'todos') {
      return agendamentos;
    }
    return agendamentos
        .where((ag) => ag.status == _filtroStatus)
        .toList();
  }

  String _formatarDataHora(String dataHora) {
    try {
      final dateTime = DateTime.parse(dataHora);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dataHora;
    }
  }

  Future<void> _abrirWhatsApp(Agendamento agendamento, String template) async {
    if (agendamento.clienteTelefone.isEmpty) return;

    String text = template
        .replaceAll('{nome}', agendamento.clienteNome)
        .replaceAll('{servico}', agendamento.servicoNome)
        .replaceAll('{data_hora}', _formatarDataHora(agendamento.dataHora));

    final url = Uri.parse('whatsapp://send?phone=55${agendamento.clienteTelefone}&text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      final webUrl = Uri.parse('https://wa.me/55${agendamento.clienteTelefone}?text=${Uri.encodeComponent(text)}');
      launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmarCancelamento(Agendamento agendamento, ApiService apiService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Agendamento'),
        content: const Text('Deseja realmente cancelar este horário?\n\nVocê também pode avisar o cliente via WhatsApp dizendo que foi cancelado.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _executarCancelamento(agendamento, apiService, false);
            },
            child: const Text('Apenas Cancelar', style: TextStyle(color: Colors.red)),
          ),
          if (agendamento.clienteTelefone.isNotEmpty)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                Navigator.pop(context);
                _executarCancelamento(agendamento, apiService, true);
              },
              icon: const Icon(Icons.chat, color: Colors.white, size: 18),
              label: const Text('Cancelar e Avisar', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Future<void> _executarCancelamento(Agendamento agendamento, ApiService apiService, bool avisarWhatsapp) async {
    final result = await apiService.cancelarAgendamento(agendamento.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        ),
      );
      if (result['success'] == true) {
        _refreshAgendamentos();
        if (avisarWhatsapp) {
          final template = apiService.configs['whatsapp_mensagem_cancelamento'] ?? 'Olá {nome}, seu agendamento de {servico} foi cancelado.';
          _abrirWhatsApp(agendamento, template);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAgendamentos,
          ),
        ],
      ),
      body: Consumer<ApiService>(
        builder: (context, apiService, child) {
          final agendamentosFiltrados = _filtrarAgendamentos(apiService.agendamentos);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filtrar por status:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildStatusChip('todos', 'Todos'),
                              const SizedBox(width: 8),
                              _buildStatusChip('agendado', 'Agendados'),
                              const SizedBox(width: 8),
                              _buildStatusChip('concluido', 'Concluídos'),
                              const SizedBox(width: 8),
                              _buildStatusChip('cancelado', 'Cancelados'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${agendamentosFiltrados.length} agendamentos',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: apiService.isLoading && apiService.agendamentos.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : agendamentosFiltrados.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                const Text(
                                  'Nenhum agendamento encontrado',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Toque no botão + na aba inicial',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              _refreshAgendamentos();
                            },
                            child: ListView.builder(
                              itemCount: agendamentosFiltrados.length,
                              itemBuilder: (context, index) {
                                final agendamento = agendamentosFiltrados[index];
                                return AgendaCard(
                                  agendamento: agendamento,
                                  onWhatsapp: agendamento.clienteTelefone.isNotEmpty
                                      ? () {
                                          final template = apiService.configs['whatsapp_mensagem'] ?? 'Olá {nome}, tudo bem? Confirmando seu agendamento de {servico} para as {data_hora}.';
                                          _abrirWhatsApp(agendamento, template);
                                        }
                                      : null,
                                  onConcluir: agendamento.status == 'agendado'
                                      ? () async {
                                          final result = await apiService.concluirAgendamento(agendamento.id);
                                          if (result['success'] == true) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(result['message']),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                            _refreshAgendamentos();
                                          } else {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(result['message']),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      : null,
                                  onCancelar: agendamento.status == 'agendado'
                                      ? () => _confirmarCancelamento(agendamento, apiService)
                                      : null,
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status, String label) {
    final bool selecionado = _filtroStatus == status;
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'agendado':
        backgroundColor = selecionado ? Colors.blue : Colors.blue.withOpacity(0.1);
        textColor = selecionado ? Colors.white : Colors.blue;
        break;
      case 'concluido':
        backgroundColor = selecionado ? Colors.green : Colors.green.withOpacity(0.1);
        textColor = selecionado ? Colors.white : Colors.green;
        break;
      case 'cancelado':
        backgroundColor = selecionado ? Colors.red : Colors.red.withOpacity(0.1);
        textColor = selecionado ? Colors.white : Colors.red;
        break;
      default:
        backgroundColor = selecionado ? Colors.grey : Colors.grey.withOpacity(0.1);
        textColor = selecionado ? Colors.white : Colors.grey;
    }

    return ChoiceChip(
      label: Text(label),
      selected: selecionado,
      onSelected: (selected) {
        setState(() {
          _filtroStatus = status;
        });
      },
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(color: textColor),
      selectedColor: backgroundColor,
    );
  }
}