"""
Configuration unique de l'agent (Phase A — contrat env Railway / k8s).

Variables : mêmes noms partout ; seules les valeurs changent selon l'environnement.
"""

from functools import lru_cache
from pathlib import Path

from pydantic import AliasChoices, Field
from pydantic_settings import BaseSettings, SettingsConfigDict


def _resolved_env_file() -> str | None:
    """Uniquement ``.env.local`` à la racine du dépôt (dev local).

    Le fichier ``.env`` n'est **jamais** lu par l'application : il sert de mémoire /
    gabarit pour recopier les valeurs à la main vers Railway, k8s, etc.
    En prod, les variables viennent de l'orchestrateur (variables Railway, ConfigMap/Secrets).
    """
    repo_root = Path(__file__).resolve().parent.parent
    env_local = repo_root / ".env.local"
    if env_local.exists():
        return str(env_local)
    return None


class Settings(BaseSettings):
    """
    Tous les réglages viennent des variables d'environnement du processus, et en dev
    optionnellement du fichier **``.env.local``** à la racine du dépôt (jamais ``.env``).
    """

    model_config = SettingsConfigDict(
        env_file=_resolved_env_file(),
        env_file_encoding="utf-8",
        extra="ignore",
        env_ignore_empty=True,
    )

    # --- LLM (toujours via API compatible OpenAI → LiteLLM) ---
    llm_api_key: str = Field(
        ...,
        validation_alias=AliasChoices("LLM_API_KEY", "MISTRAL_API_KEY"),
        description=(
            "Clé Bearer pour l’URL LLM : avec LiteLLM en proxy, en général la Virtual Key "
            "(préfixe sk-). MISTRAL_API_KEY est un alias ; ne pas dupliquer les deux avec des valeurs différentes."
        ),
    )
    llm_base_url: str = Field(
        ...,
        validation_alias=AliasChoices("LLM_BASE_URL"),
        description=(
            "Préfixe OpenAI jusqu’à /v1 (ex. https://llm.code-advisors.site/v1). "
            "Le client ajoute /chat/completions, /embeddings, etc. "
            "Auth : même clé que LLM_API_KEY en Bearer."
        ),
    )
    llm_model: str = Field(
        default="mistral/mistral-small-latest",
        validation_alias=AliasChoices("LLM_MODEL", "MISTRAL_MODEL"),
        description="Modèle LiteLLM au format provider/model.",
    )
    llm_temperature: float = Field(default=0.7, ge=0.0, le=2.0)
    llm_max_tokens: int = Field(default=1024, ge=1, le=128_000)

    # --- Embeddings (même base URL / clé que le chat, via LiteLLM) ---
    embedding_model: str = Field(
        default="mistral/mistral-embed",
        validation_alias=AliasChoices("EMBEDDING_MODEL", "MISTRAL_EMBEDDING_MODEL"),
        description=(
            "Modèle d'embeddings LiteLLM (provider/model). mistral/mistral-embed ⇒ 1024 dims "
            "(voir rag.vectorstore.EMBEDDING_DIMENSION). Changer de modèle ⇒ recréer la collection Qdrant et ré-ingérer."
        ),
    )

    # --- Qdrant ---
    qdrant_url: str = Field(
        ...,
        description="URL du cluster (Cloud ou in-cluster http://qdrant...svc:6333).",
    )
    qdrant_api_key: str = ""
    qdrant_collection_name: str = "casa_del_sabor"

    # --- Serveur agent ---
    agent_host: str = "0.0.0.0"
    agent_port: int = 8000
    api_key: str | None = Field(
        default=None,
        validation_alias=AliasChoices("API_KEY"),
        description="Protège /ingest, /upload, /status.",
    )

    # --- RAG ---
    chunk_size: int = 500
    chunk_overlap: int = 50
    top_k_results: int = 4

    # --- Debug (réponses d’erreur /chat plus verbeuses — désactivé en prod) ---
    agent_debug: bool = Field(
        default=False,
        validation_alias=AliasChoices("AGENT_DEBUG"),
        description="Si True, le détail d’exception est renvoyé dans les erreurs HTTP /chat (dev uniquement).",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()
