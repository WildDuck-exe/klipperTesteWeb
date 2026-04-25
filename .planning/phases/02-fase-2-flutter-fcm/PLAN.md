# Plano de Execução: Fase 2 — Flutter FCM + Supabase Schema

## Contexto e Objetivos

Completar integração FCM + Supabase no backend e app Flutter. Foundation do INTEGRACAO_WPP_KLIPPER.md para as partes 2, 4 e 5.

## Etapa 1: Supabase Schema (Parte 5)

- [x] **1.1** Criar tabela `push_tokens` no Supabase (SQL via dashboard ou migrate)
- [x] **1.2** Criar/verificar tabela `configuracoes` com chaves: whatsapp_mensagem, chatweb_url, horario_inicio, horario_fim
- [x] **1.3** Configurar RLS: push_tokens service_role only
- [x] **1.4** Configurar RLS: agendamentos anon pode INSERT, service_role pode tudo
- [x] **1.5** Configurar RLS: clientes anon pode INSERT e SELECT
- [x] **1.6** Habilitar Realtime em `agendamentos`

## Etapa 2: Backend Flask — Notifications + Endpoints (Parte 2)

- [x] **2.1** Corrigir `utils/notifications.py`: adicionar `_firebase_initialized` flag + check `firebase_admin._apps` antes de init
- [x] **2.2** Corrigir `utils/notifications.py`: mudar `send_multicast()` → `send_each_for_multicast()`
- [x] **2.3** Adicionar endpoint `GET /api/public/config` em `routes/public.py`
- [x] **2.4** Adicionar endpoint `POST /api/public/notificar-agendamento` em `routes/public.py`
- [ ] **2.5** Testar endpoints com curl (sem Auth)

## Etapa 3: App Flutter — Supabase Realtime + FCM (Parte 4)

- [x] **3.1** Adicionar `Supabase.initialize()` em `lib/main.dart` (url + anonKey)
- [x] **3.2** Criar `lib/services/notification_service.dart` com registro de token FCM
- [x] **3.3** Adicionar `iniciarRealtime()` em `api_service.dart` (channel 'agendamentos-changes', onPostgresChanges INSERT)
- [x] **3.4** Chamar `NotificationService.registrarToken()` + `configurarHandlers()` após login
- [x] **3.5** Adicionar `pararRealtime()` no logout/dispose

## Etapa 4: Chat UI — Feedback Visual

- [x] **4.1** Em `chat.js` `finishBooking()`: adicionar feedback visual de sucesso (confirmation card com animação)
- [x] **4.2** Após agendar: mostrar "aguarde" state no botão, depois mensagem de sucesso com ticket ID
- [x] **4.3** Notificar backend via POST `/api/public/notificar` após INSERT no Supabase

## Etapa 5: Validação — Double-Booking

- [x] **5.1** Em `routes/public.py` endpoint de criação de agendamento: verificar se slot está livre antes de INSERT
- [x] **5.2** Retornar erro 409 (conflict) se horário já ocupado
- [ ] **5.3** Testar com dois agendamentos no mesmo horário (deve falhar o segundo)

## Etapa 6: Verificação

- [ ] **6.1** Testar fluxo completo: ChatWeb → Flask → Supabase → Flutter (realtime update)
- [ ] **6.2** Verificar push notification chega ao app após agendar
- [ ] **6.3** Testar double-booking: deve retornar erro 409
- [ ] **6.4** Commit final da fase

---

## Dependências

- Etapa 1 (Supabase) deve ser executada primeiro (é foundation)
- Etapas 2, 3, 4 podem paralelo após 1
- Etapa 5 depende de 2 (endpoint existe)
- Etapa 6 no final

## Critério de Sucesso

- [ ] Supabase: push_tokens e configuracoes criados com RLS correto
- [ ] Backend: `/api/public/config` retorna config, `/api/public/notificar` dispara FCM
- [ ] Flutter: Realtime activo após login, token FCM registado
- [ ] Chat: feedback visual de confirmação aparece após agendar
- [ ] Double-booking: segundo agendamento no mesmo slot retorna 409