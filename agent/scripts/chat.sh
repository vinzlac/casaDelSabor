#!/bin/bash
# Script pour tester le chatbot

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

PORT="${1:-8000}"
MESSAGE="${2}"

if [ -z "$MESSAGE" ]; then
    echo "Usage: $0 [port] <message>"
    exit 1
fi

cd "$AGENT_DIR"

# Échapper les guillemets dans le message pour JSON
ESCAPED_MESSAGE=$(echo "$MESSAGE" | sed 's/"/\\"/g')

curl -s -X POST "http://localhost:${PORT}/chat" \
    -H "Content-Type: application/json" \
    -d "{\"message\": \"${ESCAPED_MESSAGE}\"}" | uv run python -m json.tool --no-ensure-ascii
