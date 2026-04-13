#!/usr/bin/env python3
# init_db_simple.py - Script simplificado para criar banco de dados

import os
import sqlite3
from datetime import datetime, timedelta

def criar_banco():
    """Cria o banco de dados SQLite com tabelas básicas"""

    # Caminho do banco de dados
    database_dir = os.path.join(os.path.dirname(__file__), 'database')
    database_path = os.path.join(database_dir, 'barbearia.db')

    # Cria diretório se não existir
    if not os.path.exists(database_dir):
        os.makedirs(database_dir)
        print(f"Diretório criado: {database_dir}")

    # Conecta ao banco (cria se não existir)
    conn = sqlite3.connect(database_path)
    cursor = conn.cursor()

    # Cria tabela de clientes
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS clientes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            telefone TEXT,
            data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    # Cria tabela de serviços
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS servicos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            descricao TEXT,
            duracao_minutos INTEGER DEFAULT 30,
            preco DECIMAL(10,2)
        )
    ''')

    # Cria tabela de agendamentos
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS agendamentos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente_id INTEGER NOT NULL,
            servico_id INTEGER NOT NULL,
            data_hora DATETIME NOT NULL,
            observacoes TEXT,
            status TEXT DEFAULT 'agendado',
            FOREIGN KEY (cliente_id) REFERENCES clientes(id),
            FOREIGN KEY (servico_id) REFERENCES servicos(id)
        )
    ''')

    # Cria tabela de usuarios
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            senha_hash TEXT NOT NULL
        )
    ''')

    conn.commit()
    print(f"Banco de dados criado em: {database_path}")
    print("Tabelas criadas: clientes, servicos, agendamentos")

    # Adiciona dados de exemplo
    adicionar_dados_exemplo(cursor, conn)

    # Garante usuário admin
    garantir_usuario_admin(cursor, conn)

    conn.close()
    print("Banco de dados inicializado com sucesso!")

def adicionar_dados_exemplo(cursor, conn):
    """Adiciona dados de exemplo para testes"""

    # Verifica se já existem dados
    cursor.execute("SELECT COUNT(*) FROM clientes")
    if cursor.fetchone()[0] > 0:
        print("Banco já contém dados. Pulando dados de exemplo.")
        return

    print("Adicionando dados de exemplo...")

    # Clientes de exemplo
    clientes = [
        ("João Silva", "(11) 99999-9999"),
        ("Maria Santos", "(11) 98888-8888"),
        ("Pedro Oliveira", "(11) 97777-7777"),
        ("Ana Costa", "(11) 96666-6666"),
        ("Carlos Souza", "(11) 95555-5555")
    ]

    cursor.executemany(
        "INSERT INTO clientes (nome, telefone) VALUES (?, ?)",
        clientes
    )
    print(f"  - {len(clientes)} clientes adicionados")

    # Serviços de exemplo
    servicos = [
        ("Corte de Cabelo", "Corte tradicional", 30, 30.00),
        ("Barba", "Aparação e modelagem de barba", 20, 20.00),
        ("Corte + Barba", "Combo corte e barba", 50, 45.00),
        ("Hidratação", "Hidratação capilar", 25, 25.00),
        ("Sobrancelha", "Design de sobrancelhas", 15, 15.00)
    ]

    cursor.executemany(
        "INSERT INTO servicos (nome, descricao, duracao_minutos, preco) VALUES (?, ?, ?, ?)",
        servicos
    )
    print(f"  - {len(servicos)} serviços adicionados")

    conn.commit()
    print("Dados de exemplo adicionados com sucesso!")

def garantir_usuario_admin(cursor, conn):
    """Garante que o usuário admin existe."""
    from werkzeug.security import generate_password_hash

    # Verifica se usuario admin já existe
    cursor.execute("SELECT COUNT(*) FROM usuarios")
    if cursor.fetchone()[0] == 0:
        print("Criando usuário admin padrão...")
        senha_hash = generate_password_hash('admin123')
        cursor.execute(
            "INSERT INTO usuarios (username, senha_hash) VALUES (?, ?)",
            ('admin', senha_hash)
        )
        print("  - Usuário admin criado (senha: admin123)")
        conn.commit()
    else:
        print("Usuário(s) já existente(s) na tabela usuarios.")

if __name__ == '__main__':
    criar_banco()