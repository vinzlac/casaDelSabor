"""Application FastAPI pour l'agent RAG Casa del Sabor."""

from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from config import get_settings
from rag import ingest_documents, ask_question, get_vectorstore
from rag.ingestion import get_ingestion_status
from rag.vectorstore import get_collection_info


# Modèles Pydantic pour les requêtes/réponses
class ChatRequest(BaseModel):
    """Requête de chat."""
    message: str
    session_id: str | None = None


class ChatResponse(BaseModel):
    """Réponse de chat."""
    response: str
    sources: list[str] = []
    session_id: str | None = None


class IngestRequest(BaseModel):
    """Requête d'ingestion."""
    force_reindex: bool = False


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


@app.get("/status", response_model=StatusResponse)
async def get_status():
    """Retourne le statut détaillé de l'agent."""
    status = get_ingestion_status()
    return StatusResponse(**status)


@app.post("/ingest", response_model=IngestResponse)
async def ingest(request: IngestRequest = IngestRequest()):
    """
    Ingère les documents dans le vector store.
    
    Args:
        request: Optionnel, avec force_reindex pour réindexer.
        
    Returns:
        Statistiques d'ingestion.
    """
    try:
        result = ingest_documents(force_reindex=request.force_reindex)
        return IngestResponse(**result)
    except FileNotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur d'ingestion: {str(e)}")


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
    except Exception as e:
        # Log l'erreur
        print(f"Erreur chat: {e}")
        raise HTTPException(
            status_code=500,
            detail="Désolé, une erreur s'est produite. Veuillez réessayer.",
        )


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
