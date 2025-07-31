# Architecture du projet Koutonou

## Vue d'ensemble

**Koutonou** est une marketplace multi-vendeurs connectée à l'API PrestaShop, développée en Flutter avec une architecture modulaire robuste et scalable.

## Stack technique

- **Framework** : Flutter ^3.8.1
- **Gestion d'état** : Provider ^6.1.2
- **Navigation** : GoRouter ^14.3.0 (navigation moderne et type-safe)
- **Stockage sécurisé** : Flutter Secure Storage ^9.0.0
- **Cache local** : Hive ^2.2.3
- **Requêtes HTTP** : Dio ^5.7.0 avec Certificate Pinning
- **Logs** : Logger ^2.0.2
- **Environnement** : Flutter DotEnv ^5.1.0
- **Internationalisation** : Flutter Localizations intégrée

## Structure générale

```
lib/
├── core/              # Fondations (API, auth, modèles de base)
├── modules/           # Modules métier (15 modules)
├── shared/            # Composants réutilisables
├── router/            # Configuration GoRouter + gardes
├── localization/      # Gestion multilingue
├── main.dart         # Point d'entrée avec MultiProvider
└── test_*.dart       # Pages de test pour validation
```

## Architecture des modules

Chaque module suit une structure standardisée :

```
modules/[nom_module]/
├── models/           # Modèles de données avec sérialisation JSON
├── providers/        # Gestion d'état (ChangeNotifier + Provider)
├── services/         # Logique métier et appels API
├── views/           # Écrans et pages UI
├── widgets/         # Composants UI spécifiques
└── providers.dart   # Exports centralisés des providers
```

### Modules disponibles

1. **carts** - Gestion des paniers
2. **cms** - Contenu managé
3. **configs** - Configuration système
4. **customers** - Gestion des clients
5. **customizations** - Personnalisations
6. **employees** - Gestion des employés
7. **home** - Page d'accueil
8. **orders** - Gestion des commandes
9. **products** - Catalogue produits
10. **search** - Recherche avancée
11. **shipping** - Expédition
12. **stocks** - Gestion des stocks
13. **stores** - Gestion des magasins
14. **support** - Support client
15. **taxes** - Gestion fiscale

## Core - Fondations du système

Le dossier `core/` contient toutes les fonctionnalités de base :

### api/

- **ApiClient** : Client HTTP centralisé avec Dio
- **ApiConfig** : Configuration des endpoints et paramètres
- **Certificate Pinning** : Sécurité HTTPS renforcée

### models/

- **BaseResponse** : Modèle de réponse API standardisé
- **ErrorModel** : Gestion unifiée des erreurs

### providers/

- **AuthProvider** : Gestion de l'authentification globale
- **SimpleAuthProvider** : Version simplifiée pour les tests
- **SimpleUserProvider** : Gestion des données utilisateur
- **SimpleNotificationProvider** : Système de notifications
- **SimpleCacheProvider** : Gestion du cache local

### services/

- **AuthService** : Service d'authentification avec PrestaShop
- **CacheService** : Service de cache avec Hive
- Services métier spécialisés par domaine

### theme/

- **theme.dart** : Configuration du thème Material Design
- **theme_fixed.dart** : Thème avec corrections spécifiques
- Support du mode sombre automatique

### utils/

- **Constants** : Constantes globales de l'application
- **Logger** : Système de logs configuré
- **ErrorHandler** : Gestion centralisée des erreurs

### exceptions/

- Exceptions personnalisées pour chaque type d'erreur
- Intégration avec le système de logs

## Router - Navigation moderne

Le système de navigation utilise **GoRouter** pour une approche déclarative :

### Fonctionnalités

- **Type-safe navigation** : Navigation typée et sûre
- **Deep linking** : Support des liens profonds
- **Route guards** : Protection des routes avec `RouteGuard`
- **Redirections automatiques** : Basées sur l'état d'authentification
- **Debug mode** : Logs détaillés en développement

### Structure

- **app_router.dart** : Configuration principale du router
- **routes.dart** : Définition des routes et noms
- **route_guard.dart** : Gardes d'authentification

### Routes protégées

- `/cart` - Nécessite une authentification
- `/orders` - Nécessite une authentification
- `/profile` - Nécessite une authentification

## Shared - Composants réutilisables

### widgets/

- Composants UI réutilisables dans toute l'application
- Widgets Material Design personnalisés
- Composants de base (boutons, champs, cartes, etc.)

### extensions/

- **context_extensions.dart** : Extensions pour BuildContext
- Extensions Dart pour simplifier le code

### utils/

- **validators.dart** : Validateurs de formulaires
- Utilitaires partagés entre modules
- Helpers pour les formats et conversions

## Localization - Internationalisation

- Support multilingue avec Flutter Localizations
- **LocalizationService** : Service de gestion des langues
- Fichiers de traduction organisés par module
- Persistance de la langue choisie
- Page de test dédiée (`localization_test_page.dart`)

## Pattern d'architecture et flux de données

### Gestion d'état avec Provider

```dart
// Configuration dans main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => SimpleAuthProvider()),
    ChangeNotifierProvider(create: (_) => SimpleUserProvider()),
    ChangeNotifierProvider(create: (_) => SimpleNotificationProvider()),
    ChangeNotifierProvider(create: (_) => SimpleCacheProvider()),
  ],
  child: MaterialApp.router(...)
)
```

### Flux typique d'une fonctionnalité

1. **UI (View)** → Déclenche une action
2. **Provider** → Gère l'état et appelle le service
3. **Service** → Effectue l'appel API via ApiClient
4. **Model** → Sérialise/désérialise les données
5. **Provider** → Met à jour l'état
6. **UI** → Se reconstruit automatiquement

### Navigation avec GoRouter

```dart
// Navigation déclarative
context.go('/products/123');
context.goNamed('product-detail', params: {'id': '123'});

// Avec garde d'authentification automatique
if (RouteGuard.canAccess(context, route)) {
  // Navigation autorisée
}
```

## Sécurité et performances

### Sécurité

- **Certificate Pinning** : Protection contre les attaques MITM
- **Secure Storage** : Stockage chiffré des tokens
- **Route Guards** : Protection des routes sensibles
- **Validation** : Validation côté client et serveur

### Performances

- **Cache local** : Hive pour le stockage rapide
- **Lazy loading** : Chargement à la demande des modules
- **Provider optimisé** : Reconstructions ciblées
- **Images optimisées** : Gestion intelligente des assets

## Tests et validation

### Pages de test intégrées

- **test_core_page.dart** : Tests des fonctionnalités core
- **test_core_page_simple.dart** : Tests simplifiés
- **shared_widgets_test_page.dart** : Tests des composants shared
- **localization_test_page.dart** : Tests de l'internationalisation

### Stratégie de test

- **Tests unitaires** : Models, services, utils
- **Tests de widgets** : Composants UI isolés
- **Tests d'intégration** : Flux complets utilisateur
- **Tests manuels** : Pages de test intégrées

## Développement et débogage

### Configuration de développement

- **Debug mode** : Logs détaillés avec Logger
- **Hot reload** : Développement en temps réel
- **Environment variables** : Configuration via .env
- **Error tracking** : Système de gestion d'erreurs

### Scripts utiles

- `test_core_architecture.sh` : Script de validation de l'architecture
- Documentation API générée : `doc/api/`
- Guides spécialisés : `ROUTER_TEST_GUIDE.md`

## Roadmap de développement

### Phase 1 : Fondations ✅

- [x] Configuration du projet Flutter
- [x] Architecture modulaire mise en place
- [x] Core (API, auth, models, providers)
- [x] Router avec GoRouter et gardes
- [x] Système de thème et localisation
- [x] Pages de test intégrées

### Phase 2 : Modules essentiels 🚧

- [ ] **home/** - Page d'accueil et navigation
- [ ] **products/** - Catalogue et détails produits
- [ ] **customers/** - Gestion des comptes clients
- [ ] **carts/** - Panier et gestion des articles
- [ ] **orders/** - Processus de commande

### Phase 3 : Modules avancés 📋

- [ ] **search/** - Recherche et filtres
- [ ] **stores/** - Gestion multi-vendeurs
- [ ] **stocks/** - Gestion des inventaires
- [ ] **shipping/** - Options de livraison
- [ ] **taxes/** - Calculs fiscaux

### Phase 4 : Modules spécialisés 🔮

- [ ] **cms/** - Contenu dynamique
- [ ] **configs/** - Paramètres système
- [ ] **customizations/** - Personnalisations
- [ ] **employees/** - Back-office
- [ ] **support/** - Service client

### Phase 5 : Optimisation et déploiement 🚀

- [ ] Tests d'intégration complets
- [ ] Optimisation des performances
- [ ] Sécurité et audit
- [ ] Déploiement multi-plateforme

## Conventions de développement

### Nommage

- **Fichiers** : `snake_case` (ex: `product_service.dart`)
- **Classes** : `PascalCase` (ex: `ProductService`)
- **Variables/méthodes** : `camelCase` (ex: `getCurrentUser()`)
- **Constantes** : `UPPER_SNAKE_CASE` (ex: `API_BASE_URL`)

### Structure des fichiers

- Un fichier par classe principale
- Imports organisés (dart, flutter, packages, local)
- Documentation des APIs publiques
- Tests unitaires accompagnant chaque service

### Git et versioning

- **Branches** : `feature/nom-fonctionnalite`
- **Commits** : Messages descriptifs en français
- **Tags** : Versioning sémantique (x.y.z)
- **Pull Requests** : Review obligatoire avant merge

### Performance et qualité

- **Linting** : Configuration stricte avec `flutter_lints`
- **Coverage** : Objectif de 80% de couverture de tests
- **Performance** : Monitoring des temps de chargement
- **Accessibilité** : Support des lecteurs d'écran

---

_Ce document est maintenu à jour avec l'évolution du projet. Dernière mise à jour : Juillet 2025_
