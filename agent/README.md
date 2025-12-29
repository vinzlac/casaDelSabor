# Agent RAG - Casa del Sabor

Agent conversationnel RAG (Retrieval-Augmented Generation) pour le restaurant Casa del Sabor.

## 🏗️ Architecture

- **LLM** : Mistral AI (mistral-small-latest)
- **Embeddings** : Mistral Embeddings (mistral-embed)
- **Vector Store** : Qdrant Cloud
- **Framework** : LangChain + FastAPI

## 📋 Prérequis

- Python 3.11+
- [uv](https://docs.astral.sh/uv/) (gestionnaire de paquets rapide)
- [just](https://github.com/casey/just) (command runner)
- Compte [Mistral AI](https://console.mistral.ai/) (clé API gratuite)
- Compte [Qdrant Cloud](https://cloud.qdrant.io/) (gratuit jusqu'à 1GB)

## 🚀 Installation

### 1. Installer uv et just (si pas déjà installés)

```bash
# uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# just (macOS)
brew install just

# just (Linux)
cargo install just
```

### 2. Installer les dépendances

```bash
cd agent
just install
```

### 3. Configurer les variables d'environnement

```bash
cp .env.example .env
```

Puis éditer `.env` avec vos clés API :

```env
MISTRAL_API_KEY=votre_cle_mistral
QDRANT_URL=https://votre-cluster.qdrant.io
QDRANT_API_KEY=votre_cle_qdrant
```

## 🎯 Utilisation

### Commandes disponibles

```bash
just            # Affiche toutes les commandes disponibles
just install    # Installe les dépendances
just dev        # Lance en mode développement (avec hot reload)
just run        # Lance en mode production
just ingest     # Indexe les documents
just reindex    # Force la réindexation
just status     # Vérifie le statut
just chat "Quels sont vos horaires ?"  # Test une question
```

### Démarrer le serveur

```bash
just dev
# ou pour la production
just run
```

Le serveur démarre sur `http://localhost:8000`.

### Endpoints disponibles

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/health` | GET | Health check |
| `/status` | GET | Statut détaillé de l'agent |
| `/ingest` | POST | Indexer les documents dans Qdrant |
| `/chat` | POST | Poser une question au chatbot |

### Indexer les documents

```bash
curl -X POST http://localhost:8000/ingest
```

Pour forcer une réindexation :

```bash
curl -X POST http://localhost:8000/ingest \
  -H "Content-Type: application/json" \
  -d '{"force_reindex": true}'
```

### Poser une question

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Quels sont vos horaires ?"}'
```

## 📁 Structure

```
agent/
├── main.py              # Application FastAPI
├── config.py            # Configuration (variables d'env)
├── pyproject.toml       # Configuration uv et dépendances
├── justfile            # Commandes just (task runner)
├── rag/
│   ├── __init__.py
│   ├── chain.py         # RAG Chain + Agent LangChain
│   ├── tools.py         # Outils (réservation, etc.)
│   ├── memory.py        # Gestion de la mémoire de session
│   ├── embeddings.py    # Mistral Embeddings
│   ├── vectorstore.py   # Client Qdrant
│   └── ingestion.py     # Chargement et indexation documents
├── documents/           # Documents du restaurant
│   ├── menu.md
│   ├── horaires.md
│   └── info.md
└── scripts/
    └── conversation.py  # Script de conversation interactive
```

## 🔧 Configuration

Variables d'environnement disponibles :

| Variable | Description | Défaut |
|----------|-------------|--------|
| `MISTRAL_API_KEY` | Clé API Mistral | (requis) |
| `MISTRAL_MODEL` | Modèle LLM | `mistral-small-latest` |
| `MISTRAL_EMBEDDING_MODEL` | Modèle embeddings | `mistral-embed` |
| `QDRANT_URL` | URL Qdrant Cloud | (requis) |
| `QDRANT_API_KEY` | Clé API Qdrant | (requis) |
| `QDRANT_COLLECTION_NAME` | Nom de la collection | `casa_del_sabor` |
| `AGENT_HOST` | Host du serveur | `0.0.0.0` |
| `AGENT_PORT` | Port du serveur | `8000` |
| `CHUNK_SIZE` | Taille des chunks | `500` |
| `CHUNK_OVERLAP` | Overlap des chunks | `50` |
| `TOP_K_RESULTS` | Nombre de résultats RAG | `4` |

## 🚢 Déploiement

### Railway (recommandé)

1. Créer un projet sur [Railway](https://railway.app/)
2. Connecter le repo GitHub
3. Configurer le root directory : `/agent`
4. Ajouter les variables d'environnement :
   - `MISTRAL_API_KEY`
   - `QDRANT_URL`
   - `QDRANT_API_KEY`
5. Configurer la commande de démarrage : `uv run uvicorn main:app --host 0.0.0.0 --port $PORT`

Railway détectera automatiquement Python via `pyproject.toml`.

### Autres plateformes

Le serveur peut être déployé sur n'importe quelle plateforme supportant Python :
- Heroku
- Render
- Fly.io
- AWS/GCP/Azure

Commande de démarrage :
```bash
uv run uvicorn main:app --host 0.0.0.0 --port $PORT
```

## 🔗 Intégration avec les clients

L'agent expose une API REST accessible par :
- **Web App** : Via l'API Route Next.js (`/api/chat`)
- **Mobile App** : Directement via HTTP POST vers `/chat`

Les deux clients utilisent le même endpoint `/chat` avec le format :
```json
{
  "message": "Votre question",
  "session_id": "optional-session-id"
}
```

## 📝 Ajouter des documents

Pour ajouter de nouvelles informations au chatbot :

1. Créer/modifier un fichier `.md` dans `documents/`
2. Appeler l'endpoint `/ingest` avec `force_reindex: true`

Les documents sont automatiquement découpés et indexés dans Qdrant.
