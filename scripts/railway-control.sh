#!/bin/bash
# Script pour contrôler le service Railway Casa del Sabor

SERVICE_NAME="casaDelSabor"
REGION="us-west1"  # Région par défaut (peut être modifiée)
MAX_RETRIES=3
RETRY_DELAY=5

# Couleurs pour les messages
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour exécuter une commande avec retries
execute_with_retry() {
    local cmd="$1"
    local description="$2"
    local retry_count=0
    
    while [ $retry_count -lt $MAX_RETRIES ]; do
        echo -e "${BLUE}🔄 Tentative $((retry_count + 1))/$MAX_RETRIES: ${description}${NC}"
        
        if eval "$cmd"; then
            return 0
        fi
        
        local exit_code=$?
        retry_count=$((retry_count + 1))
        
        if [ $retry_count -lt $MAX_RETRIES ]; then
            echo -e "${YELLOW}⏳ Attente ${RETRY_DELAY}s avant de réessayer...${NC}"
            sleep $RETRY_DELAY
        fi
    done
    
    return $exit_code
}

# Fonction d'aide
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commandes disponibles:"
    echo "  stop      Arrêter le service (mettre les instances à 0)"
    echo "  start     Démarrer le service (mettre les instances à 1)"
    echo "  status    Afficher le statut du service"
    echo "  restart   Redémarrer le service (stop puis start)"
    echo "  scale N   Mettre à l'échelle à N instances"
    echo ""
    echo "Exemples:"
    echo "  $0 stop"
    echo "  $0 start"
    echo "  $0 scale 2"
    echo ""
}

# Vérifier que railway CLI est installé
check_railway_cli() {
    if ! command -v railway &> /dev/null; then
        echo -e "${RED}❌ Railway CLI n'est pas installé.${NC}"
        echo "Installez-le avec: npm i -g @railway/cli"
        exit 1
    fi
    
    # Vérifier s'il y a une mise à jour disponible
    local current_version=$(railway --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [ -n "$current_version" ]; then
        echo -e "${BLUE}ℹ️  Railway CLI version: ${current_version}${NC}"
        echo -e "${YELLOW}💡 Si vous rencontrez des problèmes, mettez à jour avec: brew upgrade railway${NC}"
    fi
}

# Vérifier que le projet est lié
check_linked() {
    if ! railway status &> /dev/null; then
        echo -e "${YELLOW}⚠️  Le projet n'est pas lié.${NC}"
        echo "Exécutez: railway link"
        exit 1
    fi
}

# Arrêter le service
stop_service() {
    echo -e "${YELLOW}🛑 Arrêt du service ${SERVICE_NAME}...${NC}"
    echo -e "${YELLOW}⚠️  Note: La commande 'railway scale' a un bug connu.${NC}"
    echo -e "${YELLOW}    Utilisation de 'railway down' à la place...${NC}"
    
    if execute_with_retry "railway down -y" "Arrêt du service"; then
        echo -e "${GREEN}✅ Service arrêté (déploiement supprimé)${NC}"
        echo -e "${YELLOW}💡 Pour redémarrer, utilisez: $0 start${NC}"
    else
        echo -e "${RED}❌ Échec après ${MAX_RETRIES} tentatives${NC}"
        echo -e "${YELLOW}💡 Suggestions:${NC}"
        echo -e "   1. Vérifier votre connexion internet"
        echo -e "   2. Mettre à jour le CLI Railway: brew upgrade railway"
        echo -e "   3. Utiliser l'interface web: https://railway.app/"
        echo -e "   4. Réessayer plus tard"
        exit 1
    fi
}

# Démarrer le service
start_service() {
    echo -e "${YELLOW}🚀 Démarrage du service ${SERVICE_NAME}...${NC}"
    echo -e "${YELLOW}    Redéploiement du service...${NC}"
    
    if execute_with_retry "railway up" "Démarrage du service"; then
        echo -e "${GREEN}✅ Service démarré${NC}"
    else
        echo -e "${RED}❌ Échec après ${MAX_RETRIES} tentatives${NC}"
        echo -e "${YELLOW}💡 Suggestions:${NC}"
        echo -e "   1. Vérifier votre connexion internet"
        echo -e "   2. Mettre à jour le CLI Railway: brew upgrade railway"
        echo -e "   3. Utiliser l'interface web: https://railway.app/"
        echo -e "   4. Réessayer plus tard"
        exit 1
    fi
}

# Afficher le statut
show_status() {
    echo -e "${YELLOW}📊 Statut du service:${NC}"
    railway service status
    echo ""
    railway status
}

# Redémarrer le service
restart_service() {
    echo -e "${YELLOW}🔄 Redémarrage du service ${SERVICE_NAME}...${NC}"
    stop_service
    sleep 2
    start_service
    echo -e "${GREEN}✅ Service redémarré${NC}"
}

# Mettre à l'échelle
scale_service() {
    local instances=$1
    if [ -z "$instances" ]; then
        echo -e "${RED}❌ Nombre d'instances requis${NC}"
        echo "Usage: $0 scale N"
        exit 1
    fi
    
    echo -e "${YELLOW}📈 Mise à l'échelle à ${instances} instance(s)...${NC}"
    echo -e "${RED}⚠️  ATTENTION: La commande 'railway scale' a un bug connu dans le CLI v4.16.1${NC}"
    echo -e "${YELLOW}    Tentative avec la syntaxe standard...${NC}"
    
    # Essayer la commande scale (peut échouer à cause du bug)
    if railway scale --${REGION} ${instances} 2>/dev/null; then
        echo -e "${GREEN}✅ Service mis à l'échelle à ${instances} instance(s)${NC}"
    else
        echo -e "${RED}❌ Échec de la commande scale (bug connu)${NC}"
        echo -e "${YELLOW}💡 Alternatives:${NC}"
        echo -e "   1. Utiliser l'interface web Railway: https://railway.app/"
        echo -e "   2. Utiliser 'railway down' pour arrêter, puis 'railway up' pour redémarrer"
        exit 1
    fi
}

# Main
main() {
    check_railway_cli
    check_linked
    
    case "${1:-}" in
        stop)
            stop_service
            ;;
        start)
            start_service
            ;;
        status)
            show_status
            ;;
        restart)
            restart_service
            ;;
        scale)
            scale_service "$2"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}❌ Commande inconnue: ${1:-}${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"

