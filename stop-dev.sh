#!/bin/bash
# Script pour arrêter proprement tous les services de développement

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Répertoires
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_DIR="/tmp"
AGENT_PID_FILE="$PID_DIR/casa-del-sabor-agent.pid"
WEB_PID_FILE="$PID_DIR/casa-del-sabor-web.pid"

echo -e "${BLUE}🛑 Arrêt des services de développement...${NC}\n"

# Arrêter l'agent Python
if [ -f "$AGENT_PID_FILE" ]; then
    AGENT_PID=$(cat "$AGENT_PID_FILE")
    if ps -p "$AGENT_PID" > /dev/null 2>&1; then
        echo -e "${BLUE}   Arrêt de l'agent (PID: $AGENT_PID)...${NC}"
        kill "$AGENT_PID" 2>/dev/null || true
        sleep 1
        # Forcer l'arrêt si nécessaire
        if ps -p "$AGENT_PID" > /dev/null 2>&1; then
            kill -9 "$AGENT_PID" 2>/dev/null || true
        fi
        echo -e "${GREEN}   ✅ Agent arrêté${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Agent n'était pas en cours d'exécution${NC}"
    fi
    rm -f "$AGENT_PID_FILE"
else
    echo -e "${YELLOW}   ⚠️  Fichier PID de l'agent introuvable${NC}"
fi

# Arrêter Next.js
if [ -f "$WEB_PID_FILE" ]; then
    WEB_PID=$(cat "$WEB_PID_FILE")
    if ps -p "$WEB_PID" > /dev/null 2>&1; then
        echo -e "${BLUE}   Arrêt de Next.js (PID: $WEB_PID)...${NC}"
        kill "$WEB_PID" 2>/dev/null || true
        sleep 1
        # Forcer l'arrêt si nécessaire
        if ps -p "$WEB_PID" > /dev/null 2>&1; then
            kill -9 "$WEB_PID" 2>/dev/null || true
        fi
        echo -e "${GREEN}   ✅ Next.js arrêté${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Next.js n'était pas en cours d'exécution${NC}"
    fi
    rm -f "$WEB_PID_FILE"
else
    echo -e "${YELLOW}   ⚠️  Fichier PID de Next.js introuvable${NC}"
fi

# Arrêter Qdrant
echo -e "${BLUE}   Arrêt de Qdrant...${NC}"
cd "$SCRIPT_DIR"
if docker-compose -f docker-compose.yml ps qdrant | grep -q "Up"; then
    docker-compose -f docker-compose.yml down > /dev/null 2>&1
    echo -e "${GREEN}   ✅ Qdrant arrêté${NC}"
else
    echo -e "${YELLOW}   ⚠️  Qdrant n'était pas en cours d'exécution${NC}"
fi

# Nettoyer les processus orphelins (optionnel)
echo -e "\n${BLUE}🧹 Nettoyage...${NC}"

# Chercher les processus uvicorn orphelins
UVICORN_PIDS=$(pgrep -f "uvicorn main:app" 2>/dev/null || true)
if [ -n "$UVICORN_PIDS" ]; then
    echo -e "${YELLOW}   Arrêt des processus uvicorn orphelins...${NC}"
    echo "$UVICORN_PIDS" | xargs kill 2>/dev/null || true
fi

# Chercher les processus next dev orphelins
NEXT_PIDS=$(pgrep -f "next dev" 2>/dev/null || true)
if [ -n "$NEXT_PIDS" ]; then
    echo -e "${YELLOW}   Arrêt des processus next dev orphelins...${NC}"
    echo "$NEXT_PIDS" | xargs kill 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}✅ Tous les services ont été arrêtés${NC}"
echo ""
