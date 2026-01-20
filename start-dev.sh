#!/bin/bash
# Script pour démarrer l'environnement de développement complet
# Démarre Qdrant, l'agent Python et Next.js

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Répertoires
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$SCRIPT_DIR/agent"
WEB_DIR="$SCRIPT_DIR/web"
PID_DIR="/tmp"
AGENT_PID_FILE="$PID_DIR/casa-del-sabor-agent.pid"
WEB_PID_FILE="$PID_DIR/casa-del-sabor-web.pid"

# Fonction pour nettoyer les processus en cas d'arrêt
cleanup() {
    echo -e "\n${YELLOW}🛑 Arrêt des services...${NC}"
    
    # Arrêter l'agent
    if [ -f "$AGENT_PID_FILE" ]; then
        AGENT_PID=$(cat "$AGENT_PID_FILE")
        if ps -p "$AGENT_PID" > /dev/null 2>&1; then
            echo "   Arrêt de l'agent (PID: $AGENT_PID)"
            kill "$AGENT_PID" 2>/dev/null || true
        fi
        rm -f "$AGENT_PID_FILE"
    fi
    
    # Arrêter Next.js
    if [ -f "$WEB_PID_FILE" ]; then
        WEB_PID=$(cat "$WEB_PID_FILE")
        if ps -p "$WEB_PID" > /dev/null 2>&1; then
            echo "   Arrêt de Next.js (PID: $WEB_PID)"
            kill "$WEB_PID" 2>/dev/null || true
        fi
        rm -f "$WEB_PID_FILE"
    fi
    
    # Arrêter Qdrant
    echo "   Arrêt de Qdrant..."
    cd "$SCRIPT_DIR"
    docker-compose -f docker-compose.yml down > /dev/null 2>&1 || true
    
    echo -e "${GREEN}✅ Tous les services ont été arrêtés${NC}"
    exit 0
}

# Capturer Ctrl+C
trap cleanup SIGINT SIGTERM

echo -e "${BLUE}🚀 Démarrage de l'environnement de développement Casa del Sabor...${NC}\n"

# Vérifications préalables
echo -e "${BLUE}📋 Vérification des prérequis...${NC}"

# Vérifier Docker
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker n'est pas en cours d'exécution${NC}"
    echo -e "${YELLOW}💡 Démarrez Docker Desktop et réessayez${NC}"
    exit 1
fi
echo -e "${GREEN}   ✅ Docker est en cours d'exécution${NC}"

# Vérifier Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js n'est pas installé${NC}"
    exit 1
fi
NODE_VERSION=$(node --version)
echo -e "${GREEN}   ✅ Node.js $NODE_VERSION${NC}"

# Vérifier que 'just' est installé (pour l'agent)
if ! command -v just &> /dev/null; then
    echo -e "${YELLOW}⚠️  'just' n'est pas installé. Installation recommandée pour l'agent.${NC}"
    echo -e "${YELLOW}   Installez avec: cargo install just${NC}"
fi

# Vérifier les dépendances (optionnel)
if [ "$1" == "--check-deps" ]; then
    echo -e "${BLUE}📦 Vérification des dépendances...${NC}"
    
    if [ ! -d "$AGENT_DIR/.venv" ] && [ ! -f "$AGENT_DIR/uv.lock" ]; then
        echo -e "${YELLOW}   ⚠️  Dépendances de l'agent non installées${NC}"
        echo -e "${YELLOW}   Lancez: cd agent && just install${NC}"
    fi
    
    if [ ! -d "$WEB_DIR/node_modules" ]; then
        echo -e "${YELLOW}   ⚠️  Dépendances Next.js non installées${NC}"
        echo -e "${YELLOW}   Lancez: cd web && npm install${NC}"
    fi
fi

echo ""

# Démarrage de Qdrant
echo -e "${BLUE}📦 Démarrage de Qdrant...${NC}"
cd "$SCRIPT_DIR"

# Vérifier si Qdrant est déjà en cours d'exécution
if docker-compose -f docker-compose.yml ps qdrant | grep -q "Up"; then
    echo -e "${YELLOW}   ⚠️  Qdrant est déjà en cours d'exécution${NC}"
else
    docker-compose -f docker-compose.yml up -d qdrant
    echo -e "${GREEN}   ✅ Qdrant démarré${NC}"
fi

# Attendre que Qdrant soit prêt
echo -e "${BLUE}⏳ Attente que Qdrant soit prêt...${NC}"
timeout=30
counter=0
while ! curl -s http://localhost:6333/health > /dev/null 2>&1; do
    if [ $counter -ge $timeout ]; then
        echo -e "${RED}❌ Timeout: Qdrant n'a pas démarré après ${timeout}s${NC}"
        echo -e "${YELLOW}💡 Vérifiez les logs avec: docker-compose -f docker-compose.yml logs qdrant${NC}"
        exit 1
    fi
    sleep 1
    counter=$((counter + 1))
    echo -n "."
done
echo ""
echo -e "${GREEN}   ✅ Qdrant est prêt!${NC}"

# Vérifier .env.local pour l'agent
if [ ! -f "$AGENT_DIR/.env.local" ]; then
    echo -e "${YELLOW}⚠️  .env.local n'existe pas dans agent/${NC}"
    if [ -f "$AGENT_DIR/.env.local.example" ]; then
        echo -e "${YELLOW}   Créez-le depuis .env.local.example${NC}"
    fi
fi

# Démarrage de l'agent Python
echo -e "\n${BLUE}🐍 Démarrage de l'agent Python...${NC}"
cd "$AGENT_DIR"

# Vérifier si l'agent est déjà en cours d'exécution
if [ -f "$AGENT_PID_FILE" ]; then
    OLD_PID=$(cat "$AGENT_PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo -e "${YELLOW}   ⚠️  L'agent est déjà en cours d'exécution (PID: $OLD_PID)${NC}"
        echo -e "${YELLOW}   Utilisez ./stop-dev.sh pour l'arrêter d'abord${NC}"
    else
        rm -f "$AGENT_PID_FILE"
    fi
fi

if [ ! -f "$AGENT_PID_FILE" ]; then
    if command -v just &> /dev/null; then
        just dev > /tmp/casa-del-sabor-agent.log 2>&1 &
        AGENT_PID=$!
        echo "$AGENT_PID" > "$AGENT_PID_FILE"
        echo -e "${GREEN}   ✅ Agent démarré (PID: $AGENT_PID)${NC}"
        echo -e "${BLUE}   📝 Logs: tail -f /tmp/casa-del-sabor-agent.log${NC}"
    else
        echo -e "${RED}❌ 'just' n'est pas installé. Impossible de démarrer l'agent.${NC}"
        echo -e "${YELLOW}   Installez avec: cargo install just${NC}"
        echo -e "${YELLOW}   Ou démarrez manuellement: cd agent && uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000${NC}"
    fi
fi

# Attendre que l'agent soit prêt
if [ -f "$AGENT_PID_FILE" ]; then
    echo -e "${BLUE}⏳ Attente que l'agent soit prêt...${NC}"
    timeout=15
    counter=0
    while ! curl -s http://localhost:8000/health > /dev/null 2>&1; do
        if [ $counter -ge $timeout ]; then
            echo -e "${YELLOW}   ⚠️  L'agent n'est pas encore prêt après ${timeout}s${NC}"
            echo -e "${YELLOW}   Vérifiez les logs: tail -f /tmp/casa-del-sabor-agent.log${NC}"
            break
        fi
        sleep 1
        counter=$((counter + 1))
        echo -n "."
    done
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo ""
        echo -e "${GREEN}   ✅ Agent est prêt!${NC}"
    fi
fi

# Démarrage de Next.js
echo -e "\n${BLUE}⚛️  Démarrage de Next.js...${NC}"
cd "$WEB_DIR"

# Vérifier si Next.js est déjà en cours d'exécution
if [ -f "$WEB_PID_FILE" ]; then
    OLD_PID=$(cat "$WEB_PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo -e "${YELLOW}   ⚠️  Next.js est déjà en cours d'exécution (PID: $OLD_PID)${NC}"
        echo -e "${YELLOW}   Utilisez ./stop-dev.sh pour l'arrêter d'abord${NC}"
    else
        rm -f "$WEB_PID_FILE"
    fi
fi

if [ ! -f "$WEB_PID_FILE" ]; then
    npm run dev > /tmp/casa-del-sabor-web.log 2>&1 &
    WEB_PID=$!
    echo "$WEB_PID" > "$WEB_PID_FILE"
    echo -e "${GREEN}   ✅ Next.js démarré (PID: $WEB_PID)${NC}"
    echo -e "${BLUE}   📝 Logs: tail -f /tmp/casa-del-sabor-web.log${NC}"
fi

# Attendre que Next.js soit prêt
echo -e "${BLUE}⏳ Attente que Next.js soit prêt...${NC}"
timeout=15
counter=0
while ! curl -s http://localhost:3000 > /dev/null 2>&1; do
    if [ $counter -ge $timeout ]; then
        echo -e "${YELLOW}   ⚠️  Next.js n'est pas encore prêt après ${timeout}s${NC}"
        echo -e "${YELLOW}   Vérifiez les logs: tail -f /tmp/casa-del-sabor-web.log${NC}"
        break
    fi
    sleep 1
    counter=$((counter + 1))
    echo -n "."
done
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo ""
    echo -e "${GREEN}   ✅ Next.js est prêt!${NC}"
fi

# Résumé
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Environnement de développement prêt!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📍 URLs des services:${NC}"
echo -e "   • Qdrant Dashboard: ${GREEN}http://localhost:6333/dashboard${NC}"
echo -e "   • Agent API:        ${GREEN}http://localhost:8000${NC}"
echo -e "   • Agent Health:     ${GREEN}http://localhost:8000/health${NC}"
echo -e "   • Next.js App:      ${GREEN}http://localhost:3000${NC}"
echo ""
echo -e "${BLUE}📝 Logs:${NC}"
echo -e "   • Agent:  ${YELLOW}tail -f /tmp/casa-del-sabor-agent.log${NC}"
echo -e "   • Next.js: ${YELLOW}tail -f /tmp/casa-del-sabor-web.log${NC}"
echo ""
echo -e "${BLUE}🛑 Pour arrêter tous les services:${NC}"
echo -e "   ${YELLOW}./stop-dev.sh${NC}"
echo -e "   ou appuyez sur ${YELLOW}Ctrl+C${NC}"
echo ""
echo -e "${BLUE}💡 Pour indexer les documents dans Qdrant:${NC}"
echo -e "   ${YELLOW}cd agent && just ingest${NC}"
echo ""

# Attendre indéfiniment (ou jusqu'à Ctrl+C)
echo -e "${BLUE}Services en cours d'exécution... (Ctrl+C pour arrêter)${NC}"
wait
