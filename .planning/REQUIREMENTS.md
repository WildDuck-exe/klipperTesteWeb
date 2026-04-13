# Requisitos: Ponto do Corte

## Requisitos Funcionais (RF)

### Administrativo (Barbeiro)
- [x] **RF-01 (Login)**: Autenticação via JWT para acesso ao Dashboard.
- [x] **RF-02 (Agenda)**: Visualização em tempo real dos agendamentos do dia.
- [x] **RF-03 (Clientes)**: Cadastro e listagem de clientes.
- [x] **RF-04 (Serviços)**: Gestão de serviços (nome, preço, duração).
- [ ] **RF-05 (Notificações)**: Recebimento de alertas FCM ao surgir novo agendamento via chat.

### Cliente (Interface Chat)
- [x] **RF-06 (Serviços)**: Listagem pública de serviços.
- [x] **RF-07 (Horários)**: Consulta dinâmica de horários livres com base na duração do serviço.
- [ ] **RF-08 (Booking)**: Criação de agendamento automático após conversação.

## Requisitos Não-Funcionais (RNF)

- **RNF-01 (Segurança)**: Chaves sensíveis (FCM) devem ser ignoradas pelo controle de versão.
- **RNF-02 (Persistência)**: Uso de SQLAlchemy para garantir integridade referencial.
- **RNF-03 (Compatibilidade)**: Garantir execução em Python 3.14 (Novos recursos/auditoria).
- **RNF-04 (Performance)**: Slots de agendamento calculados em < 100ms.

## Matriz de Rastreabilidade

| ID | Status | Implementação |
|---|---|---|
| RF-01 | ✓ | `routes/auth.py` |
| RF-03 | ✓ | `routes/clientes.py` |
| RF-04 | ✓ | `routes/servicos.py` |
| RF-05 | [/] | `utils/notifications.py` |
| RF-07 | ✓ | `routes/public.py` |
| RNF-01 | ✓ | `.gitignore` (Atualizado) |
| RNF-02 | ✓ | `models/` (SQLAlchemy) |
