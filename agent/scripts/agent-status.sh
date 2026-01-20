#!/bin/bash
# Script pour vérifier le statut de l'agent Python FastAPI

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration par défaut
AGENT_URL="${AGENT_URL:-http://localhost:8000}"
AGENT_PORT="${AGENT_PORT:-8000}"

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --health      Vérifier uniquement le health check"
    echo "  --status       Vérifier le statut détaillé (nécessite API_KEY)"
    echo "  --endpoints    Lister tous les endpoints disponibles"
    echo "  --logs         Afficher les dernières lignes des logs"
    echo "  --url URL      Utiliser une URL différente (défaut: $AGENT_URL)"
    echo "  --help, -h     Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0                    # Vérification complète"
    echo "  $0 --health           # Health check uniquement"
    echo "  $0 --status           # Statut détaillé"
    echo "  $0 --url http://localhost:8001  # URL personnalisée"
}

# Fonction pour formater JSON
format_json() {
    if command -v jq &> /dev/null; then
        jq .
    elif command -v python3 &> /dev/null; then
        python3 -m json.tool 2>/dev/null || cat
    elif command -v python &> /dev/null; then
        python -m json.tool 2>/dev/null || cat
    else
        cat
    fi
}

# Vérifier le health check
check_health() {
    echo -e "${BLUE}🏥 Health Check${NC}\n"
    
    response=$(curl -s -w "\n%{http_code}" "$AGENT_URL/health" 2>&1)
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✅ Agent est en ligne${NC}"
        echo ""
        echo "$body" | format_json
        return 0
    else
        echo -e "${RED}❌ Agent n'est pas accessible${NC}"
        echo "   Code HTTP: $http_code"
        if [ -n "$body" ]; then
            echo "   Réponse: $body"
        fi
        return 1
    fi
}

# Vérifier le statut détaillé
check_status() {
    echo -e "${BLUE}📊 Statut détaillé${NC}\n"
    
    # Charger l'API_KEY si disponible
    ENV_FILE="$AGENT_DIR/.env.local"
    if [ ! -f "$ENV_FILE" ]; then
        ENV_FILE="$AGENT_DIR/.env"
    fi
    
    API_KEY=""
    if [ -f "$ENV_FILE" ] && grep -q "^API_KEY=" "$ENV_FILE" 2>/dev/null; then
        API_KEY=$(grep "^API_KEY=" "$ENV_FILE" | cut -d '=' -f2- | tr -d '"' | tr -d "'")
    fi
    
    if [ -z "$API_KEY" ]; then
        echo -e "${YELLOW}⚠️  API_KEY non trouvée dans $ENV_FILE${NC}"
        echo "   Le endpoint /status nécessite une API_KEY"
        echo "   Utilisez --health pour une vérification basique"
        return 1
    fi
    
    response=$(curl -s -w "\n%{http_code}" \
        -H "X-API-Key: $API_KEY" \
        "$AGENT_URL/status" 2>&1)
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        echo "$body" | format_json
        return 0
    else
        echo -e "${RED}❌ Erreur lors de la récupération du statut${NC}"
        echo "   Code HTTP: $http_code"
        if [ "$http_code" = "401" ] || [ "$http_code" = "403" ]; then
            echo "   💡 Vérifiez que votre API_KEY est correcte"
        fi
        if [ -n "$body" ]; then
            echo "   Réponse: $body"
        fi
        return 1
    fi
}

# Lister les endpoints
list_endpoints() {
    echo -e "${BLUE}📋 Endpoints disponibles${NC}\n"
    echo "GET  $AGENT_URL/health          - Health check (public)"
    echo "GET  $AGENT_URL/status          - Statut détaillé (API_KEY requis)"
    echo "POST $AGENT_URL/chat            - Poser une question (public)"
    echo "POST $AGENT_URL/ingest          - Indexer les documents (API_KEY requis)"
    echo "POST $AGENT_URL/upload          - Uploader un document (API_KEY requis)"
    echo ""
    echo "📚 Documentation: http://localhost:$AGENT_PORT/docs"
}

# Afficher les logs
show_logs() {
    LOG_FILE="/tmp/casa-del-sabor-agent.log"
    echo -e "${BLUE}📝 Dernières lignes des logs${NC}\n"
    
    if [ -f "$LOG_FILE" ]; then
        tail -n 20 "$LOG_FILE"
    else
        echo -e "${YELLOW}⚠️  Fichier de log non trouvé: $LOG_FILE${NC}"
        echo "   L'agent n'a peut-être pas été démarré via start-dev.sh"
    fi
}

# Vérifier si le processus est en cours d'exécution
check_process() {
    PID_FILE="/tmp/casa-del-sabor-agent.pid"
    
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Processus agent en cours d'exécution (PID: $PID)${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠️  Fichier PID trouvé mais processus non actif${NC}"
            rm -f "$PID_FILE"
            return 1
        fi
    else
        echo -e "${YELLOW}ℹ️  Aucun fichier PID trouvé${NC}"
        echo "   L'agent peut être lancé manuellement (pas via start-dev.sh)"
        return 0
    fi
}

# Main
main() {
    # Parser les arguments
    SHOW_HEALTH=false
    SHOW_STATUS=false
    SHOW_ENDPOINTS=false
    SHOW_LOGS=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --health)
                SHOW_HEALTH=true
                shift
                ;;
            --status)
                SHOW_STATUS=true
                shift
                ;;
            --endpoints)
                SHOW_ENDPOINTS=true
                shift
                ;;
            --logs)
                SHOW_LOGS=true
                shift
                ;;
            --url)
                AGENT_URL="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Option inconnue: $1${NC}"
                echo ""
                show_help
                exit 1
                ;;
        esac
    done
    
    # Si aucune option spécifique, tout afficher
    if [ "$SHOW_HEALTH" = false ] && [ "$SHOW_STATUS" = false ] && \
       [ "$SHOW_ENDPOINTS" = false ] && [ "$SHOW_LOGS" = false ]; then
        SHOW_HEALTH=true
        SHOW_STATUS=true
        SHOW_ENDPOINTS=true
    fi
    
    echo -e "${BLUE}🔍 Vérification du statut de l'agent${NC}\n"
    echo "URL: $AGENT_URL"
    echo ""
    
    # Vérifier le processus
    check_process
    echo ""
    
    # Health check
    if [ "$SHOW_HEALTH" = true ]; then
        if ! check_health; then
            echo ""
            echo -e "${RED}❌ L'agent n'est pas accessible${NC}"
            echo "   💡 Vérifiez que l'agent est bien démarré:"
            echo "      cd agent && just dev"
            exit 1
        fi
        echo ""
    fi
    
    # Statut détaillé
    if [ "$SHOW_STATUS" = true ]; then
        check_status
        echo ""
    fi
    
    # Endpoints
    if [ "$SHOW_ENDPOINTS" = true ]; then
        list_endpoints
        echo ""
    fi
    
    # Logs
    if [ "$SHOW_LOGS" = true ]; then
        show_logs
        echo ""
    fi
}

main "$@"
