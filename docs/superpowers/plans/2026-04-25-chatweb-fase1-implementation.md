# Fase 1: ChatWeb Corrigido — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Corrigir bugs B2 e B3 do ChatWeb e adicionar BACKEND_URL ao supabase-config.js

**Architecture:** PR1 adiciona BACKEND_URL ao supabase-config.js (infraestrutura). PR2 corrige formatarTelefone() e refatora showTimes() para chamar /api/public/horarios em vez de logic client-side com Supabase direto.

**Tech Stack:** JavaScript (chat.js), Python (Flask backend), Supabase

---

## Dependências verificadas

- `/api/public/horarios` endpoint JÁ EXISTE em `routes/public.py` (linhas 50+), implementado com SQLAlchemy/SQLite (não Supabase)
- `formatarTelefone()` existe em `barbearia-backend/static/chat/chat.js` linhas 21-32, com bug nos índices para 11 dígitos
- `showTimes()` existe em `chat.js` linhas 339-413, usa array hardcoded `baseTimes` e consulta Supabase direto para filtrar horários ocupados

---

## File Map

| Arquivo | Ação |
|---------|------|
| `barbearia-backend/static/chat/supabase-config.js` | MODIFICAR — adicionar BACKEND_URL |
| `barbearia-backend/supabase_client.py` | CRIAR — singleton Supabase (para eventual uso futuro) |
| `barbearia-backend/requirements.txt` | MODIFICAR — adicionar supabase>=2.0.0 |
| `barbearia-backend/static/chat/chat.js` | MODIFICAR — corrigir B2 e B3 |
| `chat/chat.js` | MODIFICAR — sincronizar correções |

---

## PR 1: Infraestrutura (supabase-config + requirements)

### Task 1: Adicionar BACKEND_URL ao supabase-config.js

**Files:**
- Modify: `barbearia-backend/static/chat/supabase-config.js`

- [ ] **Step 1: Editar supabase-config.js — adicionar BACKEND_URL**

Substituir conteúdo atual por:

```js
// Supabase Project details
const SUPABASE_URL = 'https://ocsykbqshxitgkpxgvzv.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_ocenpEvX8g_twg1mo0nB6A_JL4ltrV-';

const _supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Backend Flask URL — usado pelo chat.js para chamadas a /api/public/*
const BACKEND_URL = 'http://localhost:5000'; // ajustar para prod
```

- [ ] **Step 2: Commit**

```bash
git add barbearia-backend/static/chat/supabase-config.js
git commit -m "feat(chat): adicionar BACKEND_URL ao supabase-config.js

Co-Authored-By: Claude Opus 4.6 <noreply@openclaude.dev>"
```

---

### Task 2: Adicionar supabase ao requirements.txt

**Files:**
- Modify: `barbearia-backend/requirements.txt`

- [ ] **Step 1: Editar requirements.txt — adicionar supabase**

Adicionar ao final:
```
supabase>=2.0.0
```

- [ ] **Step 2: Commit**

```bash
git add barbearia-backend/requirements.txt
git commit -m "deps: adicionar supabase>=2.0.0 ao requirements

Co-Authored-By: Claude Opus 4.6 <noreply@openclaude.dev>"
```

---

### Task 3: Criar supabase_client.py (singleton)

**Files:**
- Create: `barbearia-backend/supabase_client.py`

- [ ] **Step 1: Criar supabase_client.py**

```python
# barbearia-backend/supabase_client.py
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

- [ ] **Step 2: Commit**

```bash
git add barbearia-backend/supabase_client.py
git commit -m "feat(backend): criar supabase_client.py singleton

Co-Authored-By: Claude Opus 4.6 <noreply@openclaude.dev>"
```

---

## PR 2: Correções de bugs (formatarTelefone + showTimes)

### Task 4: Corrigir formatarTelefone() em chat.js

**Files:**
- Modify: `barbearia-backend/static/chat/chat.js:21-32`

O bug: para 11 dígitos, `digits[2]` é o primeiro dígito do nono dígito, não onon itself. Resultado: `(71)9-2887-024` em vez de `(71) 98288-7024`.

- [ ] **Step 1: Corrigir formatarTelefone — substituir linhas 21-32**

Substituir:
```js
function formatarTelefone(value) {
    // Always work from pure digits — accepts raw or partially formatted input
    const digits = value.replace(/\D/g, '');
    if (digits.length === 0) return '';
    if (digits.length <= 2) return `(${digits}`;
    if (digits.length <= 7) {
        // (XX)XXXXX-XXXX — digits[2] is the 9, rest follows
        return `(${digits.slice(0, 2)})${digits.slice(2, 7)}-${digits.slice(7)}`;
    }
    // (XX)9XXXX-XXXX — 11 digits total
    return `(${digits.slice(0, 2)})${digits[2]}-${digits.slice(3, 7)}-${digits.slice(7, 11)}`;
}
```

Por:
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

- [ ] **Step 2: Commit**

```bash
git add barbearia-backend/static/chat/chat.js
git commit -m "fix(chat): corrigir formatarTelefone para formato (XX) 9XXXX-XXXX

Bug: indices errados geravam (71)9-2887-024 em vez de (71) 98288-7024
Fix: usar slice() correto para cada segmento do número

Co-Authored-By: Claude Opus 4.6 <noreply@openclaude.dev>"
```

---

### Task 5: Refatorar showTimes() para chamar /api/public/horarios

**Files:**
- Modify: `barbearia-backend/static/chat/chat.js:339-413`

O bug: showTimes() usa array hardcoded `baseTimes` e faz queries Supabase direto para filtrar horários ocupados. O spec pede que chame `/api/public/horarios?data=X&servico_id=Y` — o Flask já calcula horários disponíveis com lógica server-side.

- [ ] **Step 1: Substituir showTimes() — linhas 339-413**

Substituir toda a função `showTimes()` existente por:

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

**Nota:** O `BACKEND_URL` vem do `supabase-config.js` (adicionado no PR1). Se não estiver definido, assume `http://localhost:5000`.

- [ ] **Step 2: Commit**

```bash
git add barbearia-backend/static/chat/chat.js
git commit -m "refactor(chat): showTimes() agora chama /api/public/horarios do Flask

Antes: array hardcoded + queries Supabase direto para filtrar ocupados
Depois: chama endpoint Flask que calcula horários disponíveis server-side

Co-Authored-By: Claude Opus 4.6 <noreply@openclaude.dev>"
```

---

### Task 6: Sincronizar chat/chat.js (cópia)

**Files:**
- Modify: `chat/chat.js` — aplicar mesmas correções de B2 e B3

- [ ] **Step 1: Ler chat/chat.js e aplicar mesmas correções**

Verificar se `chat/chat.js` tem as mesmas funções e aplicar:
1. Correção `formatarTelefone()` (mesmo código do Task 4)
2. Refatoração `showTimes()` (mesmo código do Task 5)

- [ ] **Step 2: Commit**

```bash
git add chat/chat.js
git commit -m "sync(chat): sincronizar correções B2 e B3 em chat/chat.js

Co-Authored-By: Claude Opus 4.6 <noreply@openclaude.dev>"
```

---

## Validação

Após todos os PRs merged:
1. Iniciar Flask backend: `cd barbearia-backend && python main.py`
2. Abrir chat em `http://localhost:5000/chat/`
3. Testar máscara: digitar `71992887024` → deve mostrar `(71) 98288-7024`
4. Selecionar serviço e data → showTimes deve chamar `GET /api/public/horarios` e mostrar horários dinâmicos

---

## Resumo de Commits

| # | Commit | PR |
|---|--------|-----|
| 1 | feat(chat): adicionar BACKEND_URL ao supabase-config.js | PR1 |
| 2 | deps: adicionar supabase>=2.0.0 ao requirements | PR1 |
| 3 | feat(backend): criar supabase_client.py singleton | PR1 |
| 4 | fix(chat): corrigir formatarTelefone para formato (XX) 9XXXX-XXXX | PR2 |
| 5 | refactor(chat): showTimes() agora chama /api/public/horarios do Flask | PR2 |
| 6 | sync(chat): sincronizar correções B2 e B3 em chat/chat.js | PR2 |