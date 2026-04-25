# SPEC: Fase 1 — ChatWeb Corrigido

**Data:** 2026-04-25
**Projeto:** Klipper (Ponto do Corte)
**Escopo:** Correção de bugs no ChatWeb + endpoint `/api/public/horarios`

---

## 1. Objetivo

Corrigir 3 bugs críticos no ChatWeb e criar endpoint Flask necessário para que clientes consigam agendar horários dinamicamente via chat.

---

## 2. PR 1 — Infraestrutura

### 2.1 `barbearia-backend/static/chat/supabase-config.js`

Configurar variáveis necessárias:

```js
const SUPABASE_URL      = 'https://ocsykbqshxitgkpxgvzv.supabase.co';
const SUPABASE_ANON_KEY = 'SUA_ANON_KEY_AQUI';
const _supabase         = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
const BACKEND_URL       = 'http://localhost:5000'; // ou URL de prod
```

### 2.2 `barbearia-backend/supabase_client.py` (novo arquivo)

```python
from supabase import create_client, Client
import os

_client: Client | None = None

def get_supabase() -> Client:
    global _client
    if _client is None:
        url = os.environ.get('SUPABASE_URL')
        key = os.environ.get('SUPABASE_SERVICE_KEY')
        if not url or not key:
            raise RuntimeError("SUPABASE_URL e SUPABASE_SERVICE_KEY devem estar configurados.")
        _client = create_client(url, key)
    return _client
```

### 2.3 `barbearia-backend/requirements.txt`

Adicionar:
```
supabase>=2.0.0
```

### 2.4 `barbearia-backend/routes/public.py`

Adicionar endpoint:

```python
@public_bp.route('/api/public/horarios', methods=['GET'])
def get_horarios():
    """Retorna horários disponíveis para uma data + serviço."""
    data       = request.args.get('data')
    servico_id = request.args.get('servico_id')

    if not data or not servico_id:
        return jsonify({'error': 'data e servico_id são obrigatórios'}), 400

    from supabase_client import get_supabase
    sb = get_supabase()

    # Buscar config de horários
    config = sb.table('configuracoes').select('chave,valor').execute()
    cfg = {r['chave']: r['valor'] for r in config.data} if config.data else {}

    # Lógica de horários disponíveis (simplificada)
    # TODO: aplicar lógica de pausa, duração, dias de trabalho
    horario_inicio = cfg.get('horario_inicio', '08:00')
    horario_fim    = cfg.get('horario_fim', '18:00')

    import datetime
    h_inicio = datetime.time.fromisoformat(horario_inicio)
    h_fim    = datetime.time.fromisoformat(horario_fim)

    disponiveis = []
    current = datetime.datetime.combine(datetime.date.today(), h_inicio)
    end     = datetime.datetime.combine(datetime.date.today(), h_fim)
    while current < end:
        disponiveis.append(current.strftime('%H:%M'))
        current += datetime.timedelta(minutes=30)

    return jsonify({'disponiveis': disponiveis})
```

---

## 3. PR 2 — Correções de bugs no chat.js

### 3.1 B2: `formatarTelefone()` corrigida

```js
function formatarTelefone(value) {
    const digits = value.replace(/\D/g, '');
    if (digits.length === 0) return '';
    if (digits.length <= 2)  return `(${digits}`;
    if (digits.length <= 7)  return `(${digits.slice(0,2)}) ${digits.slice(2)}`;
    if (digits.length <= 10) return `(${digits.slice(0,2)}) ${digits.slice(2,6)}-${digits.slice(6)}`;
    return `(${digits.slice(0,2)}) ${digits.slice(2,7)}-${digits.slice(7,11)}`;
}
```

**Antes:** `(71)9-2887-024` (índices errados)
**Depois:** `(71) 98288-7024` (formato correto)

### 3.2 B3: `showTimes()` dinâmica

```js
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

---

## 4. Arquivos afetados

| Arquivo | Ação |
|---------|------|
| `barbearia-backend/static/chat/supabase-config.js` | Editar |
| `barbearia-backend/supabase_client.py` | Criar |
| `barbearia-backend/routes/public.py` | Editar |
| `barbearia-backend/requirements.txt` | Editar |
| `barbearia-backend/static/chat/chat.js` | Editar (B2 + B3) |
| `chat/chat.js` | Editar (B2 + B3 — sincronizar) |

---

## 5. Dependências

- PR1 precisa do Supabase configurado no Flask (variáveis de ambiente)
- PR2 precisa do PR1 funcionando (endpoint existe antes do chat.js chamar)

---

## 6. Critério de sucesso

- [ ] PR1 merged: ChatWeb consegue chamar `/api/public/horarios` e receber lista de horários
- [ ] PR2 merged: Máscara de telefone formata `(71) 98288-7024` corretamente
- [ ] PR2 merged: `showTimes()` mostra horários dinâmicos em vez de hardcoded
- [ ] Fluxo completo testado: dados → serviço → horário → agendamento