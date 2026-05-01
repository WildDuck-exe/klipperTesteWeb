# Project State: Klipper (Ponto do Corte)

## Current Milestone (Marco)
- **Marco 2**: Flutter FCM + Supabase Realtime (Schema concluído ✅, aguardando próxima fase)

## Active Task (Tarefa em Foco)
- **Parte 1: WhatsApp Baileys Bot** — Implementar bot Node.js que responde mensagens e inicia agendamento via ChatWeb

## High-Level Progress
- **Backend Flask**: 95% (notifications.py corrigido, endpoints /config e /notificar criados)
- **Flutter App**: 90% (Supabase Realtime + NotificationService criados)
- **ChatWeb**: 95% (B2+B3 corrigidos, feedback visual, POST push após booking)
- **Supabase Schema**: 100% ✅ (push_tokens, configuracoes criados, RLS configurado, Realtime habilitado)

## Knowledge Snapshot
- **FCM**: notifications.py corrigido com `send_each_for_multicast`, init check `firebase_admin._apps`
- **Supabase Realtime**: channel 'agendamentos-changes' no ApiService, iniciarRealtime() após login
- **Double-booking**: 409 conflict já implementado em public.py
- **Supabase Schema**: push_tokens + configuracoes criados, RLS + Realtime ✅
- **WhatsApp Bot**: Baileys bot pronto para implementar (depende de backend + /api/public/config)

## Next Step Recommendations
- Executar SQL do Supabase Schema (etapa 1 do PLAN.md Fase 2)
- Ou avançar para Parte 1: WhatsApp Baileys Bot (independente do schema)
