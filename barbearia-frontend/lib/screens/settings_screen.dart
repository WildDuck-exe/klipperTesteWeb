import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _inicioController;
  late TextEditingController _fimController;
  late TextEditingController _pausaInicioController;
  late TextEditingController _pausaFimController;

  late TextEditingController _mensagemRecepcaoController;
  late TextEditingController _mensagemPausaController;
  late TextEditingController _mensagemFechadoController;
  late TextEditingController _mensagemCancelamentoController;

  List<int> _diasSelecionados = [];
  bool _isLoading = false;

  final List<String> _diasSemana = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

  @override
  void initState() {
    super.initState();
    _initControllers();

    // Busca configs atualizadas ao abrir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApiService>(context, listen: false).fetchConfigs().then((_) {
         if (mounted) {
           setState(() {
             _initControllers();
           });
         }
      });
    });
  }

  void _initControllers() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    _inicioController = TextEditingController(text: apiService.configs['horario_inicio'] ?? '08:00');
    _fimController = TextEditingController(text: apiService.configs['horario_fim'] ?? '18:00');
    _pausaInicioController = TextEditingController(text: apiService.configs['pausa_inicio'] ?? '12:00');
    _pausaFimController = TextEditingController(text: apiService.configs['pausa_fim'] ?? '13:00');

    _mensagemRecepcaoController = TextEditingController(text: apiService.configs['whatsapp_mensagem'] ?? '');
    _mensagemPausaController = TextEditingController(text: apiService.configs['whatsapp_mensagem_pausa'] ?? '');
    _mensagemFechadoController = TextEditingController(text: apiService.configs['whatsapp_mensagem_fechado'] ?? '');
    _mensagemCancelamentoController = TextEditingController(text: apiService.configs['whatsapp_mensagem_cancelamento'] ?? '');

    final diasStr = apiService.configs['dias_trabalho'] ?? '1,2,3,4,5,6';
    _diasSelecionados = diasStr.split(',').where((e) => e.isNotEmpty).map((e) => int.tryParse(e) ?? 0).toList();
  }

  @override
  void dispose() {
    _inicioController.dispose();
    _fimController.dispose();
    _pausaInicioController.dispose();
    _pausaFimController.dispose();
    _mensagemRecepcaoController.dispose();
    _mensagemPausaController.dispose();
    _mensagemFechadoController.dispose();
    _mensagemCancelamentoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final apiService = Provider.of<ApiService>(context, listen: false);

    final result = await apiService.updateConfigs({
      'horario_inicio': _inicioController.text,
      'horario_fim': _fimController.text,
      'pausa_inicio': _pausaInicioController.text,
      'pausa_fim': _pausaFimController.text,
      'dias_trabalho': _diasSelecionados.join(','),
      'whatsapp_mensagem': _mensagemRecepcaoController.text,
      'whatsapp_mensagem_pausa': _mensagemPausaController.text,
      'whatsapp_mensagem_fechado': _mensagemFechadoController.text,
      'whatsapp_mensagem_cancelamento': _mensagemCancelamentoController.text,
    });

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
      if (result['success']) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expediente',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('Dias de Trabalho:', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List.generate(7, (index) {
                      final bool isSelected = _diasSelecionados.contains(index);
                      return ChoiceChip(
                        label: Text(_diasSemana[index]),
                        selected: isSelected,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        backgroundColor: Colors.blue.withOpacity(0.05),
                        selectedColor: const Color(0xFF0D47A1),
                        labelStyle: TextStyle(
                           color: isSelected ? Colors.white : const Color(0xFF0D47A1),
                           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _diasSelecionados.add(index);
                            } else {
                              _diasSelecionados.remove(index);
                            }
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _inicioController,
                          decoration: const InputDecoration(
                            labelText: 'Abertura (HH:mm)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.wb_sunny_outlined),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _fimController,
                          decoration: const InputDecoration(
                            labelText: 'Fechamento (HH:mm)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.nightlight_round_outlined),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _pausaInicioController,
                          decoration: const InputDecoration(
                            labelText: 'Pausa Início',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.restaurant_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _pausaFimController,
                          decoration: const InputDecoration(
                            labelText: 'Pausa Fim',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.work_outline),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ExpansionTile(
                    title: const Text(
                      'Templates de Mensagens (WhatsApp)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Clique para ver ou editar suas mensagens'),
                    leading: const Icon(Icons.message, color: Colors.green),
                    collapsedBackgroundColor: Colors.green.withOpacity(0.05),
                    backgroundColor: Colors.green.withOpacity(0.02),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    childrenPadding: const EdgeInsets.all(16),
                    iconColor: Colors.green,
                    children: [
                      TextFormField(
                        controller: _mensagemRecepcaoController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Recepção / Confirmação',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _mensagemPausaController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Aviso de Horário de Almoço',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _mensagemFechadoController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Aviso de Barbearia Fechada',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _mensagemCancelamentoController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Aviso de Cancelamento / Remarcação',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Dica: Use {nome}, {servico} e {data_hora} como variáveis dinâmicas.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _salvar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Salvar Alterações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
