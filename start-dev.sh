#!/bin/bash
# Script pour démarrer l'environnement de développement complet
# Démarre Qdrant, l'agent Python et le frontend choisi
#
# Usage:
#   ./start-dev.sh [frontend]
#
# Frontends disponibles:
#   web-alt  - Frontend Next.js alternatif (défaut)
#   web      - Frontend Next.js original
#   mobile   - Application mobile React Native/Expo

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
PID_DIR="/tmp"
AGENT_PID_FILE="$PID_DIR/casa-del-sabor-agent.pid"

# Déterminer le frontend à utiliser
FRONTEND="${1:-web-alt}"  # web-alt par défaut

# Validation du frontend
case "$FRONTEND" in
    web-alt|web|mobile)
        ;;
    *)
        echo -e "${RED}❌ Frontend invalide: $FRONTEND${NC}"
        echo -e "${YELLOW}Frontends disponibles:${NC}"
        echo -e "   ${BLUE}web-alt${NC}  - Frontend Next.js alternatif (défaut)"
        echo -e "   ${BLUE}web${NC}      - Frontend Next.js original"
        echo -e "   ${BLUE}mobile${NC}   - Application mobile React Native/Expo"
        echo ""
        echo -e "${YELLOW}Usage:${NC} ./start-dev.sh [web-alt|web|mobile]"
        exit 1
        ;;
esac

# Définir les répertoires et ports selon le frontend
case "$FRONTEND" in
    web-alt)
        FRONTEND_DIR="$SCRIPT_DIR/web-alt"
        FRONTEND_PORT=3001  # web-alt utilise le port 3001
        FRONTEND_NAME="Next.js (web-alt)"
        FRONTEND_PID_FILE="$PID_DIR/casa-del-sabor-web-alt.pid"
        FRONTEND_LOG="/tmp/casa-del-sabor-web-alt.log"
        ;;
    web)
        FRONTEND_DIR="$SCRIPT_DIR/web"
        FRONTEND_PORT=3000
        FRONTEND_NAME="Next.js (web)"
        FRONTEND_PID_FILE="$PID_DIR/casa-del-sabor-web.pid"
        FRONTEND_LOG="/tmp/casa-del-sabor-web.log"
        ;;
    mobile)
        FRONTEND_DIR="$SCRIPT_DIR/mobile"
        FRONTEND_PORT=8081  # Port Expo par défaut
        FRONTEND_NAME="React Native/Expo"
        FRONTEND_PID_FILE="$PID_DIR/casa-del-sabor-mobile.pid"
        FRONTEND_LOG="/tmp/casa-del-sabor-mobile.log"
        ;;
esac

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
    
    # Arrêter le frontend
    if [ -f "$FRONTEND_PID_FILE" ]; then
        FRONTEND_PID=$(cat "$FRONTEND_PID_FILE")
        if ps -p "$FRONTEND_PID" > /dev/null 2>&1; then
            echo "   Arrêt de $FRONTEND_NAME (PID: $FRONTEND_PID)"
            kill "$FRONTEND_PID" 2>/dev/null || true
        fi
        rm -f "$FRONTEND_PID_FILE"
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

echo -e "${BLUE}🚀 Démarrage de l'environnement de développement Casa del Sabor...${NC}"
echo -e "${BLUE}📱 Frontend sélectionné: ${GREEN}$FRONTEND_NAME${NC} ($FRONTEND)\n"

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
    
    if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
        echo -e "${YELLOW}   ⚠️  Dépendances $FRONTEND_NAME non installées${NC}"
        echo -e "${YELLOW}   Lancez: cd $FRONTEND_DIR && npm install${NC}"
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

# Démarrage du frontend
echo -e "\n${BLUE}⚛️  Démarrage de $FRONTEND_NAME...${NC}"
cd "$FRONTEND_DIR"

# Vérifier si le frontend est déjà en cours d'exécution
if [ -f "$FRONTEND_PID_FILE" ]; then
    OLD_PID=$(cat "$FRONTEND_PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo -e "${YELLOW}   ⚠️  $FRONTEND_NAME est déjà en cours d'exécution (PID: $OLD_PID)${NC}"
        echo -e "${YELLOW}   Utilisez ./stop-dev.sh pour l'arrêter d'abord${NC}"
    else
        rm -f "$FRONTEND_PID_FILE"
    fi
fi

if [ ! -f "$FRONTEND_PID_FILE" ]; then
    case "$FRONTEND" in
        web-alt|web)
            npm run dev > "$FRONTEND_LOG" 2>&1 &
            FRONTEND_PID=$!
            echo "$FRONTEND_PID" > "$FRONTEND_PID_FILE"
            echo -e "${GREEN}   ✅ $FRONTEND_NAME démarré (PID: $FRONTEND_PID)${NC}"
            echo -e "${BLUE}   📝 Logs: tail -f $FRONTEND_LOG${NC}"
            
            # Attendre que Next.js soit prêt
            echo -e "${BLUE}⏳ Attente que $FRONTEND_NAME soit prêt...${NC}"
            timeout=15
            counter=0
            while ! curl -s http://localhost:$FRONTEND_PORT > /dev/null 2>&1; do
                if [ $counter -ge $timeout ]; then
                    echo -e "${YELLOW}   ⚠️  $FRONTEND_NAME n'est pas encore prêt après ${timeout}s${NC}"
                    echo -e "${YELLOW}   Vérifiez les logs: tail -f $FRONTEND_LOG${NC}"
                    break
                fi
                sleep 1
                counter=$((counter + 1))
                echo -n "."
            done
            if curl -s http://localhost:$FRONTEND_PORT > /dev/null 2>&1; then
                echo ""
                echo -e "${GREEN}   ✅ $FRONTEND_NAME est prêt!${NC}"
            fi
            ;;
        mobile)
            # Pour Expo, on utilise npm start qui ouvre le menu interactif
            npm start > "$FRONTEND_LOG" 2>&1 &
            FRONTEND_PID=$!
            echo "$FRONTEND_PID" > "$FRONTEND_PID_FILE"
            echo -e "${GREEN}   ✅ $FRONTEND_NAME démarré (PID: $FRONTEND_PID)${NC}"
            echo -e "${BLUE}   📝 Logs: tail -f $FRONTEND_LOG${NC}"
            echo -e "${YELLOW}   💡 Expo va ouvrir un menu interactif.${NC}"
            echo -e "${YELLOW}   💡 Appuyez sur 'i' pour iOS, 'a' pour Android, ou scannez le QR code.${NC}"
            # Pas de health check pour mobile car Expo utilise un port différent
            sleep 3
            echo -e "${GREEN}   ✅ Expo est en cours de démarrage!${NC}"
            ;;
    esac
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
case "$FRONTEND" in
    web-alt|web)
        echo -e "   • $FRONTEND_NAME:    ${GREEN}http://localhost:$FRONTEND_PORT${NC}"
        ;;
    mobile)
        echo -e "   • $FRONTEND_NAME:    ${GREEN}Voir le terminal Expo pour les options${NC}"
        ;;
esac
echo ""
echo -e "${BLUE}📝 Logs:${NC}"
echo -e "   • Agent:   ${YELLOW}tail -f /tmp/casa-del-sabor-agent.log${NC}"
echo -e "   • Frontend: ${YELLOW}tail -f $FRONTEND_LOG${NC}"
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
