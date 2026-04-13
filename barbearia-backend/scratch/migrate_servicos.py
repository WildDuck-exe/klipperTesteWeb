# migrate_servicos.py
import sqlite3
import os

db_path = os.path.join('barbearia-backend', 'database', 'barbearia.db')

def migrate():
    if not os.path.exists(db_path):
        print("Database not found.")
        return

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    try:
        print("Adicionando coluna 'categoria'...")
        cursor.execute("ALTER TABLE servicos ADD COLUMN categoria VARCHAR(50) DEFAULT 'Geral'")
    except sqlite3.OperationalError:
        print("Coluna 'categoria' já existe.")

    try:
        print("Adicionando coluna 'ativo'...")
        cursor.execute("ALTER TABLE servicos ADD COLUMN ativo BOOLEAN DEFAULT 1")
    except sqlite3.OperationalError:
        print("Coluna 'ativo' já existe.")

    conn.commit()
    conn.close()
    print("Migração concluída.")

if __name__ == '__main__':
    migrate()
