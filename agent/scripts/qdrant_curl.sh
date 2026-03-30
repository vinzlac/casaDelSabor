#!/bin/bash
# Script pour vérifier le statut de Qdrant via l'API REST (curl)

# Déterminer le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$AGENT_DIR/.." && pwd)"

# Variables depuis .env.local uniquement (aligné sur l’agent)
if [ -f "$PROJECT_ROOT/.env.local" ]; then
    # shellcheck disable=SC2046
    export $(grep -v '^#' "$PROJECT_ROOT/.env.local" | grep -v '^$' | xargs)
fi

if [ -z "$QDRANT_URL" ]; then
    echo "❌ Erreur: QDRANT_URL doit être défini (export ou .env.local)"
    exit 1
fi

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Fonction pour faire une requête API
api_request() {
    local endpoint=$1
    local method=${2:-GET}
    
    curl -s -X "$method" \
        -H "api-key: $QDRANT_API_KEY" \
        "${QDRANT_URL}${endpoint}" \
        -H "Content-Type: application/json"
}

# Fonction pour formater JSON
format_json() {
    if command -v jq &> /dev/null; then
        jq .
    else
        python3 -m json.tool 2>/dev/null || cat
    fi
}

# Afficher le statut de base
show_status() {
    echo -e "${BLUE}📊 Statut du cluster Qdrant${NC}\n"
    
    # Vérifier la connexion
    echo -e "${YELLOW}🔌 Test de connexion...${NC}"
    response=$(api_request "/collections" 2>&1)
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Connexion réussie${NC}"
        echo -e "   URL: ${QDRANT_URL}\n"
    else
        echo -e "${RED}❌ Échec de la connexion${NC}"
        exit 1
    fi
    
    # Lister les collections
    echo -e "${YELLOW}📚 Collections:${NC}"
    collections=$(api_request "/collections")
    echo "$collections" | format_json
    
    # Si une collection spécifique est demandée
    if [ -n "$1" ]; then
        echo -e "\n${YELLOW}📦 Détails de la collection '$1':${NC}"
        collection_info=$(api_request "/collections/$1")
        echo "$collection_info" | format_json
    fi
}

# Afficher l'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  [collection_name]    Afficher les détails d'une collection"
    echo "  --collections        Lister toutes les collections"
    echo "  --cluster           Afficher le statut du cluster"
    echo "  --help              Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0                           # Statut de base"
    echo "  $0 casa_del_sabor            # Détails d'une collection"
    echo "  $0 --collections              # Liste des collections"
    echo "  $0 --cluster                 # Statut du cluster"
}

# Main
case "${1:-}" in
    --help|-h)
        show_help
        ;;
    --collections)
        echo -e "${BLUE}📚 Collections disponibles:${NC}\n"
        api_request "/collections" | format_json
        ;;
    --cluster)
        echo -e "${BLUE}📊 Statut du cluster:${NC}\n"
        api_request "/cluster" | format_json
        ;;
    "")
        show_status
        ;;
    *)
        show_status "$1"
        ;;
esac
