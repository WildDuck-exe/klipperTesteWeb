# config.py - Configurações da aplicação Barbearia API

import os

class Config:
    """Configurações base da aplicação."""
    # Configurações gerais
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-barbearia-2026'
    DEBUG = True  # Em produção deve ser False

    # Configurações de banco de dados
    DATABASE_PATH = os.path.join(os.path.dirname(__file__), 'database', 'barbearia.db')
    SQLALCHEMY_DATABASE_URI = f'sqlite:///{DATABASE_PATH}'
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Configurações de CORS
    CORS_ORIGINS = "*"  # Em produção, especificar origens permitidas
    CORS_RESOURCES = {r"/api/*": {"origins": "*"}}

    # Configurações da API
    API_PREFIX = '/api'
    API_VERSION = '1.0.0'

    # Configurações de logging
    LOG_LEVEL = 'INFO'
    LOG_FORMAT = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'

class DevelopmentConfig(Config):
    """Configurações para ambiente de desenvolvimento."""
    DEBUG = True
    LOG_LEVEL = 'DEBUG'

class ProductionConfig(Config):
    """Configurações para ambiente de produção."""
    DEBUG = False
    SECRET_KEY = os.environ.get('SECRET_KEY')
    CORS_ORIGINS = os.environ.get('CORS_ORIGINS', '').split(',')
    LOG_LEVEL = 'WARNING'

# Configuração atual baseada em ambiente
config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}