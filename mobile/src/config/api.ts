// Configuration de l'API
// En développement, utilise l'IP locale détectée automatiquement
// Remplace par l'URL de production quand déployé

// Import conditionnel de expo-constants
let Constants: any = null;
try {
  Constants = require('expo-constants');
} catch (e) {
  // expo-constants n'est pas encore installé, on utilisera les fallbacks
  console.warn('expo-constants non disponible, utilisation des variables d\'environnement');
}

// Fonction pour obtenir l'IP locale depuis les variables d'environnement
const getLocalIP = (): string => {
  // Option 1: Variable d'environnement système (EXPO_PUBLIC_API_URL) - priorité la plus haute
  if (process.env.EXPO_PUBLIC_API_URL) {
    return process.env.EXPO_PUBLIC_API_URL;
  }

  // Option 2: Variable d'environnement définie dans app.json (extra.apiUrl)
  if (Constants?.expoConfig?.extra?.apiUrl) {
    return Constants.expoConfig.extra.apiUrl;
  }

  // Option 3: Utiliser le nom d'hôte local depuis Constants (fonctionne sur macOS)
  if (Constants?.expoConfig?.hostUri) {
    const hostname = Constants.expoConfig.hostUri.split(':')[0];
    if (hostname && hostname !== 'localhost' && hostname !== '127.0.0.1') {
      return `http://${hostname}:8000`;
    }
  }

  // Option 4: Fallback - utilise localhost (nécessitera un tunnel ou un autre réseau)
  // En production, cela ne devrait jamais arriver
  console.warn('Aucune URL API configurée, utilisation de localhost par défaut');
  return 'http://localhost:8000';
};

// URL de production (Railway)
const PROD_API_URL = 
  process.env.EXPO_PUBLIC_PROD_API_URL ||
  Constants?.expoConfig?.extra?.prodApiUrl || 
  'https://your-agent.up.railway.app';

// Utilise la variable d'environnement ou le mode dev
export const API_URL = __DEV__ ? getLocalIP() : PROD_API_URL;
