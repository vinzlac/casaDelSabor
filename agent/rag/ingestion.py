"""Module d'ingestion des documents pour le RAG."""

import os
from pathlib import Path
from typing import List

from langchain_core.documents import Document
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.document_loaders import DirectoryLoader, TextLoader

from config import get_settings
from .vectorstore import get_vectorstore, init_vectorstore, delete_collection


# Chemin vers le dossier des documents
DOCUMENTS_DIR = Path(__file__).parent.parent / "documents"


def load_documents() -> List[Document]:
    """
    Charge tous les documents markdown du dossier documents/.
    
    Returns:
        Liste des documents chargés.
    """
    if not DOCUMENTS_DIR.exists():
        raise FileNotFoundError(f"Le dossier {DOCUMENTS_DIR} n'existe pas.")
    
    # Charge tous les fichiers .md
    loader = DirectoryLoader(
        str(DOCUMENTS_DIR),
        glob="**/*.md",
        loader_cls=TextLoader,
        loader_kwargs={"encoding": "utf-8"},
    )
    
    documents = loader.load()
    
    # Ajoute des métadonnées utiles
    for doc in documents:
        # Extrait le nom du fichier comme source
        filename = Path(doc.metadata.get("source", "")).stem
        doc.metadata["category"] = filename
        doc.metadata["restaurant"] = "Casa del Sabor"
    
    return documents


def split_documents(documents: List[Document]) -> List[Document]:
    """
    Découpe les documents en chunks pour l'indexation.
    
    Args:
        documents: Liste des documents à découper.
        
    Returns:
        Liste des chunks.
    """
    settings = get_settings()
    
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=settings.chunk_size,
        chunk_overlap=settings.chunk_overlap,
        length_function=len,
        separators=["\n## ", "\n### ", "\n\n", "\n", " ", ""],
    )
    
    chunks = splitter.split_documents(documents)
    
    return chunks


def ingest_documents(force_reindex: bool = False) -> dict:
    """
    Ingère les documents dans le vector store.
    
    Args:
        force_reindex: Si True, supprime la collection existante et réindexe.
        
    Returns:
        Dictionnaire avec les statistiques d'ingestion.
    """
    # Supprime la collection si force_reindex
    if force_reindex:
        delete_collection()
    
    # Initialise la collection si nécessaire
    collection_created = init_vectorstore()
    
    # Charge les documents
    documents = load_documents()
    
    # Découpe en chunks
    chunks = split_documents(documents)
    
    # Indexe dans Qdrant
    vectorstore = get_vectorstore()
    vectorstore.add_documents(chunks)
    
    return {
        "success": True,
        "collection_created": collection_created,
        "documents_loaded": len(documents),
        "chunks_indexed": len(chunks),
        "force_reindex": force_reindex,
    }


def get_ingestion_status() -> dict:
    """Retourne le statut de l'ingestion."""
    from .vectorstore import get_collection_info
    
    documents_exist = DOCUMENTS_DIR.exists() and any(DOCUMENTS_DIR.glob("*.md"))
    
    return {
        "documents_directory": str(DOCUMENTS_DIR),
        "documents_exist": documents_exist,
        "collection_info": get_collection_info(),
    }
