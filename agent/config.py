"""Configuration de l'agent RAG."""

import os
from pathlib import Path
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Configuration de l'application via variables d'environnement."""
    
    # Mistral AI
    mistral_api_key: str
    mistral_model: str = "mistral-small-latest"
    mistral_embedding_model: str = "mistral-embed"
    
    # Qdrant
    qdrant_url: str
    qdrant_api_key: str = ""  # Optionnel (vide pour Qdrant local)
    qdrant_collection_name: str = "casa_del_sabor"
    
    # Agent
    agent_host: str = "0.0.0.0"
    agent_port: int = 8000
    
    # API Security
    api_key: str | None = None  # API KEY pour sécuriser les endpoints admin
    
    # RAG Configuration
    chunk_size: int = 500
    chunk_overlap: int = 50
    top_k_results: int = 4
    
    class Config:
        # Charge .env.local en priorité si il existe, sinon .env
        # Note: pydantic-settings charge les fichiers dans l'ordre, mais les variables d'environnement
        # système ont toujours la priorité. En chargeant uniquement .env.local s'il existe,
        # on évite que .env écrase les valeurs de .env.local.
        # Si .env.local existe, on ne charge que celui-ci. Sinon, on charge .env.
        _agent_dir = Path(__file__).parent
        _env_local = _agent_dir / ".env.local"
        env_file = str(_env_local) if _env_local.exists() else ".env"
        env_file_encoding = "utf-8"


@lru_cache()
def get_settings() -> Settings:
    """Retourne l'instance singleton des settings."""
    return Settings()
