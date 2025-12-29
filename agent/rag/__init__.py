"""Module RAG pour Casa del Sabor."""

from .embeddings import get_embeddings
from .vectorstore import get_vectorstore, init_vectorstore
from .ingestion import ingest_documents
from .chain import get_rag_chain, ask_question
from .tools import TOOLS, reserver_table, consulter_disponibilites
from .memory import get_or_create_session, add_message, get_chat_history, clear_session

__all__ = [
    "get_embeddings",
    "get_vectorstore",
    "init_vectorstore",
    "ingest_documents",
    "get_rag_chain",
    "ask_question",
    "TOOLS",
    "reserver_table",
    "consulter_disponibilites",
    "get_or_create_session",
    "add_message",
    "get_chat_history",
    "clear_session",
]
