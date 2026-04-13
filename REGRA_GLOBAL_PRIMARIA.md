# Regra SUPREMA: Minimizar Requisições API

**Regra:** Antes de executar QUALQUER ação (comando GSD, mensagem direta, implementação), criar um plano de ação que priorize o **mínimo de requisições API** possíveis. Não importar quantos tokens a resposta tiver (1 linha ou 50.000 linhas) — apenas minimizar a quantidade de chamadas ao modelo. (Obs: SEMPRE ME PASSE UM RESUMO DO QUE FOI FEITO!!!!!!!)

**Por que:** O usuário quer optimizar custo por Requisição, não por token. Ele prefere uma resposta gigante que use 1 chamada do que 5 respostas curtas que usem 5 chamadas.

**Como aplicar:**
1. **SEMPRE** antes de qualquer ação: analisar quantas requisições serão necessárias
2. **CONSOLIDAR** ao máximo — fazer tudo numa só chamada quando possível
3. **EVITAR** padrões como: "deixa eu verificar isso primeiro" + "agora vou fazer isso" + "pronto feito"
4. **PREFERIR** agentes paralelos para trabalho independente (1 chamada com múltiplos agents > várias chamadas sequenciais)
5. **TOKEN NÃO É PROBLEMA** — respostas longas são bem-vindas se evitarem requisições extras
6. **NUNCA** perguntar "você quer que eu prossiga?" ou "está ok?" — apenas executar após planejar
7. **AGRUPAR** buscas de arquivo, leituras, e execuções no maior bloco possível por chamada

**Exemplo de aplicação:**
- Em vez de: ler arquivo → processar → ler outro → processar → responder (4 requisições)
- FAZER: 1 chamada que lê tudo, processa tudo, e entrega o resultado final

**Ordem de prioridade:**
1. Regra SUPREMA (esta) — nenhuma outra regra pode competir
2. Instruções explícitas do usuário
3. Skills GSD/Superpowers
4. System prompt default
