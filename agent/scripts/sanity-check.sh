#!/usr/bin/env bash
# Sanity checks HTTP pour l'agent Casa del Sabor (local ou distant).
#
# Usage:
#   ./scripts/sanity-check.sh                         # --env local (defaut) -> lit ../.env.local
#   ./scripts/sanity-check.sh --env prod             # lit ../.env
#   ./scripts/sanity-check.sh --base-url http://casadelsabor.homelab
#   ./scripts/sanity-check.sh --base-url http://casadelsabor.homelab --api-key "xxx"
#   ./scripts/sanity-check.sh --skip-chat
#
# Notes:
# - Sans --api-key, /status est attendu en 401 (comportement normal si API_KEY active).
# - Avec --api-key, /status doit répondre 200.
# - Le script est en lecture seule (pas d'appel /ingest).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$AGENT_DIR/.." && pwd)"

ENV_TARGET="local"
ENV_FILE=""
BASE_URL=""
API_KEY=""
SKIP_CHAT=false
CHAT_MESSAGE="Ping sanity check: réponds en une phrase."
BASE_URL_CLI=false
API_KEY_CLI=false

usage() {
  cat <<'EOF'
Usage: scripts/sanity-check.sh [options]

Options:
  --env ENV          local|prod (defaut: local)
  --env-file PATH    Fichier env explicite (override --env)
  --base-url URL     URL de base de l'API (prioritaire sur variables d'env)
  --api-key KEY      API key pour /status (header X-API-Key)
  --skip-chat        Ne pas tester /chat
  --chat-message TXT Message de test pour /chat
  -h, --help         Affiche cette aide
EOF
}

load_env_file() {
  local file_path="$1"
  [[ -f "$file_path" ]] || return 0

  # Charge uniquement les paires KEY=VALUE simples.
  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] || continue
    local key="${line%%=*}"
    local val="${line#*=}"
    val="${val%\"}"
    val="${val#\"}"
    val="${val%\'}"
    val="${val#\'}"
    export "$key=$val"
  done < "$file_path"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      ENV_TARGET="${2:-}"
      shift 2
      ;;
    --env-file)
      ENV_FILE="${2:-}"
      shift 2
      ;;
    --base-url)
      BASE_URL="${2:-}"
      BASE_URL_CLI=true
      shift 2
      ;;
    --api-key)
      API_KEY="${2:-}"
      API_KEY_CLI=true
      shift 2
      ;;
    --skip-chat)
      SKIP_CHAT=true
      shift 1
      ;;
    --chat-message)
      CHAT_MESSAGE="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Argument inconnu: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$ENV_FILE" ]]; then
  case "$ENV_TARGET" in
    local) ENV_FILE="$PROJECT_ROOT/.env.local" ;;
    prod) ENV_FILE="$PROJECT_ROOT/.env" ;;
    *)
      echo "Valeur invalide pour --env: $ENV_TARGET (attendu: local|prod)" >&2
      exit 1
      ;;
  esac
fi

load_env_file "$ENV_FILE"

# Priorités: CLI > SANITY_* > variables historiques > defaults.
if [[ "$BASE_URL_CLI" == false ]]; then
  BASE_URL="${SANITY_BASE_URL:-${BASE_URL:-http://localhost:8000}}"
fi
if [[ "$API_KEY_CLI" == false ]]; then
  API_KEY="${SANITY_API_KEY:-${API_KEY:-}}"
fi

BASE_URL="${BASE_URL%/}"

PASS_COUNT=0
FAIL_COUNT=0

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf "✅ %s\n" "$1"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf "❌ %s\n" "$1"
}

request() {
  # $1 method, $2 path, $3 outfile, $4 optional json payload
  local method="$1"
  local path="$2"
  local outfile="$3"
  local payload="${4:-}"

  local url="${BASE_URL}${path}"
  local -a args=(-sS -X "$method" "$url" -o "$outfile" -w "%{http_code}")
  local -a headers=(-H "Content-Type: application/json")

  if [[ -n "$API_KEY" ]]; then
    headers+=(-H "X-API-Key: $API_KEY")
  fi

  if [[ -n "$payload" ]]; then
    args+=("${headers[@]}" -d "$payload")
  else
    args+=("${headers[@]}")
  fi

  curl "${args[@]}"
}

echo "🔎 Sanity checks sur ${BASE_URL}"
echo "   Environnement: ${ENV_TARGET}"
if [[ -f "$ENV_FILE" ]]; then
  echo "   Fichier env: ${ENV_FILE}"
else
  echo "   Fichier env: (absent) ${ENV_FILE}"
fi
echo

TMP_HEALTH="$(mktemp)"
TMP_DOCS="$(mktemp)"
TMP_STATUS="$(mktemp)"
TMP_CHAT="$(mktemp)"
trap 'rm -f "$TMP_HEALTH" "$TMP_DOCS" "$TMP_STATUS" "$TMP_CHAT"' EXIT

# 1) /health
HTTP_CODE="$(request GET "/health" "$TMP_HEALTH")" || HTTP_CODE="000"
if [[ "$HTTP_CODE" == "200" ]]; then
  pass "GET /health -> 200"
else
  fail "GET /health -> ${HTTP_CODE}"
fi

# 2) /docs
HTTP_CODE="$(request GET "/docs" "$TMP_DOCS")" || HTTP_CODE="000"
if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "301" || "$HTTP_CODE" == "302" ]]; then
  pass "GET /docs -> ${HTTP_CODE}"
else
  fail "GET /docs -> ${HTTP_CODE}"
fi

# 3) /status
HTTP_CODE="$(request GET "/status" "$TMP_STATUS")" || HTTP_CODE="000"
if [[ -n "$API_KEY" ]]; then
  if [[ "$HTTP_CODE" == "200" ]]; then
    if rg -q "doesn't exist|Not found: Collection" "$TMP_STATUS"; then
      fail "GET /status -> 200 mais collection Qdrant absente (ingest a lancer)"
    else
      pass "GET /status -> 200"
    fi
  else
    fail "GET /status avec API key -> ${HTTP_CODE}"
  fi
else
  if [[ "$HTTP_CODE" == "401" ]]; then
    pass "GET /status sans API key -> 401 (attendu)"
  else
    fail "GET /status sans API key -> ${HTTP_CODE} (401 attendu)"
  fi
fi

# 4) /chat
if [[ "$SKIP_CHAT" == false ]]; then
  CHAT_PAYLOAD="$(CHAT_MESSAGE="$CHAT_MESSAGE" python3 - <<'PY'
import json
import os
print(json.dumps({"message": os.environ["CHAT_MESSAGE"]}))
PY
)"
  HTTP_CODE="$(request POST "/chat" "$TMP_CHAT" "$CHAT_PAYLOAD")" || HTTP_CODE="000"
  if [[ "$HTTP_CODE" == "200" ]]; then
    if rg -q "\"response\"" "$TMP_CHAT"; then
      pass "POST /chat -> 200"
    else
      fail "POST /chat -> 200 mais champ response absent"
    fi
  else
    fail "POST /chat -> ${HTTP_CODE}"
  fi
fi

echo
echo "Résultat: ${PASS_COUNT} OK / ${FAIL_COUNT} KO"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo
  echo "Détails (/health):"
  sed -n '1,80p' "$TMP_HEALTH"
  echo
  echo "Détails (/status):"
  sed -n '1,120p' "$TMP_STATUS"
  if [[ "$SKIP_CHAT" == false ]]; then
    echo
    echo "Détails (/chat):"
    sed -n '1,160p' "$TMP_CHAT"
  fi
  exit 1
fi

exit 0
