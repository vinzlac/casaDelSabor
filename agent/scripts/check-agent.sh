#!/bin/bash
# Script pour vérifier si l'agent est en cours d'exécution
# Usage: ./check-agent.sh [port] [env]
# port: port du serveur (défaut: 8000)
# env: local ou prod (défaut: local)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PORT="${1:-8000}"
ENV="${2:-local}"

# Déterminer l'URL en fonction de l'environnement
case "$ENV" in
    local)
        BASE_URL="http://localhost:${PORT}"
        ENV_NAME="Local"
        ;;
    prod)
        BASE_URL="https://casadelsabor.up.railway.app"
        ENV_NAME="Production"
        ;;
    *)
        echo -e "${RED}❌ Environnement invalide. Utilisez 'local' ou 'prod'${NC}"
        exit 1
        ;;
esac

echo -e "${BLUE}🔍 Vérification de l'agent Casa del Sabor${NC}"
echo -e "${BLUE}   Environnement: $ENV_NAME${NC}"
echo -e "${BLUE}   URL: $BASE_URL${NC}"
echo ""

# Test 1: Health check
echo -e "${YELLOW}1️⃣  Test du endpoint /health...${NC}"
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/health" 2>/dev/null)
HTTP_CODE=$(echo "$HEALTH_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$HEALTH_RESPONSE" | head -n-1)

if [ "$HTTP_CODE" -eq 200 ] 2>/dev/null; then
    echo -e "${GREEN}   ✅ Agent en ligne${NC}"
    echo "$RESPONSE_BODY" | python3 -m json.tool 2>/dev/null | sed 's/^/   /'
else
    echo -e "${RED}   ❌ Agent hors ligne${NC}"
    echo -e "${RED}   Code HTTP: $HTTP_CODE${NC}"
    echo ""
    echo -e "${YELLOW}💡 Pour démarrer l'agent:${NC}"
    if [ "$ENV" = "local" ]; then
        echo -e "   ${BLUE}cd agent && just dev${NC}"
        echo -e "   ou"
        echo -e "   ${BLUE}./start-dev.sh${NC} (depuis la racine)"
    else
        echo -e "   Vérifier les logs Railway ou redéployer"
    fi
    exit 1
fi

echo ""

# Test 2: Statut détaillé (si clé API disponible en local)
if [ "$ENV" = "local" ]; then
    cd "$AGENT_DIR"
    
    echo -e "${YELLOW}2️⃣  Test du endpoint /status...${NC}"
    
    if [ -f .env.local ] && grep -q "^API_KEY=" .env.local 2>/dev/null; then
        API_KEY=$(grep "^API_KEY=" .env.local | cut -d '=' -f2- | tr -d '"' | tr -d "'")
    elif [ -f .env ] && grep -q "^API_KEY=" .env 2>/dev/null; then
        API_KEY=$(grep "^API_KEY=" .env | cut -d '=' -f2- | tr -d '"' | tr -d "'")
    else
        echo -e "${YELLOW}   ⚠️  API_KEY non trouvée, skip du test /status${NC}"
        API_KEY=""
    fi
    
    if [ -n "$API_KEY" ]; then
        STATUS_RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/status" \
            -H "X-API-Key: $API_KEY" 2>/dev/null)
        HTTP_CODE=$(echo "$STATUS_RESPONSE" | tail -n1)
        RESPONSE_BODY=$(echo "$STATUS_RESPONSE" | head -n-1)
        
        if [ "$HTTP_CODE" -eq 200 ] 2>/dev/null; then
            echo -e "${GREEN}   ✅ Statut récupéré${NC}"
            echo "$RESPONSE_BODY" | python3 -m json.tool 2>/dev/null | sed 's/^/   /'
        else
            echo -e "${YELLOW}   ⚠️  Impossible de récupérer le statut (HTTP $HTTP_CODE)${NC}"
        fi
    fi
fi

echo ""
echo -e "${GREEN}🎉 Agent opérationnel !${NC}"
echo ""
echo -e "${BLUE}📚 Endpoints disponibles:${NC}"
echo -e "   • ${GREEN}GET${NC}  $BASE_URL/health  ${YELLOW}(health check)${NC}"
echo -e "   • ${GREEN}GET${NC}  $BASE_URL/status  ${YELLOW}(statut détaillé, API key required)${NC}"
echo -e "   • ${BLUE}POST${NC} $BASE_URL/chat    ${YELLOW}(conversation)${NC}"
echo -e "   • ${BLUE}POST${NC} $BASE_URL/upload  ${YELLOW}(upload doc, API key required)${NC}"
echo -e "   • ${BLUE}POST${NC} $BASE_URL/ingest  ${YELLOW}(indexation, API key required)${NC}"
echo ""
echo -e "${BLUE}📖 Documentation:${NC}"
echo -e "   • Swagger: $BASE_URL/docs"
echo -e "   • ReDoc:   $BASE_URL/redoc"
