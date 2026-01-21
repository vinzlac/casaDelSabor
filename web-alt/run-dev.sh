#!/bin/bash
# Script wrapper pour lancer Next.js depuis le bon répertoire
# Ce script garantit que Next.js utilise le répertoire web-alt comme répertoire de travail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Définir PWD explicitement pour forcer le répertoire de travail
export PWD="$SCRIPT_DIR"

# Lancer npm depuis le bon répertoire
exec npm run dev "$@"
