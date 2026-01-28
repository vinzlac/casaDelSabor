# Persistance de l'historique du chat

Ce document explique comment l'historique du chat est maintenant sauvegardé et restauré automatiquement.

## 🎯 Fonctionnalité

Lorsque l'utilisateur ferme et rouvre la fenêtre de chat, **l'historique complet est préservé** :
- ✅ Tous les messages précédents sont restaurés
- ✅ Le `sessionId` est conservé (permet de continuer la même conversation)
- ✅ Les timestamps sont préservés
- ✅ Fonctionne même après un rechargement de page

## 🔧 Implémentation

### Stockage

Les données sont sauvegardées dans le **localStorage** du navigateur :

| Clé | Contenu | Format |
|-----|---------|--------|
| `casadelsabor_chat_history` | Historique des messages | JSON array de Message |
| `casadelsabor_session_id` | ID de session RAG | string |

### Cycle de vie

#### 1. Chargement initial

Au montage du composant :
```typescript
// Charger l'historique
const history = loadChatHistory();
setMessages(history);

// Charger le sessionId
const savedSessionId = loadSessionId();
setSessionId(savedSessionId);
```

#### 2. Sauvegarde automatique

Chaque fois que les messages ou le sessionId changent :
```typescript
// Sauvegarder les messages
useEffect(() => {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(messages));
}, [messages]);

// Sauvegarder le sessionId
useEffect(() => {
  if (sessionId) {
    localStorage.setItem(SESSION_KEY, sessionId);
  }
}, [sessionId]);
```

#### 3. Effacement manuel

Bouton "Effacer l'historique" (icône poubelle) :
```typescript
const handleClearHistory = () => {
  if (confirm('Voulez-vous vraiment effacer...')) {
    setMessages([createInitialMessage()]);
    setSessionId(null);
    localStorage.removeItem(STORAGE_KEY);
    localStorage.removeItem(SESSION_KEY);
  }
};
```

## 🎨 Interface utilisateur

### Frontend web-alt

**Ajout dans le header du chat :**
- Icône poubelle (🗑️) pour effacer l'historique
- Icône croix (✕) pour fermer le chat (sans perdre l'historique)

```tsx
<div className="flex items-center gap-1">
  <Button onClick={handleClearHistory} title="Effacer l'historique">
    <Trash2 className="h-4 w-4" />
  </Button>
  <Button onClick={onClose} title="Fermer le chat">
    <X className="h-4 w-4" />
  </Button>
</div>
```

### Frontend web

**Bouton déjà existant dans ChatHeader :**
- Le bouton "Reset" efface maintenant aussi le localStorage

## 🔒 Sécurité et vie privée

### Durée de conservation

Les données restent dans le localStorage jusqu'à ce que :
- L'utilisateur clique sur "Effacer l'historique"
- L'utilisateur vide les données de navigation du navigateur
- L'utilisateur utilise le mode privé/incognito (pas de persistance)

### Données stockées

**Ce qui est stocké :**
- Messages de l'utilisateur et du bot
- Timestamps des messages
- Session ID pour la continuité de conversation

**Ce qui N'est PAS stocké :**
- Aucune donnée personnelle identifiable
- Pas de cookies
- Pas de données sensibles

### Limitations du localStorage

- **Quota** : ~5-10 MB par domaine (largement suffisant pour l'historique de chat)
- **Domaine** : Les données ne sont accessibles que depuis le même domaine
- **Client-side only** : Les données restent sur le navigateur de l'utilisateur

## 🧪 Test

### Scénario de test 1 : Fermeture/Réouverture

1. Ouvrir le chat
2. Envoyer quelques messages
3. Fermer le chat (croix ✕)
4. Rouvrir le chat
5. ✅ Vérifier que tous les messages sont toujours là

### Scénario de test 2 : Rechargement de page

1. Ouvrir le chat
2. Envoyer quelques messages
3. Recharger la page (F5)
4. Rouvrir le chat
5. ✅ Vérifier que tous les messages sont restaurés

### Scénario de test 3 : Continuité de conversation

1. Ouvrir le chat
2. Poser une question : "Quels sont vos horaires ?"
3. Fermer et rouvrir le chat
4. Poser une question de suivi : "Et pour le dimanche ?"
5. ✅ Vérifier que le bot comprend le contexte (grâce au sessionId préservé)

### Scénario de test 4 : Effacement

1. Ouvrir le chat avec des messages
2. Cliquer sur l'icône poubelle 🗑️
3. Confirmer l'effacement
4. ✅ Vérifier que l'historique est vide (seulement le message de bienvenue)
5. Fermer et rouvrir le chat
6. ✅ Vérifier que l'historique reste vide

## 🐛 Dépannage

### L'historique ne se sauvegarde pas

**Vérifier :**
- Le localStorage est activé dans le navigateur
- Pas de mode navigation privée/incognito actif
- Pas d'extensions bloquant le localStorage
- La console ne montre pas d'erreurs

**Test localStorage :**
```javascript
// Dans la console du navigateur
localStorage.setItem('test', 'ok');
console.log(localStorage.getItem('test')); // Devrait afficher 'ok'
```

### L'historique est perdu après un certain temps

**Cause probable :** Le navigateur a vidé le cache/localStorage

**Solution :** 
- Vérifier les paramètres du navigateur
- Ne pas utiliser de nettoyeurs automatiques de données

### Messages dupliqués

**Cause probable :** Multiple sauvegardes simultanées

**Solution :** Déjà gérée par les `useEffect` avec dépendances appropriées

## 📱 Mobile (React Native)

Pour le mobile, la persistance n'est pas encore implémentée. Pour l'ajouter :

**Option 1 : AsyncStorage**
```bash
npm install @react-native-async-storage/async-storage
```

**Option 2 : Expo SecureStore**
```bash
npx expo install expo-secure-store
```

Appliquer la même logique que pour le web avec `AsyncStorage.setItem()` et `AsyncStorage.getItem()`.

## 🔄 Migration future

Si vous souhaitez migrer vers un stockage serveur (base de données) :

1. Créer un endpoint `/api/chat/history` sur le backend
2. Sauvegarder les messages côté serveur avec un userId
3. Récupérer l'historique lors de la connexion
4. Garder le localStorage comme cache local

**Avantages du stockage serveur :**
- Historique accessible depuis plusieurs appareils
- Pas de perte de données si le localStorage est vidé
- Possibilité d'analytics et d'amélioration du chatbot

**Pour l'instant, le localStorage suffit** car :
- Simple à implémenter
- Pas besoin d'authentification
- Respect de la vie privée (données locales)
- Rapide et efficace

## 📚 Ressources

- [MDN - Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API)
- [localStorage limits](https://web.dev/storage-for-the-web/)
