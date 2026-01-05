# Guide API Railway

Railway propose une **API GraphQL** (pas REST) pour gérer vos projets, services et déploiements.

## 🔑 Obtenir une clé API

1. Aller sur [Railway Dashboard](https://railway.app/)
2. Cliquer sur votre profil → **Settings**
3. Aller dans l'onglet **Tokens**
4. Cliquer sur **New Token**
5. Donner un nom au token (ex: "API Control")
6. Copier le token généré (⚠️ il ne sera affiché qu'une seule fois)

## 📡 Endpoint de l'API

```
https://backboard.railway.app/graphql/v2
```

## 🔐 Authentification

Inclure la clé API dans l'en-tête de chaque requête :

```
Authorization: Bearer YOUR_API_KEY
```

## 📋 Exemples d'utilisation

### 1. Lister les projets

```graphql
query {
  projects {
    id
    name
    createdAt
  }
}
```

**Requête cURL :**
```bash
curl -X POST https://backboard.railway.app/graphql/v2 \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query { projects { id name } }"
  }'
```

### 2. Lister les services d'un projet

```graphql
query($projectId: String!) {
  project(id: $projectId) {
    id
    name
    services {
      id
      name
      status
    }
  }
}
```

**Variables :**
```json
{
  "projectId": "c9b11c0b-f89e-4775-8684-e0d968154102"
}
```

### 3. Obtenir le statut d'un service

```graphql
query($serviceId: String!) {
  service(id: $serviceId) {
    id
    name
    status
    deployments {
      id
      status
      createdAt
    }
  }
}
```

### 4. Supprimer un service (⚠️ permanent)

```graphql
mutation($serviceId: String!) {
  serviceDelete(id: $serviceId)
}
```

## ⚠️ Limitations importantes

**Railway ne permet PAS d'arrêter/suspendre un service via l'API GraphQL.**

Les options disponibles sont :

1. **Supprimer le service** (`serviceDelete`) - ⚠️ **Action permanente**
2. **Utiliser l'interface web** pour suspendre le service
3. **Modifier les variables d'environnement** pour désactiver le service
4. **Redéployer** avec une configuration qui empêche le démarrage

## 🛠️ Script Python d'exemple

Un script Python est disponible dans `agent/scripts/railway_control.py` pour interagir avec l'API :

```bash
# Vérifier le statut
python agent/scripts/railway_control.py \
  --action status \
  --api-key YOUR_API_KEY

# Tenter d'arrêter (affichera les options disponibles)
python agent/scripts/railway_control.py \
  --action stop \
  --api-key YOUR_API_KEY
```

## 📚 Documentation officielle

- [Railway Public API Guide](https://docs.railway.com/guides/public-api)
- [Railway API Reference](https://docs.railway.com/reference/public-api)
- [GraphiQL Explorer](https://backboard.railway.app/graphql/v2) - Pour explorer le schéma GraphQL

## 🔍 Explorer le schéma GraphQL

Railway fournit un explorateur GraphiQL interactif :

1. Aller sur https://backboard.railway.app/graphql/v2
2. Ajouter votre clé API dans les en-têtes
3. Explorer les queries et mutations disponibles

## 🛠️ Arrêter un service via Railway CLI

**Oui, c'est possible !** Le Railway CLI permet d'arrêter un service en mettant les instances à 0.

### Prérequis

1. Installer le Railway CLI :
   ```bash
   npm i -g @railway/cli
   # ou
   brew install railway
   ```

2. Se connecter :
   ```bash
   railway login
   ```

3. Lier le projet :
   ```bash
   cd /path/to/your/project
   railway link
   ```

### Arrêter un service

⚠️ **BUG CONNU** : La commande `railway scale` a un bug dans le CLI v4.16.1 qui cause un crash avec certaines régions (notamment `us-west1`).

**Méthode recommandée (fonctionne) :**
```bash
# Supprimer le déploiement actif (arrête le service)
railway down -y

# Pour redémarrer :
railway up
```

**Méthode alternative (peut échouer à cause du bug) :**
```bash
# Vérifier la région du service
railway status

# Arrêter le service en mettant les instances à 0
# ⚠️ Peut échouer avec l'erreur "Mismatch between definition and access"
railway scale --<REGION> 0

# Exemple pour us-west1 (peut ne pas fonctionner) :
railway scale --us-west1 0
```

**Si la commande `scale` échoue, utilisez `railway down` à la place.**

### Redémarrer un service

**Après `railway down` :**
```bash
railway up
```

**Après `railway scale --region 0` (si ça fonctionne) :**
```bash
railway scale --us-west1 1
```

### Autres commandes utiles

```bash
# Voir le statut du service
railway service status

# Voir les informations du projet
railway status

# Supprimer le dernier déploiement (⚠️ attention)
railway down

# Redéployer le service
railway up
```

## 💡 Alternatives pour arrêter un service

Si vous devez arrêter un service Railway, voici les meilleures options :

### Option 1 : Railway CLI (recommandé) ⭐
```bash
railway scale --<REGION> 0
```
C'est la méthode la plus simple et la plus propre.

### Option 2 : Interface Web
1. Aller sur [Railway Dashboard](https://railway.app/)
2. Sélectionner votre projet
3. Cliquer sur le service
4. Utiliser le bouton "Suspend" ou "Delete"

### Option 3 : Modifier les variables d'environnement
Ajouter une variable qui empêche le démarrage :
```bash
railway variables set DISABLE_SERVICE=true
```

Puis modifier votre application pour vérifier cette variable au démarrage.

### Option 4 : Supprimer le dernier déploiement
```bash
railway down
```
⚠️ Cela supprime le déploiement, mais le service reste actif et peut redémarrer automatiquement.

