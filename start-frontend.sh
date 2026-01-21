#!/bin/bash
# Script pour démarrer uniquement le frontend choisi
# (sans Qdrant ni agent Python)
#
# Usage:
#   ./start-frontend.sh [frontend]
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
PID_DIR="/tmp"

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
        echo -e "${YELLOW}Usage:${NC} ./start-frontend.sh [web-alt|web|mobile]"
        exit 1
        ;;
esac

# Définir les répertoires et ports selon le frontend
case "$FRONTEND" in
    web-alt)
        FRONTEND_DIR="$SCRIPT_DIR/web-alt"
        FRONTEND_PORT=3001
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
        FRONTEND_PORT=8081
        FRONTEND_NAME="React Native/Expo"
        FRONTEND_PID_FILE="$PID_DIR/casa-del-sabor-mobile.pid"
        FRONTEND_LOG="/tmp/casa-del-sabor-mobile.log"
        ;;
esac

# Fonction pour nettoyer en cas d'arrêt
cleanup() {
    echo -e "\n${YELLOW}🛑 Arrêt de $FRONTEND_NAME...${NC}"
    
    if [ -f "$FRONTEND_PID_FILE" ]; then
        FRONTEND_PID=$(cat "$FRONTEND_PID_FILE")
        if ps -p "$FRONTEND_PID" > /dev/null 2>&1; then
            echo "   Arrêt du frontend (PID: $FRONTEND_PID)"
            kill "$FRONTEND_PID" 2>/dev/null || true
        fi
        rm -f "$FRONTEND_PID_FILE"
    fi
    
    echo -e "${GREEN}✅ Frontend arrêté${NC}"
    exit 0
}

# Capturer Ctrl+C
trap cleanup SIGINT SIGTERM

echo -e "${BLUE}🚀 Démarrage de $FRONTEND_NAME...${NC}\n"

# Vérifications préalables
echo -e "${BLUE}📋 Vérification des prérequis...${NC}"

# Vérifier Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js n'est pas installé${NC}"
    exit 1
fi
NODE_VERSION=$(node --version)
echo -e "${GREEN}   ✅ Node.js $NODE_VERSION${NC}"

# Vérifier que le répertoire existe
if [ ! -d "$FRONTEND_DIR" ]; then
    echo -e "${RED}❌ Répertoire $FRONTEND_DIR n'existe pas${NC}"
    exit 1
fi

# Vérifier les dépendances
if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
    echo -e "${YELLOW}⚠️  Dépendances non installées${NC}"
    echo -e "${YELLOW}   Installation des dépendances...${NC}"
    (cd "$FRONTEND_DIR" && npm install)
    echo -e "${GREEN}   ✅ Dépendances installées${NC}"
fi

echo ""

# Vérifier si le frontend est déjà en cours d'exécution
if [ -f "$FRONTEND_PID_FILE" ]; then
    OLD_PID=$(cat "$FRONTEND_PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  $FRONTEND_NAME est déjà en cours d'exécution (PID: $OLD_PID)${NC}"
        echo -e "${YELLOW}   Utilisez ./stop-frontend.sh pour l'arrêter d'abord${NC}"
        exit 1
    else
        rm -f "$FRONTEND_PID_FILE"
    fi
fi

# Démarrage du frontend
echo -e "${BLUE}⚛️  Démarrage de $FRONTEND_NAME...${NC}"

case "$FRONTEND" in
    web-alt|web)
        # S'assurer que npm run dev est exécuté depuis le bon répertoire
        # Utiliser le script wrapper si disponible pour garantir le bon répertoire de travail
        if [ -f "$FRONTEND_DIR/run-dev.sh" ]; then
            "$FRONTEND_DIR/run-dev.sh" > "$FRONTEND_LOG" 2>&1 &
        else
            # Fallback: utiliser cd avec exec
            (cd "$FRONTEND_DIR" && exec npm run dev > "$FRONTEND_LOG" 2>&1) &
        fi
        FRONTEND_PID=$!
        echo "$FRONTEND_PID" > "$FRONTEND_PID_FILE"
        echo -e "${GREEN}   ✅ $FRONTEND_NAME démarré (PID: $FRONTEND_PID)${NC}"
        echo -e "${BLUE}   📝 Logs: tail -f $FRONTEND_LOG${NC}"
        
        # Attendre que Next.js soit prêt
        echo -e "${BLUE}⏳ Attente que $FRONTEND_NAME soit prêt...${NC}"
        timeout=30
        counter=0
        while ! curl -s http://localhost:$FRONTEND_PORT > /dev/null 2>&1; do
            if [ $counter -ge $timeout ]; then
                echo ""
                echo -e "${YELLOW}   ⚠️  $FRONTEND_NAME n'est pas encore prêt après ${timeout}s${NC}"
                echo -e "${YELLOW}   Vérifiez les logs: tail -f $FRONTEND_LOG${NC}"
                # Vérifier si le processus est toujours en cours
                if ! ps -p "$FRONTEND_PID" > /dev/null 2>&1; then
                    echo -e "${RED}   ❌ Le processus s'est arrêté. Vérifiez les erreurs dans les logs.${NC}"
                    exit 1
                fi
                break
            fi
            sleep 1
            counter=$((counter + 1))
            if [ $((counter % 5)) -eq 0 ]; then
                echo -n "."
            fi
        done
        if curl -s http://localhost:$FRONTEND_PORT > /dev/null 2>&1; then
            echo ""
            echo -e "${GREEN}   ✅ $FRONTEND_NAME est prêt!${NC}"
        fi
        ;;
    mobile)
        # Pour Expo, on utilise npm start qui ouvre le menu interactif
        (cd "$FRONTEND_DIR" && exec npm start > "$FRONTEND_LOG" 2>&1) &
        FRONTEND_PID=$!
        echo "$FRONTEND_PID" > "$FRONTEND_PID_FILE"
        echo -e "${GREEN}   ✅ $FRONTEND_NAME démarré (PID: $FRONTEND_PID)${NC}"
        echo -e "${BLUE}   📝 Logs: tail -f $FRONTEND_LOG${NC}"
        echo -e "${YELLOW}   💡 Expo va ouvrir un menu interactif.${NC}"
        echo -e "${YELLOW}   💡 Appuyez sur 'i' pour iOS, 'a' pour Android, ou scannez le QR code.${NC}"
        sleep 3
        echo -e "${GREEN}   ✅ Expo est en cours de démarrage!${NC}"
        ;;
esac

# Résumé
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ $FRONTEND_NAME est prêt!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
case "$FRONTEND" in
    web-alt|web)
        echo -e "${BLUE}📍 URL:${NC}"
        echo -e "   • $FRONTEND_NAME: ${GREEN}http://localhost:$FRONTEND_PORT${NC}"
        ;;
    mobile)
        echo -e "${BLUE}📍 Options:${NC}"
        echo -e "   • Voir le terminal Expo pour les options${NC}"
        echo -e "   • Appuyez sur 'i' pour iOS, 'a' pour Android${NC}"
        ;;
esac
echo ""
echo -e "${BLUE}📝 Logs:${NC}"
echo -e "   ${YELLOW}tail -f $FRONTEND_LOG${NC}"
echo ""
echo -e "${BLUE}🛑 Pour arrêter:${NC}"
echo -e "   ${YELLOW}./stop-frontend.sh${NC}"
echo -e "   ou appuyez sur ${YELLOW}Ctrl+C${NC}"
echo ""

# Attendre indéfiniment (ou jusqu'à Ctrl+C)
echo -e "${BLUE}Frontend en cours d'exécution... (Ctrl+C pour arrêter)${NC}"
wait
