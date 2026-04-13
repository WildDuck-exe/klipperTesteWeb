# utils/validation.py
import re

def limpar_telefone(telefone):
    """Remove todos os caracteres não numéricos do telefone."""
    if not telefone:
        return ""
    return re.sub(r'\D', '', telefone)

def validar_telefone(telefone):
    """
    Valida se o telefone tem o formato brasileiro correto:
    DD + 9 + 8 dígitos = 11 dígitos.
    Os números devem ser puramente decimais.
    """
    telefone_limpo = limpar_telefone(telefone)
    
    # Verifica se tem exatamente 11 dígitos
    if len(telefone_limpo) != 11:
        return False
        
    return True
