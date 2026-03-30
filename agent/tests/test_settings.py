"""Tests légers sur le chargement des settings (Phase E)."""

import pytest
from pydantic import ValidationError

from settings import Settings, get_settings


@pytest.fixture(autouse=True)
def _clear_settings_cache() -> None:
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


def _minimal_llm_env(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("LLM_API_KEY", "test-key")
    monkeypatch.setenv("LLM_BASE_URL", "http://litellm/v1")
    monkeypatch.setenv("QDRANT_URL", "http://qdrant:6333")


def test_missing_llm_key_raises(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("MISTRAL_API_KEY", raising=False)
    monkeypatch.delenv("LLM_API_KEY", raising=False)
    monkeypatch.setenv("LLM_BASE_URL", "http://litellm/v1")
    monkeypatch.setenv("QDRANT_URL", "http://localhost:6333")
    with pytest.raises(ValidationError) as exc:
        Settings(_env_file=None)
    err = str(exc.value).lower()
    assert "llm_api_key" in err or "field required" in err


def test_missing_llm_base_url_raises(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("LLM_API_KEY", "k")
    monkeypatch.delenv("LLM_BASE_URL", raising=False)
    monkeypatch.setenv("QDRANT_URL", "http://q:6333")
    with pytest.raises(ValidationError) as exc:
        Settings(_env_file=None)
    assert "llm_base_url" in str(exc.value).lower()


def test_missing_qdrant_url_raises(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("LLM_API_KEY", "test-key")
    monkeypatch.setenv("LLM_BASE_URL", "http://litellm/v1")
    monkeypatch.delenv("QDRANT_URL", raising=False)
    monkeypatch.delenv("MISTRAL_API_KEY", raising=False)
    with pytest.raises(ValidationError) as exc:
        Settings(_env_file=None)
    assert "qdrant_url" in str(exc.value).lower()


def test_legacy_prefixed_env_alias(monkeypatch: pytest.MonkeyPatch) -> None:
    """MISTRAL_API_KEY reste accepté comme alias de LLM_API_KEY."""
    monkeypatch.setenv("MISTRAL_API_KEY", "sk-from-legacy-alias")
    monkeypatch.delenv("LLM_API_KEY", raising=False)
    monkeypatch.setenv("LLM_BASE_URL", "http://litellm/v1")
    monkeypatch.setenv("QDRANT_URL", "http://qdrant:6333")
    s = Settings(_env_file=None)
    assert s.llm_api_key == "sk-from-legacy-alias"


def test_get_settings_returns_cached_instance(monkeypatch: pytest.MonkeyPatch) -> None:
    _minimal_llm_env(monkeypatch)
    assert get_settings() is get_settings()
