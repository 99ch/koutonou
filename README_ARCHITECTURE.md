# Architecture du projet Koutonou

## Structure générale

Ce projet Flutter suit une architecture modulaire avec une séparation claire des responsabilités :

```
lib/
├── core/              # Fonctionnalités de base
├── modules/           # Modules métier
├── shared/            # Composants partagés
├── router/            # Configuration du routage
├── localization/      # Gestion des langues
└── main.dart         # Point d'entrée
```

## Modules

Chaque module suit la même structure :

- **models/** : Modèles de données
- **providers/** : Gestion d'état (Riverpod)
- **services/** : Services métier
- **views/** : Écrans
- **widgets/** : Composants UI spécifiques au module
- **providers.dart** : Exports centralisés

## Core

- **api/** : Configuration et client API
- **models/** : Modèles de base
- **providers/** : Providers globaux
- **services/** : Services globaux
- **theme/** : Configuration du thème
- **utils/** : Utilitaires
- **exceptions/** : Gestion des erreurs

## Shared

- **widgets/** : Composants UI réutilisables
- **extensions/** : Extensions Dart
- **utils/** : Utilitaires partagés

## Ordre de développement et tests

### 1. **core/** - Fondations

**Tests à effectuer :**

- Test des utilitaires (`constants.dart`, `logger.dart`)
- Test des modèles de base (`BaseResponse`, `ErrorModel`)
- Test de la gestion d'erreurs (`ErrorHandler`)
- Test de la configuration API (`ApiClient`, `ApiConfig`)
- Test des services d'authentification
- **Point de contrôle :** Vérifier que l'API répond correctement

**Page de test manuelle pour core/ :**
Créer une page temporaire `lib/test_core_page.dart` qui teste :

1. **API** → Bouton "Test API" qui fait un appel GET/POST
2. **Modèles** → Afficher sérialisation/désérialisation JSON
3. **Erreurs** → Bouton "Test Erreur" qui déclenche une exception
4. **Auth** → Boutons "Login/Logout" avec état affiché
5. **Logger** → Messages de log visibles dans la console
6. **Constants** → Afficher les valeurs des constantes

### 2. **shared/** - Composants partagés

**Tests à effectuer :**

- Test des extensions (`context_extensions.dart`)
- Test des utilitaires de validation (`validators.dart`)
- Test des composants UI de base (`AppButton`, `AppTextField`)
- **Point de contrôle :** Créer une page de test avec tous les composants

### 3. **localization/** - Internationalisation

**Tests à effectuer :**

- Test du changement de langue
- Test des traductions manquantes
- Test de la persistance de la langue choisie
- **Point de contrôle :** Interface multilingue fonctionnelle

### 4. **router/** - Navigation

**Tests à effectuer :**

- Test de navigation entre pages
- Test des routes protégées (`RouteGuard`)
- Test des paramètres de route
- Test du deep linking
- **Point de contrôle :** Navigation complète sans erreurs

### 5. **modules/** - Logique métier

**Tests par module dans l'ordre :**

1. **home/** - Test de la page d'accueil
2. **customers/** - CRUD clients + navigation
3. **products/** - CRUD produits + intégration
4. **orders/** - Workflow complet de commande
5. **carts/** - Gestion panier + persistance

**Tests d'intégration finale :**

- Test du workflow complet utilisateur
- Test de performance
- Test sur différents devices

## Conventions

- Nommage en snake_case pour les fichiers
- Nommage en PascalCase pour les classes
- Un fichier par classe
- Documentation des APIs publiques
