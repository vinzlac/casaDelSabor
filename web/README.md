# Web App - Casa del Sabor

Application web Next.js pour le chatbot Casa del Sabor.

## 🏗️ Architecture

- **Framework** : Next.js 16 (App Router)
- **Langage** : TypeScript
- **Styling** : Tailwind CSS 4
- **UI** : Interface WhatsApp-like

## 📋 Prérequis

- Node.js 18+ et npm
- Serveur backend (agent) lancé sur `http://localhost:8000`

## 🚀 Installation

```bash
cd web
npm install
```

## 🎯 Utilisation

### Développement

```bash
npm run dev -- --hostname 0.0.0.0
```

L'application sera accessible sur `http://localhost:3000`

### Production

```bash
npm run build
npm start
```

## 📁 Structure

```
web/
├── src/
│   ├── app/
│   │   ├── api/
│   │   │   └── chat/
│   │   │       └── route.ts      # API Route proxy vers l'agent
│   │   ├── layout.tsx            # Layout principal
│   │   ├── page.tsx              # Page d'accueil (chat)
│   │   └── globals.css           # Styles globaux
│   ├── components/
│   │   └── chat/
│   │       ├── ChatContainer.tsx # Container principal
│   │       ├── ChatHeader.tsx    # En-tête du chat
│   │       ├── ChatInput.tsx     # Input de message
│   │       ├── ChatMessage.tsx   # Message individuel
│   │       ├── TypingIndicator.tsx # Indicateur de frappe
│   │       └── index.ts          # Exports
│   └── types/
│       └── chat.ts               # Types TypeScript
├── public/                       # Assets statiques
├── next.config.ts                # Configuration Next.js
└── package.json
```

## 🔧 Configuration

### Variables d'environnement

Créez un fichier `.env.local` à la racine du dossier `web/` :

```env
AGENT_URL=http://localhost:8000
```

Par défaut, l'application utilise `http://localhost:8000` pour l'agent backend.

### Configuration de l'API

L'URL de l'agent est configurée dans `src/app/api/chat/route.ts` :

```typescript
const AGENT_URL = process.env.AGENT_URL || 'http://localhost:8000';
```

## 🎨 Fonctionnalités

- 💬 Interface de chat conversationnel
- 📱 Design responsive (mobile-first)
- ⚡ Hot reload en développement
- 🎯 Mode démo si l'agent n'est pas disponible
- 📝 Affichage des sources des réponses (RAG)

## 🚢 Déploiement

### Vercel (recommandé)

Oui, il est tout à fait possible de déployer uniquement le sous-répertoire `web/` sur Vercel depuis un monorepo. Voici deux méthodes :

#### Méthode 1 : Via l'interface Vercel (recommandé)

1. Connecter votre repo GitHub à Vercel
2. Dans les paramètres du projet Vercel :
   - Aller dans **Settings** → **General**
   - Dans la section **Root Directory**, cliquer sur **Edit**
   - Sélectionner `web` comme répertoire racine
   - Cliquer sur **Save**
3. Aller dans **Settings** → **Environment Variables**
   - Ajouter la variable `AGENT_URL` avec l'URL de votre agent déployé (ex: `https://votre-agent.herokuapp.com`)
4. Déployer (automatique lors du push ou via le dashboard)

#### Méthode 2 : Via le CLI Vercel

```bash
cd web
vercel --cwd .
```

Ou depuis la racine du repo :

```bash
vercel --cwd web
```

Puis ajouter la variable d'environnement `AGENT_URL` via l'interface ou le CLI.

### Autres plateformes

```bash
npm run build
```

Le dossier `.next` contient l'application prête pour la production.

## 🔗 Intégration avec l'agent

L'application web communique avec l'agent Python via l'API Route `/api/chat` qui fait office de proxy :

1. Le frontend envoie une requête POST à `/api/chat`
2. L'API Route fait un proxy vers `http://localhost:8000/chat`
3. La réponse est renvoyée au frontend

Cette architecture permet :
- De gérer les CORS facilement
- D'ajouter une couche de sécurité
- De faire du fallback si l'agent n'est pas disponible

## 🐛 Dépannage

**L'application ne se connecte pas à l'agent** :
- Vérifier que l'agent est lancé sur `http://localhost:8000`
- Vérifier la variable d'environnement `AGENT_URL`
- Vérifier les logs de la console navigateur

**Erreur de build** :
```bash
rm -rf .next node_modules
npm install
npm run build
```

