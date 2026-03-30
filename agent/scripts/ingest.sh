#!/usr/bin/env bash
# Script pour indexer les documents dans Qdrant

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$AGENT_DIR/.." && pwd)"

PORT="${1:-8000}"

cd "$AGENT_DIR"

CURL_ARGS=(-sS -X POST "http://localhost:${PORT}/ingest" -H "Content-Type: application/json")

# API_KEY uniquement depuis .env.local (l'app ne lit pas .env)
if [ -f "$PROJECT_ROOT/.env.local" ] && grep -q "^API_KEY=" "$PROJECT_ROOT/.env.local" 2>/dev/null; then
  API_KEY="$(
    grep "^API_KEY=" "$PROJECT_ROOT/.env.local" | head -1 | cut -d '=' -f2- | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -d '"' | tr -d "'"
  )"
  CURL_ARGS+=(-H "X-API-Key: ${API_KEY}")
fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

set +e
HTTP_CODE="$(curl "${CURL_ARGS[@]}" -o "$TMP" -w "%{http_code}")"
CURL_EXIT=$?
set -e

if [[ "$CURL_EXIT" -ne 0 ]]; then
  echo "curl a échoué (code $CURL_EXIT). L'agent tourne-t-il sur http://localhost:${PORT} ? (cd agent && just dev)" >&2
  exit 1
fi

if [[ -z "$(cat "$TMP")" ]]; then
  echo "Réponse vide (HTTP ${HTTP_CODE:-?}). Vérifie le port et que l'agent est démarré." >&2
  exit 1
fi

if [[ "${HTTP_CODE}" =~ ^[45] ]]; then
  echo "HTTP ${HTTP_CODE}" >&2
fi

uv run python -m json.tool --no-ensure-ascii <"$TMP"
