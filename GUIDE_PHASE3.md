# 🚀 GUIDE PHASE 3 - API PRESTASHOP RÉELLE

## 🎯 Objectifs Phase 3

Phase 3 introduit la **connexion réelle à l'API PrestaShop** avec :

- ✅ Configuration API robuste
- ✅ Gestion d'erreurs avancée
- ✅ Retry automatique
- ✅ Authentification sécurisée
- ✅ Services améliorés

## 🛠️ Nouvelles Fonctionnalités

### 1. Configuration API (`prestashop_config.dart`)

```dart
// Configuration de développement
final config = PrestaShopConfig.development(
  host: 'localhost',
  apiKey: 'votre_cle_api',
  debug: true,
);

// Configuration de production
final config = PrestaShopConfig.production(
  host: 'votre-boutique.com',
  apiKey: 'votre_cle_api',
  useHttps: true,
);
```

### 2. Gestion d'Erreurs (`prestashop_exceptions.dart`)

```dart
try {
  final products = await productService.getAll();
} on PrestaShopException catch (e) {
  switch (e.type) {
    case PrestaShopErrorType.network:
      // Gérer erreur réseau
      break;
    case PrestaShopErrorType.authentication:
      // Gérer erreur d'authentification
      break;
    // ... autres types
  }
}
```

### 3. Services Améliorés

```dart
final languageService = LanguageService();

// Méthodes de base héritées
final languages = await languageService.getAll();
final language = await languageService.getById(1);

// Méthodes spécialisées
final activeLanguages = await languageService.getActiveLanguages();
final defaultLang = await languageService.getDefaultLanguage();
```

## 🚀 Guide de Démarrage Rapide

### 1. Initialisation de l'API

```dart
import 'package:koutonou/core/api/prestashop_initializer.dart';

// Pour le développement
await PrestaShopApiInitializer.initializeForDevelopment(
  host: 'localhost',
  apiKey: 'votre_cle_api',
);

// Pour la production
await PrestaShopApiInitializer.initializeForProduction(
  host: 'votre-boutique.com',
  apiKey: 'votre_cle_api',
);
```

### 2. Utilisation des Services

```dart
import 'package:koutonou/modules/languages/services/language_service.dart';

final languageService = LanguageService();

try {
  // Récupérer toutes les langues
  final languages = await languageService.getAll();

  // Recherche avec filtres
  final activeLanguages = await languageService.search(
    filters: {'active': '1'},
  );

  // Opérations CRUD
  final newLanguage = await languageService.create(language);
  final updated = await languageService.update(id, language);
  await languageService.delete(id);

} on PrestaShopException catch (e) {
  print('Erreur API: ${e.userFriendlyMessage}');
}
```

## 🔧 Configuration PrestaShop

### 1. Activation de l'API Web Services

1. Connectez-vous à votre back-office PrestaShop
2. Allez dans **Paramètres avancés > Web Service**
3. Activez **Activer les web services de PrestaShop**
4. Créez une nouvelle clé API
5. Configurez les permissions pour vos ressources

### 2. Variables d'Environnement (Optionnel)

Créez un fichier `.env` :

```bash
PRESTASHOP_HOST=localhost
PRESTASHOP_PATH=/prestashop/api
PRESTASHOP_API_KEY=votre_cle_api
PRESTASHOP_USE_HTTPS=false
PRESTASHOP_DEBUG=true
```

## 🧪 Tests et Validation

### Lancer les Tests Phase 3

```bash
dart tools/test_phase3.dart
```

### Tests Manuels

```dart
import 'package:koutonou/core/api/prestashop_initializer.dart';

// Test de connexion
final connected = await PrestaShopApiInitializer.runApiTests();

// Afficher la configuration
PrestaShopApiInitializer.showConfigInfo();
```

## 🏗️ Architecture Phase 3

```
lib/core/api/
├── prestashop_config.dart         # Configuration API
├── prestashop_exceptions.dart     # Gestion d'erreurs
├── prestashop_http_client.dart    # Client HTTP
└── prestashop_initializer.dart    # Initialisation

lib/core/services/
└── prestashop_base_service.dart   # Service de base

lib/modules/[resource]/services/
└── [resource]_service.dart        # Services spécialisés
```

## 📋 Endpoints Supportés

Phase 3 supporte tous les **37 endpoints PrestaShop** générés :

### Principaux

- ✅ `languages` - Gestion des langues
- ✅ `products` - Gestion des produits
- ✅ `customers` - Gestion des clients
- ✅ `orders` - Gestion des commandes
- ✅ `categories` - Gestion des catégories

### Commerce

- ✅ `carts` - Paniers
- ✅ `addresses` - Adresses
- ✅ `zones` - Zones géographiques
- ✅ `states` - États/Régions
- ✅ `taxes` - Taxes

### Et 27 autres endpoints disponibles !

## 🔄 Migration depuis Phase 2

### Avant (Phase 2)

```dart
final languageService = LanguageService();
final languages = await languageService.getAll(); // Simulation
```

### Après (Phase 3)

```dart
// 1. Initialiser l'API
await PrestaShopApiInitializer.initializeForDevelopment();

// 2. Utiliser les services (même interface !)
final languageService = LanguageService();
final languages = await languageService.getAll(); // API réelle
```

## 🚨 Gestion d'Erreurs

### Types d'Erreurs Gérées

- **Network** - Problème de connexion
- **Authentication** - Clé API invalide
- **Authorization** - Permissions insuffisantes
- **NotFound** - Ressource non trouvée
- **Validation** - Données invalides
- **Server** - Erreur serveur
- **RateLimit** - Limite de requêtes atteinte

### Retry Automatique

- ✅ Retry automatique pour erreurs temporaires
- ✅ Exponential backoff
- ✅ Limite configurable de tentatives
- ✅ Logging détaillé

## 📊 Monitoring et Debug

### Mode Debug

```dart
final config = PrestaShopConfig.development(debug: true);
```

### Logs Disponibles

- 🌐 Requêtes HTTP détaillées
- ⚠️ Erreurs et warnings
- 🔄 Tentatives de retry
- 📊 Performances

## 🔐 Sécurité

### Authentification

- ✅ Basic Auth avec clé API
- ✅ HTTPS en production
- ✅ Sanitisation des logs
- ✅ Timeout configurable

### Bonnes Pratiques

1. **Jamais** de clés API en dur dans le code
2. Utiliser des variables d'environnement
3. HTTPS obligatoire en production
4. Rotation régulière des clés API

## 🎯 Prochaines Étapes (Phase 4)

1. **💾 Système de Cache** - Cache intelligent des réponses
2. **🎨 Widgets UI** - Components Flutter réutilisables
3. **🧪 Tests Unitaires** - Couverture de test complète
4. **📚 Documentation** - Documentation auto-générée
5. **⚡ Optimisations** - Performance et pagination

---

**Phase 3 est maintenant prête !** 🎉  
Vous avez une connexion robuste à l'API PrestaShop réelle avec gestion d'erreurs avancée.
