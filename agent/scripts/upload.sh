#!/bin/bash
# Wrapper pour upload-document.sh qui lit automatiquement la clé API
# Usage: ./upload.sh <fichier.md> <env>
# env: local ou prod

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Couleurs
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Fonction d'aide
usage() {
    echo "Usage: $0 <fichier.md> <env>"
    echo ""
    echo "Arguments:"
    echo "  fichier.md  : Chemin vers le fichier markdown à uploader"
    echo "  env         : Environnement (local ou prod)"
    echo ""
    echo "Exemples:"
    echo "  $0 ../storytelling.md local"
    echo "  $0 /path/to/doc.md prod"
    echo ""
    echo "Note: La clé API sera lue depuis .env.local ou .env"
    exit 1
}

# Vérification des arguments
if [ $# -ne 2 ]; then
    echo -e "${RED}❌ Erreur: 2 arguments requis${NC}"
    usage
fi

FILE_PATH="$1"
ENV="$2"

# Chercher la clé API
cd "$AGENT_DIR"

if [ -f .env.local ] && grep -q "^API_KEY=" .env.local 2>/dev/null; then
    API_KEY=$(grep "^API_KEY=" .env.local | cut -d '=' -f2- | tr -d '"' | tr -d "'")
    echo -e "${YELLOW}🔑 Clé API trouvée dans .env.local${NC}"
elif [ -f .env ] && grep -q "^API_KEY=" .env 2>/dev/null; then
    API_KEY=$(grep "^API_KEY=" .env | cut -d '=' -f2- | tr -d '"' | tr -d "'")
    echo -e "${YELLOW}🔑 Clé API trouvée dans .env${NC}"
else
    echo -e "${RED}❌ Erreur: API_KEY non trouvée dans .env.local ou .env${NC}"
    echo "Ajoutez API_KEY=votre-cle dans l'un de ces fichiers"
    exit 1
fi

# Appeler le script principal
"$SCRIPT_DIR/upload-document.sh" "$FILE_PATH" "$API_KEY" "$ENV"
