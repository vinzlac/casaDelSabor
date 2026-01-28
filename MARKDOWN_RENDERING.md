# Rendu Markdown dans le Chat

Ce document explique comment le markdown est maintenant interprété graphiquement dans les réponses du chatbot.

## 🎨 Problème résolu

**Avant :**
```
- **Ana**, en salle, qui connaît les plats comme des histoires à raconter.
```

**Après :**
- **Ana**, en salle, qui connaît les plats comme des histoires à raconter.

Les marqueurs markdown (`**`, `-`, `#`, etc.) sont maintenant correctement interprétés et affichés graphiquement.

## 🔧 Implémentation

### Frontend Web (web-alt)

**Packages installés :**
- `react-markdown` : Convertit le markdown en React components
- `remark-gfm` : Support pour GitHub Flavored Markdown (tables, listes à puces améliorées, etc.)

**Fichiers modifiés :**
1. `web-alt/src/components/chatbot/MarkdownMessage.tsx` - Nouveau composant
2. `web-alt/src/components/chatbot/ChatWindow.tsx` - Utilise MarkdownMessage
3. `web-alt/package.json` - Dépendances ajoutées

### Frontend Web (web)

**Mêmes packages et structure**

**Fichiers modifiés :**
1. `web/src/components/chat/MarkdownMessage.tsx` - Nouveau composant
2. `web/src/components/chat/ChatMessage.tsx` - Utilise MarkdownMessage
3. `web/package.json` - Dépendances ajoutées

### Frontend Mobile (mobile)

**Package installé :**
- `react-native-markdown-display` : Rendu markdown pour React Native

**Fichiers modifiés :**
1. `mobile/src/components/ChatMessage.tsx` - Intègre le markdown avec styles personnalisés
2. `mobile/package.json` - Dépendance ajoutée

## 🎯 Éléments markdown supportés

### Texte formaté

| Markdown | Résultat |
|----------|----------|
| `**texte**` | **texte** (gras) |
| `*texte*` ou `_texte_` | *texte* (italique) |
| `` `code` `` | `code` (code inline) |

### Listes

**Listes à puces :**
```markdown
- Item 1
- Item 2
  - Sous-item
```

**Listes numérotées :**
```markdown
1. Premier
2. Deuxième
3. Troisième
```

### Titres

```markdown
# Titre 1
## Titre 2
### Titre 3
```

### Liens

```markdown
[Texte du lien](https://example.com)
```

### Citations

```markdown
> Ceci est une citation
```

### Code

**Inline :** `` `code` ``

**Bloc :**
````markdown
```
code
multilignes
```
````

### Séparateur

```markdown
---
```

## 🎨 Personnalisation des styles

### Web (web-alt & web)

Les styles sont définis dans `MarkdownMessage.tsx` via des classes Tailwind :

```tsx
<strong className="font-bold text-gray-900">{children}</strong>
<ul className="list-disc list-inside mb-2 space-y-1">{children}</ul>
```

**Pour modifier :**
- Éditer les composants dans `MarkdownMessage.tsx`
- Utiliser les classes Tailwind existantes
- Ajouter des classes CSS personnalisées si nécessaire

### Mobile

Les styles sont définis dans `ChatMessage.tsx` dans l'objet `markdownStyles` :

```tsx
const markdownStyles = {
  strong: {
    fontWeight: 'bold',
    color: '#111827',
  },
  bullet_list: {
    marginTop: 4,
    marginBottom: 4,
  },
  // ...
};
```

**Pour modifier :**
- Éditer l'objet `markdownStyles` dans `ChatMessage.tsx`
- Utiliser les propriétés StyleSheet standard de React Native

## 🧪 Test

Pour tester le rendu markdown, posez des questions au chatbot qui génèrent des réponses avec du markdown :

**Exemples de questions :**
- "Qui travaille dans le restaurant ?"
- "Quels sont vos plats ?"
- "Parle-moi de votre équipe"
- "Quelle est l'histoire du restaurant ?"

Ces questions utilisent le contenu de `storytelling.md` qui contient beaucoup de markdown.

## 📝 Notes importantes

### Messages utilisateur

Les messages de l'utilisateur restent en **texte brut** (pas de conversion markdown).

Seuls les messages du **bot** sont convertis en markdown.

### Performance

Le rendu markdown est très performant :
- Pas de ralentissement notable
- Conversion à la volée lors de l'affichage
- Pas de cache nécessaire pour les petits messages

### Compatibilité

- ✅ React 19 (web-alt & web)
- ✅ React Native / Expo (mobile)
- ✅ Next.js 16 (SSR/CSR)

## 🔄 Mise à jour

Si vous ajoutez de nouveaux éléments markdown dans les documents sources :

1. Aucune modification nécessaire côté agent (backend)
2. Le frontend interprète automatiquement tous les éléments markdown standard
3. Pour des éléments markdown personnalisés, modifier `MarkdownMessage.tsx`

## 🐛 Dépannage

### Les styles ne s'appliquent pas (Web)

Vérifier que Tailwind CSS est bien configuré et que la classe `prose` est disponible.

### Le markdown ne s'affiche pas (Mobile)

Vérifier que `react-native-markdown-display` est bien installé :
```bash
cd mobile && npm install react-native-markdown-display
```

### Caractères spéciaux mal affichés

S'assurer que les fichiers sources (`.md`) sont encodés en UTF-8.

## 📚 Ressources

- [react-markdown](https://github.com/remarkjs/react-markdown)
- [remark-gfm](https://github.com/remarkjs/remark-gfm)
- [react-native-markdown-display](https://github.com/iamacup/react-native-markdown-display)
- [GitHub Flavored Markdown Spec](https://github.github.com/gfm/)
