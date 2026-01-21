# Guide de test de l'API avec Postman

Ce guide explique comment tester l'API de l'agent RAG Casa del Sabor avec Postman.

## 📥 Import dans Postman

### Méthode 1 : Collection Postman (Recommandé)

1. Ouvrir Postman
2. Cliquer sur **Import** en haut à gauche
3. Sélectionner le fichier `postman-collection.json`
4. La collection "Casa del Sabor - Agent RAG API" apparaît dans votre sidebar

### Méthode 2 : OpenAPI/Swagger

1. Ouvrir Postman
2. Cliquer sur **Import** 
3. Sélectionner le fichier `openapi.yaml`
4. Postman génère automatiquement la collection

## ⚙️ Configuration

### 1. Variables d'environnement

La collection utilise 3 variables :

- `base_url_local` : http://localhost:8000 (pour tester en local)
- `base_url_prod` : https://casadelsabor.up.railway.app (pour la production)
- `api_key` : Votre clé API

### 2. Configurer la clé API

**Option A : Dans la collection**

1. Cliquer sur la collection "Casa del Sabor - Agent RAG API"
2. Onglet **Variables**
3. Remplacer `VOTRE_CLE_API` par votre vraie clé
4. Sauvegarder

**Option B : Créer un environnement Postman**

1. Cliquer sur l'icône ⚙️ (Manage Environments)
2. Créer deux environnements :

**Environnement "Local"**
```
base_url = http://localhost:8000
api_key = dev-api-key-12345
```

**Environnement "Production"**
```
base_url = https://casadelsabor.up.railway.app
api_key = VOTRE_CLE_API_PROD
```

3. Sélectionner l'environnement souhaité dans le menu déroulant en haut à droite

## 🧪 Tests disponibles

### Health Check (Public)

```http
GET /health
```

Pas d'authentification requise. Vérifie que le service est en ligne.

**Réponse attendue :**
```json
{
  "status": "healthy",
  "service": "casa-del-sabor-agent",
  "version": "1.0.0"
}
```

### Status Détaillé (Protégé)

```http
GET /status
Headers: X-API-Key: votre-cle
```

Retourne l'état détaillé de l'agent et des documents indexés.

**Réponse attendue :**
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

### Upload Document (Protégé)

```http
POST /upload
Headers: X-API-Key: votre-cle
Body: multipart/form-data
  - file: storytelling.md
```

Upload un nouveau document markdown.

**Étapes dans Postman :**
1. Sélectionner la requête "Upload Document"
2. Onglet **Body** → **form-data**
3. Hover sur la clé `file` → Sélectionner **File** dans le dropdown
4. Cliquer sur **Select Files** et choisir votre fichier .md
5. Envoyer

**Réponse attendue :**
```json
{
  "success": true,
  "filename": "storytelling.md",
  "message": "Fichier storytelling.md uploadé avec succès. Appelez /ingest pour l'indexer."
}
```

### Ingest Documents (Protégé)

```http
POST /ingest
Headers: 
  X-API-Key: votre-cle
  Content-Type: application/json
Body: {"force_reindex": true}
```

Indexe tous les documents du dossier `documents/`.

**Options :**
- `force_reindex: false` : Indexe seulement les nouveaux documents
- `force_reindex: true` : Supprime et recrée toute la collection

**Réponse attendue :**
```json
{
  "success": true,
  "collection_created": true,
  "documents_loaded": 4,
  "chunks_indexed": 43,
  "force_reindex": true
}
```

### Chat (Public)

```http
POST /chat
Headers: Content-Type: application/json
Body: {
  "message": "Quels sont vos horaires ?",
  "session_id": null
}
```

Conversation avec l'agent RAG.

**Pour une nouvelle conversation :**
```json
{
  "message": "Quels sont vos horaires ?",
  "session_id": null
}
```

**Pour continuer une conversation :**
```json
{
  "message": "Et pour le dimanche ?",
  "session_id": "session-abc-123"
}
```

💡 **Astuce** : Copier le `session_id` de la réponse et le réutiliser pour maintenir l'historique.

**Réponse attendue :**
```json
{
  "response": "Nous sommes ouverts du mardi au samedi de 12h à 14h30 pour le déjeuner...",
  "sources": ["horaires.md"],
  "session_id": "session-abc-123"
}
```

## 🔐 Authentification

Les endpoints suivants nécessitent une clé API dans le header `X-API-Key` :

- ✅ `/status`
- ✅ `/ingest`
- ✅ `/upload`

Les endpoints suivants sont publics :

- 🌐 `/health`
- 🌐 `/chat`

## 🎯 Workflow complet

### Scénario : Upload et indexation d'un nouveau document

1. **Upload le document**
   ```
   POST /upload (avec le fichier)
   → Vérifier success: true
   ```

2. **Indexer**
   ```
   POST /ingest (avec force_reindex: true)
   → Vérifier chunks_indexed > 0
   ```

3. **Vérifier le statut**
   ```
   GET /status
   → Vérifier vectors_count augmenté
   ```

4. **Tester le chat**
   ```
   POST /chat (avec une question sur le nouveau document)
   → Vérifier que la réponse utilise le nouveau contenu
   ```

## 🐛 Dépannage

### Erreur 401 Unauthorized

**Problème :** Clé API invalide ou manquante

**Solution :**
- Vérifier que le header `X-API-Key` est bien présent
- Vérifier que la valeur de `{{api_key}}` est correcte
- S'assurer que la variable est bien configurée dans la collection ou l'environnement

### Erreur 400 Bad Request

**Problème :** Données invalides

**Solutions :**
- Pour `/upload` : Vérifier que c'est bien un fichier .md
- Pour `/chat` : Vérifier que le message n'est pas vide
- Vérifier le format JSON du body

### Erreur 500 Internal Server Error

**Problème :** Erreur serveur

**Solutions :**
- Vérifier les logs du serveur
- Vérifier que Qdrant est accessible
- Vérifier que les clés API (Mistral, Qdrant) sont valides

## 📚 Documentation supplémentaire

- **Swagger UI (auto-généré par FastAPI)** : 
  - Local : http://localhost:8000/docs
  - Prod : https://casadelsabor.up.railway.app/docs

- **ReDoc (alternative)** :
  - Local : http://localhost:8000/redoc
  - Prod : https://casadelsabor.up.railway.app/redoc

Ces interfaces permettent de tester l'API directement depuis le navigateur !
