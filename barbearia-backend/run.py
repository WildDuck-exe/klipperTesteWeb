#!/usr/bin/env python3
# run.py - Script para iniciar a aplicação Flask

import os
import sys

# Adiciona o diretório atual ao path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app

if __name__ == '__main__':
    print("=" * 50)
    print("Barbearia API - Agenda Digital para Barbearia")
    print("=" * 50)
    print(f"URL: http://localhost:5000")
    print(f"Endpoints disponíveis:")
    print(f"  GET  /                    - Status da API")
    print(f"  GET  /api/                - Informações da API")
    print(f"  GET  /api/clientes        - Listar clientes")
    print(f"  POST /api/clientes        - Criar cliente")
    print(f"  GET  /api/clientes/<id>   - Obter cliente")
    print(f"  GET  /api/servicos        - Listar serviços")
    print(f"  POST /api/servicos        - Criar serviço")
    print(f"  GET  /api/agendamentos    - Listar agendamentos")
    print(f"  POST /api/agendamentos    - Criar agendamento")
    print(f"  PUT  /api/agendamentos/<id>/concluir - Concluir agendamento")
    print(f"  PUT  /api/agendamentos/<id>/cancelar - Cancelar agendamento")
    print(f"  GET  /api/agenda/hoje     - Agenda do dia")
    print("=" * 50)
    print("Iniciando servidor...")

    app.run(debug=True, port=5000)