"""Outils LangChain pour l'agent Casa del Sabor."""

import logging
from datetime import datetime
from typing import Optional

from langchain_core.tools import tool
from pydantic import BaseModel, Field

# Configuration du logger
logger = logging.getLogger("casa_del_sabor.tools")
logger.setLevel(logging.INFO)

# Handler console avec formatage
if not logger.handlers:
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter(
        "🔧 [TOOL] %(asctime)s - %(message)s",
        datefmt="%H:%M:%S"
    ))
    logger.addHandler(handler)


class ReservationInput(BaseModel):
    """Schéma d'entrée pour l'outil de réservation."""
    
    nom: str = Field(description="Nom du client pour la réservation")
    date: str = Field(description="Date de la réservation (format: JJ/MM/AAAA ou 'ce soir', 'demain')")
    heure: str = Field(description="Heure de la réservation (format: HH:MM ou HHh)")
    nombre_personnes: int = Field(description="Nombre de personnes", ge=1, le=20)
    telephone: Optional[str] = Field(default=None, description="Numéro de téléphone du client (optionnel)")
    email: Optional[str] = Field(default=None, description="Email du client (optionnel)")


@tool(args_schema=ReservationInput)
def reserver_table(
    nom: str,
    date: str,
    heure: str,
    nombre_personnes: int,
    telephone: Optional[str] = None,
    email: Optional[str] = None,
) -> str:
    """
    Réserve une table au restaurant Casa del Sabor.
    
    Utilise cet outil quand un client veut effectuer une réservation directement.
    Tu dois collecter les informations nécessaires (nom, date, heure, nombre de personnes)
    avant d'appeler cet outil.
    """
    # Log de l'appel à l'API factice
    logger.info("=" * 60)
    logger.info("📞 APPEL API RÉSERVATION (FACTICE)")
    logger.info("=" * 60)
    logger.info(f"  Nom: {nom}")
    logger.info(f"  Date: {date}")
    logger.info(f"  Heure: {heure}")
    logger.info(f"  Nombre de personnes: {nombre_personnes}")
    if telephone:
        logger.info(f"  Téléphone: {telephone}")
    if email:
        logger.info(f"  Email: {email}")
    logger.info("=" * 60)
    logger.info("✅ API appelée avec succès (simulation)")
    logger.info("=" * 60)
    
    # Simule un numéro de confirmation
    confirmation_number = f"CDS-{datetime.now().strftime('%Y%m%d%H%M%S')}"
    
    # Retourne le résultat pour l'agent
    return f"""Réservation effectuée avec succès !

📋 Récapitulatif :
- Nom : {nom}
- Date : {date}
- Heure : {heure}
- Nombre de personnes : {nombre_personnes}
- Numéro de confirmation : {confirmation_number}

Le client recevra une confirmation par {'email à ' + email if email else 'SMS au ' + telephone if telephone else 'téléphone lors de son arrivée'}.
"""


@tool
def consulter_disponibilites(date: str, nombre_personnes: int) -> str:
    """
    Consulte les disponibilités pour une date donnée.
    
    Utilise cet outil pour vérifier les créneaux disponibles avant de proposer une réservation.
    """
    logger.info("=" * 60)
    logger.info("🔍 CONSULTATION DISPONIBILITÉS (FACTICE)")
    logger.info(f"  Date: {date}")
    logger.info(f"  Nombre de personnes: {nombre_personnes}")
    logger.info("=" * 60)
    
    # Simule des créneaux disponibles
    return f"""Créneaux disponibles pour le {date} ({nombre_personnes} personnes) :

🍽️ Midi :
- 12h00 ✅
- 12h30 ✅
- 13h00 ✅
- 13h30 ❌ (complet)

🌙 Soir :
- 19h00 ✅
- 19h30 ✅
- 20h00 ✅
- 20h30 ✅
- 21h00 ✅
- 21h30 ❌ (complet)
"""


# Liste des outils disponibles pour l'agent
TOOLS = [reserver_table, consulter_disponibilites]
