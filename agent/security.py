"""Module de sécurité pour l'API FastAPI."""

from fastapi import Header, HTTPException, Security
from fastapi.security import APIKeyHeader
from functools import lru_cache

from config import get_settings

# Header attendu pour l'API KEY
API_KEY_HEADER = "X-API-Key"

api_key_header = APIKeyHeader(name=API_KEY_HEADER, auto_error=False)


@lru_cache()
def get_api_key() -> str | None:
    """Retourne l'API KEY configurée."""
    settings = get_settings()
    return settings.api_key


async def verify_api_key(api_key: str | None = Security(api_key_header)) -> bool:
    """
    Vérifie que l'API KEY fournie est valide.
    
    Args:
        api_key: API KEY fournie dans le header X-API-Key
        
    Returns:
        True si l'API KEY est valide
        
    Raises:
        HTTPException: Si l'API KEY est invalide ou manquante
    """
    expected_key = get_api_key()
    
    # Si aucune API KEY n'est configurée, désactiver la sécurité (rétrocompatibilité)
    if expected_key is None:
        return True
    
    # Si une API KEY est configurée mais non fournie
    if api_key is None:
        raise HTTPException(
            status_code=401,
            detail="API KEY manquante. Fournissez-la dans le header X-API-Key"
        )
    
    # Vérifier que l'API KEY correspond
    if api_key != expected_key:
        raise HTTPException(
            status_code=403,
            detail="API KEY invalide"
        )
    
    return True
