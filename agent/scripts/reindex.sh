#!/bin/bash
# Script pour forcer la réindexation des documents

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

PORT="${1:-8000}"

cd "$AGENT_DIR"

# Déterminer le fichier .env à utiliser
if [ -f .env.local ] && grep -q "^API_KEY=" .env.local 2>/dev/null; then
    API_KEY=$(grep "^API_KEY=" .env.local | cut -d '=' -f2- | tr -d '"' | tr -d "'")
    curl -s -X POST "http://localhost:${PORT}/ingest" \
        -H "X-API-Key: $API_KEY" \
        -H "Content-Type: application/json" \
        -d '{"force_reindex": true}' | uv run python -m json.tool --no-ensure-ascii
elif [ -f .env ] && grep -q "^API_KEY=" .env 2>/dev/null; then
    API_KEY=$(grep "^API_KEY=" .env | cut -d '=' -f2- | tr -d '"' | tr -d "'")
    curl -s -X POST "http://localhost:${PORT}/ingest" \
        -H "X-API-Key: $API_KEY" \
        -H "Content-Type: application/json" \
        -d '{"force_reindex": true}' | uv run python -m json.tool --no-ensure-ascii
else
    curl -s -X POST "http://localhost:${PORT}/ingest" \
        -H "Content-Type: application/json" \
        -d '{"force_reindex": true}' | uv run python -m json.tool --no-ensure-ascii
fi
