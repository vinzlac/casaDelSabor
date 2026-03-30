#!/usr/bin/env bash
# Lance l’agent FastAPI en local avec rechargement à chaud.
# Les variables sont lues depuis .env.local à la racine du dépôt (via agent/settings.py) ;
# aucun export manuel ni source n’est nécessaire.
#
# Usage :
#   ./scripts/run-agent-local.sh           # port 8000
#   ./scripts/run-agent-local.sh 8080      # autre port
#
# Prérequis : être dans le dépôt ; uv + just ; dépendances : (cd agent && uv sync).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT/agent"

if [[ "${#}" -eq 0 ]]; then
  exec just dev
else
  exec just dev "$@"
fi
