# Phase 2: Flutter FCM + Supabase Schema — Context

**Gathered:** 2026-04-25
**Status:** Ready for planning
**Source:** Marco 2 (ROADMAP.md) + INTEGRACAO_WPP_KLIPPER.md

<domain>
## Phase Boundary

Completar a integração FCM + Supabase no backend e app Flutter. Inclui:
- Supabase schema completo (push_tokens, configuracoes, RLS, realtime)
- Backend Flask: correções notifications.py + novos endpoints
- App Flutter: Supabase Realtime + FCM token registration
- Chat UI: feedback visual ao confirmar
- Validação: evitar double-booking em public.py

</domain>

<decisions>
## Implementation Decisions

### Database (Supabase)
- Tabela `push_tokens`: token FCM por dispositivo, RLS service_role only
- Tabela `configuracoes`: chave/valor para whatsapp_mensagem, chatweb_url, horarios
- RLS em `agendamentos`: anon pode INSERT, service_role pode tudo
- RLS em `clientes`: anon pode INSERT e SELECT
- Realtime habilitado em `agendamentos`

### Backend Flask
- `supabase_client.py` singleton existe (criado na Fase 1)
- `notifications.py`: fix firebase init check + usar `send_each_for_multicast` (não depreciado)
- Endpoint `GET /api/public/config`: retorna whatsapp_mensagem + chatweb_url
- Endpoint `POST /api/public/notificar-agendamento`: dispara FCM após booking
- Endpoint `POST /api/public/notificar` (chat.js chama este após agendar)

### App Flutter
- `Supabase.initialize()` no main.dart (url + anonKey)
- Realtime em `api_service.dart`: channel 'agendamentos-changes', onPostgresChanges INSERT
- `NotificationService` com registro de token FCM via Supabase push_tokens
- `ApiService`: call `iniciarRealtime()` após login

### Chat UI
- Feedback visual ao confirmar agendamento (além do ticket shown)
- Confirmação visual (checkmark动画, mensagem de sucesso com detalhes)

### Validação de Conflito
- Em `public.py` /agendamentos: verificar se slot já está ocupado antes de inserir
- Evitar double-booking com lógica de lock/unlock ou conflicto check

### Claude's Discretion
- FCM credentials path: `FIREBASE_CREDENTIALS_PATH` env var
- Backend URL no Flutter: `API_BASE_URL` via `--dart-define`
- ChatWeb servido pelo Flask (não deploy Netlify separado)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Especificações
- `docs/superpowers/specs/2026-04-25-chatweb-fase1-design.md` — Fase 1 spec (contexto)
- `INTEGRACAO_WPP_KLIPPER.md` — Plano completo de integração (fonte principal)

### Código relevante
- `barbearia-backend/utils/notifications.py` — notifications existente (corrigir)
- `barbearia-backend/routes/public.py` — endpoints públicos existentes
- `barbearia-backend/supabase_client.py` — singleton criado na Fase 1
- `barbearia-frontend/lib/main.dart` — inicialização Flutter
- `barbearia-frontend/lib/services/api_service.dart` — API service

</canonical_refs>

<specifics>
## Specific Ideas

### Supabase Schema (Parte 5)
```sql
-- push_tokens table
CREATE TABLE push_tokens (
  id BIGSERIAL PRIMARY KEY,
  token TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- configuracoes table
CREATE TABLE configuracoes (
  chave TEXT PRIMARY KEY,
  valor TEXT NOT NULL
);
INSERT INTO configuracoes (chave, valor) VALUES
  ('whatsapp_mensagem', 'Olá! Para agendar um horário, acesse o link abaixo 👇'),
  ('chatweb_url', 'https://chat.klipper.app'),
  ('horario_inicio', '08:00'),
  ('horario_fim', '18:00');
```

### notifications.py fix
```python
_firebase_initialized = False
def init_firebase():
    global _firebase_initialized
    if _firebase_initialized:
        return True
    if not firebase_admin._apps:  # evita crash na 2a chamada
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
    _firebase_initialized = True
    return True

# send_each_for_multicast (não send_multicast que é depreciado)
resp = messaging.send_each_for_multicast(message)
```

</specifics>

<deferred>
## Deferred Ideas

- WhatsApp Baileys bot (Parte 1) — depende de backend funcionando
- App Flutter: URL dinâmica via --dart-define (飞)
- ChatWeb: deploy Netlify separado (futuro)

</deferred>