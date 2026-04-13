import sqlite3
import random
from datetime import datetime, timedelta

def run_load_test():
    db_path = '../database/barbearia.db'
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    print("--- Iniciando Teste de Carga ---")
    
    # Obter IDs de clientes e serviços existentes
    clientes = cursor.execute("SELECT id FROM clientes").fetchall()
    servicos = cursor.execute("SELECT id FROM servicos").fetchall()
    
    if not clientes or not servicos:
        print("Erro: Cadastre clientes e serviços antes de rodar o teste.")
        return

    cliente_ids = [c[0] for c in clientes]
    servico_ids = [s[0] for s in servicos]
    
    print(f"Inserindo 100 agendamentos aleatórios...")
    
    start_time = datetime.now()
    
    for i in range(100):
        c_id = random.choice(cliente_ids)
        s_id = random.choice(servico_ids)
        
        # Datas nos últimos 7 dias e próximos 7 dias
        days_offset = random.randint(-7, 7)
        hours_offset = random.randint(8, 18)
        dt = datetime.now() + timedelta(days=days_offset)
        dt = dt.replace(hour=hours_offset, minute=0, second=0, microsecond=0)
        
        status = random.choice(['agendado', 'concluido', 'cancelado'])
        
        cursor.execute(
            "INSERT INTO agendamentos (cliente_id, servico_id, data_hora, status, observacoes) VALUES (?, ?, ?, ?, ?)",
            (c_id, s_id, dt.isoformat(), status, "Carga Automática")
        )

    conn.commit()
    end_time = datetime.now()
    
    duration = (end_time - start_time).total_seconds()
    print(f"Sucesso! 100 registros inseridos em {duration:.4f} segundos.")
    
    # Testar performance da query do Dashboard
    print("Testando performance da query do Dashboard (Semanal)...")
    start_dash = datetime.now()
    cursor.execute('''
        SELECT COUNT(*), SUM(s.preco)
        FROM agendamentos a
        JOIN servicos s ON a.servico_id = s.id
        WHERE DATE(a.data_hora) >= DATE('now', '-7 days')
        AND a.status != 'cancelado'
    ''')
    result = cursor.fetchone()
    end_dash = datetime.now()
    
    dash_duration = (end_dash - start_dash).total_seconds()
    print(f"Resumo Dashboard: {result[0]} agendamentos, R$ {result[1] or 0:.2f}")
    print(f"Tempo de resposta da Query: {dash_duration:.4f} segundos.")
    
    conn.close()
    print("--- Teste Finalizado ---")

if __name__ == "__main__":
    run_load_test()
