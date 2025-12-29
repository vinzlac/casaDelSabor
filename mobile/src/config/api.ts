// Configuration de l'API
// En développement, utilise l'IP locale de ton Mac
// Remplace par l'URL de production quand déployé

// Pour trouver ton IP: hostname ou ipconfig getifaddr en0
const DEV_API_URL = 'http://MacBook-Pro-de-Vincent.local:8000';

// URL de production (Railway)
const PROD_API_URL = 'https://your-agent.up.railway.app';

// Utilise la variable d'environnement ou le mode dev
export const API_URL = __DEV__ ? DEV_API_URL : PROD_API_URL;
