# Casa del Sabor - Chatbot IA

Chatbot intelligent pour le restaurant mexicain Casa del Sabor, utilisant RAG (Retrieval-Augmented Generation) avec LangChain, Mistral AI et Qdrant.

## Architecture

```mermaid
flowchart TB
    subgraph Clients
        WebApp[Web App<br/>Next.js]
        MobileApp[Mobile App<br/>React Native/Expo]
    end

    subgraph Backend[Agent Python]
        FastAPI[FastAPI Server]
        LangChain[LangChain]
        Tools[Tools<br/>Réservation]
        Memory[Session Memory]
    end

    subgraph Cloud[Services Cloud]
        Mistral[Mistral AI<br/>LLM + Embeddings]
        Qdrant[(Qdrant Cloud<br/>Vector Store)]
    end

    subgraph Data[Documents]
        Menu[menu.md]
        Horaires[horaires.md]
        Info[info.md]
    end

    WebApp -->|HTTP POST /chat| FastAPI
    MobileApp -->|HTTP POST /chat| FastAPI
    FastAPI --> LangChain
    LangChain --> Tools
    LangChain --> Memory
    LangChain -->|Completion| Mistral
    LangChain -->|Embeddings| Mistral
    LangChain -->|Similarity Search| Qdrant
    Data -->|POST /ingest| FastAPI
    FastAPI -->|Index| Qdrant
```

## Diagramme de séquence - Chat

```mermaid
sequenceDiagram
    participant User as Utilisateur
    participant App as App Web/Mobile
    participant Agent as Agent Python
    participant RAG as RAG Chain
    participant Qdrant as Qdrant Cloud
    participant Mistral as Mistral AI

    User->>App: Envoie message
    App->>Agent: POST /chat {message, session_id}
    
    Agent->>Agent: Récupère historique session
    Agent->>Mistral: Génère embedding question
    Mistral-->>Agent: Vector embedding
    
    Agent->>Qdrant: Recherche documents similaires
    Qdrant-->>Agent: Top 4 chunks pertinents
    
    Agent->>RAG: Construit prompt avec contexte
    RAG->>Mistral: Génère réponse (LLM)
    
    alt Appel d'outil requis
        Mistral-->>RAG: Tool call (réservation)
        RAG->>Agent: Exécute outil
        Agent-->>RAG: Résultat outil
        RAG->>Mistral: Génère réponse finale
    end
    
    Mistral-->>RAG: Réponse générée
    RAG-->>Agent: Réponse + sources
    Agent->>Agent: Sauvegarde dans session
    Agent-->>App: {response, sources, session_id}
    App-->>User: Affiche réponse
```

## Diagramme de séquence - Ingestion

```mermaid
sequenceDiagram
    participant Admin as Administrateur
    participant Agent as Agent Python
    participant Loader as Document Loader
    participant Splitter as Text Splitter
    participant Mistral as Mistral AI
    participant Qdrant as Qdrant Cloud

    Admin->>Agent: POST /ingest
    Agent->>Loader: Charge documents/*.md
    Loader-->>Agent: Documents bruts
    
    Agent->>Splitter: Découpe en chunks
    Splitter-->>Agent: Chunks (500 chars)
    
    loop Pour chaque chunk
        Agent->>Mistral: Génère embedding
        Mistral-->>Agent: Vector (1024 dim)
    end
    
    Agent->>Qdrant: Stocke vectors + metadata
    Qdrant-->>Agent: OK
    Agent-->>Admin: {chunks_indexed: N}
```

## Structure du projet

```
casaDelSabor/
├── src/                      # Frontend Next.js
│   ├── app/
│   │   ├── api/chat/         # API Route proxy
│   │   └── page.tsx
│   └── components/chat/      # Composants React
│
├── agent/                    # Backend Python
│   ├── main.py               # FastAPI app
│   ├── config.py             # Configuration
│   ├── rag/
│   │   ├── chain.py          # RAG Chain + Agent
│   │   ├── tools.py          # Outils (réservation)
│   │   ├── memory.py         # Gestion sessions
│   │   ├── embeddings.py     # Mistral Embeddings
│   │   ├── vectorstore.py    # Client Qdrant
│   │   └── ingestion.py      # Ingestion documents
│   └── documents/            # Documents restaurant
│       ├── menu.md
│       ├── horaires.md
│       └── info.md
│
└── mobile/                   # App React Native
    ├── App.tsx
    └── src/
        ├── screens/
        ├── components/
        └── services/
```

## Démarrage rapide

### 1. Agent Python

```bash
cd agent
cp .env.example .env          # Configurer les clés API
just install
just ingest                   # Indexer les documents
just dev                      # Lancer le serveur
```

### 2. Frontend Web

```bash
npm install
npm run dev -- --hostname 0.0.0.0
```

### 3. App Mobile

#### Prérequis

1. **Installer Expo Go sur votre téléphone** :
   - **iPhone** : Télécharger [Expo Go](https://apps.apple.com/app/expo-go/id982107779) depuis l'App Store
   - **Android** : Télécharger [Expo Go](https://play.google.com/store/apps/details?id=host.exp.exponent) depuis le Google Play Store

2. **Installer Expo CLI** (si ce n'est pas déjà fait) :
   ```bash
   npm install -g expo-cli
   ```

3. **S'assurer que votre téléphone et votre ordinateur sont sur le même réseau Wi-Fi**

#### Connexion à votre compte Expo (optionnel mais recommandé)

Se connecter à votre compte Expo permet de :
- Synchroniser vos projets entre appareils
- Utiliser les services Expo (EAS Build, EAS Update, etc.)
- Accéder à vos projets depuis n'importe quel appareil

**Se connecter** :
```bash
cd mobile
npx expo login
```

Vous serez invité à entrer votre email et mot de passe Expo. Si vous n'avez pas de compte, créez-en un sur [expo.dev](https://expo.dev).

**Vérifier votre connexion** :
```bash
npx expo whoami
```

**Se déconnecter** :
```bash
npx expo logout
```

> **Note** : La connexion à un compte Expo n'est pas obligatoire pour développer localement avec Expo Go, mais elle est recommandée pour accéder à toutes les fonctionnalités d'Expo.

#### Lancement de l'application

```bash
cd mobile
npm install
npx expo start
```

Après avoir lancé `expo start`, vous verrez un QR code dans votre terminal. 

**Sur iPhone** :
- Ouvrir l'app **Appareil photo** native
- Scanner le QR code affiché dans le terminal
- L'app Expo Go s'ouvrira automatiquement avec votre application

**Sur Android** :
- Ouvrir l'app **Expo Go**
- Appuyer sur "Scan QR Code"
- Scanner le QR code affiché dans le terminal

#### Accéder au menu de développement Expo

Une fois l'application lancée sur votre téléphone, vous pouvez accéder au menu de développement Expo de plusieurs façons :

1. **Secouer le téléphone** (shake gesture) - Méthode principale
   - Sur iPhone : Secouer vigoureusement le téléphone
   - Sur Android : Secouer le téléphone ou appuyer sur le bouton menu
   - Le menu Expo apparaîtra avec les options : Reload, Debug, etc.

2. **Geste à trois doigts** (alternative)
   - Appuyer avec trois doigts sur l'écran

3. **Multitâche iOS**
   - Glisser depuis le bas de l'écran et maintenir
   - Revenir à l'app Expo Go depuis le sélecteur d'applications

#### Options du menu Expo

Le menu de développement Expo offre plusieurs fonctionnalités utiles :

- **Reload** : Recharge l'application sans redémarrer
- **Debug Remote JS** : Active le débogage JavaScript
- **Show Element Inspector** : Inspecte les éléments de l'interface
- **Performance Monitor** : Affiche les performances en temps réel
- **Settings** : Paramètres de développement

#### Dépannage

**Le menu Expo n'apparaît pas** :
- Vérifier que vous utilisez bien Expo Go (pas une build standalone)
- Secouer plus vigoureusement le téléphone
- Redémarrer l'app Expo Go
- Relancer le serveur Expo avec `npx expo start`

**L'application ne se charge pas** :
- Vérifier que le téléphone et l'ordinateur sont sur le même réseau Wi-Fi
- Vérifier que le serveur backend (agent) est bien lancé
- Vérifier l'URL de l'API dans `mobile/src/config/api.ts`

**Erreur de connexion** :
- Vérifier que le port utilisé par Expo n'est pas bloqué par un firewall
- Essayer de lancer avec `npx expo start --tunnel` pour utiliser le tunnel Expo

**Configuration de l'API** :

L'URL de l'API backend est configurée dans `mobile/src/config/api.ts`. 

En développement, vous devrez peut-être modifier l'URL pour qu'elle corresponde à l'adresse IP de votre ordinateur :

1. Trouver votre adresse IP locale :
   ```bash
   # Sur macOS/Linux
   hostname -I
   # ou
   ipconfig getifaddr en0
   
   # Sur Windows
   ipconfig
   ```

2. Modifier `mobile/src/config/api.ts` :
   ```typescript
   const DEV_API_URL = 'http://VOTRE_IP_LOCALE:8000';
   ```

3. Redémarrer l'application Expo après modification

## Configuration

### Variables d'environnement (agent/.env)

| Variable | Description |
|----------|-------------|
| `MISTRAL_API_KEY` | Clé API Mistral AI |
| `QDRANT_URL` | URL Qdrant Cloud |
| `QDRANT_API_KEY` | Clé API Qdrant |

## Technologies

| Composant | Technologie |
|-----------|-------------|
| Frontend Web | Next.js 15, React, TypeScript |
| App Mobile | React Native, Expo |
| Backend | Python, FastAPI, LangChain |
| LLM | Mistral AI (mistral-small-latest) |
| Embeddings | Mistral AI (mistral-embed) |
| Vector Store | Qdrant Cloud |
| Package Manager | uv, npm |
| Task Runner | just |

## Fonctionnalités

- Chat conversationnel avec mémoire de session
- RAG sur les documents du restaurant (menu, horaires, infos)
- Outil de réservation (prototype)
- Interface WhatsApp-like
- Support Web et Mobile
