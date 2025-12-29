# Mobile App - Casa del Sabor

Application mobile React Native/Expo pour le chatbot Casa del Sabor.

## 🏗️ Architecture

- **Framework** : React Native avec Expo
- **Langage** : TypeScript
- **Navigation** : Expo Router (si configuré)
- **UI** : Interface WhatsApp-like native

## 📋 Prérequis

1. **Node.js 18+ et npm**
2. **Expo Go installé sur votre téléphone** :
   - [iPhone - App Store](https://apps.apple.com/app/expo-go/id982107779)
   - [Android - Google Play](https://play.google.com/store/apps/details?id=host.exp.exponent)
3. **Serveur backend (agent) lancé** sur `http://localhost:8000`
4. **Téléphone et ordinateur sur le même réseau Wi-Fi**

## 🚀 Installation

```bash
cd mobile
npm install
```

## 🎯 Utilisation

### Mode développement (recommandé)

Détecte automatiquement l'IP locale et configure l'URL de l'API :

```bash
npm run dev
```

Le script :
1. Détecte automatiquement votre IP locale
2. Configure `EXPO_PUBLIC_API_URL` avec l'IP détectée
3. Lance Expo avec la bonne configuration

### Mode production

Pour pointer vers un serveur distant (Railway, etc.) :

```bash
export EXPO_PUBLIC_PROD_API_URL=https://votre-api.up.railway.app
npm run prod
```

### Commandes alternatives

```bash
npm run android    # Lance sur Android avec détection automatique
npm run ios        # Lance sur iOS avec détection automatique
npm start          # Lance Expo sans configuration automatique
npm run get-ip     # Affiche votre IP locale
```

## 📱 Utilisation sur téléphone

1. Lancer `npm run dev`
2. Un QR code apparaît dans le terminal
3. **Sur iPhone** : Ouvrir l'app **Appareil photo** et scanner le QR code
4. **Sur Android** : Ouvrir **Expo Go** et scanner le QR code
5. L'application se charge automatiquement

## 🎛️ Menu de développement Expo

Une fois l'app lancée sur votre téléphone :

1. **Secouer le téléphone** (shake gesture) - Méthode principale
2. **Geste à trois doigts** - Alternative
3. **Multitâche iOS** - Glisser depuis le bas

Le menu offre :
- **Reload** : Recharge l'application
- **Debug Remote JS** : Active le débogage
- **Show Element Inspector** : Inspecte les éléments
- **Performance Monitor** : Affiche les performances

## 📁 Structure

```
mobile/
├── src/
│   ├── screens/
│   │   └── ChatScreen.tsx        # Écran principal du chat
│   ├── components/
│   │   ├── ChatHeader.tsx        # En-tête du chat
│   │   ├── ChatInput.tsx         # Input de message
│   │   ├── ChatMessage.tsx       # Message individuel
│   │   └── TypingIndicator.tsx   # Indicateur de frappe
│   ├── services/
│   │   └── chatService.ts        # Service API pour le chat
│   ├── config/
│   │   └── api.ts                # Configuration de l'API (détection auto)
│   └── types/
│       └── chat.ts               # Types TypeScript
├── assets/                       # Images et icônes
├── scripts/
│   ├── get-local-ip.js          # Détection IP locale
│   ├── start-dev.js              # Script de démarrage dev
│   └── start-prod.js            # Script de démarrage prod
├── App.tsx                       # Point d'entrée
├── app.json                      # Configuration Expo
└── package.json
```

## 🔧 Configuration de l'API

L'URL de l'API backend est détectée **automatiquement** dans `src/config/api.ts`.

### Priorité de configuration

1. **Variable d'environnement `EXPO_PUBLIC_API_URL`** (priorité la plus haute)
2. **Variable dans `app.json` (extra.apiUrl)**
3. **Détection automatique du nom d'hôte** (macOS) - utilisée par `npm run dev`
4. **Fallback localhost**

### Configuration manuelle (optionnel)

Si vous devez forcer une URL spécifique :

**Option 1 : Variable d'environnement**
```bash
export EXPO_PUBLIC_API_URL=http://192.168.1.100:8000
npm run dev
```

**Option 2 : app.json**
```json
{
  "expo": {
    "extra": {
      "apiUrl": "http://192.168.1.100:8000"
    }
  }
}
```

**Option 3 : Vérifier votre IP**
```bash
npm run get-ip
```

## 🔗 Connexion à Expo

### Se connecter à son compte Expo (optionnel)

```bash
npx expo login
```

Avantages :
- Synchronisation entre appareils
- Accès aux services Expo (EAS Build, EAS Update)
- Gestion des projets

### Vérifier la connexion

```bash
npx expo whoami
```

## 🚢 Build et déploiement

### Build de développement

```bash
npm run dev
```

### Build de production

Pour créer une build standalone :

```bash
npx expo build:android
npx expo build:ios
```

Ou utiliser EAS Build (recommandé) :

```bash
npm install -g eas-cli
eas build --platform android
eas build --platform ios
```

## 🐛 Dépannage

**Le menu Expo n'apparaît pas** :
- Vérifier que vous utilisez Expo Go (pas une build standalone)
- Secouer plus vigoureusement le téléphone
- Redémarrer l'app Expo Go

**L'application ne se charge pas** :
- Vérifier que le téléphone et l'ordinateur sont sur le même réseau Wi-Fi
- Vérifier que le serveur backend (agent) est bien lancé
- Vérifier l'URL de l'API avec `npm run get-ip`

**Erreur de connexion à l'API** :
- Vérifier que l'agent est accessible depuis votre téléphone
- Essayer avec `npx expo start --tunnel` pour utiliser le tunnel Expo
- Vérifier les logs dans Expo Go (secouer le téléphone → Debug Remote JS)

**L'IP n'est pas détectée automatiquement** :
- Vérifier avec `npm run get-ip`
- Configurer manuellement avec `EXPO_PUBLIC_API_URL`
- Vérifier que vous êtes sur le même réseau Wi-Fi

## 📚 Ressources

- [Documentation Expo](https://docs.expo.dev/)
- [React Native](https://reactnative.dev/)
- [Expo Go](https://expo.dev/client)

