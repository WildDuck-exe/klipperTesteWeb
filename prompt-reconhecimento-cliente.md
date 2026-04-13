# Prompt de Implementação — Reconhecimento de Cliente Recorrente (Ponto do Corte)

## Contexto do Projeto

Você está trabalhando no **Ponto do Corte**, um sistema de agenda digital para barbearia desenvolvido como Projeto de Extensão II. O stack é:

- **Backend**: Python + Flask + SQLAlchemy + SQLite
- **Frontend do cliente**: Chat web (HTML + CSS + JS vanilla), servido pelo próprio Flask em `static/chat/`
- **Frontend administrativo**: Flutter (fora do escopo desta tarefa)

O sistema possui duas categorias de rotas:
1. **Rotas públicas** (`/api/public/*`) — sem autenticação, usadas pelo chat do cliente
2. **Rotas protegidas** (`/api/*`) — requerem JWT, usadas pelo app Flutter do barbeiro

---

## Problema a Resolver

Atualmente, toda vez que um cliente acessa o chat para fazer um agendamento, ele precisa digitar **nome e telefone** novamente, mesmo que já tenha agendado antes. Além disso, o sistema não tem garantia de que o nome digitado pertence à pessoa certa — um "João Silva" pode ser qualquer pessoa.

**Restrição importante**: Não é permitido criar login e senha para o cliente. A solução deve ser transparente e não intrusiva.

---

## Solução a Implementar

A identidade do cliente é ancorada no **número de telefone**, que o backend já usa como chave de lookup (`Cliente.query.filter_by(telefone=...).first()`). A solução usa `localStorage` do navegador para lembrar o telefone entre sessões e consulta o servidor para confirmar a identidade antes de pular etapas do chat.

### Arquivos a modificar

1. `barbearia-backend/routes/public.py` — adicionar novo endpoint
2. `barbearia-backend/static/chat/chat.js` — adicionar lógica de reconhecimento

---

## Tarefa 1 — Novo endpoint em `routes/public.py`

Adicione a seguinte rota ao Blueprint `public_bp`, **sem modificar nenhuma rota existente**:

```python
@public_bp.route('/api/public/cliente', methods=['GET'])
def get_cliente_by_telefone():
    """
    Verifica se um número de telefone já possui cadastro.
    Usado pelo chat para reconhecer clientes recorrentes.
    Retorna apenas nome e telefone — nenhum dado sensível ou histórico.
    """
    telefone = request.args.get('telefone', '').strip()

    if not telefone:
        return jsonify({'error': 'Parâmetro telefone é obrigatório'}), 400

    cliente = Cliente.query.filter_by(telefone=telefone).first()

    if not cliente:
        return jsonify({'encontrado': False}), 404

    return jsonify({
        'encontrado': True,
        'nome': cliente.nome,
        'telefone': cliente.telefone
    })
```

**Por que só nome e telefone?** O endpoint é público (sem autenticação). Expor histórico de agendamentos publicamente seria um risco de privacidade. O objetivo aqui é apenas confirmar a identidade para fins de UX.

---

## Tarefa 2 — Modificações em `static/chat/chat.js`

### 2a. Entenda o estado atual do chat

O chat usa uma máquina de estados simples com a variável `state`:

```
'NAME' → 'PHONE' → 'SERVICE' → 'DATE' → 'TIME' → 'SUMMARY' → (confirmação)
```

No estado `'NAME'`, o usuário digita o nome. No `'PHONE'`, digita o telefone. Só depois vai para `'SERVICE'` (escolha do serviço).

**O objetivo é**: quando o cliente for reconhecido pelo `localStorage`, **pular direto para `'SERVICE'`**, sem pedir nome nem telefone novamente.

### 2b. Adicione a constante de chave do localStorage

No topo do arquivo, junto às outras variáveis globais, adicione:

```js
const STORAGE_KEY = 'ponto_do_corte_telefone';
```

### 2c. Substitua a inicialização do `DOMContentLoaded`

**Código atual:**
```js
document.addEventListener('DOMContentLoaded', () => {
    userInput.focus();
});
```

**Substitua por:**
```js
document.addEventListener('DOMContentLoaded', () => {
    userInput.focus();
    init();
});

async function init() {
    const telefoneSalvo = localStorage.getItem(STORAGE_KEY);

    if (telefoneSalvo) {
        const loader = showTyping();
        try {
            const res = await fetch(`${API_BASE}/cliente?telefone=${encodeURIComponent(telefoneSalvo)}`);
            loader.remove();

            if (res.ok) {
                const cliente = await res.json();
                if (cliente.encontrado) {
                    // Cliente reconhecido: preenche os dados e pula para serviços
                    userData.nome = cliente.nome;
                    userData.telefone = cliente.telefone;

                    addMessage(
                        `Olá de volta, <strong>${cliente.nome}</strong>! 👋 Que bom te ver por aqui.<br><br>` +
                        `<span style="font-size: 0.9em; opacity: 0.8;">Não é você? ` +
                        `<button onclick="esquecer()" style="background: none; border: none; text-decoration: underline; cursor: pointer; color: inherit; font-size: inherit;">` +
                        `Usar outro número</button></span>`,
                        'system',
                        true
                    );

                    state = 'SERVICE';
                    setTimeout(() => showServices(), 900);
                    return;
                }
            }
        } catch (e) {
            loader.remove();
            // Falha silenciosa: segue o fluxo normal sem travar o chat
        }
    }

    // Fluxo normal: nenhum dado salvo ou cliente não encontrado no servidor
    addMessage(
        "Olá! Bem-vindo ao Ponto do Corte. 💈<br>Para começarmos, qual é o seu <strong>nome</strong>?",
        'system',
        true
    );
}
```

### 2d. Adicione a função `esquecer()`

Esta função permite que outra pessoa usando o mesmo dispositivo inicie um novo cadastro:

```js
function esquecer() {
    localStorage.removeItem(STORAGE_KEY);
    userData = {
        nome: '',
        telefone: '',
        servico_id: null,
        servico_nome: '',
        data: '',
        data_hora: ''
    };
    state = 'NAME';
    addMessage("Tudo bem! Vamos recomeçar. Qual é o seu <strong>nome</strong>?", 'system', true);
}
```

### 2e. Salve o telefone após agendamento bem-sucedido

Dentro da função `finishBooking()`, **após o bloco `if (response.ok)`**, adicione a linha de persistência:

```js
// Logo após confirmar que response.ok é true, antes de addMessage:
localStorage.setItem(STORAGE_KEY, userData.telefone);
```

O trecho completo do `if (response.ok)` deve ficar assim:

```js
if (response.ok) {
    // Persiste o telefone para reconhecimento futuro
    localStorage.setItem(STORAGE_KEY, userData.telefone);

    addMessage(`
        <div class="success-animation">
            <svg class="checkmark" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52">
                <circle class="checkmark__circle" cx="26" cy="26" r="25" fill="none"/>
                <path class="checkmark__check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
            </svg>
        </div>
        🎉 <strong>Pronto, ${userData.nome}!</strong> Seu agendamento foi realizado com sucesso.
    `, "system", true);
    addMessage(`O barbeiro já foi notificado. Te esperamos lá!`, "system");
} else {
    addMessage(`Houve um erro: ${resData.error}`, "system");
}
```

---

## Comportamento esperado após a implementação

### Cenário 1 — Primeira visita
1. `localStorage` vazio → fluxo normal começa com "Qual é o seu nome?"
2. Cliente digita nome, telefone, escolhe serviço, data, hora e confirma
3. Ao confirmar: `localStorage.setItem('ponto_do_corte_telefone', '(11) 99999-9999')`

### Cenário 2 — Visita posterior (mesmo dispositivo/navegador)
1. `localStorage` tem o telefone salvo
2. Chat consulta `GET /api/public/cliente?telefone=(11) 99999-9999`
3. Servidor retorna `{ encontrado: true, nome: "João Silva", telefone: "..." }`
4. Chat exibe: *"Olá de volta, João! 👋"* e já abre a seleção de serviços

### Cenário 3 — Outro usuário no mesmo dispositivo
1. O cliente reconhecido clica em "Usar outro número"
2. `localStorage` é limpo, `userData` é resetado, `state` volta para `'NAME'`
3. Fluxo normal recomeça

### Cenário 4 — Telefone salvo mas cliente deletado do banco
1. Consulta ao servidor retorna 404 (`encontrado: false`)
2. Fallback silencioso: fluxo normal começa normalmente
3. O `localStorage` desatualizado não causa erro visível

---

## O que NÃO fazer

- **Não salve o nome no `localStorage`** — o nome pode ser atualizado no banco pelo barbeiro; o servidor é a fonte da verdade
- **Não exponha agendamentos anteriores no endpoint público** — apenas nome e telefone são necessários
- **Não bloqueie o chat se o fetch falhar** — sempre tenha um caminho de fallback para o fluxo normal (o `catch` com `loader.remove()` garante isso)
- **Não modifique** nenhuma rota existente em `public.py` — apenas adicione a nova

---

## Checklist de verificação

Após implementar, confirme:

- [ ] `GET /api/public/cliente?telefone=XXXXXXXXXX` retorna 200 com `{encontrado: true, nome, telefone}` para um telefone cadastrado
- [ ] O mesmo endpoint retorna 404 com `{encontrado: false}` para telefone desconhecido
- [ ] Primeira visita: chat começa pedindo nome normalmente
- [ ] Segunda visita no mesmo navegador: chat exibe "Olá de volta" e pula para serviços
- [ ] Botão "Usar outro número" limpa o localStorage e reinicia o fluxo
- [ ] Se o servidor estiver fora do ar durante o `init()`, o chat ainda funciona normalmente (não trava)
- [ ] O telefone é salvo no localStorage **somente** após agendamento bem-sucedido (não antes)
