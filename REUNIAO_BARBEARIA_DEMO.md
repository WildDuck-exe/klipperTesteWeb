# Reunião de Demonstração - Barbearia

**Data:** 14 de Abril de 2026 (Terça-feira)

## Objetivo
Apresentar o aplicativo e o chat de agendamento ao proprietario/funcionarios da barbearia.

---

## O que Será Demonstrado

### 1. Aplicativo Flutter (Frontend)
- Telas principais: Home, Agendamentos, Clientes, Servicos, Configuracoes
- Navegacao com magic bottom nav
- Lista de agendamentos com agenda_card
- Funcionalidades de agendamento

### 2. Chat de Agendamento (Backend)
- Interface web em `barbearia-backend/static/chat/`
- Arquivos: `chat.css`, `chat.js`, `index.html`
- Integração com backend Flask

---

## Como Subir o Backend + Chat (ngrok)

### Passo 1: Iniciar o Backend
```bash
cd barbearia-backend
python3 run.py
```
- URL local: `http://localhost:5000`
- Confirme que o chat funciona em `http://localhost:5000/chat`

### Passo 2: Criar Túnel Público (ngrok)
```bash
ngrok http 5000
```
- Será gerada uma URL pública (ex: `https://abc123.ngrok.io`)
- Essa URL expira ao fechar o ngrok

### Passo 3: Testar
- Acessar a URL do ngrok no navegador do celular do proprietario
- Confirmar que chat carrega e funciona

---

## Status Atual do Projeto
- **Frontend:** 5 telas implementadas (home, agendamentos, clientes, servicos, settings)
- **Backend:** API Flask com endpoints para clientes, servicos e agendamentos
- **Chat:** Interface web standalone para agendamento
- **Modulo de Reconhecimento de Cliente:** `prompt-reconhecimento-cliente.md`

---

## Checklist Pré-Demo

- [ ] Backend inicia sem erros (`python3 run.py`)
- [ ] Chat carrega em `http://localhost:5000/chat`
- [ ] ngrok configurado e URL pública gerada
- [ ] Celular do proprietario acessa a URL do ngrok
- [ ] Flutter app compilado (se necessário mostrar o app diretamente)

---

## Opções Futuras de Deploy (Produção)

| Opção | Custo | Uso |
|-------|-------|-----|
| Railway | Grátis | Backend + Chat |
| Render | Grátis | Backend + Chat |
| PythonAnywhere | Grátis | Backend (limitado) |

---

## Feedback do Proprietario
(notas durante a demo)

-

-

-

---

## Arquivos Relevantes
- `barbearia-frontend/` - Projeto Flutter
- `barbearia-backend/` - Backend Flask + chat web
- `PLANO_CHAT_AGENDAMENTO.md` - Plano do chat de agendamento
- `prompt-reconhecimento-cliente.md` - Modulo de reconhecimento
- `magic-navigation.html` - Prototipo da navegacao