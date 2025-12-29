"""Module de l'agent RAG avec outils LangChain."""

from functools import lru_cache
from typing import Optional

from langchain_mistralai import ChatMistralAI
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.output_parsers import StrOutputParser
from langchain_core.messages import HumanMessage, AIMessage

from config import get_settings
from .vectorstore import get_vectorstore
from .tools import TOOLS, reserver_table, consulter_disponibilites
from .memory import get_or_create_session, add_message, get_chat_history


# Prompt système pour l'agent du restaurant
SYSTEM_PROMPT = """Tu es l'assistant virtuel de Casa del Sabor, un restaurant mexicain authentique situé à Paris.

Tu dois répondre aux questions des clients de manière chaleureuse, professionnelle et en utilisant parfois des expressions espagnoles pour l'ambiance (comme "¡Hola!", "¡Perfecto!", "¡Buen provecho!").

## Contexte du restaurant
{context}

## Tes capacités
Tu disposes d'outils pour :
1. **Réserver une table** : Tu peux effectuer une réservation directement si le client le souhaite.
2. **Consulter les disponibilités** : Tu peux vérifier les créneaux disponibles pour une date.

## Règles importantes
- Sois concis mais chaleureux
- Utilise des emojis appropriés (🌮 🍹 📍 etc.) avec modération
- Si on te demande le menu, liste les plats avec leurs prix
- Pour les réservations, propose TOUJOURS de réserver directement via toi, en plus des autres options (téléphone, email)
- Quand un client veut réserver, demande-lui les informations manquantes de manière naturelle
- Ne invente jamais de prix, horaires ou informations non présentes dans le contexte
- Si tu ne trouves pas l'information, propose de contacter le restaurant directement
"""

HUMAN_PROMPT = """Question du client : {question}

Réponds de manière utile et chaleureuse :"""


@lru_cache()
def get_llm() -> ChatMistralAI:
    """Retourne une instance du LLM Mistral."""
    settings = get_settings()
    
    return ChatMistralAI(
        model=settings.mistral_model,
        api_key=settings.mistral_api_key,
        temperature=0.7,
        max_tokens=1024,
    )


@lru_cache()
def get_llm_with_tools() -> ChatMistralAI:
    """Retourne une instance du LLM Mistral avec les outils bindés."""
    settings = get_settings()
    
    llm = ChatMistralAI(
        model=settings.mistral_model,
        api_key=settings.mistral_api_key,
        temperature=0.7,
        max_tokens=1024,
    )
    
    return llm.bind_tools(TOOLS)


def format_docs(docs) -> str:
    """Formate les documents récupérés en une chaîne de contexte."""
    return "\n\n---\n\n".join(
        f"[Source: {doc.metadata.get('category', 'inconnu')}]\n{doc.page_content}"
        for doc in docs
    )


def get_rag_chain(with_history: bool = False):
    """
    Construit et retourne la chaîne RAG complète.
    
    Args:
        with_history: Si True, inclut un placeholder pour l'historique.
    
    Returns:
        La chaîne RAG prête à être invoquée.
    """
    llm = get_llm_with_tools()
    
    # Construit le prompt avec ou sans historique
    if with_history:
        prompt = ChatPromptTemplate.from_messages([
            ("system", SYSTEM_PROMPT),
            MessagesPlaceholder(variable_name="chat_history"),
            ("human", HUMAN_PROMPT),
        ])
    else:
        prompt = ChatPromptTemplate.from_messages([
            ("system", SYSTEM_PROMPT),
            ("human", HUMAN_PROMPT),
        ])
    
    return prompt | llm


async def execute_tool_calls(tool_calls: list) -> list[str]:
    """Exécute les appels d'outils et retourne les résultats."""
    results = []
    
    for tool_call in tool_calls:
        tool_name = tool_call.get("name")
        tool_args = tool_call.get("args", {})
        
        if tool_name == "reserver_table":
            result = reserver_table.invoke(tool_args)
            results.append(result)
        elif tool_name == "consulter_disponibilites":
            result = consulter_disponibilites.invoke(tool_args)
            results.append(result)
    
    return results


async def ask_question(question: str, session_id: Optional[str] = None) -> dict:
    """
    Pose une question à l'agent RAG et retourne la réponse.
    
    Args:
        question: La question du client.
        session_id: ID de session pour maintenir l'historique (optionnel).
        
    Returns:
        Dictionnaire avec la réponse et les métadonnées.
    """
    settings = get_settings()
    
    # Gestion de la session
    session_id, session = get_or_create_session(session_id)
    chat_history = get_chat_history(session_id)
    has_history = len(chat_history) > 0
    
    # Récupère le contexte via RAG
    vectorstore = get_vectorstore()
    retriever = vectorstore.as_retriever(
        search_type="similarity",
        search_kwargs={"k": settings.top_k_results},
    )
    
    # Récupère les documents pertinents
    source_docs = await retriever.ainvoke(question)
    context = format_docs(source_docs)
    
    # Ajoute le message utilisateur à l'historique
    add_message(session_id, "user", question)
    
    # Prépare la chaîne avec ou sans historique
    chain = get_rag_chain(with_history=has_history)
    
    # Prépare les paramètres d'invocation
    invoke_params = {
        "context": context,
        "question": question,
    }
    if has_history:
        invoke_params["chat_history"] = chat_history
    
    # Invoque le LLM
    response = await chain.ainvoke(invoke_params)
    
    # Vérifie si le LLM veut appeler des outils
    tool_results = []
    final_response = ""
    
    if hasattr(response, "tool_calls") and response.tool_calls:
        # Exécute les outils
        tool_results = await execute_tool_calls(response.tool_calls)
        
        # Génère une réponse finale avec les résultats des outils
        llm = get_llm()
        follow_up_prompt = ChatPromptTemplate.from_messages([
            ("system", SYSTEM_PROMPT),
            MessagesPlaceholder(variable_name="chat_history"),
            ("human", HUMAN_PROMPT),
            ("assistant", "J'ai effectué l'action demandée. Voici le résultat :"),
            ("human", "Résultat de l'outil : {tool_result}\n\nMaintenant, formule une réponse finale chaleureuse pour le client."),
        ])
        
        follow_up_chain = follow_up_prompt | llm | StrOutputParser()
        final_response = await follow_up_chain.ainvoke({
            "context": context,
            "question": question,
            "chat_history": chat_history,
            "tool_result": "\n".join(tool_results),
        })
    else:
        # Pas d'appel d'outil, utilise la réponse directe
        final_response = response.content if hasattr(response, "content") else str(response)
    
    # Ajoute la réponse à l'historique
    add_message(session_id, "assistant", final_response)
    
    # Extrait les sources uniques
    sources = list(set(
        doc.metadata.get("category", "inconnu")
        for doc in source_docs
    ))
    
    return {
        "response": final_response,
        "sources": sources,
        "question": question,
        "session_id": session_id,
        "tools_used": [tc.get("name") for tc in response.tool_calls] if hasattr(response, "tool_calls") and response.tool_calls else [],
    }
