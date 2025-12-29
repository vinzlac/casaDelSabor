"""Module d'embeddings avec Mistral AI."""

from functools import lru_cache
from langchain_mistralai import MistralAIEmbeddings
from config import get_settings


@lru_cache()
def get_embeddings() -> MistralAIEmbeddings:
    """
    Retourne une instance singleton des embeddings Mistral.
    
    Utilise le modèle mistral-embed pour générer les vecteurs.
    """
    settings = get_settings()
    
    return MistralAIEmbeddings(
        model=settings.mistral_embedding_model,
        api_key=settings.mistral_api_key,
    )
