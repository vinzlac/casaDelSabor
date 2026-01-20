#!/bin/bash
# Script pour vérifier le statut du frontend Next.js

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration par défaut
FRONTEND_URL="${FRONTEND_URL:-http://localhost:3000}"
FRONTEND_PORT="${FRONTEND_PORT:-3000}"

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
    echo "  --health      Vérifier uniquement si le frontend répond"
    echo "  --api         Tester la connexion à l'API route /api/chat"
    echo "  --env         Afficher la configuration des variables d'environnement"
    echo "  --logs        Afficher les dernières lignes des logs"
    echo "  --url URL     Utiliser une URL différente (défaut: $FRONTEND_URL)"
    echo "  --help, -h    Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0                    # Vérification complète"
    echo "  $0 --health           # Health check uniquement"
    echo "  $0 --api              # Tester l'API route"
    echo "  $0 --url http://localhost:3001  # URL personnalisée"
}

# Vérifier si le frontend répond
check_health() {
    echo -e "${BLUE}🏥 Health Check${NC}\n"
    
    response=$(curl -s -w "\n%{http_code}" "$FRONTEND_URL" 2>&1)
    http_code=$(echo "$response" | tail -n1)
    
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✅ Frontend est en ligne${NC}"
        echo "   URL: $FRONTEND_URL"
        echo "   Code HTTP: $http_code"
        return 0
    else
        echo -e "${RED}❌ Frontend n'est pas accessible${NC}"
        echo "   Code HTTP: $http_code"
        return 1
    fi
}

# Tester l'API route
test_api() {
    echo -e "${BLUE}🔌 Test de l'API route /api/chat${NC}\n"
    
    # Vérifier que AGENT_URL est configurée
    ENV_FILE="$WEB_DIR/.env.local"
    if [ ! -f "$ENV_FILE" ]; then
        ENV_FILE="$WEB_DIR/.env"
    fi
    
    AGENT_URL=""
    if [ -f "$ENV_FILE" ] && grep -q "^AGENT_URL=" "$ENV_FILE" 2>/dev/null; then
        AGENT_URL=$(grep "^AGENT_URL=" "$ENV_FILE" | cut -d '=' -f2- | tr -d '"' | tr -d "'")
    fi
    
    if [ -z "$AGENT_URL" ]; then
        echo -e "${YELLOW}ℹ️  AGENT_URL non configurée dans $ENV_FILE${NC}"
        echo "   Utilisation de la valeur par défaut: http://localhost:8000"
        AGENT_URL="http://localhost:8000"
    else
        echo "   AGENT_URL configurée: $AGENT_URL"
    fi
    
    # Tester l'API route
    echo ""
    echo "   Test de connexion à l'agent..."
    response=$(curl -s -w "\n%{http_code}" \
        -X POST "$FRONTEND_URL/api/chat" \
        -H "Content-Type: application/json" \
        -d '{"message": "test"}' 2>&1)
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}   ✅ API route fonctionne${NC}"
        # Extraire juste un aperçu de la réponse
        if command -v jq &> /dev/null; then
            echo "$body" | jq -r '.response // .error // "Réponse reçue"' | head -c 100
            echo "..."
        fi
        return 0
    else
        echo -e "${YELLOW}   ⚠️  API route a retourné le code: $http_code${NC}"
        if [ -n "$body" ]; then
            echo "   Réponse: $(echo "$body" | head -c 200)"
        fi
        echo ""
        echo "   💡 Cela peut être normal si l'agent n'est pas démarré"
        return 1
    fi
}

# Afficher la configuration
show_env() {
    echo -e "${BLUE}⚙️  Configuration${NC}\n"
    
    ENV_FILE="$WEB_DIR/.env.local"
    if [ ! -f "$ENV_FILE" ]; then
        ENV_FILE="$WEB_DIR/.env"
    fi
    
    if [ -f "$ENV_FILE" ]; then
        echo "Fichier: $ENV_FILE"
        echo ""
        if grep -q "^AGENT_URL=" "$ENV_FILE" 2>/dev/null; then
            AGENT_URL=$(grep "^AGENT_URL=" "$ENV_FILE" | cut -d '=' -f2- | tr -d '"' | tr -d "'")
            echo "AGENT_URL: $AGENT_URL"
        else
            echo "AGENT_URL: (non définie, utilise http://localhost:8000 par défaut)"
        fi
    else
        echo -e "${YELLOW}⚠️  Aucun fichier .env.local ou .env trouvé${NC}"
        echo "   Utilisation des valeurs par défaut"
        echo ""
        echo "AGENT_URL: http://localhost:8000 (défaut)"
    fi
}

# Afficher les logs
show_logs() {
    LOG_FILE="/tmp/casa-del-sabor-web.log"
    echo -e "${BLUE}📝 Dernières lignes des logs${NC}\n"
    
    if [ -f "$LOG_FILE" ]; then
        tail -n 20 "$LOG_FILE"
    else
        echo -e "${YELLOW}⚠️  Fichier de log non trouvé: $LOG_FILE${NC}"
        echo "   Le frontend n'a peut-être pas été démarré via start-dev.sh"
    fi
}

# Vérifier si le processus est en cours d'exécution
check_process() {
    PID_FILE="/tmp/casa-del-sabor-web.pid"
    
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Processus Next.js en cours d'exécution (PID: $PID)${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠️  Fichier PID trouvé mais processus non actif${NC}"
            rm -f "$PID_FILE"
            return 1
        fi
    else
        echo -e "${YELLOW}ℹ️  Aucun fichier PID trouvé${NC}"
        echo "   Le frontend peut être lancé manuellement (pas via start-dev.sh)"
        return 0
    fi
}

# Main
main() {
    # Parser les arguments
    SHOW_HEALTH=false
    SHOW_API=false
    SHOW_ENV=false
    SHOW_LOGS=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --health)
                SHOW_HEALTH=true
                shift
                ;;
            --api)
                SHOW_API=true
                shift
                ;;
            --env)
                SHOW_ENV=true
                shift
                ;;
            --logs)
                SHOW_LOGS=true
                shift
                ;;
            --url)
                FRONTEND_URL="$2"
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
    if [ "$SHOW_HEALTH" = false ] && [ "$SHOW_API" = false ] && \
       [ "$SHOW_ENV" = false ] && [ "$SHOW_LOGS" = false ]; then
        SHOW_HEALTH=true
        SHOW_API=true
        SHOW_ENV=true
    fi
    
    echo -e "${BLUE}🔍 Vérification du statut du frontend${NC}\n"
    echo "URL: $FRONTEND_URL"
    echo ""
    
    # Vérifier le processus
    check_process
    echo ""
    
    # Health check
    if [ "$SHOW_HEALTH" = true ]; then
        if ! check_health; then
            echo ""
            echo -e "${RED}❌ Le frontend n'est pas accessible${NC}"
            echo "   💡 Vérifiez que le frontend est bien démarré:"
            echo "      cd web && npm run dev"
            exit 1
        fi
        echo ""
    fi
    
    # Configuration
    if [ "$SHOW_ENV" = true ]; then
        show_env
        echo ""
    fi
    
    # Test API
    if [ "$SHOW_API" = true ]; then
        test_api
        echo ""
    fi
    
    # Logs
    if [ "$SHOW_LOGS" = true ]; then
        show_logs
        echo ""
    fi
}

main "$@"
