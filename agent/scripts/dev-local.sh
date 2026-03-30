#!/bin/bash
# Script pour démarrer l'environnement de développement local

set -e

echo "🚀 Démarrage de l'environnement de développement local..."

# Déterminer le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$AGENT_DIR/.." && pwd)"

# Vérifier que Docker est en cours d'exécution
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker n'est pas en cours d'exécution"
    echo "💡 Démarrez Docker Desktop et réessayez"
    exit 1
fi

# Démarrer Qdrant
echo "📦 Démarrage de Qdrant..."
cd "$PROJECT_ROOT"
docker-compose -f docker-compose.yml up -d qdrant

# Attendre que Qdrant soit prêt
echo "⏳ Attente que Qdrant soit prêt..."
timeout=30
counter=0
while ! curl -s http://localhost:6333/health > /dev/null 2>&1; do
    if [ $counter -ge $timeout ]; then
        echo "❌ Timeout: Qdrant n'a pas démarré après ${timeout}s"
        echo "💡 Vérifiez les logs avec: docker-compose -f docker-compose.yml logs qdrant"
        exit 1
    fi
    sleep 1
    counter=$((counter + 1))
    echo -n "."
done
echo ""
echo "✅ Qdrant est prêt!"

# Vérifier si .env.local existe (racine du dépôt)
if [ ! -f "$PROJECT_ROOT/.env.local" ]; then
    echo "⚠️  .env.local n'existe pas"
    if [ -f "$PROJECT_ROOT/.env.local.example" ]; then
        echo "📝 Création de .env.local depuis .env.local.example..."
        cp "$PROJECT_ROOT/.env.local.example" "$PROJECT_ROOT/.env.local"
        echo "✅ Fichier .env.local créé"
        echo "💡 Modifiez $PROJECT_ROOT/.env.local avec vos clés (ex. LLM_API_KEY)"
    else
        echo "⚠️  .env.local.example n'existe pas non plus"
        echo "💡 Créez manuellement $PROJECT_ROOT/.env.local avec vos variables d'environnement"
    fi
else
    echo "✅ .env.local existe déjà"
fi

# Vérifier/installer les dépendances Python
echo "📦 Vérification des dépendances Python..."
cd "$AGENT_DIR"
if [ ! -d ".venv" ] && [ ! -f "uv.lock" ]; then
    echo "⚠️  Les dépendances ne semblent pas être installées"
    echo "💡 Installation des dépendances..."
    if command -v uv &> /dev/null; then
        uv sync
        echo "✅ Dépendances installées"
    else
        echo "⚠️  'uv' n'est pas installé. Installez les dépendances manuellement:"
        echo "   cd agent && uv sync"
    fi
else
    echo "✅ Dépendances déjà installées"
    # Vérifier si python-multipart est installé (requis pour /upload)
    if ! uv pip list 2>/dev/null | grep -q "python-multipart"; then
        echo "⚠️  python-multipart manquant, installation..."
        uv sync
    fi
fi

echo ""
echo "✅ Environnement prêt!"
echo ""
echo "📊 Qdrant Dashboard: http://localhost:6333/dashboard"
echo "🔧 Pour démarrer l'agent:"
echo "   cd agent"
echo "   just dev"
echo ""
echo "📚 Pour indexer les documents:"
echo "   cd agent"
echo "   just ingest"
echo ""
echo "💡 Note: Le fichier .env.local est chargé automatiquement par l'application."
echo "   Plus besoin d'exporter manuellement les variables d'environnement !"
echo ""
echo "🛑 Pour arrêter Qdrant:"
echo "   docker-compose -f docker-compose.yml down"
