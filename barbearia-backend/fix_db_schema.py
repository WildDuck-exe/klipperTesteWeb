import sqlite3
import os

# Caminho do banco de dados (relativo ao backend)
db_path = 'database/barbearia.db'

if not os.path.exists(db_path):
    print(f"Erro: Banco de dados não encontrado em {db_path}")
    exit(1)

def fix_schema():
    print(f"Iniciando reparo do banco de dados: {db_path}")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Colunas a serem adicionadas na tabela 'usuarios'
    new_columns = [
        ('email', 'TEXT'),
        ('nome_exibicao', 'TEXT'),
        ('telefone', 'TEXT')
    ]

    for col_name, col_type in new_columns:
        try:
            print(f"Tentando adicionar coluna '{col_name}'...")
            cursor.execute(f"ALTER TABLE usuarios ADD COLUMN {col_name} {col_type};")
            print(f"Sucesso: Coluna '{col_name}' adicionada.")
        except sqlite3.OperationalError as e:
            if "duplicate column name" in str(e).lower():
                print(f"Info: Coluna '{col_name}' já existe.")
            else:
                print(f"Erro ao adicionar '{col_name}': {e}")

    conn.commit()
    conn.close()
    print("Reparo concluído!")

if __name__ == '__main__':
    fix_schema()
