# Fase D1 — Demo Netlify

## Objetivo
Preparar a versão demo (`barbearia-frontend-web-demo`) para apresentação estável no Netlify, com memória local persistente e branding Klipper.

## Escopo
- Corrigir erros de build no `ApiService.dart`.
- Implementar persistência local (SharedPreferences) para dados mockados.
- Configurar login offline (`admin/admin`, `demo/demo`).
- Criar `netlify.toml` para roteamento SPA.
- Aplicar branding visual Klipper.

## Estratégia de Persistência
- Cada dispositivo mantém seu próprio estado via `localStorage`.
- CRUDs locais atualizam o estado persistido.
- Botão "Reset Demo" para limpar o estado local.

## Critérios de Aceite
- Build Web funcional.
- State isolado por navegador.
- Roteamento Netlify sem 404.
- Identidade visual Klipper.
