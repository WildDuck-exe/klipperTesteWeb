---
phase: 05-compatibilidade-entrega
plan: 01
type: compatibility-docs
wave: 1
depends_on: null
files_modified:
  - barbearia-backend/requirements.txt
  - barbearia-backend/README.md
  - barbearia-frontend/README.md
autonomous: true
---

# Phase 5: Compatibilidade e Entrega Academica

## Tarefa 1: Auditoria de Compatibilidade Python 3.14

<read_first>
- C:/Users/Ian/Desktop/Nova pasta/barbearia-backend/requirements.txt
- C:/Users/Ian/Desktop/Nova pasta/barbearia-backend/app.py
</read_first>

<acceptance_criteria>
- `python --version` retorna 3.14.x
- `python -m py_compile barbearia-backend/app.py` executa sem erro
- `pip install -r barbearia-backend/requirements.txt --dry-run` lista dependencias compatíveis
- `python -c "import flask; import sqlalchemy; import firebase_admin"` executa sem ImportError
</acceptance_criteria>

<action>
1. Executar `python --version` para confirmar Python 3.14.x instalado
2. Executar `python -m py_compile barbearia-backend/app.py` para validar sintaxe
3. Executar `pip install -r barbearia-backend/requirements.txt --dry-run` para verificar dependencias
4. Executar `python -c "import flask; import sqlalchemy; import firebase_admin"` para validar bibliotecas
5. Documentar resultados em `05-PLAN.md` - se alguma biblioteca falhar, adicionar versao compatvel ao requirements.txt
</action>

---

## Tarefa 2: Atualizacao dos Manuais de Instalacao

<read_first>
- C:/Users/Ian/Desktop/Nova pasta/barbearia-backend/README.md
- C:/Users/Ian/Desktop/Nova pasta/barbearia-frontend/README.md
- C:/Users/Ian/Desktop/Nova pasta/barbearia-backend/requirements.txt
</read_first>

<acceptance_criteria>
- `grep -i "python 3.14" barbearia-backend/README.md` encontra referencia correta
- `grep -i "pip install" barbearia-backend/README.md` encontra instrucao de instalacao
- `grep -i "flutter" barbearia-frontend/README.md` encontra instrucao deexecucao
- `grep -i "firebase" barbearia-backend/README.md` encontra configuracao FCM
</acceptance_criteria>

<action>
1. Ler `barbearia-backend/README.md` atual
2. Atualizar secao de instalacao com:
   - Python 3.14 comoversao minima
   - Comando `pip install -r requirements.txt`
   - Configuracao devariaveis .env (FCM keys)
3. Ler `barbearia-frontend/README.md` atual
4. Atualizar secao de instalacao com:
   - Flutter 3.x comoversao minima
   - Passos para `flutter pub get`
   - Configuracao de FCM token no app
5. Verificar atualizacoes com grep
</action>

---

## Tarefa 3: Preparacao do Walkthrough Final

<read_first>
- C:/Users/Ian/Desktop/Nova pasta/barbearia-backend/app.py
- C:/Users/Ian/Desktop/Nova pasta/barbearia-frontend/lib/main.dart
- C:/Users/Ian/Desktop/Nova pasta/.planning/phases/05-compatibilidade-entrega/05-CONTEXT.md
</read_first>

<acceptance_criteria>
- `python app.py` inicia backend sem erro (saida contem "Running on")
- `flutter analyze` no frontend executa sem erro fatal
- Script de demonstracao cobre: login barbeiro, agendamento via chat, conclusao servico, dashboard
</acceptance_criteria>

<action>
1. Executar `cd barbearia-backend && python app.py` e verificar saida
2. Executar `cd barbearia-frontend && flutter analyze` e verificar saida
3. Criar documento `walkthrough-script.md` com fluxo de demonstracao:
   - Passo 1: Login como barbeiro (credenciais teste)
   - Passo 2: Agendamento via chat web (cliente ficticio)
   - Passo 3: Conclusao servico (atualizar status)
   - Passo 4: Verificacao no dashboard
4. Documentar comandos de verificacao (grep/CLI) para cada passo
</action>

---

*Plano: 05-PLAN.md*
*Criado em: 12/04/2026*
