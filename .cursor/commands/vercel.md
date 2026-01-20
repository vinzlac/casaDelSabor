# Commandes Vercel

Commandes utiles pour gérer le déploiement Vercel du frontend Next.js.

## 🚀 Installation et configuration

```bash
# Installer Vercel CLI
npm i -g vercel

# Se connecter
vercel login

# Lier le projet
cd web
vercel link
```

## 📊 Déploiement

```bash
# Déployer en production
cd web
vercel --prod

# Déployer en preview
vercel

# Déployer depuis la racine
vercel --cwd web

# Voir les déploiements
vercel ls
```

## 🔧 Variables d'environnement

```bash
# Lister les variables
vercel env ls

# Ajouter une variable
vercel env add AGENT_URL

# Supprimer une variable
vercel env rm AGENT_URL

# Pull les variables locales
vercel env pull .env.local
```

### Configuration importante

```bash
# Configurer l'URL de l'agent Railway
vercel env add AGENT_URL production
# Entrer: https://casadelsabor.up.railway.app

# Pour preview aussi
vercel env add AGENT_URL preview
# Entrer: https://casadelsabor.up.railway.app
```

## 📊 Statut et logs

```bash
# Voir les logs en temps réel
vercel logs

# Voir les logs d'un déploiement spécifique
vercel logs <deployment-url>

# Voir les informations du projet
vercel inspect
```

## 🔗 Domaine et URLs

```bash
# Lister les domaines
vercel domains ls

# Ajouter un domaine personnalisé
vercel domains add example.com

# Ouvrir le projet dans le navigateur
vercel open
```

## 🐛 Dépannage

```bash
# Vérifier la configuration
vercel inspect

# Voir les builds
vercel builds ls

# Redéployer après un problème
vercel --prod --force

# Nettoyer le cache
vercel --prod --force --debug
```

## 📁 Configuration du projet

### Root Directory

Si le projet est dans un monorepo, configurer le Root Directory :

1. Via l'interface web :
   - Settings → General → Root Directory → `web`

2. Via `vercel.json` :
```json
{
  "buildCommand": "cd web && npm run build",
  "outputDirectory": "web/.next"
}
```

## 🔍 Vérification

```bash
# Tester localement avec les variables de production
vercel dev

# Vérifier que AGENT_URL est bien configurée
vercel env ls

# Tester la connexion à l'agent
curl https://votre-app.vercel.app/api/chat \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "test"}'
```

## 📈 Analytics et monitoring

```bash
# Voir les analytics du projet
vercel analytics

# Voir les métriques de performance
vercel inspect --logs

# Voir les erreurs et exceptions
vercel logs --follow
```

## 🚀 Preview Deployments

```bash
# Créer une preview pour une branche spécifique
vercel --branch feature-branch

# Lister toutes les previews
vercel ls

# Supprimer une preview
vercel rm <deployment-url>

# Promouvoir une preview en production
vercel promote <deployment-url>
```

## 🔄 Builds et cache

```bash
# Nettoyer le cache de build
vercel --prod --force

# Voir les détails d'un build
vercel inspect <deployment-url>

# Télécharger les logs de build
vercel logs <deployment-url> --output build.log

# Rebuild sans cache
vercel --prod --force --no-cache
```

## ⚡ Edge Functions et Middleware

```bash
# Tester les edge functions localement
vercel dev

# Voir les logs des edge functions
vercel logs --follow

# Déployer avec debug
vercel --prod --debug
```

## 🔐 Sécurité et headers

```bash
# Vérifier les headers de sécurité
curl -I https://votre-app.vercel.app

# Tester les CORS
curl -H "Origin: https://example.com" \
  -H "Access-Control-Request-Method: POST" \
  -X OPTIONS \
  https://votre-app.vercel.app/api/chat
```

## 🧪 Tests et validation

```bash
# Tester localement avec les variables de production
vercel dev

# Vérifier la configuration avant déploiement
vercel build

# Tester un déploiement preview
vercel --prebuilt
```

## 📦 Gestion des déploiements

```bash
# Voir tous les déploiements
vercel ls --all

# Voir les détails d'un déploiement
vercel inspect <deployment-url>

# Rollback vers un déploiement précédent
vercel rollback <deployment-url>

# Alias un déploiement
vercel alias <deployment-url> production
```

## 🔍 Debugging

```bash
# Mode debug avec logs détaillés
vercel --debug

# Voir les logs en temps réel
vercel logs --follow

# Filtrer les logs par type
vercel logs --follow --output logs.txt

# Voir les erreurs uniquement
vercel logs | grep -i error
```

## 🌐 Domaine personnalisé

```bash
# Ajouter un domaine
vercel domains add example.com

# Vérifier la configuration DNS
vercel domains verify example.com

# Lister tous les domaines
vercel domains ls

# Supprimer un domaine
vercel domains rm example.com
```

## 📊 Performance

```bash
# Voir les métriques de performance
vercel inspect

# Tester la vitesse de chargement
curl -w "@curl-format.txt" -o /dev/null -s https://votre-app.vercel.app

# Vérifier le cache
curl -I https://votre-app.vercel.app | grep -i cache
```

## 🔄 CI/CD Integration

```bash
# Déployer depuis CI/CD
vercel --prod --token $VERCEL_TOKEN

# Vérifier le statut d'un déploiement
vercel inspect <deployment-url> --wait
```

## 📚 Ressources

- [Vercel Dashboard](https://vercel.com/dashboard)
- [Vercel CLI Docs](https://vercel.com/docs/cli)
- [Vercel Environment Variables](https://vercel.com/docs/concepts/projects/environment-variables)
- [Vercel Analytics](https://vercel.com/docs/analytics)
- [Vercel Edge Functions](https://vercel.com/docs/functions/edge-functions)