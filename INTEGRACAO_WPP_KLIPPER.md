# 🔗 Integração Completa: WhatsApp (Baileys) → ChatWeb → App Klipper

> **Objetivo:** Cliente manda qualquer mensagem no WhatsApp do barbeiro → recebe link do ChatWeb automaticamente → faz agendamento → barbeiro recebe notificação push + lista atualizada no app em tempo real.

---

## 🗺️ Fluxo Completo

```
CLIENTE                     SERVIDOR (Node.js)           APP DO BARBEIRO
───────                     ──────────────────           ───────────────
1. Manda "oi" no WhatsApp
   do barbeiro
         │
         ▼
   Baileys (Node.js)
   detecta mensagem
         │
         ▼ GET /api/public/config
         ├──────────────────────→ Flask retorna
         │                        whatsapp_mensagem +
         │                        chatweb_url
         │
         ▼ responde automaticamente:
   "Olá! Para agendar, acesse:
    https://chat.klipper.app"
         │
         ▼ (cliente clica no link)

2. ChatWeb abre no browser
   nome → telefone → serviço
   → data → horário → confirma
         │
         ├─ INSERT clientes ──────────────────────→ Supabase
         ├─ INSERT agendamentos ──────────────────→ Supabase
         │                                              │
         │                                              │ Realtime WS
         │                                              ▼
         │                                    App atualiza lista ✅
         │
         └─ POST /api/public/notificar ──→ Flask
                                           FCM push ──→ 📱 App
                                                   "💈 João agendou
                                                    Corte às 14:00" ✅
```

---

## 📋 Diagnóstico: O Que Está Quebrado Hoje

| # | Arquivo | Problema | Impacto |
|---|---------|----------|---------|
| 1 | `main.dart` + `config.py` | App usa Flask/SQLite, chat usa Supabase — bancos diferentes | **Crítico** |
| 2 | `chat.js` `formatarTelefone()` | Índices errados → máscara gera `(71)9-2887-024` | Alto |
| 3 | `chat.js` `showTimes()` | Horários hardcodados, ignora pausa/duração/dias | Alto |
| 4 | `static/chat/supabase-config.js` | Arquivo vazio → chat servido pelo Flask não funciona | Alto |
| 5 | `notifications.py` | Não verifica `firebase_admin._apps` → crash na 2ª chamada | Médio |
| 6 | `notifications.py` | Usa `send_multicast()` depreciado | Médio |
| 7 | `main.dart` | `baseUrl: 'http://10.0.2.2:5000'` hardcodado para emulador | Médio |
| 8 | — | WhatsApp bot não existe no projeto | **Feature nova** |

---

## 🏗️ Arquitetura Final

```
┌─────────────────────────────────────────────────────────────┐
│                         SUPABASE                            │
│  clientes · servicos · agendamentos · push_tokens          │
│  configuracoes · (realtime habilitado em agendamentos)     │
└──────────┬──────────────────────────────┬───────────────────┘
           │ Supabase JS (anon key)        │ supabase-py (service key)
           ▼                               ▼
┌──────────────────┐           ┌──────────────────────────────┐
│  ChatWeb         │           │  Flask Backend               │
│  (link público)  │           │  /api/public/config  ←──┐   │
│  Netlify / etc.  │           │  /api/public/horarios    │   │
│  chat.js         │           │  /api/public/notificar   │   │
└──────────────────┘           │  /api/* (admin autent.)  │   │
                               └──────────────┬───────────┘   │
                                              │ FCM            │
                                              ▼               │
                               ┌──────────────────────────┐  │
                               │  App Flutter (barbeiro)  │  │
                               │  Supabase Realtime       │  │
                               │  FCM notifications       │  │
                               └──────────────────────────┘  │
                                                              │
┌─────────────────────────────────────────────────────────────┘
│  Baileys Bot (Node.js — mesmo servidor ou processo separado)
│  Escuta mensagens → GET /api/public/config → responde com link
└─────────────────────────────────────────────────────────────
```

---

## 🛠️ Implementação

---

### PARTE 1 — Baileys Bot (WhatsApp)

O Baileys é uma biblioteca Node.js que se conecta ao WhatsApp Web via WebSocket. Roda no servidor, sem custo, sem API oficial da Meta.

#### 1.1 Criar o projeto do bot

```bash
# Na raiz do repositório, criar pasta separada:
mkdir whatsapp-bot && cd whatsapp-bot
npm init -y
npm install @whiskeysockets/baileys qrcode-terminal axios dotenv
```

#### 1.2 `whatsapp-bot/.env`

```env
FLASK_API_URL=https://SEU-BACKEND.onrender.com
```

#### 1.3 `whatsapp-bot/.gitignore`

```
auth_session/
.env
node_modules/
```

#### 1.4 `whatsapp-bot/bot.js`

```js
require('dotenv').config();
const {
    default: makeWASocket,
    useMultiFileAuthState,
    DisconnectReason,
    fetchLatestBaileysVersion,
} = require('@whiskeysockets/baileys');
const qrcode = require('qrcode-terminal');
const axios  = require('axios');

const FLASK_API_URL = process.env.FLASK_API_URL;

// Busca mensagem e URL configuradas pelo barbeiro no app
async function getConfig() {
    try {
        const { data } = await axios.get(`${FLASK_API_URL}/api/public/config`);
        return {
            mensagem:   data.whatsapp_mensagem || 'Olá! Para agendar, acesse o link:',
            chatwebUrl: data.chatweb_url       || 'https://chat.klipper.app',
        };
    } catch (err) {
        console.error('[Bot] Erro ao buscar config:', err.message);
        return {
            mensagem:   'Olá! Para agendar, acesse o link:',
            chatwebUrl: 'https://chat.klipper.app',
        };
    }
}

async function conectar() {
    const { version } = await fetchLatestBaileysVersion();
    const { state, saveCreds } = await useMultiFileAuthState('./auth_session');

    const sock = makeWASocket({
        version,
        auth: state,
        printQRInTerminal: false,
    });

    // ── Conexão ──────────────────────────────────────────────────────
    sock.ev.on('connection.update', ({ connection, lastDisconnect, qr }) => {
        if (qr) {
            console.log('\n📱 Escaneie o QR Code com o WhatsApp do barbeiro:\n');
            qrcode.generate(qr, { small: true });
        }
        if (connection === 'close') {
            const shouldReconnect =
                lastDisconnect?.error?.output?.statusCode !== DisconnectReason.loggedOut;
            console.log('[Bot] Conexão encerrada. Reconectando:', shouldReconnect);
            if (shouldReconnect) conectar();
        } else if (connection === 'open') {
            console.log('[Bot] ✅ WhatsApp conectado!');
        }
    });

    sock.ev.on('creds.update', saveCreds);

    // ── Mensagens recebidas ──────────────────────────────────────────
    sock.ev.on('messages.upsert', async ({ messages, type }) => {
        if (type !== 'notify') return;

        for (const msg of messages) {
            if (msg.key.fromMe)                      continue; // ignorar próprias
            if (msg.key.remoteJid.endsWith('@g.us')) continue; // ignorar grupos

            const remetente = msg.key.remoteJid;
            const texto = msg.message?.conversation
                       || msg.message?.extendedTextMessage?.text
                       || '';

            console.log(`[Bot] Mensagem de ${remetente}: "${texto}"`);

            const { mensagem, chatwebUrl } = await getConfig();
            const resposta = `${mensagem}\n\n🔗 ${chatwebUrl}`;

            await sock.sendMessage(remetente, { text: resposta });
            console.log(`[Bot] ✅ Resposta enviada para ${remetente}`);
        }
    });
}

conectar();
```

#### 1.5 `whatsapp-bot/package.json` — adicionar scripts

```json
{
  "scripts": {
    "start": "node bot.js",
    "dev":   "node --watch bot.js"
  }
}
```

#### 1.6 Rodando o bot

```bash
cd whatsapp-bot
npm start
# Primeira vez: escanear QR Code no terminal com o WhatsApp do barbeiro
# A sessão fica salva em ./auth_session — não precisa escanear de novo
```

> **Para manter em produção:** usar `pm2 start bot.js --name klipper-bot` ou deploy no Railway com `Procfile: web: node bot.js`.

---

### PARTE 2 — Backend Flask: novos endpoints e correções

#### 2.1 Novo `supabase_client.py`

```python
# barbearia-backend/supabase_client.py
from supabase import create_client, Client
import os

_client: Client | None = None

def get_supabase() -> Client:
    global _client
    if _client is None:
        url = os.environ.get('SUPABASE_URL')
        key = os.environ.get('SUPABASE_SERVICE_KEY')  # service_role — nunca expor no frontend
        if not url or not key:
            raise RuntimeError("SUPABASE_URL e SUPABASE_SERVICE_KEY devem estar configurados.")
        _client = create_client(url, key)
    return _client
```

#### 2.2 Novo endpoint `GET /api/public/config`

Adicionar em `routes/public.py`:

```python
@public_bp.route('/api/public/config', methods=['GET'])
def get_config_public():
    """
    Retorna configurações públicas usadas pelo bot e pelo ChatWeb.
    Não expõe dados sensíveis — apenas mensagens e URLs configuráveis.
    """
    from supabase_client import get_supabase
    result = get_supabase().table('configuracoes').select('chave,valor').execute()
    config_map = {r['chave']: r['valor'] for r in result.data} if result.data else {}

    return jsonify({
        'whatsapp_mensagem': config_map.get(
            'whatsapp_mensagem',
            'Olá! Para agendar um horário, acesse o link abaixo 👇'
        ),
        'chatweb_url':    config_map.get('chatweb_url',    'https://chat.klipper.app'),
        'horario_inicio': config_map.get('horario_inicio', '08:00'),
        'horario_fim':    config_map.get('horario_fim',    '18:00'),
    })
```

#### 2.3 Novo endpoint `POST /api/public/notificar-agendamento`

```python
@public_bp.route('/api/public/notificar-agendamento', methods=['POST'])
def notificar_agendamento():
    """
    Chamado pelo ChatWeb após inserir agendamento no Supabase.
    Apenas dispara o push FCM para o barbeiro — não grava nada.
    """
    data = request.get_json()
    required = ['cliente_nome', 'servico_nome', 'data_hora_fmt']

    if not data or not all(k in data for k in required):
        return jsonify({'error': 'Campos obrigatórios: cliente_nome, servico_nome, data_hora_fmt'}), 400

    from utils.notifications import enviar_notificacao_novo_agendamento
    notificado = enviar_notificacao_novo_agendamento(
        cliente_nome=data['cliente_nome'],
        servico_nome=data['servico_nome'],
        data_hora_str=data['data_hora_fmt'],
    )
    return jsonify({'notificado': notificado}), 200
```

#### 2.4 Corrigir `utils/notifications.py`

```python
# utils/notifications.py — versão corrigida completa
import os
import firebase_admin
from firebase_admin import credentials, messaging

_firebase_initialized = False

def init_firebase() -> bool:
    global _firebase_initialized
    if _firebase_initialized:
        return True

    cred_path = os.environ.get(
        'FIREBASE_CREDENTIALS_PATH',
        os.path.join(os.path.dirname(os.path.dirname(__file__)), 'firebase-service-account.json')
    )

    if not os.path.exists(cred_path):
        print(f"[FCM] ⚠️  Credenciais não encontradas: {cred_path}")
        return False

    try:
        if not firebase_admin._apps:          # ← evita crash na 2ª chamada
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
        _firebase_initialized = True
        print("[FCM] ✅ Firebase inicializado.")
        return True
    except Exception as e:
        print(f"[FCM] ❌ Erro: {e}")
        return False


def enviar_notificacao_novo_agendamento(cliente_nome: str, servico_nome: str, data_hora_str: str) -> bool:
    if not init_firebase():
        return False

    from supabase_client import get_supabase
    result = get_supabase().table('push_tokens').select('token').execute()
    tokens = [r['token'] for r in result.data] if result.data else []

    if not tokens:
        print("[FCM] Nenhum token registrado.")
        return False

    message = messaging.MulticastMessage(
        notification=messaging.Notification(
            title='💈 Novo Agendamento!',
            body=f'{cliente_nome} → {servico_nome} • {data_hora_str}',
        ),
        data={
            'tipo':      'novo_agendamento',
            'cliente':   cliente_nome,
            'servico':   servico_nome,
            'data_hora': data_hora_str,
        },
        tokens=tokens,
    )

    try:
        resp = messaging.send_each_for_multicast(message)   # ← API atual, não depreciada
        print(f"[FCM] ✅ {resp.success_count} enviados, {resp.failure_count} falhas.")
        return resp.success_count > 0
    except Exception as e:
        print(f"[FCM] ❌ Erro multicast: {e}")
        return False
```

#### 2.5 Atualizar `config.py`

```python
# barbearia-backend/config.py
import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-key')
    DEBUG      = os.environ.get('FLASK_DEBUG', 'false').lower() == 'true'

    SUPABASE_URL         = os.environ.get('SUPABASE_URL')
    SUPABASE_SERVICE_KEY = os.environ.get('SUPABASE_SERVICE_KEY')
    SUPABASE_ANON_KEY    = os.environ.get('SUPABASE_ANON_KEY')

    FIREBASE_CREDENTIALS_PATH = os.environ.get(
        'FIREBASE_CREDENTIALS_PATH',
        os.path.join(os.path.dirname(__file__), 'firebase-service-account.json')
    )

    CORS_ORIGINS   = os.environ.get('CORS_ORIGINS', '*').split(',')
    CORS_RESOURCES = {r"/api/*": {"origins": "*"}}
    API_VERSION    = '1.0.0'
```

#### 2.6 Adicionar `supabase` ao `requirements.txt`

```
supabase>=2.0.0
```

---

### PARTE 3 — ChatWeb: corrigir bugs

#### 3.1 Corrigir máscara de telefone em `chat.js`

```js
// Substituir formatarTelefone inteira:
function formatarTelefone(value) {
    const digits = value.replace(/\D/g, '');
    if (digits.length === 0) return '';
    if (digits.length <= 2)  return `(${digits}`;
    if (digits.length <= 7)  return `(${digits.slice(0,2)}) ${digits.slice(2)}`;
    if (digits.length <= 10) return `(${digits.slice(0,2)}) ${digits.slice(2,6)}-${digits.slice(6)}`;
    // 11 dígitos: (XX) 9XXXX-XXXX
    return `(${digits.slice(0,2)}) ${digits.slice(2,7)}-${digits.slice(7,11)}`;
}
```

#### 3.2 Corrigir horários dinâmicos em `chat.js`

```js
// Substituir showTimes() inteira:
async function showTimes() {
    const loader = showTyping();
    try {
        const url = `${BACKEND_URL}/api/public/horarios?data=${userData.data}&servico_id=${userData.servico_id}`;
        const resp = await fetch(url);
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
        const json = await resp.json();
        loader.remove();

        const disponiveis = json.disponiveis || [];

        if (disponiveis.length === 0) {
            addMessage("Nenhum horário disponível nesta data. 😔 Escolha outro dia.", "system");
            setTimeout(() => askDate(), 1500);
            return;
        }

        addMessage(
            `Temos <strong>${disponiveis.length}</strong> horários disponíveis. Qual prefere?`,
            "system", true
        );

        const grid = document.createElement('div');
        grid.className = 'horarios-grid';
        disponiveis.forEach(hora => {
            const btn = document.createElement('button');
            btn.className = 'time-chip';
            btn.textContent = hora;
            btn.onclick = () => selectTime(hora);
            grid.appendChild(btn);
        });

        chatWindow.appendChild(grid);
        chatWindow.scrollTop = chatWindow.scrollHeight;
        userInput.disabled = true;
    } catch (e) {
        loader.remove();
        addMessage("Erro ao carregar horários. Tente novamente.", "system");
        console.error('[showTimes]', e);
    }
}
```

#### 3.3 Notificar push após agendar em `chat.js`

Dentro de `finishBooking()`, logo após `if (!bookingError)`, antes do `localStorage.setItem`:

```js
// Notifica FCM via backend (fire-and-forget — não bloqueia o fluxo)
const horaFmt = userData.data_hora.split('T')[1].substring(0, 5);
const dataFmt = userData.data.split('-').reverse().join('/');

fetch(`${BACKEND_URL}/api/public/notificar-agendamento`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        cliente_nome:  userData.nome,
        servico_nome:  userData.servico_nome,
        data_hora_fmt: `${dataFmt} às ${horaFmt}`,
    }),
}).catch(err => console.warn('[Push]', err));
```

#### 3.4 Atualizar `supabase-config.js` (em ambos `chat/` e `static/chat/`)

```js
// chat/supabase-config.js  E  barbearia-backend/static/chat/supabase-config.js
const SUPABASE_URL      = 'https://ocsykbqshxitgkpxgvzv.supabase.co';
const SUPABASE_ANON_KEY = 'SUA_ANON_KEY_AQUI';  // anon key — segura no frontend

const _supabase   = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
const BACKEND_URL = 'https://SEU-BACKEND.onrender.com';
```

---

### PARTE 4 — App Flutter: receber em tempo real

#### 4.1 Inicializar Supabase no `main.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url:     'https://ocsykbqshxitgkpxgvzv.supabase.co',
    anonKey: 'SUA_ANON_KEY',
  );

  // ... Firebase.initializeApp(), runApp() etc.
}
```

#### 4.2 Supabase Realtime em `api_service.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

// Dentro da classe ApiService:
RealtimeChannel? _agendamentosChannel;

void iniciarRealtime() {
  _agendamentosChannel = Supabase.instance.client
      .channel('agendamentos-changes')
      .onPostgresChanges(
        event:    PostgresChangeEvent.insert,
        schema:   'public',
        table:    'agendamentos',
        callback: (payload) {
          print('[Realtime] Novo agendamento: ${payload.newRecord}');
          fetchAgendamentos();
          notifyListeners();
        },
      )
      .subscribe();
}

void pararRealtime() {
  _agendamentosChannel?.unsubscribe();
  _agendamentosChannel = null;
}
```

Chamar `apiService.iniciarRealtime()` logo após login bem-sucedido.

#### 4.3 `notification_service.dart` — criar arquivo

```dart
// lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static Future<void> registrarToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await Supabase.instance.client
        .from('push_tokens')
        .upsert(
          {'token': token, 'updated_at': DateTime.now().toIso8601String()},
          onConflict: 'token',
        );

    // Renovação automática de token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      Supabase.instance.client.from('push_tokens').upsert(
        {'token': newToken, 'updated_at': DateTime.now().toIso8601String()},
        onConflict: 'token',
      );
    });

    print('[FCM] Token registrado.');
  }

  static void configurarHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      print('[FCM] Foreground: ${msg.notification?.title}');
      // Exibir SnackBar ou atualizar badge se quiser
    });
  }
}
```

Chamar após login:
```dart
await NotificationService.registrarToken();
NotificationService.configurarHandlers();
```

#### 4.4 URL dinâmica no `main.dart`

```dart
// ANTES (hardcodado):
create: (_) => ApiService(baseUrl: 'http://10.0.2.2:5000'),

// DEPOIS (dinâmico via --dart-define):
const backendUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://SEU-BACKEND.onrender.com',
);
create: (_) => ApiService(baseUrl: backendUrl),
```

Build:
```bash
flutter build apk --dart-define=API_BASE_URL=https://SEU-BACKEND.onrender.com
```

---

### PARTE 5 — Supabase: schema e permissões

Executar no SQL Editor do Supabase:

```sql
-- 1. Tabela push_tokens
CREATE TABLE IF NOT EXISTS push_tokens (
  id         BIGSERIAL PRIMARY KEY,
  token      TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "service_role only" ON push_tokens
  USING (auth.role() = 'service_role');

-- 2. Tabela configuracoes
CREATE TABLE IF NOT EXISTS configuracoes (
  chave TEXT PRIMARY KEY,
  valor TEXT NOT NULL
);
INSERT INTO configuracoes (chave, valor) VALUES
  ('horario_inicio',    '08:00'),
  ('horario_fim',       '18:00'),
  ('pausa_inicio',      '12:00'),
  ('pausa_fim',         '13:00'),
  ('dias_trabalho',     '1,2,3,4,5,6'),
  ('whatsapp_mensagem', 'Olá! Para agendar um horário, acesse o link abaixo 👇'),
  ('chatweb_url',       'https://SEU-CHATWEB.netlify.app')
ON CONFLICT (chave) DO NOTHING;

-- 3. RLS para agendamentos
ALTER TABLE agendamentos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon pode inserir" ON agendamentos
  FOR INSERT WITH CHECK (true);
CREATE POLICY "service_role pode tudo em agendamentos" ON agendamentos
  USING (auth.role() = 'service_role');

-- 4. RLS para clientes
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon pode inserir cliente" ON clientes
  FOR INSERT WITH CHECK (true);
CREATE POLICY "anon pode consultar cliente" ON clientes
  FOR SELECT USING (true);

-- 5. Habilitar Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE agendamentos;
```

---

## 📦 Variáveis de Ambiente

### Flask Backend (Render / Railway / `.env`)
```env
SECRET_KEY=sua-chave-secreta
SUPABASE_URL=https://ocsykbqshxitgkpxgvzv.supabase.co
SUPABASE_SERVICE_KEY=eyJ...   # service_role — NUNCA expor no frontend
SUPABASE_ANON_KEY=eyJ...
FIREBASE_CREDENTIALS_PATH=/etc/secrets/firebase-service-account.json
CORS_ORIGINS=https://seu-chatweb.netlify.app
FLASK_DEBUG=false
```

### Baileys Bot (`whatsapp-bot/.env`)
```env
FLASK_API_URL=https://SEU-BACKEND.onrender.com
```

### ChatWeb (`chat/supabase-config.js`)
```
SUPABASE_ANON_KEY → anon key (segura no frontend)
BACKEND_URL       → https://SEU-BACKEND.onrender.com
```

### App Flutter (`--dart-define`)
```
API_BASE_URL → https://SEU-BACKEND.onrender.com
```

---

## 📁 Resumo dos Arquivos Modificados / Criados

```
raiz/
└── whatsapp-bot/                         ← 🆕 novo projeto Node.js
    ├── bot.js
    ├── package.json
    ├── .env                              ← não commitar
    ├── .gitignore
    └── auth_session/                     ← não commitar (sessão WhatsApp)

barbearia-backend/
├── config.py                             ← ✏️ tudo via env vars
├── supabase_client.py                    ← 🆕 singleton Supabase
├── requirements.txt                      ← ✏️ + supabase>=2.0.0
├── routes/
│   └── public.py                         ← ✏️ + /config e /notificar-agendamento
└── utils/
    └── notifications.py                  ← ✏️ fix firebase init + send_each_for_multicast

chat/
├── chat.js                               ← ✏️ máscara + showTimes + notificar push
└── supabase-config.js                    ← ✏️ + BACKEND_URL

barbearia-backend/static/chat/
└── supabase-config.js                    ← ✏️ copiar de chat/ (estava vazio)

barbearia-frontend/
├── lib/
│   ├── main.dart                         ← ✏️ Supabase.initialize + URL dinâmica
│   ├── services/
│   │   ├── api_service.dart              ← ✏️ + iniciarRealtime()
│   │   └── notification_service.dart     ← 🆕 registrar token FCM
└── pubspec.yaml                          ← verificar supabase_flutter + firebase_messaging
```

---

## ✅ Checklist de Demo

### Preparação (hoje à noite)
- [ ] Flask backend deployado com todas as vars de ambiente configuradas
- [ ] SQL da Parte 5 executado no Supabase (tabelas + RLS + realtime)
- [ ] `chatweb_url` e `whatsapp_mensagem` inseridos em `configuracoes`
- [ ] `chat/supabase-config.js` atualizado → ChatWeb deployado (Netlify/etc.)
- [ ] `firebase-service-account.json` acessível pelo backend
- [ ] `cd whatsapp-bot && npm install && npm start` → escanear QR Code com WhatsApp do barbeiro
- [ ] App Flutter buildado com `API_BASE_URL` correto

### Roteiro da demo
1. App aberto no celular do barbeiro → logado → Realtime ativo
2. Outro celular: mandar "oi" no WhatsApp do barbeiro
3. Bot responde automaticamente com a mensagem + link do ChatWeb
4. Clicar no link → preencher o fluxo completo → confirmar
5. Celular do barbeiro: push notification aparece + lista atualiza em tempo real
6. No app: concluir o agendamento para fechar o ciclo

### Atenção
> O campo **"Mensagem de boas-vindas"** já existe na tela de Configurações do app (`whatsapp_mensagem`). O barbeiro pode editar diretamente no app — o bot busca esse valor a cada mensagem recebida, então a mudança é instantânea sem reiniciar nada.

---

*Klipper v1.0 · Documento gerado em 25/04/2026*
