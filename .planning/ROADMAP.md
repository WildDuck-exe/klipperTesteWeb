# Roadmap: Ponto do Corte (Finalização)

## Marco 1: Auditoria de Segurança e Projeto
**Status**: 🟢 Concluído

- [x] Sweep de segurança (FCM keys, .env).
- [x] Atualização de `.gitignore` e templates `.env.example`.
- [x] Re-inicialização dos contratos do projeto (GSD Unified Flow).

## Marco 2: Flutter FCM + Supabase Realtime (Em Execução — Fase 2)
**Status**: 🟡 Em Progresso

- [x] **Chat UI**: Feedback visual ao confirmar agendamento.
- [x] **FCM Client**: Registro de token + Supabase Realtime no app Flutter.
- [x] **Validação de Conflito**: Lógica de double-booking em public.py (retorna 409).
- [ ] **Supabase Schema**: SQL tables + RLS + Realtime (requer execução manual no dashboard).

## Fase 2 Concluída (10/15 tasks)
- Backend: notifications.py corrigido, endpoints /config e /notificar-agendamento criados
- Flutter: Supabase Realtime + NotificationService criados
- Chat: feedback visual + POST /notificar-agendamento após booking
- Double-booking: 409 returned when conflict detected

## Marco 3: Compatibilidade e Entrega Acadêmica
**Status**: 🟢 Concluído

- [x] **Auditoria Python 3.14**: Python 3.14.3, todas bibliotecas compatíveis.
- [x] **Geração de Docs**: README.md backend e frontend atualizados.
- [x] **Walkthrough Final**: Script de demonstração criado (`walkthrough-script.md`).

## Marco Extra: Demonstração e Apresentação (Trilha Paralela)
**Status**: 🟡 Planejado

- [ ] **Fase D1 — Demo Netlify**: Preparar versão web autônoma para deploy.

---
*Roadmap revisado em: 25/04/2026 (Fase 2 em execução — Marco 2 atualizado).*
