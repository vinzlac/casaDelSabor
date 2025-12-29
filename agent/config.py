"""Configuration de l'agent RAG."""

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
    qdrant_api_key: str
    qdrant_collection_name: str = "casa_del_sabor"
    
    # Agent
    agent_host: str = "0.0.0.0"
    agent_port: int = 8000
    
    # RAG Configuration
    chunk_size: int = 500
    chunk_overlap: int = 50
    top_k_results: int = 4
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache()
def get_settings() -> Settings:
    """Retourne l'instance singleton des settings."""
    return Settings()
