"""Application FastAPI pour l'agent RAG Casa del Sabor."""

import logging
from contextlib import asynccontextmanager
from pathlib import Path
import shutil

from openai import BadRequestError
from fastapi import Depends, FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from config import get_settings
from rag import ingest_documents, ask_question, get_vectorstore
from rag.chain import KnowledgeBaseUnavailableError
from rag.ingestion import get_ingestion_status
from rag.vectorstore import get_collection_info
from security import verify_api_key

logger = logging.getLogger(__name__)


def _friendly_chat_error_detail(exc: Exception) -> str:
    """Retourne un message utilisateur lisible pour les erreurs de chat attendues."""
    raw = str(exc)
    lowered = raw.lower()

    if "no healthy deployments for this model" in lowered:
        settings = get_settings()
        return (
            "Le modèle LLM configuré n'est pas disponible sur le proxy LiteLLM. "
            f"Vérifiez `LLM_MODEL` (actuel: `{settings.llm_model}`) avec `GET /v1/models`, "
            "puis redémarrez l'agent."
        )

    if "authentication" in lowered or "api key" in lowered:
        return (
            "Erreur d'authentification vers le proxy LiteLLM. "
            "Vérifiez `LLM_API_KEY` (Virtual Key `sk-...`) et `LLM_BASE_URL`."
        )

    return "Désolé, une erreur s'est produite. Veuillez réessayer."


# Modèles Pydantic pour les requêtes/réponses
class ChatRequest(BaseModel):
    """Requête de chat."""
    message: str = Field(
        description="Message de l'utilisateur à envoyer au chatbot",
        example="Quels sont vos horaires d'ouverture ?"
    )
    session_id: str | None = Field(
        default=None,
        description="ID de session pour maintenir l'historique de conversation. Si None, une nouvelle session est créée.",
        example="session-abc-123-xyz"
    )


class ChatResponse(BaseModel):
    """Réponse de chat."""
    response: str
    sources: list[str] = []
    session_id: str | None = None


class IngestRequest(BaseModel):
    """Requête d'ingestion."""
    force_reindex: bool = Field(
        default=False,
        description="Si True, supprime et recrée la collection (réindexation complète). Si False, ajoute seulement les nouveaux documents."
    )


class IngestResponse(BaseModel):
    """Réponse d'ingestion."""
    success: bool
    collection_created: bool
    documents_loaded: int
    chunks_indexed: int
    force_reindex: bool


class HealthResponse(BaseModel):
    """Réponse de health check."""
    status: str
    service: str
    version: str


class StatusResponse(BaseModel):
    """Réponse de statut détaillé."""
    documents_directory: str
    documents_exist: bool
    collection_info: dict


class UploadResponse(BaseModel):
    """Réponse d'upload."""
    success: bool
    filename: str
    message: str


# Chemin vers le dossier des documents
DOCUMENTS_DIR = Path(__file__).parent / "documents"


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Gestion du cycle de vie de l'application."""
    # Startup
    print("🚀 Démarrage de l'agent Casa del Sabor...")
    yield
    # Shutdown
    print("👋 Arrêt de l'agent...")


# Création de l'application
app = FastAPI(
    title="Casa del Sabor - Agent RAG",
    description="Agent conversationnel RAG pour le restaurant Casa del Sabor",
    version="1.0.0",
    lifespan=lifespan,
)

# Configuration CORS pour permettre les appels depuis l'UI Next.js
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En production, spécifier les domaines autorisés
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Endpoint de health check."""
    return HealthResponse(
        status="healthy",
        service="casa-del-sabor-agent",
        version="1.0.0",
    )


@app.get("/status", response_model=StatusResponse, dependencies=[Depends(verify_api_key)])
async def get_status():
    """Retourne le statut détaillé de l'agent."""
    status = get_ingestion_status()
    return StatusResponse(**status)


@app.post("/ingest", response_model=IngestResponse, dependencies=[Depends(verify_api_key)])
async def ingest(request: IngestRequest = IngestRequest()):
    """
    Indexe ou réindexe les documents dans le vector store.
    
    ## Modes d'utilisation
    
    **Indexation normale** (`force_reindex: false`, défaut):
    - Ajoute les nouveaux documents à la collection existante
    - Conserve les documents déjà indexés
    - Plus rapide
    
    **Réindexation complète** (`force_reindex: true`):
    - Supprime la collection existante
    - Recrée la collection à partir de zéro
    - Indexe tous les documents du dossier `documents/`
    - Utile après avoir ajouté/modifié des documents
    
    Args:
        request: Configuration avec `force_reindex` (bool, défaut: false)
        
    Returns:
        Statistiques d'ingestion (nombre de documents, chunks, etc.)
    """
    try:
        result = ingest_documents(force_reindex=request.force_reindex)
        return IngestResponse(**result)
    except FileNotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur d'ingestion: {str(e)}")


@app.post("/upload", response_model=UploadResponse, dependencies=[Depends(verify_api_key)])
async def upload_document(file: UploadFile = File(...)):
    """
    Upload un nouveau document markdown pour l'indexation.
    
    Args:
        file: Fichier markdown à uploader
        
    Returns:
        Confirmation de l'upload
    """
    # Vérifier que c'est un fichier .md
    if not file.filename or not file.filename.endswith('.md'):
        raise HTTPException(
            status_code=400,
            detail="Seuls les fichiers .md sont acceptés"
        )
    
    # S'assurer que le dossier documents existe
    DOCUMENTS_DIR.mkdir(exist_ok=True)
    
    # Sauvegarder le fichier
    file_path = DOCUMENTS_DIR / file.filename
    
    try:
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        return UploadResponse(
            success=True,
            filename=file.filename,
            message=f"Fichier {file.filename} uploadé avec succès. Appelez /ingest pour l'indexer."
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Erreur lors de l'upload: {str(e)}"
        )


@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Endpoint principal de chat.
    
    Reçoit un message, interroge le RAG et retourne la réponse.
    Passe un session_id pour maintenir l'historique de conversation.
    
    Args:
        request: Message de l'utilisateur avec session_id optionnel.
        
    Returns:
        Réponse générée par le RAG avec le session_id à réutiliser.
    """
    if not request.message or not request.message.strip():
        raise HTTPException(status_code=400, detail="Le message ne peut pas être vide.")
    
    try:
        result = await ask_question(
            question=request.message.strip(),
            session_id=request.session_id,
        )
        return ChatResponse(
            response=result["response"],
            sources=result.get("sources", []),
            session_id=result.get("session_id"),
        )
    except KnowledgeBaseUnavailableError:
        # Cas métier attendu: ingestion non faite / collection absente.
        return ChatResponse(
            response=(
                "Je ne peux pas encore répondre à cette question car je n'ai pas tous les "
                "éléments de connaissance à ma disposition. "
                "Merci de lancer l'ingestion des documents puis de réessayer."
            ),
            sources=[],
            session_id=request.session_id,
        )
    except BadRequestError as e:
        settings = get_settings()
        if settings.agent_debug:
            logger.exception("Erreur chat (BadRequestError)")
            detail = f"{type(e).__name__}: {e}"
        else:
            # Cas attendu (modèle indisponible, payload invalide), log concis sans stacktrace.
            logger.warning("Erreur chat (BadRequestError): %s", e)
            detail = _friendly_chat_error_detail(e)
        raise HTTPException(status_code=400, detail=detail)
    except Exception as e:
        settings = get_settings()
        if settings.agent_debug:
            logger.exception("Erreur chat")
            detail = f"{type(e).__name__}: {e}"
        else:
            logger.error("Erreur chat: %s", e)
            detail = _friendly_chat_error_detail(e)
        raise HTTPException(status_code=500, detail=detail)


# Point d'entrée pour uvicorn
if __name__ == "__main__":
    import uvicorn
    
    settings = get_settings()
    uvicorn.run(
        "main:app",
        host=settings.agent_host,
        port=settings.agent_port,
        reload=True,
    )
