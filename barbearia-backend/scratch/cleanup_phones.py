# cleanup_phones.py
import sys
import os
import re

# Adiciona o caminho para importar os modelos (pai de scratch)
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import app
from models import db, Cliente

def limpar_telefone(telefone):
    if not telefone:
        return ""
    return re.sub(r'\D', '', telefone)

def run_cleanup():
    with app.app_context():
        clientes = Cliente.query.all()
        count = 0
        for cliente in clientes:
            novo_tel = limpar_telefone(cliente.telefone)
            if novo_tel != cliente.telefone:
                print(f"Limpando: {cliente.nome} | {cliente.telefone} -> {novo_tel}")
                cliente.telefone = novo_tel
                count += 1
        
        if count > 0:
            db.session.commit()
            print(f"\nSucesso: {count} telefones padronizados.")
        else:
            print("\nNenhum telefone precisava de limpeza.")

if __name__ == '__main__':
    run_cleanup()
