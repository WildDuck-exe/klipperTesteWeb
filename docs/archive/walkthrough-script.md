# Walkthrough Script - Ponto do Corte

Script de demonstração do sistema completo de agendamento digital.

---

## Passo 1: Login como Barbeiro

1. Executar o backend:
```bash
cd barbearia-backend
python app.py
```
Saída esperada: `Running on http://127.0.0.1:5000`

2. Executar o app Flutter:
```bash
cd barbearia-frontend
flutter run -d windows
```

3. Na tela de login:
- Usuário: `admin`
- Senha: `admin123`

**Verificação:** Tela Dashboard carrega com agenda do dia vazia.

---

## Passo 2: Cadastro de Cliente e Serviço

1. No Dashboard, tocar em **Clientes** na bottom nav
2. Tocar no botão **+**
3. Preencher:
   - Nome: `Carlos Santos`
   - Telefone: `(11) 98765-4321`
4. Tocar **Salvar**

**Verificação:** Cliente aparece na lista.

---

## Passo 3: Agendamento via Chat Web (Cliente)

1. Abrir navegador em: `http://localhost:5000/chat`
2. O chat responde: `"Olá! Prazer em te conhecer, qual seu nome?"`
3. Digitar: `Carlos`
4. O chat responde pedindo telefone
5. Digitar número: `11987654321`
   - Máscara aplica automaticamente: `(11)98765-4321`
   - Borda verde quando válido
6. Selecionar serviço: `Corte de Cabelo`
7. Selecionar data: choosing tomorrow's date
8. Selecionar horário disponível
9. Confirmar agendamento

**Verificação:** Modal de sucesso aparece. Notificação push chega no app do barbeiro.

---

## Passo 4: Conclusão do Serviço

1. No app Flutter, o Dashboard mostra o agendamento pendente
2. Tocar no card do agendamento
3. Tocar **Concluir** (botão verde)

**Verificação:**
- Status muda para "Concluído"
- Dashboard atualiza contadores
- Receita confirmada aumenta

---

## Passo 5: Verificação no Dashboard

1. Observar cards:
   - Agendados: 0 (todos concluídos)
   - Concluídos: 1
   - Receita Confirmada: valor do serviço

**Verificação:** Dados financeiros batem com operação realizada.

---

## Comandos de Verificação Rápida

```bash
# Backend
curl http://localhost:5000/api/clientes
curl http://localhost:5000/api/agenda/hoje
curl http://localhost:5000/api/dashboard/resumo

# Flutter
cd barbearia-frontend && flutter analyze
```

---

## Duração Estimada

Demonstração completa: **5-7 minutos**

- Login: 30 segundos
- Cadastro: 1 minuto
- Chat booking: 2-3 minutos
- Conclusão: 1 minuto
- Verificação: 30 segundos
