# KLIPPER — FASE 1: RELATÓRIO DE ANÁLISE

**Data:** 2026-04-13
**Status:** CONCLUÍDA — aguardando aprovação para Fase 2
**Regra:** Zero implementações. Análise pura.

---

## 1. Resumo Executivo

O projeto Klipper está em estado funcional com 3 módulos:
- **Backend** Flask + SQLAlchemy + SQLite (7 tabelas)
- **Frontend** Flutter (Android/iOS/Web)
- **Chat Web** HTML/JS (serve via Flask static)

A codebase está funcional mas com gaps identificados que impactam as Fases 2 e 3 diretamente.

---

## 2. Arquitetura de Banco de Dados

### 2.1 Script em Uso

**`init_db.py`** é o script ativo — usa SQLAlchemy via `app.app_context()`.
**`init_db_simple.py`** é um script paralelo mais antigo, com SQLite direto (4 tabelas apenas) — **não é o script em uso no projeto atual**.

### 2.2 Tabelas Existentes (via `init_db.py`)

| Tabela | Modelo | Colunas Principais |
|--------|--------|-------------------|
| `usuarios` | `Usuario` | id, username, senha_hash |
| `clientes` | `Cliente` | id, nome, telefone, data_cadastro |
| `servicos` | `Servico` | id, nome, descricao, duracao_minutos, preco, categoria, ativo |
| `agendamentos` | `Agendamento` | id, cliente_id, servico_id, data_hora, observacoes, status |
| `push_tokens` | `PushToken` | id, token, dispositivo, atualizado_em |
| `configuracoes` | `Configuracao` | id, chave, valor, descricao, atualizado_em |
| `despesas` | `Despesa` | id, descricao, valor, data, categoria |

### 2.3 Modelo `Usuario` — STATUS CRÍTICO

```
Usuario(id, username, senha_hash)
```

**Gaps identificados:**
- Sem campo `email`
- Sem campo `telefone`
- Sem campo `nome_exibicao` ou `barbearia_nome`

**Impacto na Fase 2 (Cadastro):**
O endpoint de registro de novo usuário **não existe** no backend. Para implementar cadastro real com `POST /api/auth/register`, o modelo `Usuario` precisará de `email` (único, para login e recuperação de senha).

**Impacto na Fase 2 (Esqueci Senha):**
Sem `email` no modelo, não há como implementar recuperação real. A Fase 2 só terá estrutura visual placeholder.

**Impacto na Fase 3 (Perfil):**
O modelo `Usuario` não carrega dados da barbearia. Fase 3 precisaria de modelo `Barbearia` separado ou extensão do `Usuario`.

---

## 3. Status de Autenticação

### 3.1 Backend (`routes/auth.py`)

| Endpoint | Método | Status |
|----------|--------|--------|
| `/api/auth/login` | POST | ✅ Existe — JWT 24h |
| `/api/auth/register-token` | POST | ✅ Existe — só registra FCM |
| `/api/auth/logout` | qualquer | ❌ **NÃO EXISTE** |

### 3.2 Frontend (`api_service.dart`)

| Método | Status | Notas |
|--------|--------|-------|
| `login()` | ✅ Funcional | Salva token em SharedPreferences |
| `logout()` | ✅ Funcional localmente | Só limpa SharedPreferences. **Não notifica backend.** |
| `loadToken()` | ✅ Funcional | Restaura sessão ao abrir app |

**GAP CRÍTICO:** `logout()` é 100% client-side. O token JWT permanece válido no servidor por até 24h. Para segurança real em produção, precisaria de um endpoint de logout que adicione o token a uma blacklist.

---

## 4. Mapa Completo de Branding "Ponto do Corte"

### 4.1 Frontend Flutter

| Arquivo | Linha | Texto/Asset |
|---------|-------|-------------|
| `lib/main.dart` | 63 | `title: 'Ponto do Corte'` |
| `lib/screens/login_screen.dart` | 119 | `Text('Ponto do Corte')` — título do login |
| `lib/screens/login_screen.dart` | 204 | `'© 2026 Sistema de Gestão de Barbearia'` — footer |
| `lib/screens/login_screen.dart` | 109 | `'assets/images/logo.png'` — logo antiga |
| `lib/screens/home_screen.dart` | 437 | `Text('Ponto do Corte')` — drawer header |
| `lib/screens/about_screen.dart` | 54 | `Text('Ponto do Corte')` — nome no about |
| `lib/screens/about_screen.dart` | 198 | Texto de privacidade menciona "Ponto do Corte" |
| `lib/screens/about_screen.dart` | 234 | `'© 2026 Ponto do Corte'` — footer about |
| `lib/theme/app_theme.dart` | 5 | `// Paleta Premium - Ponto do Corte` — comentário |
| `assets/images/logo.png` | — | Logo antiga (~816KB) |

### 4.2 Backend / Chat Web

| Arquivo | Linha | Texto/Asset |
|---------|-------|-------------|
| `barbearia-backend/static/chat/index.html` | 6 | `<title>Ponto do Corte | Chat de Agendamento</title>` |
| `barbearia-backend/static/chat/index.html` | 15 | `<h1>Ponto do Corte</h1>` |
| `barbearia-backend/static/chat/chat.js` | 79 | Mensagem boas-vindas: `"Olá! Bem-vindo ao <strong>Ponto do Corte</strong>. 💈"` |
| `barbearia-backend/static/chat/chat.js` | 482 | Ticket header: `"💈 Ponto do Corte"` |

### 4.3 Branding Antigo (para futura troca)

| Caminho | Status | Prioridade |
|---------|--------|-----------|
| `assets/images/logo.png` | Logo antiga | Substituir por `layout/logo_klipper.png` |
| `assets/images/layout/logo_klipper.png` | ✅ Nova logo **já presente** | Alta — referenciar na Fase 5 |

---

## 5. Status do Build Web

### 5.1 Dependências Flutter (`pubspec.yaml`)

```
flutter: sdk >=3.0.0 <4.0.0
http: ^1.1.0
provider: ^6.1.1
intl: ^0.19.0
flutter_dotenv: ^5.1.0
shared_preferences: ^2.2.2
firebase_core: ^3.6.0
firebase_messaging: ^15.1.3
url_launcher: ^6.2.1
google_fonts: ^6.1.0
animations: ^2.0.11
flutter_spinkit: ^5.2.0
```

### 5.2 Problemas de Build Web Identificados

| Problema | Severity | Detalhe |
|----------|----------|---------|
| `firebase_core` e `firebase_messaging` | 🔴 BLOQUEANTE | Firebase não funciona na Web. Código já tem `kIsWeb` guards, mas dependências estão no pubspec. Em build web puro pode causar warnings ou bundling desnecessário. |
| `google_fonts` | 🟡 WARN | Faz download de fontes na runtime. Em ambiente offline/restrito vai usar fallback. Não bloqueia build mas altera visual. |
| `.env` como asset | 🟡 WARN | `pubspec.yaml` lista `.env` como asset — arquivo sensível que não deveria estar no controle de versão. |

### 5.3 Assets

- `assets/images/logo.png` — 816KB, logo antiga (referenciada em 4 lugares)
- `assets/images/layout/logo_klipper.png` — 791KB, **nova logo já presente**
- `assets/images/empty_agenda.png` — 309KB

**Nota:** `pubspec.yaml` declara `assets/images/` (com trailing slash) — isso inclui subpastas recursivamente. `layout/logo_klipper.png` será incluído no build automaticamente.

---

## 6. Análise da Magic Navigation

### 6.1 Implementação Real

A Magic Navigation existe exclusivamente em:

**`lib/widgets/magic_bottom_nav.dart`** — Widget completo com:
- `MagicBottomNav` (StatefulWidget) com `AnimationController` e `_floatAnimation`
- `_MagicNavState` gerencia a animação de scale dos botões Kart-like
- `_MagicNavItem` — item individual com animação de tamanho e cor

**Navegação de 5 itens:**
```
[0] Dashboard  — dashboard_outlined
[1] Clientes   — people_outline
[2] Agenda     — calendar_today_outlined
[3] Serviços   — content_cut_outlined
[4] Vendas     — monetization_on_outlined
```

### 6.2 Integração na HomeScreen

```dart
// home_screen.dart:29
int _selectedIndex = 0;

// home_screen.dart:147 — Drawer dependente do índice
drawer: isDesktop ? null : _buildDrawer(),

// No AppBar top-left:
IconButton(
  icon: const Icon(Icons.menu),
  onPressed: () => Scaffold.of(context).openDrawer(),
)

// No bottom: MagicBottomNav
MagicBottomNav(
  currentIndex: _selectedIndex,
  onTap: _handleNavigation,  // Atualiza _selectedIndex
)

// Corpo: IndexedStack (preserva estado ao trocar de aba)
IndexedStack(
  index: _selectedIndex,
  children: [Dashboard, Clientes, Agenda, Servicos, Vendas],
)
```

### 6.3 Riscos para Magic Navigation

| Risco | Fase que pode impactar | Detalhe |
|-------|----------------------|---------|
| **Adicionar tela fora do IndexedStack** | Fase 3, 4 | Se for adicionada uma tela de "Perfil" ou "Configurações" via `push()` sem ser no `IndexedStack`, a `MagicBottomNav` não responde. |
| **Alterar `_selectedIndex`** | Qualquer fase | Se qualquer código setar `_selectedIndex` manualmente para valor > 4, dá index error. |
| **Modificar `_navIcons` ou `_navLabels`** | Fase 5 | Se o rebranding trocar ícones ou labels, a animação da `MagicBottomNav` precisa continuar funcionando. |

**Regra de ouro preservada:** A `MagicBottomNav` é completamente isolada — recebe `currentIndex` e `onTap` como parâmetros. Só precisa que `HomeScreen` passe os valores corretos. Qualquer nova tela que precise de navegação deve usar `Navigator.push()` **sem interferir no `_selectedIndex` da home**.

---

## 7. Endpoints Públicos (Chat Web)

| Endpoint | Método | Função |
|----------|--------|--------|
| `/api/public/validate-phone` | GET | Valida formato de telefone |
| `/api/public/cliente` | GET | Busca cliente por telefone |
| `/api/public/servicos` | GET | Lista serviços ativos |
| `/api/public/horarios` | GET | Calcula horários disponíveis |
| `/api/public/agendar` | POST | Cria agendamento + push |

✅ Sistema público do chat está bem estruturado e separado da autenticação.

---

## 8. Configurações Existentes

**8 tabelas em `configuracoes` (chave/valor):**

| Chave | Valor padrão | Uso |
|-------|-------------|-----|
| `horario_inicio` | `08:00` | Cálculo de horários |
| `horario_fim` | `18:00` | Cálculo de horários |
| `dias_trabalho` | `1,2,3,4,5,6` | Dias ativos (0=Dom) |
| `pausa_inicio` | `12:00` | Bloqueio de horário |
| `pausa_fim` | `13:00` | Bloqueio de horário |
| `whatsapp_mensagem` | `Olá {nome}...Ponto do Corte...` | Template WhatsApp |
| `whatsapp_mensagem_pausa` | `...` | Template |
| `whatsapp_mensagem_fechado` | `...` | Template |
| `whatsapp_mensagem_cancelamento` | `Olá {nome}...` | Template |

**Nota:** Mensagens WhatsApp ainda dizem "Ponto do Corte" — serão impactadas pela Fase 5.

---

## 9. Dívida Técnica — Impacto por Fase

| Gap | Fase Impactada | Gravidade | Ação Necessária |
|-----|---------------|-----------|-----------------|
| Sem endpoint `/api/auth/register` | Fase 2 | 🔴 CRÍTICO | Criar no backend antes de qualquer implementação frontend |
| Sem campo `email` em `Usuario` | Fase 2 | 🔴 CRÍTICO | Adicionar coluna email ao modelo antes do register |
| Sem endpoint `/api/auth/logout` | Fase 2 | 🟡 MÉDIO | Criar endpoint com blacklist de token (ou aceitar gap de segurança) |
| Sem `email` para recuperação | Fase 2 | 🟡 MÉDIO | Só estrutura placeholder é possível sem email |
| Sem modelo `Perfil`/`Barbearia` | Fase 3 | 🔴 CRÍTICO | Criar modelo separate ou estender `Usuario` |
| Sem tela "Meu Perfil" | Fase 3 | 🔴 CRÍTICO | Criar `profile_screen.dart` |
| Drawer sem "Meu Perfil" | Fase 4 | 🟡 MÉDIO | Adicionar item no `_buildDrawer()` |
| Firebase não funciona na Web | Todas | 🟢 BAIXO | Aceito como design — não tratar |
| Mensagens WhatsApp com "Ponto do Corte" | Fase 5 | 🟡 MÉDIO | Atualizar valores em `Configuracao` |
| `google_fonts` online-only | Todas | 🟢 BAIXO | Adicionar fallback se offline preocupar |

---

## 10. Perguntas em Aberto (para decisão antes da Fase 2)

1. **Cadastro (Fase 2):** O campo `email` será obrigatório para registro? Qual validação de formato?
2. **Modelo de dados (Fase 3):** A barbearia terá um nome próprio separado do usuário admin, ou o `username` do admin é o nome da barbearia?
3. **Logo nova:** A `logo_klipper.png` deve substituir `logo.png` já na **Fase 1** (só troca de caminho) ou apenas na **Fase 5**?

---

## 11. Critérios de Aceite da Fase 1 — VERIFICAÇÃO

- [x] Todos os erros de build documentados
- [x] Dependências mapeadas com versions
- [x] Dívida técnica que afeta Fase 2 e 3 listada
- [x] Status do endpoint de logout: **NÃO EXISTE no backend** — gap documentado
- [x] Status do modelo `Usuario`: **INSUFICIENTE** para Fase 2 — precisa de email
- [x] Mapa completo de arquivos com branding "Ponto do Corte" entregue (seção 4)
- [x] Nenhum arquivo alterado

---

*Relatório gerado em fase de análise — nenhuma implementação foi feita.*
