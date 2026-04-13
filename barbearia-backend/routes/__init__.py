from .clientes import clientes_bp
from .servicos import servicos_bp
from .agendamentos import agendamentos_bp
from .auth import auth_bp
from .public import public_bp
from .configuracao import config_bp
from .despesas import despesas_bp

def register_blueprints(app):
    """Registra todos os Blueprints no app Flask."""
    app.register_blueprint(auth_bp)
    app.register_blueprint(clientes_bp)
    app.register_blueprint(servicos_bp)
    app.register_blueprint(agendamentos_bp)
    app.register_blueprint(public_bp)
    app.register_blueprint(config_bp)
    app.register_blueprint(despesas_bp)
