#!/usr/bin/env python3
# migrate_add_email.py
# Script de migração para adicionar coluna email na tabela usuarios
# IDEMPOTENTE - seguro rodar múltiplas vezes

import os
import sqlite3
import sys

def migrate_add_email():
    """Adiciona coluna email à tabela usuarios se não existir."""
    database_path = os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        'database',
        'barbearia.db'
    )

    # Se banco não existe ainda, não precisa migrar
    if not os.path.exists(database_path):
        print("Banco não existe ainda. Migração desnecessária.")
        return

    conn = sqlite3.connect(database_path)
    cursor = conn.cursor()

    # Verifica se a coluna email já existe
    cursor.execute("PRAGMA table_info(usuarios)")
    colunas = [col[1] for col in cursor.fetchall()]

    if 'email' in colunas:
        print("Coluna 'email' já existe na tabela usuarios. Migração ignorada.")
    else:
        # Adiciona coluna como nullable (dados antigos ficam NULL)
        cursor.execute("ALTER TABLE usuarios ADD COLUMN email VARCHAR(120)")
        print("Coluna 'email' adicionada (nullable).")

    # Verifica se o índice único já existe
    cursor.execute(
        "SELECT name FROM sqlite_master WHERE type='index' AND name='ix_usuarios_email'"
    )
    if cursor.fetchone():
        print("Índice único 'ix_usuarios_email' já existe. Migração ignorada.")
    else:
        # Cria índice único para garantir uniqueness (ignora NULLs no SQLite)
        cursor.execute(
            "CREATE UNIQUE INDEX ix_usuarios_email ON usuarios(email)"
        )
        print("Índice único 'ix_usuarios_email' criado.")

    conn.commit()
    conn.close()
    print("Migração concluída com sucesso.")

if __name__ == '__main__':
    migrate_add_email()
