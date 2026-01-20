# Commandes Qdrant

Commandes utiles pour gérer Qdrant (local Docker et Cloud).

## 🐳 Qdrant Local (Docker)

### Démarrage et arrêt

```bash
# Démarrer Qdrant
cd agent
just qdrant-up

# Ou depuis la racine
docker-compose -f docker-compose.yml up -d qdrant

# Arrêter Qdrant
just qdrant-down

# Voir les logs
just qdrant-logs

# Vérifier le statut
just qdrant-status

# Nettoyer toutes les données (supprime le volume)
just qdrant-clean
```

### Health check

```bash
# Vérifier que Qdrant est prêt
curl http://localhost:6333/health

# Dashboard web
open http://localhost:6333/dashboard
```

## ☁️ Qdrant Cloud

### Vérifier le statut

```bash
# Utiliser le script Python
cd agent
python scripts/qdrant_status.py

# Lister toutes les collections
python scripts/qdrant_status.py --collections

# Détails d'une collection spécifique
python scripts/qdrant_status.py --collection casa_del_sabor

# Statut du cluster
python scripts/qdrant_status.py --cluster

# Tout afficher
python scripts/qdrant_status.py --all
```

### API REST directe

```bash
# Health check
curl https://votre-cluster.qdrant.io/health

# Lister les collections
curl -H "api-key: YOUR_API_KEY" \
  https://votre-cluster.qdrant.io/collections

# Info d'une collection
curl -H "api-key: YOUR_API_KEY" \
  https://votre-cluster.qdrant.io/collections/casa_del_sabor
```

## 🔧 Commandes via l'agent

```bash
# Indexer les documents
cd agent
just ingest

# Réindexer (forcer)
just reindex

# Vérifier le statut de l'agent
just status
```

## 🔍 Recherche et requêtes

### Recherche de similarité

```bash
# Via l'API REST (exemple de recherche)
curl -X POST http://localhost:6333/collections/casa_del_sabor/points/search \
  -H "Content-Type: application/json" \
  -d '{
    "vector": [0.1, 0.2, ...],
    "limit": 4,
    "with_payload": true
  }'

# Via Python (dans l'agent)
cd agent
python -c "
from rag.vectorstore import get_qdrant_client
client = get_qdrant_client()
results = client.search('casa_del_sabor', query_vector=[0.1]*1024, limit=4)
print(results)
"
```

### Compter les points

```bash
# Via API REST
curl http://localhost:6333/collections/casa_del_sabor

# Via Python
python scripts/qdrant_status.py --collection casa_del_sabor
```

## 💾 Backup et restauration

### Backup local (Docker)

```bash
# Créer un backup du volume
docker run --rm \
  -v casa-del-sabor_qdrant_storage:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/qdrant-backup-$(date +%Y%m%d).tar.gz /data

# Restaurer depuis un backup
docker run --rm \
  -v casa-del-sabor_qdrant_storage:/data \
  -v $(pwd):/backup \
  alpine sh -c "cd /data && tar xzf /backup/qdrant-backup-YYYYMMDD.tar.gz"
```

### Export/Import de collection (Cloud)

```bash
# Exporter une collection (via API)
curl -X POST "https://votre-cluster.qdrant.io/collections/casa_del_sabor/snapshots" \
  -H "api-key: YOUR_API_KEY"

# Télécharger le snapshot
curl -O "https://votre-cluster.qdrant.io/collections/casa_del_sabor/snapshots/<snapshot-id>" \
  -H "api-key: YOUR_API_KEY"
```

## 🧹 Maintenance

### Nettoyer les données

```bash
# Supprimer une collection (⚠️ attention)
curl -X DELETE http://localhost:6333/collections/casa_del_sabor

# Supprimer des points spécifiques
curl -X POST http://localhost:6333/collections/casa_del_sabor/points/delete \
  -H "Content-Type: application/json" \
  -d '{"points": [1, 2, 3]}'

# Nettoyer complètement (local)
just qdrant-clean
```

### Optimisation

```bash
# Forcer l'optimisation d'une collection
curl -X POST http://localhost:6333/collections/casa_del_sabor/index \
  -H "Content-Type: application/json"
```

## 📊 Monitoring avancé

### Métriques et statistiques

```bash
# Statistiques du cluster
curl http://localhost:6333/metrics

# Info système
curl http://localhost:6333/cluster

# Vérifier l'espace disque utilisé (local)
docker exec casa-del-sabor-qdrant du -sh /qdrant/storage
```

### Logs détaillés

```bash
# Logs Docker avec timestamps
docker-compose -f docker-compose.yml logs -f --timestamps qdrant

# Logs des 100 dernières lignes
docker-compose -f docker-compose.yml logs --tail=100 qdrant
```

## 🔐 Sécurité (Cloud)

```bash
# Vérifier les permissions de l'API key
curl -H "api-key: YOUR_API_KEY" \
  https://votre-cluster.qdrant.io/collections

# Tester la connexion
curl -H "api-key: YOUR_API_KEY" \
  https://votre-cluster.qdrant.io/health
```

## 📊 Informations utiles

- **Port local** : `6333` (REST API), `6334` (gRPC)
- **Dashboard local** : http://localhost:6333/dashboard
- **Collection par défaut** : `casa_del_sabor`
- **Dimensions des vecteurs** : 1024 (Mistral Embeddings)
- **Distance par défaut** : Cosine similarity