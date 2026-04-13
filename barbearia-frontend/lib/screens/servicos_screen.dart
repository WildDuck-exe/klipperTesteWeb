import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class ServicosScreen extends StatefulWidget {
  const ServicosScreen({super.key});

  @override
  State<ServicosScreen> createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApiService>().fetchServicos();
    });
  }

  void _abrirFormulario({Servico? servico}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ServicoForm(servico: servico),
    ).then((_) => context.read<ApiService>().fetchServicos());
  }

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Serviços'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ApiService>().fetchServicos(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        label: const Text('Novo Serviço'),
        icon: const Icon(Icons.add),
      ),
      body: api.isLoading
          ? const Center(child: CircularProgressIndicator())
          : api.servicos.isEmpty
              ? const Center(child: Text('Nenhum serviço cadastrado.'))
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<ApiService>().fetchServicos();
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: api.servicos.length,
                  itemBuilder: (context, index) {
                    final s = api.servicos[index];
                    // Mostra apenas ativos na gestão (opcional, ou mostra todos com flag)
                    if (!s.ativo) return const SizedBox.shrink();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          s.nome,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  s.categoria,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${s.duracaoMinutos} min • R\$ ${s.preco.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _abrirFormulario(servico: s),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmarExclusao(s),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  void _confirmarExclusao(Servico servico) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Serviço'),
        content: Text('Deseja realmente remover "${servico.nome}"?\n\nEle não aparecerá para novos agendamentos, mas ficará preservado no histórico.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final res = await context.read<ApiService>().deleteServico(servico.id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['message'])),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ServicoForm extends StatefulWidget {
  final Servico? servico;
  const _ServicoForm({this.servico});

  @override
  State<_ServicoForm> createState() => _ServicoFormState();
}

class _ServicoFormState extends State<_ServicoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _precoController;
  late TextEditingController _duracaoController;
  late TextEditingController _descricaoController;
  String _categoriaSelecionada = 'Geral';

  final List<String> _categorias = ['Geral', 'Cabelo', 'Barba', 'Combo', 'Estética', 'Outros'];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.servico?.nome ?? '');
    _precoController = TextEditingController(text: widget.servico?.preco.toString() ?? '');
    _duracaoController = TextEditingController(text: widget.servico?.duracaoMinutos.toString() ?? '30');
    _descricaoController = TextEditingController(text: widget.servico?.descricao ?? '');
    _categoriaSelecionada = widget.servico?.categoria ?? 'Geral';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.servico == null ? 'Novo Serviço' : 'Editar Serviço',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Serviço', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precoController,
                      decoration: const InputDecoration(labelText: 'Preço (R\$)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _duracaoController,
                      decoration: const InputDecoration(labelText: 'Duração (min)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _categoriaSelecionada,
                decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
                items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _categoriaSelecionada = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição (opcional)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: _salvar,
                  child: const Text('Salvar Serviço', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final api = context.read<ApiService>();
    
    try {
      // Tratamento para aceitar vírgula como separador decimal (comum no Brasil)
      final precoLimpo = _precoController.text.replaceAll(',', '.');
      final duracaoLimpa = _duracaoController.text.replaceAll(',', '.');
      
      final preco = double.parse(precoLimpo);
      final duracao = int.parse(duracaoLimpa.split('.')[0]); // Garante int

      Map<String, dynamic> res;

      if (widget.servico == null) {
        res = await api.criarServico(
          _nomeController.text,
          preco,
          duracao,
          _descricaoController.text,
          _categoriaSelecionada,
        );
      } else {
        res = await api.updateServico(
          widget.servico!.id,
          _nomeController.text,
          preco,
          duracao,
          _descricaoController.text,
          _categoriaSelecionada,
        );
      }

      if (mounted) {
        if (res['success'] == true) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']),
            backgroundColor: res['success'] == true ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro nos valores: digite apenas números e pontos. ($e)'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}