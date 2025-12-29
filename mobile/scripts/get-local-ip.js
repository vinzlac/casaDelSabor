#!/usr/bin/env node

/**
 * Script pour détecter automatiquement l'IP locale de la machine
 * et l'injecter dans app.json ou afficher pour configuration
 */

const os = require('os');
const { execSync } = require('child_process');

function getLocalIP() {
  try {
    // Sur macOS/Linux, essayer d'obtenir l'IP de l'interface principale
    const platform = os.platform();
    
    if (platform === 'darwin') {
      // macOS - utiliser ipconfig getifaddr en0 (interface Wi-Fi principale)
      try {
        const ip = execSync('ipconfig getifaddr en0', { encoding: 'utf-8' }).trim();
        if (ip) return ip;
      } catch (e) {
        // Essayer en1 si en0 ne fonctionne pas
        try {
          const ip = execSync('ipconfig getifaddr en1', { encoding: 'utf-8' }).trim();
          if (ip) return ip;
        } catch (e2) {
          // Ignorer
        }
      }
    } else if (platform === 'linux') {
      // Linux - utiliser hostname -I
      try {
        const ip = execSync('hostname -I', { encoding: 'utf-8' }).trim().split(' ')[0];
        if (ip) return ip;
      } catch (e) {
        // Ignorer
      }
    }
    
    // Fallback: utiliser les interfaces réseau
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
      for (const iface of interfaces[name]) {
        // Ignorer les adresses internes et IPv6
        if (iface.family === 'IPv4' && !iface.internal) {
          return iface.address;
        }
      }
    }
  } catch (error) {
    console.error('Erreur lors de la détection de l\'IP:', error.message);
  }
  
  return null;
}

function getHostname() {
  try {
    // Sur macOS, utiliser le nom d'hôte .local
    const hostname = os.hostname();
    if (!hostname) return null;
    
    // Si le hostname se termine déjà par .local, ne pas l'ajouter à nouveau
    if (hostname.endsWith('.local')) {
      return hostname;
    }
    
    return `${hostname}.local`;
  } catch (error) {
    return null;
  }
}

const ip = getLocalIP();
const hostname = getHostname();

if (ip) {
  console.log(`IP locale détectée: ${ip}`);
  console.log(`URL API suggérée: http://${ip}:8000`);
}

if (hostname) {
  console.log(`Nom d'hôte détecté: ${hostname}`);
  console.log(`URL API alternative: http://${hostname}:8000`);
}

if (!ip && !hostname) {
  console.log('Impossible de détecter automatiquement l\'IP locale.');
  console.log('Veuillez configurer manuellement dans app.json ou via EXPO_PUBLIC_API_URL');
  process.exit(1);
}

// Exporter pour utilisation dans d'autres scripts
if (require.main === module) {
  // Si exécuté directement, afficher les résultats
  process.exit(0);
}

module.exports = { getLocalIP, getHostname };

