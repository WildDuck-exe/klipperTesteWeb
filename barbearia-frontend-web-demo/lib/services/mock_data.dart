import 'api_service.dart';

class MockData {
  static List<Cliente> getClientes() {
    return [
      Cliente(id: 1, nome: "Carlos Alberto", telefone: "(11) 98765-4321", dataCadastro: "2026-01-10"),
      Cliente(id: 2, nome: "João Silva", telefone: "(11) 91234-5678", dataCadastro: "2026-02-15"),
      Cliente(id: 3, nome: "Ricardo Santos", telefone: "(11) 99887-7665", dataCadastro: "2026-03-01"),
      Cliente(id: 4, nome: "Bruno Oliveira", telefone: "(21) 97766-5544", dataCadastro: "2026-03-20"),
      Cliente(id: 5, nome: "Marcos Paulo", telefone: "(31) 96655-4433", dataCadastro: "2026-04-05"),
    ];
  }

  static List<Servico> getServicos() {
    return [
      Servico(id: 1, nome: "Corte de Cabelo", descricao: "Corte tradicional com tesoura ou máquina", duracaoMinutos: 30, preco: 45.0, categoria: "Cabelo", ativo: true),
      Servico(id: 2, nome: "Barba Completa", descricao: "Barba desenhada com toalha quente", duracaoMinutos: 45, preco: 35.0, categoria: "Barba", ativo: true),
      Servico(id: 3, nome: "Combo (Corte + Barba)", descricao: "O melhor custo-benefício", duracaoMinutos: 75, preco: 70.0, categoria: "Combos", ativo: true),
      Servico(id: 4, nome: "Acabamento/Pezinho", descricao: "Limpeza rápida dos contornos", duracaoMinutos: 15, preco: 15.0, categoria: "Cabelo", ativo: true),
      Servico(id: 5, nome: "Pigmentação", descricao: "Disfarce de falhas no cabelo ou barba", duracaoMinutos: 30, preco: 25.0, categoria: "Estilo", ativo: true),
    ];
  }

  static DashboardData getDashboard() {
    return DashboardData(
      totalAgendamentos: 154,
      agendamentosConcluidos: 142,
      faturamentoEstimado: 6245.0,
      faturamentoReal: 5890.0,
      period: "Mês Atual",
    );
  }

  static List<Agendamento> getAgendamentosHoje() {
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    return [
      Agendamento(
        id: 101,
        clienteId: 1,
        servicoId: 1,
        dataHora: "$dateStr 09:00:00",
        observacoes: "Degradê alto",
        status: "agendado",
        clienteNome: "Carlos Alberto",
        servicoNome: "Corte de Cabelo",
        clienteTelefone: "(11) 98765-4321",
      ),
      Agendamento(
        id: 102,
        clienteId: 2,
        servicoId: 2,
        dataHora: "$dateStr 10:30:00",
        observacoes: "Sem perfume no pós-barba",
        status: "agendado",
        clienteNome: "João Silva",
        servicoNome: "Barba Completa",
        clienteTelefone: "(11) 91234-5678",
      ),
      Agendamento(
        id: 103,
        clienteId: 3,
        servicoId: 3,
        dataHora: "$dateStr 14:00:00",
        observacoes: "",
        status: "concluido",
        clienteNome: "Ricardo Santos",
        servicoNome: "Combo (Corte + Barba)",
        clienteTelefone: "(11) 99887-7665",
      ),
    ];
  }
}
