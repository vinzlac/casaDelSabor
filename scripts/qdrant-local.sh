#!/usr/bin/env bash
# Qdrant local via docker-compose (racine du dépôt).
# Usage:
#   ./scripts/qdrant-local.sh [start [--clean|-c] | stop]
#   start           (défaut si aucun argument) — démarre, conserve le volume
#   start --clean   supprime le volume puis démarre (réindexation nécessaire)
#   stop            arrête les conteneurs, conserve le volume

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

usage() {
  cat <<'EOF'
Usage: scripts/qdrant-local.sh [start [--clean|-c] | stop]

  start           Démarre Qdrant (docker compose up -d), conserve les données du volume.
                  Comportement par défaut si aucun argument.
  start --clean   Comme start, mais supprime d’abord le volume Docker (base vide).
                  Alias : start -c

  stop            Arrête Qdrant (docker compose down), conserve le volume.

  -h, --help      Affiche cette aide.

Exécution : cd automatique vers la racine du dépôt (docker-compose.yml).
EOF
  exit "${1:-0}"
}

if [[ "${#}" -eq 0 ]]; then
  CMD=start
elif [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage 0
else
  CMD="$1"
  shift
fi

case "$CMD" in
  start)
    CLEAN=false
    if [[ "${1:-}" == "--clean" || "${1:-}" == "-c" ]]; then
      CLEAN=true
      shift
    fi
    if [[ -n "${1:-}" ]]; then
      echo "Argument inattendu après start : $1 (seuls --clean ou -c sont acceptés)." >&2
      usage 1
    fi
    if [[ "$CLEAN" == true ]]; then
      echo "[qdrant-local] Arrêt du conteneur et suppression du volume Docker (qdrant_storage)…"
      docker compose down -v
    fi
    echo "[qdrant-local] Démarrage de Qdrant (docker compose up -d)…"
    docker compose up -d
    echo "[qdrant-local] Qdrant API: http://localhost:6333"
    echo "[qdrant-local] Dans .env.local : QDRANT_URL=http://localhost:6333 (sans clé si local)"
    ;;
  stop)
    if [[ -n "${1:-}" ]]; then
      echo "La commande stop n'accepte pas d'arguments." >&2
      usage 1
    fi
    echo "[qdrant-local] Arrêt de Qdrant (docker compose down, volume conservé)…"
    docker compose down
    echo "[qdrant-local] Qdrant est arrêté. Pour relancer : ./scripts/qdrant-local.sh start"
    ;;
  help)
    usage 0
    ;;
  *)
    echo "Commande inconnue: $CMD" >&2
    usage 1
    ;;
esac
