#!/bin/bash
# Wrapper pour qdrant_status.py avec option --env

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Fonction d'aide
show_help() {
    echo "Usage: $0 [ENV] [OPTIONS...]"
    echo ""
    echo "Environnements:"
    echo "  local  Utilise .env.local (défaut)"
    echo "  prod   Utilise .env"
    echo ""
    echo "Options supplémentaires (passées à qdrant_status.py):"
    echo "  --collections      Liste toutes les collections"
    echo "  --collection NAME  Détails d'une collection spécifique"
    echo "  --cluster          Statut du cluster"
    echo "  --all              Tout afficher"
    echo "  --json             Sortie au format JSON"
    echo ""
    echo "Exemples:"
    echo "  $0                           # Statut local (défaut)"
    echo "  $0 local --all                # Tout afficher depuis .env.local"
    echo "  $0 prod --collections         # Collections depuis .env"
    echo "  $0 prod --collection casa_del_sabor  # Détails depuis .env"
}

# Vérifier les arguments
if [ $# -eq 0 ]; then
    # Pas d'arguments, utiliser local par défaut
    ENV="local"
    OTHER_ARGS=""
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
elif [ "$1" = "local" ] || [ "$1" = "prod" ]; then
    # Premier argument est l'environnement
    ENV="$1"
    shift
    OTHER_ARGS="$@"
else
    # Pas d'environnement spécifié, utiliser local par défaut
    ENV="local"
    OTHER_ARGS="$@"
fi

# Appeler le script Python avec --env
cd "$AGENT_DIR"

# Utiliser uv run python si disponible, sinon python3, sinon python
if command -v uv &> /dev/null; then
    uv run python scripts/qdrant_status.py --env "$ENV" $OTHER_ARGS
elif command -v python3 &> /dev/null; then
    python3 scripts/qdrant_status.py --env "$ENV" $OTHER_ARGS
elif command -v python &> /dev/null; then
    python scripts/qdrant_status.py --env "$ENV" $OTHER_ARGS
else
    echo "❌ Erreur: python, python3 ou uv n'est pas installé"
    exit 1
fi
