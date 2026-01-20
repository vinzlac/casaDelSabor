# Commandes Railway

Commandes utiles pour gérer le déploiement Railway de l'agent Python.

## 🚀 Installation et configuration

```bash
# Installer Railway CLI
npm i -g @railway/cli
# ou
brew install railway

# Se connecter
railway login

# Lier le projet
cd agent
railway link
```

## 📊 Statut et informations

```bash
# Statut du service
railway service status

# Informations du projet
railway status

# Voir les logs en temps réel
railway logs

# Voir les logs d'un déploiement spécifique
railway logs --deployment <deployment-id>
```

## 🛑 Contrôle du service

```bash
# Arrêter le service (supprime le déploiement actif)
railway down -y

# Redémarrer le service
railway up

# Redéployer
railway up --detach
```

### Via le script de contrôle

```bash
# Utiliser le script helper
./scripts/railway-control.sh stop
./scripts/railway-control.sh start
./scripts/railway-control.sh restart
./scripts/railway-control.sh status
./scripts/railway-control.sh scale 2
```

## 🔧 Variables d'environnement

```bash
# Lister les variables
railway variables

# Ajouter/modifier une variable
railway variables set MISTRAL_API_KEY=your_key

# Supprimer une variable
railway variables delete MISTRAL_API_KEY

# Ouvrir l'éditeur de variables
railway variables
```

## 📦 Déploiements

```bash
# Voir l'historique des déploiements
railway deployments

# Voir les logs d'un déploiement
railway logs --deployment <id>

# Ouvrir le déploiement dans le navigateur
railway open
```

## 🔗 URLs et accès

```bash
# Obtenir l'URL du service
railway domain

# Ouvrir le service dans le navigateur
railway open

# Générer une URL publique
railway domain generate
```

## 🐛 Dépannage

```bash
# Vérifier la version du CLI
railway --version

# Mettre à jour le CLI
brew upgrade railway

# Voir les logs en temps réel
railway logs --follow

# Redémarrer après un problème
railway down -y && railway up
```

## ⚠️ Notes importantes

- **Bug connu** : `railway scale --region 0` peut échouer avec certaines régions (notamment `us-west1`)
- **Alternative** : Utiliser `railway down` puis `railway up` pour redémarrer
- **Documentation** : Voir `RAILWAY_API.md` pour l'API GraphQL

## 📈 Monitoring et métriques

```bash
# Voir les métriques (CPU, mémoire, réseau)
railway metrics

# Voir les métriques en temps réel
railway metrics --live

# Voir l'utilisation des ressources
railway metrics --service <service-id>
```

## 🔐 Secrets et sécurité

```bash
# Gérer les secrets (alternative aux variables)
railway secrets

# Voir les secrets
railway secrets list

# Ajouter un secret
railway secrets set SECRET_KEY=value
```

## 🏗️ Builds et CI/CD

```bash
# Voir l'historique des builds
railway builds

# Voir les logs d'un build spécifique
railway logs --build <build-id>

# Déclencher un build manuel
railway up --detach
```

## 💾 Volumes et stockage

```bash
# Lister les volumes
railway volumes

# Créer un volume
railway volume create

# Monter un volume dans un service
railway volume attach <volume-id>
```

## 🔄 Rollback

```bash
# Voir les déploiements précédents
railway deployments

# Rollback vers un déploiement précédent
railway rollback <deployment-id>

# Voir les différences entre déploiements
railway diff <deployment-id-1> <deployment-id-2>
```

## 🧪 Tests et validation

```bash
# Tester localement avec Railway
railway run python main.py

# Exécuter une commande dans l'environnement Railway
railway run bash

# Tester avec les variables d'environnement Railway
railway run --env-file .env.test python test.py
```

## 📊 Analytics et insights

```bash
# Voir les statistiques d'utilisation
railway usage

# Voir les coûts
railway billing

# Voir les événements récents
railway events
```

## 🔗 Intégrations

```bash
# Connecter un repo GitHub
railway github

# Configurer les webhooks
railway webhooks

# Voir les intégrations actives
railway integrations
```

## 🛠️ Commandes avancées

```bash
# Exécuter une commande dans le service
railway run <command>

# Ouvrir un shell dans le service
railway shell

# Télécharger les logs
railway logs --output logs.txt

# Voir les variables d'environnement en JSON
railway variables --json
```

## 📚 Ressources

- [Railway Dashboard](https://railway.app/)
- [Railway CLI Docs](https://docs.railway.com/develop/cli)
- [Railway API Docs](https://docs.railway.com/reference/public-api)
- [Railway Pricing](https://railway.app/pricing)