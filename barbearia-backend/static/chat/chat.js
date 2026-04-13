const chatWindow = document.getElementById('chat-window');
const userInput = document.getElementById('user-input');
const sendBtn = document.getElementById('send-btn');

let state = 'NAME';
let userData = {
    nome: '',
    telefone: '',
    servico_id: null,
    servico_nome: '',
    data: '',
    data_hora: ''
};

const API_BASE = '/api/public';
const STORAGE_KEY = 'ponto_do_corte_telefone';

// Inicialização
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

// Enviar mensagem
sendBtn.addEventListener('click', handleUserInput);
userInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') handleUserInput();
});

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

function handleUserInput() {
    const text = userInput.value.trim();
    if (!text && state !== 'SERVICE' && state !== 'TIME') return;

    if (state === 'NAME') {
        userData.nome = text;
        addMessage(text, 'user');
        userInput.value = '';
        state = 'PHONE';
        setTimeout(() => askPhone(), 500);
    } else if (state === 'PHONE') {
        userData.telefone = text;
        addMessage(text, 'user');
        userInput.value = '';
        state = 'SERVICE';
        setTimeout(() => showServices(), 500);
    }
}

function addMessage(text, sender, isHtml = false) {
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
}

function disableOldOptions() {
    // Desabilita todos os botões de opções anteriores para evitar cliques fora de contexto
    const buttons = document.querySelectorAll('.option-btn, .horario-btn, .confirm-btn');
    buttons.forEach(btn => {
        btn.disabled = true;
        btn.style.opacity = '0.6';
        btn.style.cursor = 'not-allowed';
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

function askPhone() {
    addMessage(`Prazer em te conhecer, <strong>${userData.nome}</strong>! Qual é o seu número de <strong>telefone</strong> (com DDD)?`, 'system', true);
}

async function showServices() {
    const loader = showTyping();
    try {
        const response = await fetch(`${API_BASE}/servicos`);
        const servicos = await response.json();
        loader.remove();

        addMessage("Ótimo! Agora escolha qual serviço você deseja realizar:", "system");
        
        const optionsDiv = document.createElement('div');
        optionsDiv.className = 'options-container';
        
        servicos.forEach(s => {
            const btn = document.createElement('button');
            btn.className = 'option-btn';
            btn.innerHTML = `
                <span>${s.nome}</span>
                <span class="price">R$ ${s.preco.toFixed(2)}</span>
            `;
            btn.onclick = () => selectService(s.id, s.nome);
            optionsDiv.appendChild(btn);
        });
        
        chatWindow.appendChild(optionsDiv);
        chatWindow.scrollTop = chatWindow.scrollHeight;
        userInput.disabled = true;
    } catch (e) {
        loader.remove();
        addMessage("Ops, tive um problema ao carregar os serviços. Tente novamente mais tarde.", "system");
    }
}

function selectService(id, nome) {
    disableOldOptions(); // Desabilita botões de outros serviços
    userData.servico_id = id;
    userData.servico_nome = nome;
    addMessage(nome, 'user');
    
    state = 'DATE';
    setTimeout(() => askDate(), 500);
}

function askDate() {
    userInput.disabled = false;
    userInput.type = 'date';
    userInput.focus();
    
    // Define data mínima como hoje
    const hoje = new Date().toISOString().split('T')[0];
    userInput.min = hoje;
    
    addMessage("Perfeito. Em qual **data** você gostaria de agendar?", "system", true);
    
    // Sobrescreve o handler de input para capturar a data
    sendBtn.onclick = handleDateInput;
    userInput.onkeypress = (e) => {
        if (e.key === 'Enter') handleDateInput();
    };
}

function handleDateInput() {
    const dateValue = userInput.value;
    if (!dateValue) return;

    disableOldOptions(); // Garante limpeza de botões residuais
    userData.data = dateValue;
    const dateFormatted = dateValue.split('-').reverse().join('/');
    addMessage(dateFormatted, 'user');
    
    userInput.value = '';
    userInput.type = 'text';
    userInput.disabled = true;
    
    state = 'TIME';
    showTimes();
}

async function showTimes() {
    const loader = showTyping();
    try {
        const response = await fetch(`${API_BASE}/horarios?data=${userData.data}&servico_id=${userData.servico_id}`);
        const data = await response.json();
        loader.remove();

        if (data.disponiveis.length === 0) {
            addMessage("Não temos horários disponíveis para esta data. Por favor, escolha outro dia.", "system");
            setTimeout(() => askDate(), 1000);
            return;
        }

        addMessage("Temos estes horários disponíveis. Qual prefere?", "system");
        
        const grid = document.createElement('div');
        grid.className = 'horarios-grid';
        
        data.disponiveis.forEach(hora => {
            const btn = document.createElement('button');
            btn.className = 'horario-btn';
            btn.textContent = hora;
            btn.onclick = () => selectTime(hora);
            grid.appendChild(btn);
        });
        
        chatWindow.appendChild(grid);
        chatWindow.scrollTop = chatWindow.scrollHeight;
    } catch (e) {
        loader.remove();
        addMessage("Erro ao carregar horários.", "system");
    }
}

function selectTime(hora) {
    disableOldOptions(); // Desabilita grade de horários
    userData.data_hora = `${userData.data}T${hora}:00`;
    addMessage(hora, 'user');
    
    state = 'SUMMARY';
    setTimeout(() => showSummary(), 500);
}

function showSummary() {
    const summaryHtml = `
        <div class="summary-card">
            <h3>Confirme seu Agendamento</h3>
            <div class="summary-detail">
                <span class="label">Serviço:</span>
                <span class="value">${userData.servico_nome}</span>
            </div>
            <div class="summary-detail">
                <span class="label">Data:</span>
                <span class="value">${userData.data.split('-').reverse().join('/')}</span>
            </div>
            <div class="summary-detail">
                <span class="label">Horário:</span>
                <span class="value">${userData.data_hora.split('T')[1].substring(0, 5)}</span>
            </div>
            <button id="confirm-booking-btn" class="confirm-btn">Confirmar Agendamento</button>
        </div>
    `;
    addMessage(summaryHtml, 'system', true);
    
    const btn = document.getElementById('confirm-booking-btn');
    btn.onclick = () => {
        btn.disabled = true;
        btn.textContent = 'Agendando...';
        finishBooking();
    };
}

async function finishBooking() {
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
            // Persiste o telefone para reconhecimento futuro
            localStorage.setItem(STORAGE_KEY, userData.telefone);

            const ticketId = Math.random().toString(36).substr(2, 9).toUpperCase();
            const dataFormatada = userData.data.split('-').reverse().join('/');
            const horaFormatada = userData.data_hora.split('T')[1].substring(0, 5);

            // Mensagem no chat
            addMessage(`
                <div class="success-animation">
                    <svg class="checkmark" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52">
                        <circle class="checkmark__circle" cx="26" cy="26" r="25" fill="none"/>
                        <path class="checkmark__check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
                    </svg>
                </div>
            `, "system", true);

            // Modal de sucesso
            showSuccessModal(userData.servico_nome, dataFormatada, horaFormatada, ticketId);

            addMessage(`O barbeiro já foi notificado. Te esperamos lá! 💈`, "system");
        } else {
            addMessage(`Houve um erro: ${resData.error}`, "system");
            // Se for conflito, permite tentar outro horário
            if (response.status === 409) {
                setTimeout(() => askDate(), 2000);
            }
        }
    } catch (e) {
        loader.remove();
        addMessage("Erro ao conectar com o servidor.", "system");
    }
}

function showSuccessModal(servico, data, hora, ticketId) {
    // Remove modal existente se houver
    const existing = document.getElementById('success-modal-overlay');
    if (existing) existing.remove();

    const overlay = document.createElement('div');
    overlay.id = 'success-modal-overlay';
    overlay.innerHTML = `
        <div class="success-modal-content">
            <div class="success-modal-check">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52">
                    <circle cx="26" cy="26" r="25" fill="none" stroke="#22C55E" stroke-width="2"/>
                    <path fill="none" stroke="#22C55E" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
                </svg>
            </div>
            <h2 style="color:#22C55E;margin:0;font-size:22px;">Agendamento Confirmado!</h2>
            <p style="color:#94a3b8;margin:4px 0 20px;font-size:14px;">Prepare-se para ficar com o cabelo na régua 💈</p>
            <div class="ticket" style="text-align:left;width:100%;">
                <div class="ticket-header">Ponto do Corte</div>
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
            <button class="new-booking-btn" onclick="resetChat()" style="margin-top:16px;">
                Novo Agendamento
            </button>
        </div>
    `;
    document.body.appendChild(overlay);

    // Abre com animação
    requestAnimationFrame(() => {
        overlay.style.opacity = '1';
    });

    // Fecha ao clicar fora
    overlay.addEventListener('click', (e) => {
        if (e.target === overlay) {
            overlay.style.opacity = '0';
            setTimeout(() => overlay.remove(), 300);
        }
    });
}

function resetChat() {
    // Fecha o modal se estiver aberto
    const modal = document.getElementById('success-modal-overlay');
    if (modal) modal.remove();

    // Limpa serviço e agenda, mantém nome e telefone
    userData.servico_id = null;
    userData.servico_nome = '';
    userData.data = '';
    userData.data_hora = '';

    // Limpa o chat e volta para o início direto (sem init() para evitar loop)
    chatWindow.innerHTML = '';
    state = 'SERVICE';
    setTimeout(() => showServices(), 300);
}

