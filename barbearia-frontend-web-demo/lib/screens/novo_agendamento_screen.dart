import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';

class NovoAgendamentoScreen extends StatefulWidget {
  const NovoAgendamentoScreen({super.key});

  @override
  State<NovoAgendamentoScreen> createState() => _NovoAgendamentoScreenState();
}

class _NovoAgendamentoScreenState extends State<NovoAgendamentoScreen> {
  final _observacoesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int? _clienteSelecionadoId;
  int? _servicoSelecionadoId;
  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDados();
    });
  }

  void _loadDados() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.fetchClientes();
    apiService.fetchServicos();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  Future<void> _selecionarHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada,
    );
    if (picked != null && picked != _horaSelecionada) {
      setState(() {
        _horaSelecionada = picked;
      });
    }
  }

  Future<void> _criarAgendamento() async {
    if (_formKey.currentState!.validate()) {
      if (_clienteSelecionadoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione um cliente'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_servicoSelecionadoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione um serviço'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final dataHora = DateTime(
        _dataSelecionada.year,
        _dataSelecionada.month,
        _dataSelecionada.day,
        _horaSelecionada.hour,
        _horaSelecionada.minute,
      );

      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.criarAgendamento(
        _clienteSelecionadoId!,
        _servicoSelecionadoId!,
        dataHora.toIso8601String(),
        _observacoesController.text,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
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
      body: Consumer<ApiService>(
        builder: (context, apiService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Novo Agendamento',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Cliente',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          apiService.clientes.isEmpty
                              ? const Text(
                                  'Nenhum cliente cadastrado',
                                  style: TextStyle(color: Colors.grey),
                                )
                              : DropdownButtonFormField<int>(
                                  value: _clienteSelecionadoId,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  items: apiService.clientes.map((cliente) {
                                    return DropdownMenuItem<int>(
                                      value: cliente.id,
                                      child: Text(cliente.nome),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _clienteSelecionadoId = value;
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
                          const Text(
                            'Serviço',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          apiService.servicos.isEmpty
                              ? const Text(
                                  'Nenhum serviço cadastrado',
                                  style: TextStyle(color: Colors.grey),
                                )
                              : DropdownButtonFormField<int>(
                                  value: _servicoSelecionadoId,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.cut),
                                  ),
                                  items: apiService.servicos.map((servico) {
                                    return DropdownMenuItem<int>(
                                      value: servico.id,
                                      child: Text(servico.nome),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _servicoSelecionadoId = value;
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
                          const Text(
                            'Data e Hora',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selecionarData(context),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.calendar_today),
                                    ),
                                    child: Text(
                                      DateFormat('dd/MM/yyyy').format(_dataSelecionada),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selecionarHora(context),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.access_time),
                                    ),
                                    child: Text(
                                      _horaSelecionada.format(context),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Observações',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _observacoesController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Observações (opcional)',
                              prefixIcon: Icon(Icons.note),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _criarAgendamento,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'AGENDAR',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }
}