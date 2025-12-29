#!/usr/bin/env node

/**
 * Script pour lancer Expo en mode développement avec détection automatique de l'IP locale
 * Usage: npm run dev
 */

const { spawn } = require('child_process');
const { getLocalIP, getHostname } = require('./get-local-ip');

// Port par défaut de l'API backend
const API_PORT = process.env.API_PORT || '8000';

// Détecter l'IP locale
const ip = getLocalIP();
const hostname = getHostname();

let apiUrl = null;

// Priorité: IP > hostname
if (ip) {
  apiUrl = `http://${ip}:${API_PORT}`;
  console.log(`🌐 IP locale détectée: ${ip}`);
  console.log(`🔗 URL API configurée: ${apiUrl}`);
} else if (hostname) {
  apiUrl = `http://${hostname}:${API_PORT}`;
  console.log(`🌐 Nom d'hôte détecté: ${hostname}`);
  console.log(`🔗 URL API configurée: ${apiUrl}`);
} else {
  console.error('❌ Impossible de détecter automatiquement l\'IP locale.');
  console.log('💡 Vous pouvez définir manuellement: export EXPO_PUBLIC_API_URL=http://VOTRE_IP:8000');
  process.exit(1);
}

// Configurer la variable d'environnement et lancer Expo
process.env.EXPO_PUBLIC_API_URL = apiUrl;
process.env.NODE_ENV = 'development';

console.log('\n🚀 Lancement d\'Expo en mode développement...\n');

// Lancer Expo avec les arguments passés
const args = process.argv.slice(2);
const expoProcess = spawn('npx', ['expo', 'start', ...args], {
  stdio: 'inherit',
  shell: false,
  env: {
    ...process.env,
    EXPO_PUBLIC_API_URL: apiUrl,
  },
});

expoProcess.on('error', (error) => {
  console.error('❌ Erreur lors du lancement d\'Expo:', error);
  process.exit(1);
});

expoProcess.on('exit', (code) => {
  process.exit(code || 0);
});

