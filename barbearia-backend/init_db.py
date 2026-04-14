#!/usr/bin/env python3
# init_db.py
# Script de inicialização do banco de dados SQLAlchemy para a Ponto do Corte

import os
import sys
from datetime import datetime, timedelta
from werkzeug.security import generate_password_hash

# Adiciona o diretório atual ao path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app
from models import db, Cliente, Servico, Agendamento, Usuario, PushToken, Configuracao, Despesa

def init_database():
    """Inicializa o banco de dados e cria todas as tabelas."""
    print("Inicializando banco de dados Ponto do Corte...")

    with app.app_context():
        # Cria o diretório database se não existir
        database_dir = os.path.dirname(app.config['DATABASE_PATH'])
        if not os.path.exists(database_dir):
            os.makedirs(database_dir)
            print(f"Diretorio criado: {database_dir}")

        # Cria todas as tabelas
        db.create_all()
        print(f"Banco de dados criado em: {app.config['DATABASE_PATH']}")
        print("Tabelas sincronizadas: clientes, servicos, agendamentos, usuarios, push_tokens, configuracoes, despesas")

        # Verifica se já existem dados
        if Cliente.query.first() is None:
            print("Adicionando dados de exemplo...")
            add_sample_data()
            print("Dados iniciais adicionados com sucesso!")
        else:
            # Garante que as configurações padrão existam mesmo que já existam outros dados
            add_default_config()
            print("Banco de dados já configurado.")

    print("Inicialização concluída!")

def add_default_config():
    """Adiciona configurações padrões se não existirem."""
    configs = [
        ('horario_inicio', '08:00', 'Horário de abertura da barbearia'),
        ('horario_fim', '18:00', 'Horário de fechamento da barbearia'),
        ('dias_trabalho', '1,2,3,4,5,6', 'Dias da semana de expediente (0=Dom, 1=Seg...)'),
        ('pausa_inicio', '12:00', 'Horário de início do almoço/pausa'),
        ('pausa_fim', '13:00', 'Horário de término do almoço/pausa'),
        ('whatsapp_mensagem', 'Olá {nome}, tudo bem? Sou da barbearia Ponto do Corte. Confirmando seu agendamento de {servico} para {data_hora}. Podemos confirmar?', 'Mensagem Recepção'),
        ('whatsapp_mensagem_pausa', 'Olá, estamos em horário de almoço no momento. Retornaremos em breve!', 'Mensagem Pausa'),
        ('whatsapp_mensagem_fechado', 'Olá, a barbearia encontra-se fechada no momento. Nosso horário de atendimento é...', 'Mensagem Fechado'),
        ('whatsapp_mensagem_cancelamento', 'Olá {nome}, infelizmente precisaremos desmarcar ou remarcar seu horário de {servico} para {data_hora}. Gostaria de escolher um novo horário?', 'Mensagem Cancelamento')
    ]
    
    for chave, valor, desc in configs:
        if not Configuracao.query.filter_by(chave=chave).first():
            config = Configuracao(chave=chave, valor=valor, descricao=desc)
            db.session.add(config)
    
    db.session.commit()

def add_sample_data():
    """Adiciona dados de exemplo para testes."""
    
    admin = Usuario(
        username="admin", 
        email="admin@klipper.com",
        senha_hash=generate_password_hash("123456")
    )
    db.session.add(admin)

    # 2. Clientes
    clientes = [
        Cliente(nome="Joao Silva", telefone="(11) 99999-9999"),
        Cliente(nome="Maria Santos", telefone="(11) 98888-8888"),
        Cliente(nome="Pedro Oliveira", telefone="(11) 97777-7777")
    ]
    for c in clientes: db.session.add(c)

    # 3. Serviços
    servicos = [
        Servico(nome='Corte Masculino', preco=35.0, duracao_minutos=30, categoria='Cabelo'),
        Servico(nome='Barba Completa', preco=25.0, duracao_minutos=20, categoria='Barba'),
        Servico(nome='Corte + Barba', preco=50.0, duracao_minutos=50, categoria='Combo'),
        Servico(nome='Sombrancelha', preco=15.0, duracao_minutos=15, categoria='Estética')
    ]
    for s in servicos: db.session.add(s)

    # 4. Configurações
    add_default_config()

    # 5. Despesas de Exemplo
    despesas = [
        Despesa(descricao="Aluguel", valor=1200.00, categoria="Fixa"),
        Despesa(descricao="Energia", valor=250.00, categoria="Geral"),
        Despesa(descricao="Pomada Modeladora", valor=80.00, categoria="Produtos")
    ]
    for d in despesas: db.session.add(d)

    db.session.commit()

    # 6. Agendamentos
    hoje = datetime.now().replace(minute=0, second=0, microsecond=0)
    
    agendamentos = [
        Agendamento(cliente_id=1, servico_id=1, data_hora=hoje + timedelta(hours=2)),
        Agendamento(cliente_id=2, servico_id=3, data_hora=hoje + timedelta(hours=4), observacoes="Primeira vez"),
        Agendamento(cliente_id=3, servico_id=2, data_hora=hoje + timedelta(days=1, hours=10))
    ]
    for a in agendamentos: db.session.add(a)
    
    db.session.commit()

if __name__ == '__main__':
    init_database()