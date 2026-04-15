import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class FinanceiroScreen extends StatefulWidget {
  const FinanceiroScreen({super.key});

  @override
  State<FinanceiroScreen> createState() => _FinanceiroScreenState();
}

class _FinanceiroScreenState extends State<FinanceiroScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDados();
    });
  }

  void _carregarDados() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.fetchDespesas();
    apiService.fetchDashboard(period: 'today');
  }

  void _showNovaDespesa() {
    final descController = TextEditingController();
    final valorController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
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
                  
                  final result = await apiService.criarDespesa(descController.text, valor, dataHoje);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
                child: const Text('Salvar Despesa'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financeiro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
          ),
        ],
      ),
      body: Consumer<ApiService>(
        builder: (context, apiService, child) {
          final totalDespesas = apiService.despesas.fold(0.0, (sum, item) => sum + item.valor);
          final faturamento = apiService.dashboardData?.faturamentoReal ?? 0.0;
          final lucro = faturamento - totalDespesas;

          return Column(
            children: [
              // Resumo Financeiro
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        const Text('Meu Lucro (Hoje)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          'R\$ ${lucro.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem('Faturamento', faturamento, Colors.greenAccent),
                            _buildSummaryItem('Despesas', totalDespesas, Colors.redAccent),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Row(
                      children: [
                        Icon(Icons.list_alt, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        const Text('Últimas Despesas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: apiService.despesas.isEmpty
                  ? const Center(child: Text('Nenhuma despesa cadastrada.'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        _carregarDados();
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: ListView.builder(
                        itemCount: apiService.despesas.length,
                        itemBuilder: (context, index) {
                          final d = apiService.despesas[index];
                          return ListTile(
                            leading: const CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.arrow_downward, color: Colors.white, size: 16)),
                            title: Text(d.descricao, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(d.data))),
                            trailing: Text('R\$ ${d.valor.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            onLongPress: () {
                               _confirmarDelete(d.id);
                            },
                          );
                        },
                      ),
                    ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: null,
    );
  }

  void _confirmarDelete(int id) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('Remover Despesa?'),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
           TextButton(
             onPressed: () async {
                final apiService = Provider.of<ApiService>(context, listen: false);
                await apiService.deleteDespesa(id);
                if (mounted) Navigator.pop(context);
             }, 
             child: const Text('Remover', style: TextStyle(color: Colors.red))
            ),
         ],
       )
     );
  }

  Widget _buildSummaryItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 4),
        Text('R\$ ${value.toStringAsFixed(2)}', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
