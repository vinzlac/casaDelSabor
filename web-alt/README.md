# Web Alt - Casa del Sabor

Site web alternatif pour le restaurant Casa del Sabor avec un design mexicain coloré et festif.

## 🏗️ Architecture

- **Framework** : Next.js 16 (App Router)
- **Langage** : TypeScript
- **Styling** : Tailwind CSS 4 avec palette mexicaine
- **UI Components** : shadcn/ui
- **Chatbot** : Intégration avec l'agent FastAPI RAG

## 📋 Prérequis

- Node.js 18+ et npm
- Serveur backend (agent) lancé sur `http://localhost:8000`

## 🚀 Installation

```bash
cd web-alt
npm install
```

## 🎯 Utilisation

### Développement

```bash
npm run dev
```

L'application sera accessible sur `http://localhost:3001`

### Production

```bash
npm run build
npm start
```

## 📁 Structure

```
web-alt/
├── src/
│   ├── app/
│   │   ├── layout.tsx              # Layout avec chatbot global
│   │   ├── page.tsx                # Page d'accueil (sections)
│   │   ├── menu/
│   │   │   └── page.tsx            # Page menu complète
│   │   ├── reservation/
│   │   │   └── page.tsx            # Page réservation
│   │   ├── contact/
│   │   │   └── page.tsx            # Page contact
│   │   ├── api/
│   │   │   └── chat/
│   │   │       └── route.ts       # API route proxy vers agent
│   │   └── globals.css             # Styles globaux + thème mexicain
│   ├── components/
│   │   ├── ui/                     # Composants shadcn/ui
│   │   ├── chatbot/
│   │   │   ├── ChatbotWidget.tsx   # Widget chatbot flottant
│   │   │   └── ChatWindow.tsx      # Fenêtre de chat
│   │   ├── sections/
│   │   │   ├── HeroSection.tsx     # Section hero
│   │   │   ├── MenuSection.tsx     # Section menu (accueil)
│   │   │   ├── HoursSection.tsx   # Section horaires
│   │   │   ├── AboutSection.tsx    # Section à propos
│   │   │   └── ReservationSection.tsx
│   │   ├── menu/
│   │   │   ├── MenuCategory.tsx    # Catégorie de menu
│   │   │   └── MenuItem.tsx        # Item de menu
│   │   └── reservation/
│   │       └── ReservationForm.tsx # Formulaire de réservation
│   ├── lib/
│   │   ├── utils.ts                # Utilitaires (cn, etc.)
│   │   └── api.ts                  # Client API pour chatbot
│   └── types/
│       ├── chat.ts                 # Types chatbot
│       └── restaurant.ts           # Types restaurant
├── public/                         # Assets statiques
└── package.json
```

## 🎨 Palette de couleurs mexicaine

Le thème utilise des couleurs vives et festives :
- **Rouge mexicain** : `#DC143C`
- **Vert mexicain** : `#228B22`
- **Jaune doré** : `#FFD700`
- **Orange vif** : `#FF8C00`
- **Rose fuchsia** : `#FF69B4`
- **Bleu ciel** : `#1E90FF`

## 🔧 Configuration

### Variables d'environnement

Créez un fichier `.env.local` à la racine du dossier `web-alt/` :

```env
AGENT_URL=http://localhost:8000
```

Par défaut, l'application utilise `http://localhost:8000` pour l'agent backend.

## 🎨 Fonctionnalités

- 💬 Chatbot flottant toujours visible (bas à droite)
- 🏠 Page d'accueil avec sections (Hero, Menu, Horaires, À propos, Réservation)
- 📋 Page Menu complète avec catégories et filtres
- 📅 Page Réservation avec formulaire
- 📍 Page Contact avec carte et informations
- 📱 Design responsive (mobile-first)
- ⚡ Hot reload en développement
- 🎯 SEO optimisé avec structured data
- 🎨 Design mexicain coloré et festif

## 🔗 Intégration avec l'agent

Le chatbot utilise l'API `/api/chat` qui fait office de proxy vers l'agent FastAPI :

1. Le frontend envoie une requête POST à `/api/chat`
2. L'API Route fait un proxy vers `http://localhost:8000/chat`
3. La réponse est renvoyée au frontend

Cette architecture permet :
- De gérer les CORS facilement
- D'ajouter une couche de sécurité
- De faire du fallback si l'agent n'est pas disponible

## 🚢 Déploiement

### Vercel (recommandé)

1. Connecter votre repo GitHub à Vercel
2. Configurer le root directory : `/web-alt`
3. Ajouter la variable d'environnement `AGENT_URL` avec l'URL de votre agent déployé
4. Déployer

### Autres plateformes

```bash
npm run build
```

Le dossier `.next` contient l'application prête pour la production.

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

**Le chatbot ne s'affiche pas** :
- Vérifier que le composant `ChatbotWidget` est bien inclus dans le layout
- Vérifier les styles CSS (gradient-mexican, etc.)

## 📚 Technologies utilisées

- Next.js 16
- React 19
- TypeScript
- Tailwind CSS 4
- shadcn/ui
- Lucide React (icônes)
- date-fns
