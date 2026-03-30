#!/bin/bash
# Script pour vérifier le statut de l'agent

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$AGENT_DIR/.." && pwd)"

PORT="${1:-8000}"

cd "$AGENT_DIR"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Vérifier d'abord si Qdrant (Docker) tourne
echo -e "${YELLOW}📦 Vérification du container Qdrant...${NC}"
QDRANT_STATUS=$(docker ps --filter "name=casa-del-sabor-qdrant" --format "{{.Status}}" 2>/dev/null)

if [ -n "$QDRANT_STATUS" ]; then
    echo -e "${GREEN}✅ Container Qdrant en ligne${NC}"
    echo -e "${QDRANT_STATUS}"
else
    echo -e "${RED}❌ Container Qdrant hors ligne${NC}"
    echo ""
    echo -e "${YELLOW}💡 Pour démarrer Qdrant:${NC}"
    echo -e "   ${BLUE}docker-compose up -d qdrant${NC}"
fi
echo ""

# Vérifier d'abord si l'agent est en ligne
HEALTH_CHECK=$(curl -s -w "%{http_code}" "http://localhost:${PORT}/health" -o /dev/null)

if [ "$HEALTH_CHECK" != "200" ]; then
    echo -e "${RED}❌ Agent hors ligne${NC}"
    echo ""
    echo -e "${YELLOW}💡 Pour démarrer l'agent:${NC}"
    echo -e "   ${GREEN}just dev${NC}  (mode développement)"
    echo -e "   ${GREEN}just run${NC}  (mode production)"
    echo ""
    echo -e "${YELLOW}ℹ️  Utilisez 'just check' pour plus d'informations${NC}"
    exit 0
fi

echo -e "${GREEN}✅ Agent en ligne${NC}"
echo ""

if [ -f "$PROJECT_ROOT/.env.local" ] && grep -q "^API_KEY=" "$PROJECT_ROOT/.env.local" 2>/dev/null; then
    API_KEY=$(grep "^API_KEY=" "$PROJECT_ROOT/.env.local" | cut -d '=' -f2- | tr -d '"' | tr -d "'")
    RESPONSE=$(curl -s "http://localhost:${PORT}/status" -H "X-API-Key: $API_KEY")
else
    RESPONSE=$(curl -s "http://localhost:${PORT}/status")
fi

# Vérifier si la réponse est vide
if [ -z "$RESPONSE" ]; then
    echo -e "${RED}❌ Impossible de récupérer le statut${NC}"
    echo -e "${YELLOW}Vérifiez que l'API_KEY est correcte${NC}"
    exit 1
fi

# Afficher le JSON formaté
echo "$RESPONSE" | uv run python -m json.tool --no-ensure-ascii
