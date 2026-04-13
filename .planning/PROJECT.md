# Ponto do Corte: Agenda Digital para Barbearia

## O Que é Isto

O **Ponto do Corte** é um sistema completo de gestão para barbearias, desenvolvido como Projeto de Extensão II. O ecossistema inclui:
- **Backend**: API REST robusta em Flask com SQLAlchemy.
- **Frontend Administrativo**: App nativo Windows/Mobile em Flutter para o barbeiro.
- **Interface de Cliente**: Chatbot de agendamento web para clientes finais.
- **Notificações**: Integração em tempo real via Firebase Cloud Messaging (FCM).

## Valor Central

Simplificar a jornada de agendamento do cliente através de uma interface de chat intuitiva, enquanto oferece controle total e notificações instantâneas para o profissional.

## Requisitos

### Validados (Entregues)
- ✓ Migração completa da base para **SQLAlchemy ORM**.
- ✓ Autenticação Segura via **JWT**.
- ✓ Refatoração modular com **Blueprints**.
- ✓ Suíte de testes para modelos e rotas.
- ✓ Interface administrativa Flutter (Home, Clientes, Agenda).

### Ativos (Foco Atual)
- [ ] **Finalização do Chat**: Polimento da interface web e integração de horários dinâmicos.
- [ ] **Notificações Push**: Garantir entrega de alertas FCM no Windows/Mobile.
- [ ] **Compatibilidade Python 3.14**: Auditoria de tipos e sintaxe para a versão mais recente.
- [ ] **Preparação para Deploy**: Configuração de scripts de inicialização e auditoria de segurança.

### Fora de Escopo
- Pagamentos integrados (Gateway).
- Gestão de estoque/produtos.
- Multi-locação (SaaS).

## Contexto

Projeto em fase final de refinamento para entrega acadêmica. Foco total em polimento de UI/UX e estabilidade das notificações.

## Restrições

- **Tech Stack**: Python (Flask + SQLAlchemy), Dart (Flutter + Provider), SQLite.
- **Infra**: Firebase Cloud Messaging para notificações.
- **Segurança**: Chaves privadas protegidas via `.gitignore` e templates `.env.example`.

## Decisões Chave

| Decisão | Racional | Resultado |
|----------|-----------|---------|
| SQLAlchemy | Abstração do banco para facilitar migração futura (ex: Postgres). | ✓ Sucesso |
| Chat Público | Maior conversão de clientes ao remover barreira de login/cadastro. | ✓ Sucesso |
| FCM Multicast | Garante que múltiplos dispositivos do barbeiro recebam o alerta. | ✓ Em teste |

---
*Última atualização: 12/04/2024 - Re-inicialização via GSD Unified Flow.*
