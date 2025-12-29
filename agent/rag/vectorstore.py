"""Module de gestion du vector store Qdrant."""

from functools import lru_cache
from qdrant_client import QdrantClient
from qdrant_client.http import models
from langchain_qdrant import QdrantVectorStore

from config import get_settings
from .embeddings import get_embeddings


# Dimension des embeddings Mistral
EMBEDDING_DIMENSION = 1024


@lru_cache()
def get_qdrant_client() -> QdrantClient:
    """Retourne une instance singleton du client Qdrant."""
    settings = get_settings()
    
    return QdrantClient(
        url=settings.qdrant_url,
        api_key=settings.qdrant_api_key,
    )


def init_vectorstore() -> bool:
    """
    Initialise la collection Qdrant si elle n'existe pas.
    
    Returns:
        True si la collection a été créée, False si elle existait déjà.
    """
    settings = get_settings()
    client = get_qdrant_client()
    
    # Vérifie si la collection existe
    collections = client.get_collections().collections
    collection_names = [c.name for c in collections]
    
    if settings.qdrant_collection_name in collection_names:
        return False
    
    # Crée la collection
    client.create_collection(
        collection_name=settings.qdrant_collection_name,
        vectors_config=models.VectorParams(
            size=EMBEDDING_DIMENSION,
            distance=models.Distance.COSINE,
        ),
    )
    
    return True


def get_vectorstore() -> QdrantVectorStore:
    """
    Retourne le vector store LangChain connecté à Qdrant.
    
    Note: Ne pas utiliser @lru_cache ici car on veut toujours
    une connexion fraîche au vector store.
    """
    settings = get_settings()
    client = get_qdrant_client()
    embeddings = get_embeddings()
    
    return QdrantVectorStore(
        client=client,
        collection_name=settings.qdrant_collection_name,
        embedding=embeddings,
    )


def delete_collection() -> bool:
    """
    Supprime la collection Qdrant (utile pour réindexer).
    
    Returns:
        True si la collection a été supprimée.
    """
    settings = get_settings()
    client = get_qdrant_client()
    
    try:
        client.delete_collection(settings.qdrant_collection_name)
        return True
    except Exception:
        return False


def get_collection_info() -> dict:
    """Retourne les informations sur la collection."""
    settings = get_settings()
    client = get_qdrant_client()
    
    try:
        info = client.get_collection(settings.qdrant_collection_name)
        return {
            "name": settings.qdrant_collection_name,
            "points_count": info.points_count,
            "status": info.status.value,
        }
    except Exception as e:
        return {
            "name": settings.qdrant_collection_name,
            "error": str(e),
        }
