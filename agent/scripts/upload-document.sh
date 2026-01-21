#!/bin/bash
# Script pour uploader et indexer un document via l'API
# Usage: ./upload-document.sh <fichier.md> <API_KEY> <env>
# env: local ou prod

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'aide
usage() {
    echo -e "${BLUE}Usage:${NC}"
    echo "  $0 <fichier.md> <API_KEY> <env>"
    echo ""
    echo -e "${BLUE}Arguments:${NC}"
    echo "  fichier.md  : Chemin vers le fichier markdown à uploader"
    echo "  API_KEY     : Clé API pour l'authentification"
    echo "  env         : Environnement (local ou prod)"
    echo ""
    echo -e "${BLUE}Exemples:${NC}"
    echo "  $0 ../storytelling.md ma-cle-api local"
    echo "  $0 /path/to/doc.md ma-cle-api prod"
    exit 1
}

# Vérification des arguments
if [ $# -ne 3 ]; then
    echo -e "${RED}❌ Erreur: 3 arguments requis${NC}"
    usage
fi

FILE_PATH="$1"
API_KEY="$2"
ENV="$3"

# Vérification que le fichier existe
if [ ! -f "$FILE_PATH" ]; then
    echo -e "${RED}❌ Erreur: Le fichier '$FILE_PATH' n'existe pas${NC}"
    exit 1
fi

# Vérification que c'est un fichier .md
if [[ ! "$FILE_PATH" =~ \.md$ ]]; then
    echo -e "${RED}❌ Erreur: Le fichier doit avoir l'extension .md${NC}"
    exit 1
fi

# Détermination de l'URL en fonction de l'environnement
case "$ENV" in
    local)
        BASE_URL="http://localhost:8000"
        echo -e "${BLUE}🏠 Environnement: Local${NC}"
        ;;
    prod)
        # URL Railway
        BASE_URL="https://casadelsabor.up.railway.app"
        echo -e "${BLUE}🚀 Environnement: Production${NC}"
        ;;
    *)
        echo -e "${RED}❌ Erreur: Environnement invalide. Utilisez 'local' ou 'prod'${NC}"
        usage
        ;;
esac

FILENAME=$(basename "$FILE_PATH")

echo -e "${YELLOW}📄 Fichier: $FILENAME${NC}"
echo -e "${YELLOW}🔑 API Key: ${API_KEY:0:8}...${NC}"
echo ""

# Étape 1: Upload du fichier
echo -e "${BLUE}⬆️  Étape 1/2: Upload du fichier...${NC}"

UPLOAD_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/upload" \
    -H "X-API-Key: $API_KEY" \
    -F "file=@$FILE_PATH")

HTTP_CODE=$(echo "$UPLOAD_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$UPLOAD_RESPONSE" | head -n-1)

if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✅ Upload réussi!${NC}"
    echo "$RESPONSE_BODY" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE_BODY"
else
    echo -e "${RED}❌ Échec de l'upload (HTTP $HTTP_CODE)${NC}"
    echo "$RESPONSE_BODY"
    exit 1
fi

echo ""

# Étape 2: Réindexation
echo -e "${BLUE}🔄 Étape 2/2: Réindexation de la collection...${NC}"

INGEST_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/ingest" \
    -H "X-API-Key: $API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"force_reindex": true}')

HTTP_CODE=$(echo "$INGEST_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$INGEST_RESPONSE" | head -n-1)

if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✅ Réindexation réussie!${NC}"
    echo "$RESPONSE_BODY" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE_BODY"
    echo ""
    echo -e "${GREEN}🎉 Document '$FILENAME' uploadé et indexé avec succès!${NC}"
else
    echo -e "${RED}❌ Échec de la réindexation (HTTP $HTTP_CODE)${NC}"
    echo "$RESPONSE_BODY"
    exit 1
fi
