"""Embeddings via API OpenAI-compatible (LiteLLM)."""

from functools import lru_cache

from langchain_core.embeddings import Embeddings
from langchain_openai import OpenAIEmbeddings

from config import get_settings


@lru_cache
def get_embeddings() -> Embeddings:
    """Embeddings OpenAI-compatible ; modèles au format ``provider/model`` côté LiteLLM."""
    settings = get_settings()
    base = settings.llm_base_url.rstrip("/")
    return OpenAIEmbeddings(
        model=settings.embedding_model,
        openai_api_key=settings.llm_api_key,
        openai_api_base=base,
    )
