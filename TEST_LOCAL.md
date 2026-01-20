# Guide de test local - Casa del Sabor

Guide complet pour tester toute l'application en local.

## 🎯 Méthode rapide (recommandée)

### 1. Prérequis

Assurez-vous d'avoir installé :
- ✅ **Docker Desktop** (en cours d'exécution)
- ✅ **Node.js** 18+ et npm
- ✅ **Python** 3.11+
- ✅ **uv** (gestionnaire de paquets Python)
- ✅ **just** (command runner)

### 2. Installation des dépendances (première fois uniquement)

```bash
# Depuis la racine du projet

# Installer les dépendances de l'agent
cd agent
just install

# Installer les dépendances du frontend
cd ../web
npm install

# Retour à la racine
cd ..
```

### 3. Configuration

#### Configuration de l'agent

```bash
cd agent

# Créer le fichier .env.local depuis l'exemple
cp .env.local.example .env.local

# Éditer .env.local et ajouter votre clé Mistral AI
# MISTRAL_API_KEY=votre_cle_mistral_ici
```

**Fichier `.env.local` minimal :**
```env
# Qdrant local
QDRANT_URL=http://localhost:6333
QDRANT_API_KEY=
QDRANT_COLLECTION_NAME=casa_del_sabor

# Mistral AI (OBLIGATOIRE)
MISTRAL_API_KEY=votre_cle_mistral

# Agent
AGENT_HOST=0.0.0.0
AGENT_PORT=8000

# API Security (optionnel pour le dev local)
API_KEY=dev-api-key-12345
```

#### Configuration du frontend (optionnel)

```bash
cd web

# Créer .env.local si vous voulez personnaliser
cp .env.local.example .env.local

# Par défaut, il utilise http://localhost:8000
```

### 4. Démarrer tous les services

```bash
# Depuis la racine du projet
./start-dev.sh
```

Ce script démarre automatiquement :
- ✅ **Qdrant** (Docker) sur `http://localhost:6333`
- ✅ **Agent Python** (FastAPI) sur `http://localhost:8000`
- ✅ **Frontend Next.js** sur `http://localhost:3000`

### 5. Indexer les documents (première fois)

Dans un **nouveau terminal** :

```bash
cd agent
just ingest
```

Vous devriez voir :
```json
{
  "success": true,
  "chunks_indexed": 15,
  "message": "Documents indexés avec succès"
}
```

### 6. Tester l'application

1. **Ouvrir le frontend** : http://localhost:3000
2. **Tester le chat** : Posez une question comme "Quels sont vos horaires ?"
3. **Vérifier l'agent** : http://localhost:8000/health
4. **Dashboard Qdrant** : http://localhost:6333/dashboard

### 7. Arrêter tous les services

```bash
# Depuis la racine du projet
./stop-dev.sh
```

Ou appuyez sur `Ctrl+C` dans le terminal où `start-dev.sh` est en cours d'exécution.

---

## 📝 Méthode manuelle (étape par étape)

Si vous préférez démarrer chaque service manuellement :

### Terminal 1 : Qdrant

```bash
# Démarrer Qdrant
docker-compose -f docker-compose.yml up -d qdrant

# Vérifier qu'il est prêt
curl http://localhost:6333/health

# Voir les logs
docker-compose -f docker-compose.yml logs -f qdrant
```

### Terminal 2 : Agent Python

```bash
cd agent

# Vérifier que .env.local existe et est configuré
cat .env.local

# Démarrer l'agent
just dev
```

L'agent sera accessible sur `http://localhost:8000`

### Terminal 3 : Indexer les documents

```bash
cd agent

# Indexer les documents (première fois)
just ingest
```

### Terminal 4 : Frontend Next.js

```bash
cd web

# Démarrer Next.js
npm run dev
```

Le frontend sera accessible sur `http://localhost:3000`

---

## 🧪 Tests et vérifications

### Vérifier que tout fonctionne

#### 1. Health check de l'agent

```bash
curl http://localhost:8000/health
```

Réponse attendue :
```json
{
  "status": "healthy",
  "service": "Casa del Sabor RAG Agent"
}
```

#### 2. Statut de l'agent

```bash
cd agent
just status
```

#### 3. Tester le chat via API

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Quels sont vos horaires ?"}'
```

#### 4. Tester via le frontend

1. Ouvrir http://localhost:3000
2. Taper une question dans le chat
3. Vérifier que la réponse arrive

#### 5. Vérifier Qdrant

```bash
# Via le dashboard
open http://localhost:6333/dashboard

# Via le script Python
cd agent
python scripts/qdrant_status.py --all

# Ou via le wrapper shell
agent/scripts/qdrant-status.sh local --all
```

#### 6. Vérifier l'agent

```bash
# Vérification complète
agent/scripts/agent-status.sh

# Options
agent/scripts/agent-status.sh --health    # Health check uniquement
agent/scripts/agent-status.sh --status    # Statut détaillé
agent/scripts/agent-status.sh --logs     # Voir les logs

# Via just
cd agent
just agent-status
just agent-health
```

#### 7. Vérifier le frontend

```bash
# Vérification complète
web/scripts/front-status.sh

# Options
web/scripts/front-status.sh --health    # Health check uniquement
web/scripts/front-status.sh --api       # Tester l'API route
web/scripts/front-status.sh --env       # Configuration
web/scripts/front-status.sh --logs      # Voir les logs
```

---

## 🐛 Dépannage

### Qdrant ne démarre pas

```bash
# Vérifier que Docker est en cours d'exécution
docker info

# Voir les logs
docker-compose -f docker-compose.yml logs qdrant

# Redémarrer
docker-compose -f docker-compose.yml restart qdrant
```

### L'agent ne démarre pas

```bash
cd agent

# Vérifier les dépendances
just install

# Vérifier la configuration
cat .env.local

# Vérifier que la clé Mistral est bien définie
grep MISTRAL_API_KEY .env.local

# Voir les logs
tail -f /tmp/casa-del-sabor-agent.log
```

### Next.js ne démarre pas

```bash
cd web

# Vérifier les dépendances
npm install

# Nettoyer et réinstaller
rm -rf node_modules .next
npm install

# Vérifier les logs
tail -f /tmp/casa-del-sabor-web.log
```

### L'agent ne répond pas

```bash
# Vérifier que l'agent est bien démarré
curl http://localhost:8000/health

# Vérifier les documents sont indexés
cd agent
just status

# Réindexer si nécessaire
just reindex
```

### Erreur "Connection refused" au frontend

1. Vérifier que l'agent est bien sur `http://localhost:8000`
2. Vérifier le fichier `web/.env.local` :
   ```env
   AGENT_URL=http://localhost:8000
   ```
3. Redémarrer Next.js

---

## 📊 URLs des services

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | Application Next.js |
| Agent API | http://localhost:8000 | API FastAPI |
| Agent Health | http://localhost:8000/health | Health check |
| Agent Status | http://localhost:8000/status | Statut détaillé (nécessite API_KEY) |
| Qdrant Dashboard | http://localhost:6333/dashboard | Interface web Qdrant |
| Qdrant API | http://localhost:6333 | API REST Qdrant |

---

## 🔄 Workflow de développement

### Modifier les documents

1. Éditer les fichiers dans `agent/documents/`
2. Réindexer :
   ```bash
   cd agent
   just reindex
   ```

### Modifier le code de l'agent

1. Modifier le code Python
2. L'agent redémarre automatiquement (hot reload)
3. Tester via le frontend ou curl

### Modifier le frontend

1. Modifier le code Next.js
2. Le frontend se recharge automatiquement (hot reload)
3. Voir les changements dans le navigateur

---

## 💡 Astuces

### Voir les logs en temps réel

```bash
# Logs de l'agent
tail -f /tmp/casa-del-sabor-agent.log

# Logs de Next.js
tail -f /tmp/casa-del-sabor-web.log

# Logs de Qdrant
docker-compose -f docker-compose.yml logs -f qdrant
```

### Tester avec curl

```bash
# Test simple
curl http://localhost:8000/health

# Test du chat
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Bonjour"}'

# Test avec session
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Quels sont vos horaires ?", "session_id": "test-123"}'
```

### Nettoyer et recommencer

```bash
# Arrêter tous les services
./stop-dev.sh

# Nettoyer Qdrant (supprime toutes les données)
cd agent
just qdrant-clean

# Redémarrer
cd ..
./start-dev.sh

# Réindexer
cd agent
just ingest
```

---

## ✅ Checklist de vérification

Avant de commencer à développer, vérifiez :

- [ ] Docker Desktop est en cours d'exécution
- [ ] Les dépendances sont installées (`just install` et `npm install`)
- [ ] Le fichier `agent/.env.local` existe et contient `MISTRAL_API_KEY`
- [ ] Qdrant démarre correctement (`curl http://localhost:6333/health`)
- [ ] L'agent démarre correctement (`curl http://localhost:8000/health`)
- [ ] Les documents sont indexés (`just ingest`)
- [ ] Le frontend démarre correctement (http://localhost:3000)
- [ ] Le chat fonctionne (test dans le navigateur)

---

## 📚 Ressources

- [Agent README](./agent/README.md) - Documentation détaillée de l'agent
- [Web README](./web/README.md) - Documentation du frontend
- [Commandes Qdrant](.cursor/commands/qdrant.md) - Commandes utiles Qdrant
