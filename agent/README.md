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

**Pour la production (Qdrant Cloud) :**
```bash
cp .env.example .env
```

Puis éditer `.env` avec vos clés API :

```env
MISTRAL_API_KEY=votre_cle_mistral
QDRANT_URL=https://votre-cluster.qdrant.io
QDRANT_API_KEY=votre_cle_qdrant
API_KEY=votre_cle_api_secrete
```

**Pour le développement local (Qdrant Docker) :**
```bash
cp .env.local.example .env.local
```

Puis éditer `.env.local` :

```env
MISTRAL_API_KEY=votre_cle_mistral
QDRANT_URL=http://localhost:6333
QDRANT_API_KEY=
API_KEY=dev-api-key-12345
```

**Note** : L'application charge automatiquement `.env.local` en priorité s'il existe, sinon `.env`. Plus besoin d'exporter manuellement les variables !

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
just health     # Health check simple
just agent-status      # Statut détaillé via script
just agent-health      # Health check uniquement
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

| Endpoint | Méthode | Description | Sécurité |
|----------|---------|-------------|----------|
| `/health` | GET | Health check | Public |
| `/status` | GET | Statut détaillé de l'agent | API KEY |
| `/ingest` | POST | Indexer les documents dans Qdrant | API KEY |
| `/upload` | POST | Uploader un document markdown | API KEY |
| `/chat` | POST | Poser une question au chatbot | Public |

### 📦 Tester l'API avec Postman

Des fichiers sont disponibles pour tester facilement l'API :

- **`openapi.yaml`** : Spécification OpenAPI/Swagger complète
- **`postman-collection.json`** : Collection Postman prête à l'emploi
- **`API_TESTING.md`** : Guide détaillé d'utilisation

**Import rapide dans Postman :**
1. Ouvrir Postman
2. Import → Sélectionner `postman-collection.json`
3. Configurer la variable `api_key` dans la collection
4. Tester ! 🚀

**Documentation interactive (auto-générée par FastAPI) :**
- Swagger UI : http://localhost:8000/docs (local) ou https://casadelsabor.up.railway.app/docs (prod)
- ReDoc : http://localhost:8000/redoc (local) ou https://casadelsabor.up.railway.app/redoc (prod)

Voir **[API_TESTING.md](./API_TESTING.md)** pour un guide complet.

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
| `QDRANT_URL` | URL Qdrant Cloud ou Local | (requis) |
| `QDRANT_API_KEY` | Clé API Qdrant | (optionnel, vide pour Qdrant local) |
| `QDRANT_COLLECTION_NAME` | Nom de la collection | `casa_del_sabor` |
| `AGENT_HOST` | Host du serveur | `0.0.0.0` |
| `AGENT_PORT` | Port du serveur | `8000` |
| `CHUNK_SIZE` | Taille des chunks | `500` |
| `CHUNK_OVERLAP` | Overlap des chunks | `50` |
| `TOP_K_RESULTS` | Nombre de résultats RAG | `4` |
| `API_KEY` | Clé API pour sécuriser les endpoints admin | (optionnel) |

## 🚢 Déploiement

### Railway (recommandé)

Railway supporte le déploiement depuis un sous-répertoire. Deux méthodes sont disponibles :

#### Méthode 1 : Configuration via l'interface Railway (recommandée)

1. Créer un projet sur [Railway](https://railway.app/)
2. Connecter le repo GitHub
3. Dans les **Settings** du service :
   - **Root Directory** : Définir `/agent`
   - **Start Command** : `uv run uvicorn main:app --host 0.0.0.0 --port $PORT`
4. Ajouter les variables d'environnement dans **Variables** :
   - `MISTRAL_API_KEY` (requis)
   - `QDRANT_URL` (requis)
   - `QDRANT_API_KEY` (requis)
   - `API_KEY` (recommandé pour sécuriser les endpoints)
   - `QDRANT_COLLECTION_NAME` (optionnel, défaut: `casa_del_sabor`)
   - `MISTRAL_MODEL` (optionnel, défaut: `mistral-small-latest`)
   - `MISTRAL_EMBEDDING_MODEL` (optionnel, défaut: `mistral-embed`)

Railway détectera automatiquement Python via `pyproject.toml` et installera les dépendances avec `uv`.

#### Méthode 2 : Configuration via fichiers (déjà configuré)

Un fichier `railway.json` et un `Dockerfile` ont été créés à la racine du projet pour automatiser la configuration.

**Étapes de déploiement via GitHub :**

1. **Pousser votre code sur GitHub** (si ce n'est pas déjà fait) :
   ```bash
   git add .
   git commit -m "Configure Railway deployment"
   git push origin main
   ```

2. **Créer un projet sur Railway** :
   - Aller sur [Railway](https://railway.app/)
   - Se connecter avec votre compte GitHub
   - Cliquer sur **"New Project"**

3. **Connecter le repository GitHub** :
   - Choisir **"Deploy from GitHub repo"**
   - Sélectionner votre repository `casaDelSabor`
   - Railway détectera automatiquement le fichier `railway.json` à la racine

4. **Configuration automatique** :
   - Railway lira `railway.json` qui utilise le `Dockerfile` personnalisé
   - Le Dockerfile :
     - Installe `uv` automatiquement
     - Copie le dossier `agent/` dans le conteneur
     - Installe les dépendances avec `uv sync --frozen`
     - Configure la commande de démarrage avec `uv run uvicorn`

5. **Ajouter les variables d'environnement** :
   Dans l'onglet **Variables** du service Railway, ajouter :
   - `MISTRAL_API_KEY` (requis)
   - `QDRANT_URL` (requis)
   - `QDRANT_API_KEY` (requis)
   - `API_KEY` (recommandé pour sécuriser les endpoints)
   - `QDRANT_COLLECTION_NAME` (optionnel, défaut: `casa_del_sabor`)
   - `MISTRAL_MODEL` (optionnel, défaut: `mistral-small-latest`)
   - `MISTRAL_EMBEDDING_MODEL` (optionnel, défaut: `mistral-embed`)

6. **Déploiement automatique** :
   - Railway déploiera automatiquement à chaque push sur la branche connectée
   - Vous pouvez voir les logs en temps réel dans l'interface Railway

**Note** : Après le déploiement, n'oubliez pas d'appeler l'endpoint `/ingest` pour indexer les documents (avec API KEY si configurée) :
```bash
curl -X POST https://votre-app.up.railway.app/ingest \
  -H "X-API-Key: votre_cle_api_secrete"
```

**Avantages de cette méthode** :
- ✅ Configuration versionnée dans le repo
- ✅ Déploiement automatique à chaque push
- ✅ Installation automatique de `uv` dans le Dockerfile
- ✅ Pas besoin de configurer manuellement le Root Directory
- ✅ Facile à reproduire sur d'autres environnements

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

## 🔒 Sécurisation de l'API

Les endpoints sensibles (`/ingest`, `/status`, `/upload`) sont protégés par authentification API KEY.

### Configuration

Ajoutez `API_KEY` dans votre fichier `.env` :

```env
API_KEY=votre_cle_api_secrete
```

**Note** : Si `API_KEY` n'est pas définie, les endpoints restent publics (rétrocompatibilité).

### Utilisation des endpoints protégés

Tous les endpoints protégés nécessitent le header `X-API-Key` :

```bash
# Ingestion (avec API KEY)
curl -X POST http://localhost:8000/ingest \
  -H "X-API-Key: votre_cle_api_secrete" \
  -H "Content-Type: application/json" \
  -d '{"force_reindex": true}'

# Statut (avec API KEY)
curl -X GET http://localhost:8000/status \
  -H "X-API-Key: votre_cle_api_secrete"

# Upload d'un document (avec API KEY)
curl -X POST http://localhost:8000/upload \
  -H "X-API-Key: votre_cle_api_secrete" \
  -F "file=@nouveau_menu.md"
```

### Endpoint `/upload`

Permet d'uploader dynamiquement de nouveaux documents markdown :

```bash
curl -X POST http://localhost:8000/upload \
  -H "X-API-Key: votre_cle_api_secrete" \
  -F "file=@nouveau_document.md"
```

Le fichier sera sauvegardé dans `agent/documents/`. Appelez ensuite `/ingest` pour l'indexer.

## 🧪 Développement Local avec Qdrant Docker

Pour tester en local sans utiliser Qdrant Cloud :

### 1. Démarrer Qdrant local

```bash
# Depuis la racine du projet
docker-compose up -d qdrant

# Ou avec just (depuis agent/)
just qdrant-up
```

### 2. Configurer l'environnement local

Créez un fichier `agent/.env.local` :

```bash
cp agent/.env.local.example agent/.env.local
```

Puis modifiez `agent/.env.local` :

```env
# Qdrant Local (sans API KEY)
QDRANT_URL=http://localhost:6333
QDRANT_API_KEY=

# Mistral AI (utilisez votre vraie clé)
MISTRAL_API_KEY=votre_cle_mistral

# API Security (optionnel pour le dev)
API_KEY=dev-api-key-12345
```

### 3. Démarrer l'agent

```bash
cd agent
just dev
```

**Note** : Le fichier `.env.local` est chargé automatiquement par l'application Python (via `pydantic-settings`). Plus besoin d'exporter manuellement les variables !

### 4. Indexer les documents

Dans un autre terminal :

```bash
cd agent
just ingest
```

### Commandes Qdrant disponibles

```bash
just qdrant-up      # Démarrer Qdrant
just qdrant-down    # Arrêter Qdrant
just qdrant-logs    # Voir les logs
just qdrant-status  # Vérifier le statut
just qdrant-clean   # Supprimer toutes les données
```

### Script de démarrage rapide

Utilisez le script `dev-local.sh` pour tout configurer automatiquement :

```bash
./agent/scripts/dev-local.sh
```

Ce script :
- Vérifie que Docker est en cours d'exécution
- Démarre Qdrant
- Attend que Qdrant soit prêt
- Crée `.env.local` si nécessaire
- Affiche les instructions

### Dashboard Qdrant

Accédez au dashboard sur : http://localhost:6333/dashboard

## 📝 Ajouter des documents

Pour ajouter de nouvelles informations au chatbot :

### Méthode 1 : Fichier manuel

1. Créer/modifier un fichier `.md` dans `documents/`
2. Appeler l'endpoint `/ingest` avec `force_reindex: true` (avec API KEY)

### Méthode 2 : Upload via API

1. Uploader le fichier via `/upload` (avec API KEY)
2. Appeler l'endpoint `/ingest` pour indexer (avec API KEY)

Les documents sont automatiquement découpés et indexés dans Qdrant.

### Méthode 3 : Scripts d'upload automatisés

Deux scripts sont disponibles pour simplifier l'upload et l'indexation :

#### Script avec lecture automatique de la clé API (recommandé)

```bash
# Upload en local (lit la clé API depuis .env.local ou .env)
./agent/scripts/upload.sh chemin/vers/document.md local

# Upload en production
./agent/scripts/upload.sh chemin/vers/document.md prod

# Exemple concret
./agent/scripts/upload.sh storytelling.md local
```

Le script `upload.sh` lit automatiquement la clé API depuis `.env.local` ou `.env`.

#### Script avec paramètres explicites

```bash
# Upload avec tous les paramètres explicites
./agent/scripts/upload-document.sh chemin/vers/document.md VOTRE_CLE_API local

# Exemple
./agent/scripts/upload-document.sh storytelling.md dev-api-key-12345 local
```

Le script `upload-document.sh` permet de spécifier manuellement la clé API (utile pour CI/CD).

**Les deux scripts effectuent automatiquement :**
1. ✅ Upload du fichier via `/upload`
2. ✅ Réindexation de la collection via `/ingest`
3. ✅ Affichage coloré du statut et des résultats

## 🔍 Vérifier le statut de Qdrant (CLI)

Deux scripts sont disponibles pour vérifier le statut du cluster Qdrant en ligne de commande :

### Script Python (recommandé)

```bash
# Statut de base (utilise .env.local par défaut)
python agent/scripts/qdrant_status.py

# Utiliser un environnement spécifique
python agent/scripts/qdrant_status.py --env local    # Utilise .env.local
python agent/scripts/qdrant_status.py --env prod    # Utilise .env

# Lister toutes les collections
python agent/scripts/qdrant_status.py --collections
python agent/scripts/qdrant_status.py --env prod --collections

# Détails d'une collection spécifique
python agent/scripts/qdrant_status.py --collection casa_del_sabor
python agent/scripts/qdrant_status.py --env prod --collection casa_del_sabor

# Statut du cluster
python agent/scripts/qdrant_status.py --cluster

# Tout afficher
python agent/scripts/qdrant_status.py --all
python agent/scripts/qdrant_status.py --env prod --all
```

### Via just (commandes simplifiées)

```bash
# Statut détaillé (local par défaut)
just qdrant-info
just qdrant-info local
just qdrant-info prod

# Tout afficher
just qdrant-info-all
just qdrant-info-all prod

# Collections
just qdrant-collections
just qdrant-collections prod

# Détails d'une collection
just qdrant-collection casa_del_sabor
just qdrant-collection casa_del_sabor prod
```

### Via wrapper shell

```bash
# Utiliser le wrapper shell
./agent/scripts/qdrant-status.sh                    # Local (défaut)
./agent/scripts/qdrant-status.sh local --all        # Local avec toutes les infos
./agent/scripts/qdrant-status.sh prod --collections # Prod avec collections
```

### Script Shell (curl)

```bash
# Statut de base
./agent/scripts/qdrant_curl.sh

# Détails d'une collection
./agent/scripts/qdrant_curl.sh casa_del_sabor

# Lister les collections
./agent/scripts/qdrant_curl.sh --collections

# Statut du cluster
./agent/scripts/qdrant_curl.sh --cluster
```

**Note** : Les scripts utilisent les variables d'environnement définies dans `.env` (`QDRANT_URL` et `QDRANT_API_KEY`).
