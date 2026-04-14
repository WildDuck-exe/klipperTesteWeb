# KLIPPER — EXECUÇÃO FASEADA GUIADA POR IA

## 1. Finalidade deste documento

Este arquivo é o **documento mestre de execução** da missão atual do projeto.
Ele deve ser usado pela IA como referência principal para:

- entender o objetivo do produto
- comparar o estado atual do código com o estado desejado
- executar mudanças por fases
- pedir confirmação antes de iniciar cada fase
- preservar a navegação existente
- evitar mudanças fora de escopo

Este documento **não autoriza implementação automática imediata**.
Antes de cada fase, a IA deve analisar, apontar riscos, listar dependências e **aguardar confirmação explícita do usuário**.

---

## 2. Nome oficial e identidade do produto

### Nome oficial atual
**Klipper**

### Nome antigo que ainda pode existir no projeto
**Ponto do Corte**

### Diretriz
Sempre que houver divergência entre nome antigo e nome atual, considerar **Klipper** como a marca oficial a ser consolidada.

---

## 3. Contexto atual do projeto

O repositório atual contém um ecossistema com três frentes principais:

1. **Backend** em Flask + SQLAlchemy
2. **App administrativo** em Flutter
3. **Chat web** para agendamento do cliente

Também já existe uma navegação importante no app Flutter, conhecida neste projeto como:

### Regra crítica
**Magic Navigation / Magic Bottom Navigation**

Essa navegação **não pode ser quebrada, removida ou degradada** durante nenhuma fase da missão.

---

## 4. Protocolo obrigatório de execução da IA

A IA deve seguir este protocolo em toda a missão.

### 4.1. Antes de iniciar qualquer fase
A IA deve:

1. ler este documento inteiro
2. analisar o estado atual do código
3. localizar os arquivos realmente envolvidos
4. identificar riscos técnicos
5. identificar dependências da fase
6. listar o que está faltando para começar
7. fazer perguntas objetivas apenas sobre a fase atual
8. **aguardar confirmação explícita do usuário**

### 4.2. O que a IA não pode fazer
A IA **não pode**:

- começar implementações sem confirmação
- avançar automaticamente para a próxima fase
- tratar hipótese como decisão final
- alterar partes do projeto fora do escopo da fase atual
- refatorar grandes trechos sem necessidade real
- quebrar a Magic Navigation
- assumir que documentação antiga representa o estado atual do código sem validar no repositório

### 4.3. Ao concluir uma fase
A IA deve obrigatoriamente entregar:

- resumo do que foi feito
- lista de arquivos alterados
- riscos residuais
- como validar manualmente
- o que ficou pendente
- confirmação de que **não avançará para a próxima fase sem autorização**

---

## 5. Estado desejado do produto

A evolução do Klipper nesta missão tem como foco principal:

- fortalecer o fluxo de autenticação
- estruturar melhor a entrada do usuário novo
- criar uma área de perfil mais completa
- organizar melhor navegação e ações secundárias
- consolidar a identidade visual da marca Klipper
- alinhar o chat web ao nome e à marca oficial
- preservar a base funcional existente

---

## 6. Restrições críticas

### 6.1. Navegação
- a **Magic Navigation** deve continuar funcionando
- a navegação principal existente não deve ser quebrada
- novas telas devem ser integradas com compatibilidade

### 6.2. Escopo
- cada fase deve atacar apenas o próprio escopo
- não misturar implementação funcional com refinamento visual profundo sem necessidade

### 6.3. Branding
- a nova marca oficial é **Klipper**
- referências antigas a **Ponto do Corte** devem ser mapeadas antes de serem alteradas

### 6.4. Segurança operacional
- a IA deve preservar a estabilidade do projeto
- sempre que houver risco de regressão, deve apontar antes de implementar

---

## 7. Fase 0 — Análise obrigatória do repositório

### Objetivo
Entender com precisão a arquitetura atual antes de qualquer mudança.

### Escopo
A IA deve apenas analisar.

### Deve fazer
- mapear backend, frontend Flutter e chat web
- localizar login, autenticação, home/dashboard, navegação e branding
- localizar a implementação da Magic Navigation
- identificar se já existe drawer/menu hambúrguer, perfil e assets de logo
- detectar inconsistências entre documentação antiga e código atual
- detectar erros ou limitações já existentes que podem afetar as próximas fases

### Não deve fazer
- não implementar nada
- não editar nada
- não renomear nada
- não trocar assets ainda

### Saída esperada
- resumo da arquitetura atual
- arquivos-chave por módulo
- riscos técnicos
- conflitos entre documentação e código
- perguntas objetivas antes da Fase 1

### Critério de aceite
A fase só é considerada concluída quando a IA apresentar análise clara e aguardar autorização.

---

## 8. Fase 1 — Preparação segura da missão

### Objetivo
Garantir que o projeto esteja pronto para receber mudanças com segurança.

### Escopo
- validar dependências críticas
- apontar problemas conhecidos de build/execução
- identificar se existe dívida técnica imediata que afeta as próximas fases
- confirmar localização dos arquivos de branding

### Itens previstos
- mapear erros já conhecidos
- identificar limitações atuais do build Flutter/Web
- apontar assets atuais de logo e ícones
- identificar textos antigos de marca no app e no chat web

### Fora de escopo
- correção visual ampla
- refatorações grandes
- mudanças de negócio

### Antes de iniciar, a IA deve perguntar
- a nova logo já está posicionada em pasta definitiva?
- o usuário quer trocar apenas nome e logo nesta missão ou também paleta visual?

### Critério de aceite
- riscos documentados
- arquivos críticos localizados
- pendências pré-fase apontadas

---

## 9. Fase 2 — Evolução da autenticação

### Objetivo
Completar o fluxo de autenticação do produto.

### Estado desejado
A tela de login deve evoluir para contemplar:

- acesso por login
- opção de **Cadastro**
- opção de **Esqueci minha senha?**

### Escopo
- analisar a tela de login atual
- propor a melhor forma de adicionar cadastro e recuperação de senha
- preservar integração com backend e navegação existente

### Itens previstos
- adicionar entrada para cadastro
- adicionar entrada para recuperação de senha
- garantir navegação correta entre essas telas
- não quebrar o fluxo atual de login

### Fora de escopo
- redefinição completa da arquitetura de autenticação
- múltiplos perfis de usuário
- reestruturação profunda do backend sem necessidade

### Antes de iniciar, a IA deve perguntar
- cadastro será apenas frontend neste momento ou já com backend funcional?
- recuperação de senha será implementada de forma real ou apenas estrutural nesta fase?

### Critérios de aceite
- usuário consegue acessar cadastro a partir do login
- usuário consegue acessar recuperação de senha a partir do login
- login atual continua funcional
- navegação principal permanece estável

---

## 10. Fase 3 — Primeiro acesso e estrutura de perfil

### Objetivo
Organizar o onboarding inicial e criar a base da área de perfil.

### Estado desejado
No primeiro acesso do novo usuário, o sistema deve encaminhá-lo para completar:

- perfil pessoal
- dados da barbearia ou salão

Também deve existir uma tela de **Meu Perfil**.

### Escopo
- estruturar fluxo de primeiro acesso
- estruturar tela Meu Perfil
- permitir edição de perfil
- permitir upload da logo do estabelecimento
- exibir identificação visual do local cadastrado

### Fora de escopo
- sistema completo multiusuário
- permissões avançadas
- modelagem final de papéis de equipe

### Antes de iniciar, a IA deve perguntar
- quais campos mínimos do perfil pessoal devem existir?
- quais campos mínimos da barbearia devem existir?
- o upload da logo será salvo localmente, no backend ou apenas preparado estruturalmente?

### Critérios de aceite
- novo usuário possui fluxo claro de primeiro acesso
- tela Meu Perfil existe e é acessível
- edição de perfil funciona
- upload/seleção de logo está integrado ao fluxo definido
- nada quebra na navegação atual

---

## 11. Fase 4 — Menu hambúrguer e organização do dashboard

### Objetivo
Centralizar ações secundárias e organizar melhor a navegação superior.

### Estado desejado
O menu hambúrguer deve funcionar corretamente e concentrar:

- Configurações
- Sobre o app
- Meu Perfil
- Sair do app

### Escopo
- corrigir ou implementar o menu hambúrguer
- mover ações hoje dispersas no topo do dashboard para dentro dele
- preservar a Magic Navigation

### Fora de escopo
- redesign completo do dashboard
- mudanças profundas na bottom nav

### Antes de iniciar, a IA deve perguntar
- o menu já existe parcialmente e deve ser aproveitado, ou a implementação atual deve ser substituída?
- quais elementos do topo devem ser removidos e quais devem permanecer?

### Critérios de aceite
- menu abre e fecha corretamente
- itens estão acessíveis e funcionais
- topo do dashboard fica mais limpo
- Magic Navigation permanece intacta

---

## 12. Fase 5 — Rebranding para Klipper

### Objetivo
Consolidar a nova identidade do produto no app e no chat web.

### Estado desejado
- marca oficial consolidada como **Klipper**
- logo oficial substituindo assets antigos
- referências visuais antigas de **Ponto do Corte** removidas dos pontos visíveis principais

### Escopo
- criar ou usar pasta central de assets da nova marca
- substituir logos atuais
- aplicar a nova logo no app e no chat web
- alinhar textos visíveis do produto ao nome Klipper
- fazer pequenos ajustes visuais coerentes com a nova logo

### Fora de escopo
- redesign completo de UX
- reestruturação total de tema sem necessidade
- rebranding de tudo que não é visível ou relevante nesta missão, sem validação

### Antes de iniciar, a IA deve perguntar
- qual arquivo é a logo oficial definitiva?
- haverá apenas troca de logo e nome ou também ajustes de cor e estilo?
- quais ambientes devem ser atualizados nesta fase: login, app, about, chat web, ícones?

### Critérios de aceite
- app e chat web exibem a marca Klipper nos pontos definidos
- referências principais a Ponto do Corte foram substituídas
- a nova identidade está visualmente coerente
- assets estão centralizados e organizados

---

## 13. Fase 6 — Validação futura de produto

### Objetivo
Registrar pontos que ainda dependem de validação com barbearia real.

### Esta fase não é implementação imediata.
Ela serve para documentar hipóteses de evolução futura.

### Tópicos de validação futura
- modelo multiusuário por barbearia
- papéis e permissões
- conta única vs múltiplos acessos
- necessidade real de níveis de controle por agenda

### Diretriz
A IA não deve tratar isso como implementação obrigatória agora, a menos que o usuário peça explicitamente.

---

## 14. Ordem recomendada de execução

1. Fase 0 — análise obrigatória
2. Fase 1 — preparação segura
3. Fase 2 — autenticação
4. Fase 3 — primeiro acesso e perfil
5. Fase 4 — menu hambúrguer
6. Fase 5 — rebranding Klipper
7. Fase 6 — validações futuras

---

## 15. Formato de resposta esperado da IA em cada fase

Sempre responder com esta estrutura:

### 1. Entendimento da fase
- o que será feito
- o que não será feito

### 2. Arquivos impactados
- lista objetiva dos arquivos que pretende ler ou alterar

### 3. Riscos
- riscos técnicos
- riscos visuais
- risco para navegação

### 4. Perguntas antes de começar
- perguntas curtas e objetivas

### 5. Espera por confirmação
A IA deve encerrar a resposta aguardando autorização.

---

## 16. Checklist permanente da missão

- [ ] não quebrar a Magic Navigation
- [ ] não avançar de fase sem confirmação
- [ ] não assumir decisões não confirmadas
- [ ] preservar estabilidade do projeto
- [ ] tratar Klipper como marca oficial
- [ ] mapear branding antigo antes de substituir
- [ ] manter escopo controlado por fase

---

## 17. Observação final para a IA

Este documento governa a missão atual.

Se existir conflito entre documentação antiga do projeto e a missão atual, a IA deve:

1. apontar o conflito
2. validar no código atual
3. perguntar ao usuário qual direção seguir
4. aguardar confirmação antes de alterar qualquer coisa

A prioridade máxima desta missão é:

**evoluir o produto com segurança, sem quebrar a navegação existente, e consolidar a marca Klipper de forma progressiva e controlada.**
