# 🤝 Guide de Contribution - Koutonou

Merci de votre intérêt pour contribuer à **Koutonou** ! Ce guide vous aidera à contribuer efficacement au projet.

## 🎯 Vue d'ensemble

Koutonou est une plateforme e-commerce mobile Flutter connectée à PrestaShop. Le projet suit une architecture modulaire stricte et des standards de qualité élevés.

## 🚀 Démarrage Rapide

### 📋 Prérequis

```bash
# Flutter SDK
flutter --version  # Flutter 3.24.1+
dart --version     # Dart 3.5.1+

# Tools
git --version      # Git 2.0+
```

### 🔧 Setup Développement

```bash
# 1. Fork et clone
git clone https://github.com/[votre-username]/koutonou.git
cd koutonou

# 2. Install dependencies
flutter pub get

# 3. Configuration environnement
cp .env.example .env
# Éditer .env avec vos paramètres

# 4. Générer code
dart run build_runner build

# 5. Lancer l'app
flutter run
```

## 📁 Architecture du Projet

### 🏗️ Structure Modulaire

```
lib/
├── core/              # Fondations (API, auth, utils)
├── modules/           # Modules métier (15 modules)
│   ├── configs/       # ✅ VALIDÉ (languages, currencies, countries)
│   ├── products/      # 🚧 EN COURS (Phase 2)
│   ├── customers/     # 🚧 EN COURS (Phase 2)
│   └── ...           # 📋 PLANIFIÉ
├── shared/            # Composants réutilisables
├── router/            # Navigation GoRouter
└── localization/      # i18n support
```

### 🎯 Pattern Standard

Chaque module suit cette structure :

```
modules/[module_name]/
├── models/            # JSON serializable models
├── services/          # Business logic + API
├── providers/         # State management (optional)
├── views/            # UI screens (optional)
├── widgets/          # UI components (optional)
└── providers.dart    # Exports
```

## 🔄 Workflow de Contribution

### 1. 🎯 Choisir une Tâche

- Consulter les [Issues GitHub](https://github.com/99ch/koutonou/issues)
- Regarder le [Project Board](https://github.com/99ch/koutonou/projects)
- Prioriser selon les labels :
  - `good first issue` : Pour débuter
  - `phase-2` : Modules core e-commerce
  - `enhancement` : Améliorations
  - `bug` : Corrections

### 2. 🌿 Créer une Branche

```bash
# Pattern de nommage des branches
git checkout -b [type]/[module]/[description]

# Exemples
git checkout -b feature/products/catalog-api
git checkout -b fix/configs/cache-ttl
git checkout -b docs/architecture/modules-guide
```

### 3. 💻 Développement

#### 📊 Pour un Nouveau Module

```bash
# 1. Créer la structure
mkdir -p lib/modules/[module]/{models,services,providers,views,widgets}

# 2. Analyser l'API PrestaShop
curl "http://localhost:8080/prestashop/proxy.php/[resource]?output_format=JSON&display=full&limit=1"

# 3. Créer le modèle
# lib/modules/[module]/models/[resource]_model.dart

# 4. Implémenter le service
# lib/modules/[module]/services/[resource]_service.dart

# 5. Générer le code
dart run build_runner build --delete-conflicting-outputs

# 6. Tester
flutter test
flutter run
```

#### 🔧 Standards de Code

```dart
// ✅ Exemple de modèle standard
@JsonSerializable()
class ProductModel {
  @JsonKey(name: 'id')
  @IntStringConverter()
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  const ProductModel({this.id, this.name});

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}

// ✅ Exemple de service standard
class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final Map<String, CacheEntry<List<ProductModel>>> _cache = {};

  Future<List<ProductModel>> getAll({Map<String, String>? filters}) async {
    // Cache check
    // API call
    // Parse data
    // Update cache
    // Return results
  }
}
```

### 4. 🧪 Tests

```bash
# Tests unitaires
flutter test test/modules/[module]/

# Tests intégration
flutter test integration_test/

# Tests manuels
flutter run
# Tester dans l'interface
```

### 5. 📚 Documentation

```bash
# Mettre à jour la documentation
# - README.md si nécessaire
# - README_ARCHITECTURE.md pour l'architecture
# - lib/modules/ARCHITECTURE.md pour les modules
# - Ajouter des tests dans ROUTER_TEST_GUIDE.md
```

### 6. 📝 Commit

```bash
# Pattern de commit
git add .
git commit -m "[type]([module]): description"

# Exemples
git commit -m "feat(products): add catalog API integration"
git commit -m "fix(configs): handle string/int type conversion"
git commit -m "docs(architecture): update modules roadmap"
git commit -m "test(router): add authentication flow tests"
```

### 7. 🚀 Pull Request

1. **Push la branche**

   ```bash
   git push origin [branch-name]
   ```

2. **Créer PR** sur GitHub avec :

   - Titre descriptif
   - Description détaillée
   - Checklist complétée
   - Screenshots si UI

3. **Template PR** :

   ```markdown
   ## 🎯 Description

   Brief description of changes

   ## ✅ Type de changement

   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## 🧪 Tests

   - [ ] Unit tests pass
   - [ ] Integration tests pass
   - [ ] Manual testing completed

   ## 📚 Documentation

   - [ ] Code commented
   - [ ] Documentation updated
   - [ ] Architecture guide updated if needed

   ## 📊 Performance

   - [ ] No performance regression
   - [ ] Cache strategy appropriate
   - [ ] Memory usage acceptable
   ```

## 🎯 Types de Contributions

### 🚧 Phase 2 - Core E-commerce (PRIORITÉ)

**Modules en développement :**

- **products/** : Catalogue, détails, variations
- **customers/** : Auth, profils, adresses
- **carts/** : Panier, calculs, persistance
- **orders/** : Commandes, payment, status

### 🔧 Améliorations Architecture

- Performance optimizations
- Error handling improvements
- Cache strategies refinement
- UI/UX enhancements

### 📚 Documentation

- API guides pour nouveaux modules
- Tutorial videos
- Code examples
- Architecture deep dives

### 🧪 Testing

- Unit test coverage
- Integration test scenarios
- Performance benchmarks
- UI automated tests

## 📋 Standards de Qualité

### ✅ Code Quality Checklist

- [ ] **Linting** : `flutter analyze` sans warnings
- [ ] **Formatting** : `dart format .` appliqué
- [ ] **Tests** : Coverage >80% pour nouveau code
- [ ] **Documentation** : Dartdoc pour APIs publiques
- [ ] **Performance** : Pas de régression
- [ ] **Architecture** : Suit les patterns établis

### 🎯 Review Criteria

1. **Fonctionnalité** : Feature works as expected
2. **Architecture** : Follows established patterns
3. **Performance** : No regression, optimized
4. **Testing** : Adequate coverage
5. **Documentation** : Clear and complete
6. **Code Quality** : Clean, readable, maintainable

## 🔒 Sécurité

### ⚠️ Guidelines

- Ne jamais commiter de clés API réelles
- Utiliser .env pour configuration sensitive
- Valider tous les inputs utilisateur
- Gérer les erreurs sans exposer d'infos internes
- Suivre les best practices Flutter security

### 🛡️ Review Process

- Toute PR est reviewée par les maintainers
- Tests de sécurité automatisés
- Validation des patterns de sécurité
- Audit des dépendances

## 🏆 Recognition

### 🌟 Contributors

Les contributeurs sont reconnus dans :

- README.md contributors section
- Release notes
- GitHub contributors graph
- Special mentions pour contributions significatives

### 🎯 Milestones

- **First PR** : Welcome badge
- **5 PRs** : Regular contributor recognition
- **Module Complete** : Module champion badge
- **Architecture Improvement** : Technical excellence badge

## 📞 Support

### 💬 Communication

- **Issues** : Questions techniques, bugs
- **Discussions** : Idées, features, architecture
- **Email** : [maintainers@koutonou.com](mailto:maintainers@koutonou.com)

### 📚 Resources

- **Documentation** : [DOCUMENTATION_INDEX.md](./DOCUMENTATION_INDEX.md)
- **Architecture** : [README_ARCHITECTURE.md](./README_ARCHITECTURE.md)
- **Testing** : [ROUTER_TEST_GUIDE.md](./ROUTER_TEST_GUIDE.md)
- **Examples** : Module configs/ comme référence

## 🎉 Welcome!

Nous sommes ravis de vous accueillir dans la communauté Koutonou ! Votre contribution, quelle que soit sa taille, est précieuse pour faire de Koutonou la meilleure plateforme e-commerce mobile Flutter.

**Happy Coding! 🚀**

---

_📝 Guide de contribution mis à jour avec succès MVP Phase 1_  
_🗓️ Dernière mise à jour : 3 août 2025_  
_🤝 Communauté : Ouverte et accueillante pour tous les niveaux_
