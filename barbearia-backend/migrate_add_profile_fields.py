#!/usr/bin/env python3
# migrate_add_profile_fields.py
# Adiciona colunas nome_exibicao e telefone à tabela usuarios
# IDEMPOTENTE - seguro rodar múltiplas vezes

import os
import sqlite3
import sys

def migrate_add_profile_fields():
    """Adiciona colunas nome_exibicao e telefone à tabela usuarios."""
    database_path = os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        'database',
        'barbearia.db'
    )

    if not os.path.exists(database_path):
        print("Banco não existe ainda. Migração desnecessária.")
        return

    conn = sqlite3.connect(database_path)
    cursor = conn.cursor()

    # Verifica colunas existentes
    cursor.execute("PRAGMA table_info(usuarios)")
    colunas = {col[1] for col in cursor.fetchall()}

    if 'nome_exibicao' in colunas:
        print("Coluna 'nome_exibicao' já existe. Migração ignorada.")
    else:
        cursor.execute("ALTER TABLE usuarios ADD COLUMN nome_exibicao VARCHAR(100)")
        print("Coluna 'nome_exibicao' adicionada.")

    if 'telefone' in colunas:
        print("Coluna 'telefone' já existe. Migração ignorada.")
    else:
        cursor.execute("ALTER TABLE usuarios ADD COLUMN telefone VARCHAR(20)")
        print("Coluna 'telefone' adicionada.")

    conn.commit()
    conn.close()
    print("Migração de campos de perfil concluída.")

if __name__ == '__main__':
    migrate_add_profile_fields()
