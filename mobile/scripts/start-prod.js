#!/usr/bin/env node

/**
 * Script pour lancer Expo en mode production avec URL de production
 * Usage: npm run prod
 */

const { spawn } = require('child_process');

// URL de production par défaut (peut être surchargée par EXPO_PUBLIC_PROD_API_URL)
const PROD_API_URL = process.env.EXPO_PUBLIC_PROD_API_URL || 
                     process.env.PROD_API_URL ||
                     'https://your-agent.up.railway.app';

if (!process.env.EXPO_PUBLIC_PROD_API_URL && !process.env.PROD_API_URL) {
  console.warn('⚠️  Aucune URL de production configurée.');
  console.warn(`   Utilisation de l'URL par défaut: ${PROD_API_URL}`);
  console.warn('   Pour configurer: export EXPO_PUBLIC_PROD_API_URL=https://votre-api.com\n');
}

// Configurer la variable d'environnement et lancer Expo
process.env.EXPO_PUBLIC_API_URL = PROD_API_URL;
process.env.NODE_ENV = 'production';

console.log(`🌐 Mode: Production`);
console.log(`🔗 URL API: ${PROD_API_URL}\n`);
console.log('🚀 Lancement d\'Expo en mode production...\n');

// Lancer Expo avec les arguments passés
const args = process.argv.slice(2);
const expoProcess = spawn('npx', ['expo', 'start', ...args], {
  stdio: 'inherit',
  shell: false,
  env: {
    ...process.env,
    EXPO_PUBLIC_API_URL: PROD_API_URL,
  },
});

expoProcess.on('error', (error) => {
  console.error('❌ Erreur lors du lancement d\'Expo:', error);
  process.exit(1);
});

expoProcess.on('exit', (code) => {
  process.exit(code || 0);
});

