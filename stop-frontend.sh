#!/bin/bash
# Script pour arrêter le frontend en cours d'exécution

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Répertoires
PID_DIR="/tmp"
WEB_PID_FILE="$PID_DIR/casa-del-sabor-web.pid"
WEB_ALT_PID_FILE="$PID_DIR/casa-del-sabor-web-alt.pid"
MOBILE_PID_FILE="$PID_DIR/casa-del-sabor-mobile.pid"

echo -e "${BLUE}🛑 Arrêt des frontends...${NC}\n"

FRONTEND_STOPPED=false

# Arrêter web
if [ -f "$WEB_PID_FILE" ]; then
    WEB_PID=$(cat "$WEB_PID_FILE")
    if ps -p "$WEB_PID" > /dev/null 2>&1; then
        echo -e "${BLUE}   Arrêt de Next.js (web) (PID: $WEB_PID)...${NC}"
        kill "$WEB_PID" 2>/dev/null || true
        sleep 1
        if ps -p "$WEB_PID" > /dev/null 2>&1; then
            kill -9 "$WEB_PID" 2>/dev/null || true
        fi
        echo -e "${GREEN}   ✅ Next.js (web) arrêté${NC}"
        FRONTEND_STOPPED=true
    fi
    rm -f "$WEB_PID_FILE"
fi

# Arrêter web-alt
if [ -f "$WEB_ALT_PID_FILE" ]; then
    WEB_ALT_PID=$(cat "$WEB_ALT_PID_FILE")
    if ps -p "$WEB_ALT_PID" > /dev/null 2>&1; then
        echo -e "${BLUE}   Arrêt de Next.js (web-alt) (PID: $WEB_ALT_PID)...${NC}"
        kill "$WEB_ALT_PID" 2>/dev/null || true
        sleep 1
        if ps -p "$WEB_ALT_PID" > /dev/null 2>&1; then
            kill -9 "$WEB_ALT_PID" 2>/dev/null || true
        fi
        echo -e "${GREEN}   ✅ Next.js (web-alt) arrêté${NC}"
        FRONTEND_STOPPED=true
    fi
    rm -f "$WEB_ALT_PID_FILE"
fi

# Arrêter mobile (Expo)
if [ -f "$MOBILE_PID_FILE" ]; then
    MOBILE_PID=$(cat "$MOBILE_PID_FILE")
    if ps -p "$MOBILE_PID" > /dev/null 2>&1; then
        echo -e "${BLUE}   Arrêt de React Native/Expo (PID: $MOBILE_PID)...${NC}"
        kill "$MOBILE_PID" 2>/dev/null || true
        sleep 1
        if ps -p "$MOBILE_PID" > /dev/null 2>&1; then
            kill -9 "$MOBILE_PID" 2>/dev/null || true
        fi
        echo -e "${GREEN}   ✅ React Native/Expo arrêté${NC}"
        FRONTEND_STOPPED=true
    fi
    rm -f "$MOBILE_PID_FILE"
fi

# Nettoyer les processus orphelins
NEXT_PIDS=$(pgrep -f "next dev" 2>/dev/null || true)
if [ -n "$NEXT_PIDS" ]; then
    echo -e "${YELLOW}   Arrêt des processus next dev orphelins...${NC}"
    echo "$NEXT_PIDS" | xargs kill 2>/dev/null || true
fi

EXPO_PIDS=$(pgrep -f "expo start" 2>/dev/null || true)
if [ -n "$EXPO_PIDS" ]; then
    echo -e "${YELLOW}   Arrêt des processus expo orphelins...${NC}"
    echo "$EXPO_PIDS" | xargs kill 2>/dev/null || true
fi

if [ "$FRONTEND_STOPPED" = false ]; then
    echo -e "${YELLOW}   ⚠️  Aucun frontend n'était en cours d'exécution${NC}"
fi

echo ""
echo -e "${GREEN}✅ Tous les frontends ont été arrêtés${NC}"
echo ""
