# Guide de Test - Module Router

## 🧪 Tests du Module Router de Koutonou

### Préparation

1. **Serveur lancé** : ✅ Application servie sur port 8081
2. **URL d'accès** : http://localhost:8081
3. **Console développeur** : Ouvrir F12 pour voir les logs

### Tests à effectuer

#### 📱 1. Navigation de base

- [ ] **Page d'accueil** : L'app se charge sur `/home`
- [ ] **Navigation bottom bar** : Tester les 3 onglets (Localisation, Core Test, Router Test)
- [ ] **URLs dans le navigateur** : Vérifier que l'URL change lors de la navigation

#### 🔐 2. Authentification et protection des routes

- [ ] **Aller à Router Test** (3ème onglet)
- [ ] **Tester "Panier"** : Doit rediriger vers `/auth/login` (route protégée)
- [ ] **Tester "Profil"** : Doit rediriger vers `/auth/login` (route protégée)
- [ ] **Se connecter** : Utiliser le bouton "Se connecter (Demo)"
- [ ] **Retester Panier/Profil** : Doivent maintenant être accessibles

#### 🧭 3. Navigation avancée

- [ ] **Deep linking** : Aller directement à `http://localhost:8081/products`
- [ ] **URL protection** : Aller à `http://localhost:8081/cart` sans être connecté
- [ ] **Redirection auth** : Tester `http://localhost:8081/auth/login` quand connecté

#### 🔄 4. Tests de redirection

- [ ] **Connexion → Retour** : Se connecter puis vérifier la redirection
- [ ] **Déconnexion** : Sur la page Profil, tester "Se déconnecter"
- [ ] **Pages d'erreur** : Aller à `http://localhost:8081/route-inexistante`

#### 📊 5. État et informations

- [ ] **Carte d'infos** : Vérifier dans Router Test
  - Route actuelle affichée correctement
  - État d'authentification correct
- [ ] **Console logs** : Vérifier les logs de navigation dans F12

### Scénarios de test complets

#### Scénario 1 : Utilisateur non connecté

1. Aller sur Router Test
2. Cliquer "Panier" → Redirection login ✅
3. Cliquer "Profil" → Redirection login ✅
4. Naviguer vers "Produits" → Accessible ✅

#### Scénario 2 : Connexion et navigation

1. Aller à `/auth/login`
2. Cliquer "Se connecter (Demo)"
3. Vérifier redirection vers `/home`
4. Tester accès aux pages protégées

#### Scénario 3 : Deep linking et protection

1. URL directe : `http://localhost:8081/cart`
2. → Doit rediriger vers login
3. Se connecter
4. → Devrait retourner au panier

### Points à vérifier dans la console

```javascript
// Dans la console du navigateur (F12), chercher :
// ✅ Logs de GoRouter
"GoRouter";

// ✅ Logs de navigation
"Navigation vers:";
"Redirection check pour:";

// ❌ Erreurs à éviter
"ERROR";
"Exception";
```

### Tests de régression

#### Performance

- [ ] Navigation fluide sans lag
- [ ] Pas de reconstruction inutile des pages
- [ ] URLs propres dans la barre d'adresse

#### Robustesse

- [ ] Gestion des erreurs 404
- [ ] Protection des routes sensibles
- [ ] Persistance de l'état d'authentification

### Résultats attendus

| Test                        | Résultat attendu          | ✅/❌ |
| --------------------------- | ------------------------- | ----- |
| Page d'accueil              | Charge sur `/home`        |       |
| Navigation tabs             | Change les onglets        |       |
| Route protégée non connecté | Redirige vers login       |       |
| Connexion demo              | Authentifie l'utilisateur |       |
| Route protégée connecté     | Accès autorisé            |       |
| Deep link protégé           | Redirige puis retourne    |       |
| Page 404                    | Affiche page d'erreur     |       |
| URLs propres                | Pas de # dans l'URL       |       |

### 🎯 Objectifs du test

1. **Fonctionnalité** : Le router fonctionne comme prévu
2. **Sécurité** : Les routes sont correctement protégées
3. **UX** : Navigation fluide et intuitive
4. **Architecture** : Code modulaire et maintenable

### 📝 Rapport de test

Une fois les tests terminés, noter :

- ✅ **Tests réussis** : X/Y
- ❌ **Tests échoués** : Liste des problèmes
- 🔧 **Améliorations** : Suggestions d'optimisation

---

_Ce guide teste l'implémentation complète du module router avec GoRouter, protection des routes, et navigation moderne._
