"""Module de l'agent RAG avec outils LangChain."""

import json
from functools import lru_cache

from langchain_core.language_models.chat_models import BaseChatModel
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_openai import ChatOpenAI

from config import get_settings

from .memory import add_message, get_chat_history, get_or_create_session
from .tools import TOOLS, consulter_disponibilites, reserver_table
from .vectorstore import get_vectorstore


class KnowledgeBaseUnavailableError(Exception):
    """Levée quand la base vectorielle n'est pas prête (ex: collection absente)."""


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


def _build_base_llm() -> BaseChatModel:
    """Chat LLM via endpoint OpenAI-compatible (LiteLLM)."""
    settings = get_settings()
    return ChatOpenAI(
        model=settings.llm_model,
        api_key=settings.llm_api_key,
        base_url=settings.llm_base_url.rstrip("/"),
        temperature=settings.llm_temperature,
        max_tokens=settings.llm_max_tokens,
    )


@lru_cache
def get_llm() -> BaseChatModel:
    """Retourne le LLM configuré (LiteLLM)."""
    return _build_base_llm()


@lru_cache
def get_llm_with_tools() -> BaseChatModel:
    """LLM avec outils bindés."""
    return _build_base_llm().bind_tools(TOOLS)


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


def _tool_call_name_args(tool_call: object) -> tuple[str | None, dict]:
    """Normalise un tool_call OpenAI / LangChain (dict ou objet)."""
    if isinstance(tool_call, dict):
        name = tool_call.get("name")
        raw_args = tool_call.get("args")
        if raw_args is None and "arguments" in tool_call:
            raw_args = tool_call.get("arguments")
    else:
        name = getattr(tool_call, "name", None)
        raw_args = getattr(tool_call, "args", None)
        if raw_args is None:
            raw_args = getattr(tool_call, "arguments", None)

    if isinstance(raw_args, str):
        try:
            tool_args = json.loads(raw_args) if raw_args.strip() else {}
        except json.JSONDecodeError:
            tool_args = {}
    elif isinstance(raw_args, dict):
        tool_args = raw_args
    else:
        tool_args = {}

    return name, tool_args


async def execute_tool_calls(tool_calls: list) -> list[str]:
    """Exécute les appels d'outils et retourne les résultats."""
    results = []

    for tool_call in tool_calls:
        tool_name, tool_args = _tool_call_name_args(tool_call)

        if tool_name == "reserver_table":
            result = reserver_table.invoke(tool_args)
            results.append(result)
        elif tool_name == "consulter_disponibilites":
            result = consulter_disponibilites.invoke(tool_args)
            results.append(result)

    return results


async def ask_question(question: str, session_id: str | None = None) -> dict:
    """
    Pose une question à l'agent RAG et retourne la réponse.

    Args:
        question: La question du client.
        session_id: ID de session pour maintenir l'historique (optionnel).

    Returns:
        Dictionnaire avec la réponse et les métadonnées.
    """
    settings = get_settings()

    session_id, session = get_or_create_session(session_id)
    chat_history = get_chat_history(session_id)
    has_history = len(chat_history) > 0

    vectorstore = get_vectorstore()
    retriever = vectorstore.as_retriever(
        search_type="similarity",
        search_kwargs={"k": settings.top_k_results},
    )

    try:
        source_docs = await retriever.ainvoke(question)
    except Exception as e:
        lowered = str(e).lower()
        if "doesn't exist" in lowered or "not found: collection" in lowered:
            raise KnowledgeBaseUnavailableError(
                "La collection vectorielle n'est pas encore disponible."
            ) from e
        raise
    context = format_docs(source_docs)

    add_message(session_id, "user", question)

    chain = get_rag_chain(with_history=has_history)

    invoke_params: dict[str, object] = {
        "context": context,
        "question": question,
    }
    if has_history:
        invoke_params["chat_history"] = chat_history

    response = await chain.ainvoke(invoke_params)

    tool_results = []
    final_response = ""

    if hasattr(response, "tool_calls") and response.tool_calls:
        tool_results = await execute_tool_calls(response.tool_calls)

        llm = get_llm()
        follow_up_prompt = ChatPromptTemplate.from_messages([
            ("system", SYSTEM_PROMPT),
            MessagesPlaceholder(variable_name="chat_history"),
            ("human", HUMAN_PROMPT),
            ("assistant", "J'ai effectué l'action demandée. Voici le résultat :"),
            ("human", "Résultat de l'outil : {tool_result}\n\nMaintenant, formule une réponse finale chaleureuse pour le client."),
        ])

        follow_up_chain = follow_up_prompt | llm | StrOutputParser()
        chat_history = get_chat_history(session_id)
        final_response = await follow_up_chain.ainvoke({
            "context": context,
            "question": question,
            "chat_history": chat_history,
            "tool_result": "\n".join(tool_results),
        })
    else:
        raw = response.content if hasattr(response, "content") else str(response)
        final_response = raw if isinstance(raw, str) else (str(raw) if raw is not None else "")

    add_message(session_id, "assistant", final_response)

    sources = list(set(
        doc.metadata.get("category", "inconnu")
        for doc in source_docs
    ))

    tools_used: list[str | None] = []
    if hasattr(response, "tool_calls") and response.tool_calls:
        for tc in response.tool_calls:
            name, _ = _tool_call_name_args(tc)
            tools_used.append(name)

    return {
        "response": final_response,
        "sources": sources,
        "question": question,
        "session_id": session_id,
        "tools_used": tools_used,
    }
