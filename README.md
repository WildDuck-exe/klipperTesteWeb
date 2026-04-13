# BarberShop - Agenda Digital para Barbearia

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)

Sistema de gestão e agendamento desenvolvido como **Projeto de Extensão II (Engenharia de Software)**. O objetivo é fornecer uma ferramenta simples, segura e eficiente para barbeiros gerenciarem sua agenda e acompanharem seu faturamento.

## 🚀 Funcionalidades Principal

- **Autenticação Segura**: Acesso restrito via JWT (JSON Web Token).
- **Dashboard de Gestão**: Resumo de agendamentos e faturamento (Hoje/Semanal).
- **Agenda em Tempo Real**: Visualização, conclusão e cancelamento de serviços.
- **Gestão de Clientes**: Cadastro simplificado e busca rápida.
- **Estrutura Modular**: Backend organizado com Flask Blueprints para fácil escalabilidade.

## 🛠️ Como Executar o Projeto

### Pré-requisitos
- Python 3.10+
- Flutter SDK
- (Opcional) Git

---

### 1. Configurando o Backend (Servidor)

```bash
cd barbearia-backend

# Instalar dependências
pip install -r requirements.txt

# Inicializar o banco de dados (Cria tabelas e usuário admin)
python init_db_simple.py

# Iniciar o servidor
python run.py
```
O servidor estará rodando em `http://localhost:5000`.

### 2. Configurando o Frontend (App)

```bash
cd barbearia-frontend

# Obter dependências do Flutter
flutter pub get

# Rodar o aplicativo localmente
flutter run
```

### 3. Rodando a Versão Web (Recomendado para demonstração)

Como geramos a versão compilada para web, você pode rodá-la rapidamente sem baixar nada extra:

```bash
cd barbearia-frontend/build/web
python -m http.server 8080
```
Acesse em seu navegador: `http://localhost:8080`

> ⚠️ **Nota:** Certifique-se de que o **Backend (item 1)** esteja rodando paralelamente para que o login e a agenda funcionem corretamente.

## 🔐 Credenciais Padrão

Para o primeiro acesso, utilize:
- **Usuário:** `admin`
- **Senha:** `admin123`

## 📂 Estrutura do Projeto

```text
├── barbearia-backend/
│   ├── database/        # Banco de dados SQLite
│   ├── routes/          # Módulos da API (Blueprints)
│   ├── utils/           # Utilitários (Segurança/Auth)
│   ├── app.py           # Configuração centralizado
│   └── run.py           # Script de entrada
├── barbearia-frontend/
│   ├── lib/
│   │   ├── screens/     # Telas do App
│   │   ├── services/    # Integração com API
│   │   └── widgets/     # Componentes reutilizáveis
└── README.md            # Este arquivo
```

## 📝 Detalhes Técnicos

- **Segurança**: Senhas armazenadas com hash `pbkdf2:sha256`.
- **API**: Comunicação via REST JSON.
- **Persistência**: SQLite para dados locais e `shared_preferences` para o token no celular.

---
*Desenvolvido como projeto acadêmico - 2026*
