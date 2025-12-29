"""Module de gestion de la mémoire des conversations."""

import uuid
from datetime import datetime, timedelta
from typing import Optional
from langchain_core.messages import HumanMessage, AIMessage, BaseMessage


# Stockage en mémoire des sessions (en production, utiliser Redis)
_sessions: dict[str, dict] = {}

# Durée de vie d'une session (1 heure)
SESSION_TTL = timedelta(hours=1)


def create_session() -> str:
    """Crée une nouvelle session et retourne son ID."""
    session_id = str(uuid.uuid4())
    _sessions[session_id] = {
        "created_at": datetime.now(),
        "last_activity": datetime.now(),
        "messages": [],
    }
    return session_id


def get_session(session_id: str) -> Optional[dict]:
    """Récupère une session par son ID."""
    session = _sessions.get(session_id)
    
    if session is None:
        return None
    
    # Vérifie si la session a expiré
    if datetime.now() - session["last_activity"] > SESSION_TTL:
        del _sessions[session_id]
        return None
    
    return session


def get_or_create_session(session_id: Optional[str] = None) -> tuple[str, dict]:
    """Récupère une session existante ou en crée une nouvelle."""
    if session_id:
        session = get_session(session_id)
        if session:
            session["last_activity"] = datetime.now()
            return session_id, session
    
    # Crée une nouvelle session
    new_id = create_session()
    return new_id, _sessions[new_id]


def add_message(session_id: str, role: str, content: str) -> None:
    """Ajoute un message à l'historique de la session."""
    session = get_session(session_id)
    if session:
        session["messages"].append({
            "role": role,
            "content": content,
            "timestamp": datetime.now().isoformat(),
        })
        session["last_activity"] = datetime.now()


def get_chat_history(session_id: str) -> list[BaseMessage]:
    """Retourne l'historique de chat au format LangChain."""
    session = get_session(session_id)
    if not session:
        return []
    
    messages = []
    for msg in session["messages"]:
        if msg["role"] == "user":
            messages.append(HumanMessage(content=msg["content"]))
        elif msg["role"] == "assistant":
            messages.append(AIMessage(content=msg["content"]))
    
    return messages


def clear_session(session_id: str) -> bool:
    """Supprime une session."""
    if session_id in _sessions:
        del _sessions[session_id]
        return True
    return False


def cleanup_expired_sessions() -> int:
    """Nettoie les sessions expirées. Retourne le nombre de sessions supprimées."""
    now = datetime.now()
    expired = [
        sid for sid, session in _sessions.items()
        if now - session["last_activity"] > SESSION_TTL
    ]
    
    for sid in expired:
        del _sessions[sid]
    
    return len(expired)
