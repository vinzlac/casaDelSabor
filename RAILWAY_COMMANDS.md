# Commandes Railway - Gestion de l'agent en production

Guide complet pour gérer l'agent Casa del Sabor en production sur Railway.

## 🚀 Commandes rapides (via just)

```bash
cd agent

# Arrêter l'agent en prod
just railway-stop

# Démarrer l'agent en prod
just railway-start

# Redémarrer l'agent en prod
just railway-restart

# Voir le statut en prod
just railway-status
```

## 🛠️ Commandes détaillées (via script)

### Arrêter le service

```bash
./scripts/railway-control.sh stop
```

**Ce qui se passe :**
- 🛑 Le déploiement est supprimé
- 💰 Arrêt de la facturation
- 🌐 L'URL reste active mais retourne une erreur

**Pour redémarrer :**
```bash
./scripts/railway-control.sh start
```

### Démarrer le service

```bash
./scripts/railway-control.sh start
```

**Ce qui se passe :**
- 🚀 Redéploiement du service
- ⏱️ Attente du démarrage (quelques secondes)
- ✅ Service disponible sur l'URL Railway

### Redémarrer le service

```bash
./scripts/railway-control.sh restart
```

**Équivalent à :**
```bash
stop → attente 2s → start
```

### Voir le statut

```bash
./scripts/railway-control.sh status
```

**Affiche :**
- État du service (running, stopped, etc.)
- Nombre d'instances
- URL de déploiement
- Dernière mise à jour

## 🔍 Vérifier que l'agent répond

### Via just check

```bash
cd agent && just check prod
```

**Affiche :**
- ✅ Agent en ligne / ❌ Agent hors ligne
- Version du service
- Tous les endpoints disponibles
- Liens vers la documentation Swagger

### Via curl

```bash
curl https://casadelsabor.up.railway.app/health
```

**Réponse attendue si en ligne :**
```json
{
  "status": "healthy",
  "service": "casa-del-sabor-agent",
  "version": "1.0.0"
}
```

## 📊 Commandes Railway CLI natives

### Statut général

```bash
railway status
```

### Logs en temps réel

```bash
railway logs
```

### Ouvrir le dashboard

```bash
railway open
```

### Voir les variables d'environnement

```bash
railway variables
```

## 💡 Cas d'usage courants

### 1. Économiser des crédits (arrêt temporaire)

```bash
# Arrêter pour la nuit
just railway-stop

# Redémarrer le lendemain
just railway-start
```

### 2. Appliquer des changements

```bash
# Après avoir poussé sur Git
just railway-restart
```

### 3. Vérifier que tout fonctionne

```bash
# 1. Voir le statut Railway
just railway-status

# 2. Vérifier que l'API répond
just check prod

# 3. Tester le chat
curl -X POST https://casadelsabor.up.railway.app/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Bonjour"}'
```

### 4. Déboguer un problème

```bash
# 1. Voir les logs
railway logs

# 2. Vérifier le statut
just railway-status

# 3. Redémarrer
just railway-restart

# 4. Vérifier à nouveau
just check prod
```

## ⚠️ Avertissements

### railway scale (bug connu)

La commande `railway scale` a un bug dans certaines versions du CLI. Le script utilise `railway down` et `railway up` à la place.

### Temps de démarrage

Après un `start` ou `restart`, attendez **30-60 secondes** avant que le service soit complètement opérationnel.

### Vérification

Utilisez **toujours** `just check prod` après un démarrage pour confirmer que l'agent répond correctement.

## 🆘 Dépannage

### "Project not linked"

```bash
cd agent
railway link
```

Sélectionnez votre projet Railway.

### "Railway CLI not found"

```bash
# Installation
npm i -g @railway/cli

# Ou avec Homebrew
brew install railway
```

### Service ne démarre pas

1. **Vérifier les logs :**
   ```bash
   railway logs
   ```

2. **Vérifier les variables d'environnement :**
   ```bash
   railway variables
   ```
   
   Assurez-vous que :
   - `MISTRAL_API_KEY` est définie
   - `QDRANT_URL` pointe vers Qdrant Cloud
   - `QDRANT_API_KEY` est définie

3. **Redéployer depuis le dashboard :**
   ```bash
   railway open
   ```

## 📚 Ressources

- **Dashboard Railway** : https://railway.app/
- **Documentation Railway** : https://docs.railway.app/
- **Agent Swagger (prod)** : https://casadelsabor.up.railway.app/docs
- **Support Railway** : https://discord.gg/railway

## 🎯 Résumé des commandes essentielles

```bash
# Arrêter
just railway-stop

# Démarrer
just railway-start

# Statut
just railway-status

# Vérifier que ça marche
just check prod
```

C'est tout ce dont vous avez besoin ! 🚀
