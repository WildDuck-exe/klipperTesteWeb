const chatWindow = document.getElementById('chat-window');
const userInput = document.getElementById('user-input');
const sendBtn = document.getElementById('send-btn');

let state = 'NAME';
let userData = {
    nome: '',
    telefone: '',
    telefoneFormatado: '',
    servico_id: null,
    servico_nome: '',
    data: '',
    data_hora: ''
};
let lastErrorText = null; // Track last error to prevent duplicate DOM spam

const API_BASE = '/api/public';
const STORAGE_KEY = 'ponto_do_corte_telefone';

// ─── Máscara de telefone brasileiro ────────────────────────────────────────────
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

function apenasDigitos(str) {
    return str.replace(/\D/g, '');
}

// ─── Inicialização ───────────────────────────────────────────────────────────
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
                    userData.nome = cliente.nome;
                    userData.telefone = telefoneSalvo;

                    addMessage(
                        `Olá de volta, <strong>${cliente.nome}</strong>! 👋 Que bom te ver por aqui.<br><br>` +
                        `<span style="font-size: 0.9em; opacity: 0.8;">Não é você? ` +
                        `<button onclick="esqueci()" style="background: none; border: none; text-decoration: underline; cursor: pointer; color: inherit; font-size: inherit;">` +
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
        }
    }

    addMessage(
        "Olá! Bem-vindo ao <strong>Ponto do Corte</strong>. 💈<br>Para começarmos, qual é o seu <strong>nome completo</strong>?",
        'system',
        true
    );
}

// ─── Envio de mensagem ────────────────────────────────────────────────────────
sendBtn.addEventListener('click', handleUserInput);
userInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') handleUserInput();
});

userInput.addEventListener('input', () => {
    if (state === 'PHONE') {
        const formatted = formatarTelefone(userInput.value);
        userInput.value = formatted;
        validarTelefone();
    }
});

function validarTelefone() {
    const digits = apenasDigitos(userInput.value);
    // Aceita 11 dígitos independentes do dígito após o DDD
    const valid = digits.length === 11;
    userInput.style.borderColor = valid ? 'var(--success, #22c55e)' : (digits.length > 0 ? 'var(--error, #ef4444)' : '');
    return valid;
}

function handleUserInput() {
    const text = userInput.value.trim();
    if (!text && state !== 'SERVICE' && state !== 'TIME') return;

    if (state === 'NAME') {
        if (text.length < 2) {
            shakeInput();
            addMessage("Por favor, digite um nome válido (pelo menos 2 letras).", "system");
            return;
        }
        userData.nome = text;
        addMessage(text, 'user');
        userInput.value = '';
        state = 'PHONE';
        setTimeout(() => askPhone(), 500);
    } else if (state === 'PHONE') {
        // Liberal input — strip all non-digits, accept any punctuation user typed
        const digits = apenasDigitos(text);
        if (digits.length !== 11) {
            // If we already showed the same error, just shake the existing bubble
            const errorMsg = `O número precisa ter <strong>11 dígitos</strong> com DDD.<br>Exemplo: <strong>(71)99288-7024</strong>`;
            if (lastErrorText && lastErrorText.includes('11 dígitos')) {
                const bubbles = chatWindow.querySelectorAll('.message.system .bubble');
                if (bubbles.length > 0) {
                    const lastBubble = bubbles[bubbles.length - 1];
                    lastBubble.classList.remove('shake-msg');
                    void lastBubble.offsetWidth;
                    lastBubble.classList.add('shake-msg');
                    userInput.value = '';
                    return;
                }
            }
            addMessage(errorMsg, "system", true);
            userInput.value = '';
            return;
        }
        userData.telefone = digits;
        userData.telefoneFormatado = formatarTelefone(digits);
        addMessage(userData.telefoneFormatado, 'user');
        userInput.value = '';
        state = 'SERVICE';
        setTimeout(() => showServices(), 500);
    } else if (state === 'DATE') {
        handleDateInput();
    }
}

function shakeInput() {
    userInput.style.animation = 'none';
    userInput.offsetHeight; // força reflow
    userInput.style.animation = 'shake 0.4s ease';
}

// ─── Mensagens ────────────────────────────────────────────────────────────────
function addMessage(text, sender, isHtml = false) {
    // Deduplicate identical error messages — shake existing bubble instead of DOM spam
    if (sender === 'system' && !isHtml && lastErrorText === text) {
        const bubbles = chatWindow.querySelectorAll('.message.system .bubble');
        if (bubbles.length > 0) {
            const lastBubble = bubbles[bubbles.length - 1];
            lastBubble.classList.remove('shake-msg');
            void lastBubble.offsetWidth; // force reflow
            lastBubble.classList.add('shake-msg');
            return; // don't append duplicate
        }
    }

    const msgDiv = document.createElement('div');
    msgDiv.className = `message ${sender}`;

    const bubble = document.createElement('div');
    bubble.className = 'bubble';

    if (isHtml) {
        bubble.innerHTML = text;
    } else {
        bubble.textContent = text;
    }

    msgDiv.appendChild(bubble);
    chatWindow.appendChild(msgDiv);
    chatWindow.scrollTop = chatWindow.scrollHeight;

    // Remember this error for deduplication
    if (sender === 'system' && !isHtml) {
        lastErrorText = text;
    }
}

function disableOldOptions() {
    const buttons = document.querySelectorAll('.option-btn, .horario-btn, .confirm-btn');
    buttons.forEach(btn => {
        btn.disabled = true;
        btn.style.opacity = '0.5';
        btn.style.pointerEvents = 'none';
    });
}

function showTyping() {
    const typingDiv = document.createElement('div');
    typingDiv.className = 'message system typing-msg';
    typingDiv.innerHTML = `
        <div class="bubble">
            <div class="typing">
                <div class="dot"></div>
                <div class="dot"></div>
                <div class="dot"></div>
            </div>
        </div>
    `;
    chatWindow.appendChild(typingDiv);
    chatWindow.scrollTop = chatWindow.scrollHeight;
    return typingDiv;
}

// ─── Fluxo: Telefone ─────────────────────────────────────────────────────────
function askPhone() {
    userInput.disabled = false;
    userInput.type = 'tel';
    userInput.inputMode = 'numeric';
    userInput.value = '';
    userInput.placeholder = '(00)90000-0000';
    userInput.maxLength = 15;
    userInput.focus();

    addMessage(
        `Prazer, <strong>${userData.nome}</strong>! 💈 Agora me informe seu <strong>celular</strong> com DDD:<br>` +
        `<span style="font-size: 0.85em; opacity: 0.7;">Ex: (71)98888-7777 — são 11 dígitos com o 9 depois do DDD</span>`,
        'system',
        true
    );
}

// ─── Fluxo: Serviços ─────────────────────────────────────────────────────────
async function showServices() {
    const loader = showTyping();
    try {
        const response = await fetch(`${API_BASE}/servicos`);
        const servicos = await response.json();
        loader.remove();

        if (servicos.length === 0) {
            addMessage("Nenhum serviço disponível no momento. Tente novamente mais tarde.", "system");
            return;
        }

        addMessage("Ótimo! Escolha o serviço:", "system");

        const optionsDiv = document.createElement('div');
        optionsDiv.className = 'services-grid';

        servicos.forEach(s => {
            const btn = document.createElement('button');
            btn.className = 'service-card';
            btn.innerHTML = `
                <span class="service-name">${s.nome}</span>
                <span class="service-meta">${s.duracao_minutos} min</span>
                <span class="service-price">R$ ${s.preco.toFixed(2)}</span>
            `;
            btn.onclick = () => selectService(s.id, s.nome);
            optionsDiv.appendChild(btn);
        });

        chatWindow.appendChild(optionsDiv);
        chatWindow.scrollTop = chatWindow.scrollHeight;
        userInput.disabled = true;
    } catch (e) {
        loader.remove();
        addMessage("Erro ao carregar serviços. Verifique sua conexão.", "system");
    }
}

function selectService(id, nome) {
    disableOldOptions();
    userData.servico_id = id;
    userData.servico_nome = nome;
    addMessage(nome, 'user');

    state = 'DATE';
    setTimeout(() => askDate(), 500);
}

// ─── Fluxo: Data ──────────────────────────────────────────────────────────────
function askDate() {
    userInput.disabled = false;
    userInput.type = 'date';
    userInput.value = '';
    userInput.placeholder = '';
    userInput.maxLength = '';
    userInput.focus();

    const hoje = new Date().toISOString().split('T')[0];
    userInput.min = hoje;

    addMessage(
        `Ótimo, <strong>${userData.servico_nome}</strong>! 📅 Qual <strong>data</strong> você prefere?`,
        'system',
        true
    );
}

function handleDateInput() {
    const dateValue = userInput.value;
    if (!dateValue) return;

    disableOldOptions();
    userData.data = dateValue;
    const dateFormatted = dateValue.split('-').reverse().join('/');
    addMessage(dateFormatted, 'user');

    userInput.value = '';
    userInput.type = 'text';
    userInput.disabled = true;

    state = 'TIME';
    showTimes();
}

// O evento automático "change" foi desativado para o Input Date. 
// O disparo ocorria intermitentemente antes da hora certa.
// Agora aguardamos o consentimento pelo botão enviar do Flow.

// ─── Fluxo: Horários ─────────────────────────────────────────────────────────
async function showTimes() {
    const loader = showTyping();
    try {
        const response = await fetch(`${API_BASE}/horarios?data=${userData.data}&servico_id=${userData.servico_id}`);
        const data = await response.json();
        loader.remove();

        if (data.disponiveis.length === 0) {
            addMessage("Nenhum horário disponível nesta data. 😔 Por favor, escolha outro dia.", "system");
            setTimeout(() => askDate(), 1500);
            return;
        }

        addMessage(`Temos <strong>${data.disponiveis.length}</strong> horários disponíveis. Qual prefere?`, "system", true);

        const grid = document.createElement('div');
        grid.className = 'horarios-grid';

        data.disponiveis.forEach(hora => {
            const btn = document.createElement('button');
            btn.className = 'time-chip';
            btn.textContent = hora;
            btn.onclick = () => selectTime(hora);
            grid.appendChild(btn);
        });

        chatWindow.appendChild(grid);
        chatWindow.scrollTop = chatWindow.scrollHeight;
    } catch (e) {
        loader.remove();
        addMessage("Erro ao carregar horários. Tente novamente.", "system");
    }
}

function selectTime(hora) {
    disableOldOptions();
    userData.data_hora = `${userData.data}T${hora}:00`;
    addMessage(hora, 'user');

    state = 'SUMMARY';
    setTimeout(() => showSummary(), 500);
}

// ─── Confirmação ─────────────────────────────────────────────────────────────
function showSummary() {
    const dataFmt = userData.data.split('-').reverse().join('/');
    const horaFmt = userData.data_hora.split('T')[1].substring(0, 5);

    const summaryHtml = `
        <div class="summary-card">
            <h3>✅ Confirme seu Agendamento</h3>
            <div class="summary-detail">
                <span class="label">💈 Serviço</span>
                <span class="value">${userData.servico_nome}</span>
            </div>
            <div class="summary-detail">
                <span class="label">📅 Data</span>
                <span class="value">${dataFmt}</span>
            </div>
            <div class="summary-detail">
                <span class="label">⏰ Horário</span>
                <span class="value">${horaFmt}</span>
            </div>
            <button id="confirm-booking-btn" class="confirm-btn" onclick="finishBooking()">
                ✅ Confirmar Agendamento
            </button>
        </div>
    `;
    addMessage(summaryHtml, 'system', true);
}

// ─── Booking ─────────────────────────────────────────────────────────────────
async function finishBooking() {
    const btn = document.getElementById('confirm-booking-btn');
    if (btn) {
        btn.disabled = true;
        btn.textContent = '⏳ Aguarde...';
    }

    const loader = showTyping();
    try {
        const response = await fetch(`${API_BASE}/agendar`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                nome: userData.nome,
                telefone: userData.telefone,
                servico_id: userData.servico_id,
                data_hora: userData.data_hora
            })
        });

        const resData = await response.json();
        loader.remove();

        if (response.ok) {
            localStorage.setItem(STORAGE_KEY, userData.telefone);

            const ticketId = Math.random().toString(36).substr(2, 9).toUpperCase();
            const dataFmt = userData.data.split('-').reverse().join('/');
            const horaFmt = userData.data_hora.split('T')[1].substring(0, 5);

            addMessage(`
                <div class="success-animation">
                    <svg class="checkmark" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52">
                        <circle class="checkmark__circle" cx="26" cy="26" r="25" fill="none"/>
                        <path class="checkmark__check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
                    </svg>
                </div>
            `, "system", true);

            showSuccessModal(userData.servico_nome, dataFmt, horaFmt, ticketId);
            addMessage(`O barbeiro já foi notificado. Te esperamos lá! 💈`, "system");

        } else if (response.status === 409) {
            addMessage(`Este horário acabou de ser preenchido. 😔 Por favor, escolha outro.`, "system");
            setTimeout(() => askDate(), 2000);
        } else {
            addMessage(`Erro: ${resData.error || 'Não foi possível confirmar. Tente novamente.'}`, "system");
            if (btn) {
                btn.disabled = false;
                btn.textContent = '✅ Confirmar Agendamento';
            }
        }
    } catch (e) {
        loader.remove();
        addMessage("Erro de conexão. Verifique sua internet.", "system");
        if (btn) {
            btn.disabled = false;
            btn.textContent = '✅ Confirmar Agendamento';
        }
    }
}

// ─── Modal de Sucesso ─────────────────────────────────────────────────────────
function showSuccessModal(servico, data, hora, ticketId) {
    const existing = document.getElementById('success-modal-overlay');
    if (existing) existing.remove();

    const overlay = document.createElement('div');
    overlay.id = 'success-modal-overlay';
    overlay.innerHTML = `
        <div class="success-modal-content">
            <div class="success-modal-icon">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52" width="72" height="72">
                    <circle cx="26" cy="26" r="25" fill="none" stroke="#22C55E" stroke-width="2"/>
                    <path fill="none" stroke="#22C55E" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
                </svg>
            </div>
            <h2 style="color:#22C55E;margin:0 0 4px;font-size:22px;">Agendamento Confirmado!</h2>
            <p style="color:#94a3b8;margin:0 0 20px;font-size:14px;">Prepare-se para ficar na régua 💈</p>
            <div class="ticket">
                <div class="ticket-header">💈 Ponto do Corte</div>
                <div class="ticket-body">
                    <div class="ticket-row">
                        <span class="ticket-label">Serviço</span>
                        <span class="ticket-value">${servico}</span>
                    </div>
                    <div class="ticket-row">
                        <span class="ticket-label">Data</span>
                        <span class="ticket-value">${data}</span>
                    </div>
                    <div class="ticket-row">
                        <span class="ticket-label">Horário</span>
                        <span class="ticket-value">${hora}</span>
                    </div>
                </div>
                <div class="ticket-footer">TOKEN: ${ticketId}</div>
            </div>
            <button class="new-booking-btn" onclick="resetChat()">
                🔄 Novo Agendamento
            </button>
        </div>
    `;
    document.body.appendChild(overlay);

    requestAnimationFrame(() => {
        overlay.style.opacity = '1';
    });

    overlay.addEventListener('click', (e) => {
        if (e.target === overlay) {
            overlay.style.opacity = '0';
            setTimeout(() => overlay.remove(), 300);
        }
    });
}

// ─── Reset ────────────────────────────────────────────────────────────────────
function resetChat() {
    const modal = document.getElementById('success-modal-overlay');
    if (modal) {
        modal.style.opacity = '0';
        setTimeout(() => modal.remove(), 300);
    }

    userData.servico_id = null;
    userData.servico_nome = '';
    userData.data = '';
    userData.data_hora = '';

    userInput.type = 'text';
    userInput.disabled = true;
    userInput.value = '';

    chatWindow.innerHTML = '';
    state = 'SERVICE';

    addMessage(
        `Ótimo, <strong>${userData.nome}</strong>! Vamos criar um novo agendamento. 💈<br>Qual serviço você gostaria?`,
        'system',
        true
    );
    setTimeout(() => showServices(), 300);
}

function esqueci() {
    localStorage.removeItem(STORAGE_KEY);
    userData = {
        nome: '',
        telefone: '',
        telefoneFormatado: '',
        servico_id: null,
        servico_nome: '',
        data: '',
        data_hora: ''
    };
    userInput.type = 'text';
    userInput.disabled = false;
    userInput.value = '';
    chatWindow.innerHTML = '';
    state = 'NAME';
    init();
}
