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
  late TextEditingController _mensagemController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    _inicioController = TextEditingController(text: apiService.configs['horario_inicio'] ?? '08:00');
    _fimController = TextEditingController(text: apiService.configs['horario_fim'] ?? '18:00');
    _mensagemController = TextEditingController(text: apiService.configs['whatsapp_mensagem'] ?? '');
    
    // Busca configs atualizadas ao abrir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      apiService.fetchConfigs().then((_) {
         setState(() {
           _inicioController.text = apiService.configs['horario_inicio'] ?? '08:00';
           _fimController.text = apiService.configs['horario_fim'] ?? '18:00';
           _mensagemController.text = apiService.configs['whatsapp_mensagem'] ?? '';
         });
      });
    });
  }

  @override
  void dispose() {
    _inicioController.dispose();
    _fimController.dispose();
    _mensagemController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final apiService = Provider.of<ApiService>(context, listen: false);
    
    final result = await apiService.updateConfigs({
      'horario_inicio': _inicioController.text,
      'horario_fim': _fimController.text,
      'whatsapp_mensagem': _mensagemController.text,
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
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
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
                  const SizedBox(height: 32),
                  const Text(
                    'WhatsApp',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _mensagemController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Mensagem de Confirmação',
                      hintText: 'Use {nome}, {servico} e {data_hora} como variáveis.',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dica: {nome} será substituído pelo nome do cliente automaticamente.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
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
