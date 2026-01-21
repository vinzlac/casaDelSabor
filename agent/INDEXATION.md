# Guide d'indexation des documents

Ce guide explique comment indexer et réindexer les documents dans le RAG via l'endpoint `/ingest`.

## 🔄 L'endpoint `/ingest`

Un seul endpoint pour deux modes d'utilisation :

### Mode 1 : Indexation normale (par défaut)

**Utilisation :** Ajouter de nouveaux documents sans toucher aux existants

```bash
# Via curl (sans body = force_reindex: false par défaut)
curl -X POST http://localhost:8000/ingest \
  -H "X-API-Key: votre-cle"

# Ou explicitement
curl -X POST http://localhost:8000/ingest \
  -H "X-API-Key: votre-cle" \
  -H "Content-Type: application/json" \
  -d '{"force_reindex": false}'
```

**Comportement :**
- ✅ Ajoute les nouveaux documents
- ✅ Conserve les documents déjà indexés
- ✅ Plus rapide
- ✅ Pas de downtime

**Quand l'utiliser :**
- Après avoir uploadé un nouveau document via `/upload`
- Pour indexer des documents ajoutés manuellement dans le dossier `documents/`

### Mode 2 : Réindexation complète

**Utilisation :** Supprimer et recréer toute la collection

```bash
curl -X POST http://localhost:8000/ingest \
  -H "X-API-Key: votre-cle" \
  -H "Content-Type: application/json" \
  -d '{"force_reindex": true}'
```

**Comportement :**
- 🗑️ Supprime la collection Qdrant existante
- 🆕 Recrée une nouvelle collection vide
- 📚 Indexe TOUS les documents du dossier `documents/`
- ⏱️ Plus lent (retraite tous les documents)

**Quand l'utiliser :**
- Après avoir modifié le contenu d'un document existant
- Pour nettoyer et repartir de zéro
- Après avoir supprimé des documents
- Si la collection est corrompue ou incohérente

## 📊 Réponse de l'API

```json
{
  "success": true,
  "collection_created": true,
  "documents_loaded": 4,
  "chunks_indexed": 43,
  "force_reindex": true
}
```

**Champs :**
- `success` : Indique si l'opération a réussi
- `collection_created` : True si une nouvelle collection a été créée
- `documents_loaded` : Nombre de fichiers .md chargés
- `chunks_indexed` : Nombre total de chunks indexés dans Qdrant
- `force_reindex` : Mode utilisé (true = réindexation, false = normal)

## 🎯 Workflows recommandés

### Workflow 1 : Ajouter un nouveau document

```bash
# 1. Uploader le fichier
curl -X POST http://localhost:8000/upload \
  -H "X-API-Key: votre-cle" \
  -F "file=@nouveau-document.md"

# 2. Indexer (mode normal suffit)
curl -X POST http://localhost:8000/ingest \
  -H "X-API-Key: votre-cle" \
  -H "Content-Type: application/json" \
  -d '{"force_reindex": false}'
```

### Workflow 2 : Modifier un document existant

```bash
# 1. Modifier le fichier directement dans documents/
# (ou le supprimer et en uploader un nouveau)

# 2. FORCER la réindexation
curl -X POST http://localhost:8000/ingest \
  -H "X-API-Key: votre-cle" \
  -H "Content-Type: application/json" \
  -d '{"force_reindex": true}'
```

### Workflow 3 : Premier déploiement

```bash
# Lors du premier déploiement, forcer la création de la collection
curl -X POST http://localhost:8000/ingest \
  -H "X-API-Key: votre-cle" \
  -H "Content-Type: application/json" \
  -d '{"force_reindex": true}'
```

## 🛠️ Scripts disponibles

### Via scripts shell

```bash
# Indexation normale
./agent/scripts/ingest.sh

# Réindexation complète
./agent/scripts/reindex.sh
```

### Via just

```bash
cd agent

# Indexation normale
just ingest

# Réindexation complète
just reindex
```

### Via les scripts d'upload

Les scripts `upload.sh` et `upload-document.sh` appellent automatiquement `/ingest` avec `force_reindex: true` après l'upload.

## 🔍 Vérifier le résultat

Après une indexation, vérifiez le statut :

```bash
curl -X GET http://localhost:8000/status \
  -H "X-API-Key: votre-cle"
```

Réponse attendue :

```json
{
  "documents_directory": "/app/documents",
  "documents_exist": true,
  "collection_info": {
    "exists": true,
    "vectors_count": 43,
    "points_count": 43
  }
}
```

Le `vectors_count` doit correspondre au `chunks_indexed` de la réponse d'ingestion.

## ⚠️ Bonnes pratiques

### ✅ À faire

- Utiliser `force_reindex: false` par défaut pour les nouveaux documents
- Utiliser `force_reindex: true` après modification de documents existants
- Vérifier le statut après chaque indexation
- Tester les changements avec le endpoint `/chat`

### ❌ À éviter

- Ne pas réindexer inutilement (coût API Mistral pour les embeddings)
- Ne pas indexer en boucle rapide (rate limiting)
- Ne pas oublier d'indexer après avoir uploadé un document

## 📚 Swagger

Pour tester directement depuis le navigateur :

- **Local** : http://localhost:8000/docs
- **Production** : https://casadelsabor.up.railway.app/docs

1. Cliquer sur **Authorize** 🔓
2. Entrer votre API Key
3. Développer `/ingest` → **Try it out**
4. Cocher ou décocher `force_reindex`
5. **Execute**

La documentation Swagger affiche maintenant clairement les deux modes d'utilisation ! 🎉
