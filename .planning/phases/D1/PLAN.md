# Plano de Execução: Fase D1 — Demo Netlify

## Contexto e Objetivos
Transformar a versão demo em um produto de apresentação estável, offline e com persistência local por dispositivo.

## Etapa 1: Infraestrutura e Build
- [ ] Criar `netlify.toml` com regras de `redirects` para SPA.
- [ ] Corrigir erros de build no `ApiService.dart` (private field access errors).
- [ ] Validar compilação web localmente (`flutter build web`).

## Etapa 2: Persistência Local (Memory Device)
- [ ] Adicionar métodos `toJson` e `fromJson` (generativos) às classes de modelo.
- [ ] Implementar `_saveDemoDataLocally` e `_loadDemoDataLocally` no `ApiService`.
- [ ] Garantir que o app carregue os dados do `SharedPreferences` no início.
- [ ] Atualizar operações de criação/edição para persistirem no `localStorage`.

## Etapa 3: UX e Branding
- [ ] Implementar login "Bypass" para credenciais `admin/admin` e `demo/demo`.
- [ ] Aplicar branding Klipper completo (Logos, Cores e Strings).
- [ ] Adicionar botão de "Reset de Demo" no Perfil.

## Etapa 4: Verificação
- [ ] Testar persistência: Criar cliente, recarregar página, verificar permanência.
- [ ] Testar roteamento Netlify (refresh em subpáginas).
- [ ] Validar visual Klipper em resoluções Web e Mobile.
