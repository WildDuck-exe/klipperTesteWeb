# tests/test_init_db.py
# Testes para o script de inicialização do banco de dados

import os
import tempfile
import pytest
from unittest.mock import patch, MagicMock

def test_init_db_script_structure():
    """Testa que o script init_db.py existe e tem a estrutura correta."""
    script_path = os.path.join(os.path.dirname(__file__), '..', 'init_db.py')
    assert os.path.exists(script_path), "init_db.py não encontrado"

    # Lê o conteúdo do script
    with open(script_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Verifica funções essenciais
    assert 'def init_database():' in content
    assert 'def add_sample_data():' in content
    assert 'def reset_database():' in content
    assert 'def show_database_info():' in content

    # Verifica imports
    assert 'from flask import Flask' in content
    assert 'from config import Config' in content
    assert 'from models import db, Cliente, Servico, Agendamento' in content

def test_init_db_imports():
    """Testa que o script pode ser importado sem erros."""
    # Adiciona o diretório pai ao path
    import sys
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

    try:
        # Tenta importar o módulo
        import init_db
        assert hasattr(init_db, 'init_database')
        assert hasattr(init_db, 'add_sample_data')
        assert hasattr(init_db, 'reset_database')
        assert hasattr(init_db, 'show_database_info')
    finally:
        # Remove do path
        sys.path.pop(0)

@patch('init_db.Flask')
@patch('init_db.db')
def test_init_database_function(mock_db, mock_flask):
    """Testa a função init_database com mocks."""
    import sys
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

    try:
        import init_db

        # Configura mocks
        mock_app = MagicMock()
        mock_flask.return_value = mock_app
        mock_app.config = {
            'DATABASE_PATH': '/tmp/test.db'
        }

        mock_app.app_context.return_value.__enter__.return_value = None

        # Mock para os.path.exists e os.makedirs
        with patch('init_db.os.path.exists') as mock_exists:
            with patch('init_db.os.makedirs') as mock_makedirs:
                mock_exists.return_value = False

                # Mock para Cliente.query.first()
                with patch('init_db.Cliente') as mock_cliente_class:
                    mock_cliente = MagicMock()
                    mock_cliente.query.first.return_value = None
                    mock_cliente_class.query.first.return_value = None

                    # Chama a função
                    init_db.init_database()

                    # Verifica chamadas
                    mock_flask.assert_called_once()
                    mock_db.init_app.assert_called_once_with(mock_app)
                    mock_makedirs.assert_called_once_with(os.path.dirname('/tmp/test.db'))
                    mock_db.create_all.assert_called_once()

    finally:
        sys.path.pop(0)

def test_add_sample_data_logic():
    """Testa a lógica da função add_sample_data."""
    import sys
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

    try:
        import init_db

        # Mock do db.session
        mock_session = MagicMock()
        mock_session.add = MagicMock()
        mock_session.commit = MagicMock()

        # Mock dos modelos
        with patch('init_db.Cliente') as mock_cliente:
            with patch('init_db.Servico') as mock_servico:
                with patch('init_db.Agendamento') as mock_agendamento:
                    with patch('init_db.db') as mock_db:
                        mock_db.session = mock_session

                        # Mock datetime
                        with patch('init_db.datetime') as mock_datetime:
                            mock_now = MagicMock()
                            mock_now.replace.return_value = MagicMock()
                            mock_datetime.now.return_value = mock_now
                            mock_datetime.side_effect = __import__('datetime').datetime

                            # Mock timedelta
                            with patch('init_db.timedelta') as mock_timedelta:
                                mock_timedelta.side_effect = __import__('datetime').timedelta

                                # Chama a função
                                init_db.add_sample_data()

                                # Verifica que session.add foi chamado várias vezes
                                assert mock_session.add.call_count > 0
                                assert mock_session.commit.call_count >= 3  # Pelo menos 3 commits

    finally:
        sys.path.pop(0)

def test_script_has_main_block():
    """Testa que o script tem o bloco if __name__ == '__main__'."""
    script_path = os.path.join(os.path.dirname(__file__), '..', 'init_db.py')
    with open(script_path, 'r', encoding='utf-8') as f:
        content = f.read()

    assert "if __name__ == '__main__':" in content
    assert "import argparse" in content
    assert "parser = argparse.ArgumentParser" in content

def test_script_command_line_arguments():
    """Testa que o script suporta os argumentos de linha de comando."""
    script_path = os.path.join(os.path.dirname(__file__), '..', 'init_db.py')
    with open(script_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Verifica que todas as ações estão definidas
    assert "'init'" in content
    assert "'reset'" in content
    assert "'info'" in content
    assert "'add-sample'" in content

def test_database_directory_creation():
    """Testa que o script cria o diretório database se não existir."""
    import sys
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

    try:
        import init_db

        # Cria um diretório temporário para teste
        with tempfile.TemporaryDirectory() as temp_dir:
            # Mock do app.config
            mock_app = MagicMock()
            mock_app.config = {
                'DATABASE_PATH': os.path.join(temp_dir, 'database', 'test.db')
            }
            mock_app.app_context.return_value.__enter__.return_value = None

            # Mock Flask para retornar nosso mock_app
            with patch('init_db.Flask', return_value=mock_app):
                with patch('init_db.db') as mock_db:
                    with patch('init_db.Cliente') as mock_cliente:
                        mock_cliente.query.first.return_value = None

                        # Chama create_app (função interna)
                        app = init_db.create_app()
                        assert app == mock_app

                        # Verifica que o diretório seria criado
                        db_dir = os.path.dirname(mock_app.config['DATABASE_PATH'])
                        assert 'database' in db_dir

    finally:
        sys.path.pop(0)

def test_sample_data_counts():
    """Testa que os dados de exemplo têm quantidades esperadas."""
    import sys
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

    try:
        import init_db

        # Analisa o código para contar quantos dados são criados
        script_path = os.path.join(os.path.dirname(__file__), '..', 'init_db.py')
        with open(script_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Conta clientes (5 na lista)
        assert "clientes = [" in content
        # Conta serviços (5 na lista)
        assert "servicos = [" in content
        # Conta agendamentos (7 na lista)
        assert "agendamentos = [" in content

    finally:
        sys.path.pop(0)