# Testes

## Backend (Pytest)
A suíte de testes está em `barbearia-backend/tests/`.
- **Unitários**: Testam modelos e lógica de utilitários isoladamente.
- **Integração**: Testam endpoints da API usando o client do Flask e um banco de dados em memória ou temporário.
- **Status Atual**: Foco em cobertura de Modelos e Autenticação.

### Execução:
```bash
cd barbearia-backend
pytest
```

## Frontend (Flutter)
- **Widget Tests**: Localizados na pasta `test/`.
- **Foco**: Verificação de estados de UI e fluxos de navegação básica.
- **Integração Manual**: Dada a natureza visual, a verificação manual em ambiente de desenvolvimento é prioritária.

### Execução:
```bash
cd barbearia-frontend
flutter test
```

## Verificação de Notificações
- Como envolve o Firebase, os testes de push devem ser feitos com dispositivos reais ou simuladores configurados com Play Services.
- Log de sucesso/falha do Firebase Admin no backend é a principal fonte de validação técnica.
