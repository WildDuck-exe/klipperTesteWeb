# Preocupacoes e Riscos: Ponto do Corte

## Seguranca

### CORS Excessivamente Permissivo
- **Risco**: `CORS_ORIGINS = "*"` em `config.py` permite qualquer origem.
- **Impacto**: Ataques de cross-site em ambientes de producao.
- **Mitigacao**: Restringir origens no `ProductionConfig` para dominios conhecidos (barbearia real + localhost para desenvolvimento).

### Credenciais FCM Expostas
- **Risco**: `firebase-service-account.json` contem chaves privadas do Firebase.
- **Impacto**: Acesso nao autorizado ao Firebase e custos indevidos.
- **Mitigacao**: Ja ignorado pelo `.gitignore`. Garantir que nunca seja commitado (verificar hooks pre-commit).

### Endpoints Publicos sem Autenticacao
- **Risco**: `/api/public/*` permite agendamentos sem verificacao de telefone (SMS/WhatsApp).
- **Impacto**: Spam e registros de clientes falsos via chat.
- **Mitigacao**: Implementar rate-limiting por IP e validacao de telefone via SMS ou WhatsApp antes de permitir agendamento.

### Seguranca da Interface Web (Chat)
- **Risco**: Arquivos estaticos em `static/chat` servidos sem headers de seguranca.
- **Impacto**: Ausencia de CSP, X-Frame-Options, HSTS.
- **Mitigacao**: Adicionar headers de seguranca no Flask antes de servir arquivos estaticos.

---

## Arquitetura e Escalabilidade

### SQLite em Concorrencia Alta
- **Risco**: Lock de escrita no SQLite causa timeouts em multiplas requisicoes simultaneas.
- **Impacto**: Agendamentos falham quando muitos clientes acessam o chat ao mesmo tempo.
- **Mitigacao**: Migrar para PostgreSQL se o volume de agendamentos simultaneos crescer. Enquanto isso, limitar conexoes no pool e usar transactions curtas.

### Race Condition em Agendamentos
- **Risco**: Dois clientes reservando o mesmo slot ao mesmo tempo.
- **Status Atual**: Logica de verificacao existe em `public.py` linhas 140-146, mas usa loop Python em memoria sem lock atomico.
- **Impacto**: Possivel double-booking em condicoes de alta concorrencia.
- **Mitigacao**: Implementar verificacao atomica no banco (constraint UNIQUE em data_hora + servico_id) ou usar `SELECT FOR UPDATE` dentro de transaction.

### Integridade de Despesas
- **Risco**: `Despesa.categoria` pode ser null ou string vazia (sem validacao no model).
- **Impacto**: Registros sem categoria poluem relatorios financeiros.
- **Mitigacao**: Adicionar validacao no model (nullable=False ou valor default) e validacao no endpoint `routes/despesas.py`.

---

## Tecnologico

### FCM no Windows (Flutter)
- **Risco**: Suporte a notificacoes nativas no Flutter para Windows e instavel/experimental.
- **Impacto**: Barbeiro pode nao receber notificacoes no PC.
- **Mitigacao**: Implementar fallback via tray icon com polling ou manter celular como dispositivo principal para FCM.

### Compatibilidade Python 3.14
- **Risco**: Bibliotecas C-extensions (SQLAlchemy, firebase-admin) podem quebrar com mudancas na linguagem.
- **Impacto**: Breaking changes em sintaxe ou API internas.
- **Mitigacao**:Auditar todas as bibliotecas com `python3.14 -c "import modulo"` apos release. Manter versoes pinned no requirements.txt.

### Chat UI sem Feedback Visual
- **Risco**: Cliente faz agendamento mas nao recebe confirmacao visual clara.
- **Impacto**: Cliente duda se o agendamento foi confirmado.
- **Mitigacao**: Adicionar modal/step de confirmacao no chat com ID do agendamento e mensagem de sucesso.

---

## Continuidade de Dados

### Ausencia de Backup
- **Risco**: `barbearia.db` nao tem rotina de backup.
- **Impacto**: Perda total de dados em falha de disco ou corrupcao.
- **Mitigacao**: Criar script de backup diario (cron ou task scheduler) que faca dump do SQLite para diretorio backup/.

### PushToken sem Expiracao
- **Risco**: Tokens FCM invalidos permanecem no banco para sempre.
- **Impacto**: Multicast tenta enviar para tokens invalidos, causando latencia e custos.
- **Mitigacao**: Implementar limpeza periodica de tokens expirados ou usar `messaging.send_multicast` que ja filtra falhos.

---

## Divida Tecnica

### Arquivos de Setup Redundantes
- **Risco**: `init_db.py` e `init_db_simple.py` duplicam logica.
- **Impacto**: Confusao sobre qual usar em producao.
- **Mitigacao**: Consolidar em um unico script e manter o outro como backup (ou remover).

### Secret Key Hardcoded
- **Risco**: `SECRET_KEY = 'dev-secret-key-barbearia-2026'` em `app.py` linha 25.
- **Impacto**: Seguranca comprometida se app.py for commitado.
- **Mitigacao**: Sempre usar variavel de ambiente com fallback seguro para dev apenas.

---

## Pendencias de Implementacao (Roadmap)

| Item | Prioridade | Blocoador |
|------|------------|-----------|
| Feedback visual no chat (confirmacao de agendamento) | Alta | Nao - standalone |
| Registro de token FCM no Flutter Windows | Alta | Marco 2 |
| Validacao de telefone no chat (anti-spam) | Media | For a do escopo inicial |
| Migracao para PostgreSQL (se volume crescer) | Baixa | Condicional |
| Script de backup diario | Media | For a do escopo academico |

---

*Ultima atualizacao: 12/04/2026 - Consolidado conforme Regra Global Primaria (minimo de chamadas API).*