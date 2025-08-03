# 🛍️ Koutonou - E-commerce Mobile Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![PrestaShop](https://img.shields.io/badge/PrestaShop-API-green.svg)](https://prestashop.com/)
[![MVP Status](https://img.shields.io/badge/MVP-✅%20Validated-brightgreen.svg)](./MVP_FRONTEND_FEASIBILITY.md)

**Plateforme e-commerce mobile moderne connectée à PrestaShop avec architecture modulaire.**

## 🎯 Vue d'ensemble

Koutonou est une application mobile Flutter qui démontre la **faisabilité complète** d'intégration avec les APIs PrestaShop. Le projet valide une architecture scalable pour marketplace e-commerce avec gestion multilingue, multi-devises et multi-pays.

### ✅ MVP Phase 1 - Validé

- **🌐 APIs PrestaShop** : Languages, Currencies, Countries (241 pays)
- **📱 Interface Flutter** : Navigation, cache intelligent, gestion d'erreurs
- **🔧 Architecture** : Modulaire, scalable, production-ready
- **🎨 UI/UX** : Demo fonctionnel, simulation e-commerce

## 🚀 Démarrage Rapide

### Prérequis

```bash
flutter --version  # Flutter 3.0+
dart --version     # Dart 3.0+
```

### Installation

```bash
# Cloner le projet
git clone https://github.com/99ch/koutonou.git
cd koutonou

# Installer les dépendances
flutter pub get

# Générer les modèles
dart run build_runner build

# Configuration environnement
cp .env.example .env
# Éditer .env avec vos paramètres API

# Lancer l'application
flutter run
```

## 📁 Structure du Projet

```
koutonou/
├── 📱 lib/
│   ├── 🎯 main.dart                 # Point d'entrée
│   ├── ⚙️ core/                     # Services core, thème, utils
│   ├── 🌐 localization/             # Internationalisation
│   ├── 📦 modules/                  # Modules métier
│   │   ├── configs/                 # Languages, Currencies, Countries
│   │   ├── customers/               # Authentification utilisateurs
│   │   ├── orders/                  # Gestion commandes
│   │   └── ...                      # Autres modules
│   ├── 🛣️ router/                   # Navigation GoRouter
│   └── 🔧 shared/                   # Widgets réutilisables
├── 📊 tools/                        # Scripts génération code
├── 🧪 test/                         # Tests automatisés
└── 📋 docs/                         # Documentation
```

## 🛠️ Fonctionnalités

### ✅ Implémentées (MVP Phase 1)

- **🌍 Configuration Globale**
  - Sélection langue dynamique (Français/Anglais)
  - Gestion multi-devises (EUR, USD, etc.)
  - Support 241 pays avec détails complets

- **📱 Interface Utilisateur**
  - Navigation fluide (GoRouter)
  - Thème adaptatif (Light/Dark)
  - Cache intelligent (TTL 1h)
  - Gestion d'erreurs robuste

- **🔗 Intégration API**
  - PrestaShop REST API complète
  - Proxy PHP pour CORS et auth
  - Parsing automatique JSON
  - Logging détaillé

### 🚧 En Développement (Phase 2)

- **📦 Catalogue Produits**
- **👥 Authentification Clients**
- **🛒 Gestion Panier**
- **📋 Processus Commande**

## 📊 Performance

| Métrique | Valeur | Status |
|----------|--------|--------|
| Cache Hit Rate | 95%+ | ✅ Excellent |
| API Response | <1s | ✅ Rapide |
| Langues supportées | 2+ | ✅ Extensible |
| Pays supportés | 241 | ✅ Global |
| Build Time | ~30s | ✅ Optimisé |

## 🧪 Tests & Validation

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/

# Tests MVP spécifiques
./test_core_architecture.sh
./run_mvp_phase1.sh
```

## 📚 Documentation

- **[📋 Architecture](./README_ARCHITECTURE.md)** - Design patterns et structure
- **[🧪 Tests Guide](./ROUTER_TEST_GUIDE.md)** - Guide de test du router
- **[✅ MVP Report](./MVP_FRONTEND_FEASIBILITY.md)** - Rapport de faisabilité
- **[🏆 Success Report](./MVP_PHASE1_SUCCESS_REPORT.md)** - Résultats Phase 1

## 🌟 Technologies

- **Frontend** : Flutter 3.0+, Dart 3.0+
- **Backend** : PrestaShop REST API
- **Navigation** : GoRouter
- **State Management** : Provider
- **Serialization** : json_annotation/build_runner
- **Internationalisation** : flutter_localizations
- **Cache** : Memory cache avec TTL

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/amazing-feature`)
3. Commit les changements (`git commit -m 'Add amazing feature'`)
4. Push la branche (`git push origin feature/amazing-feature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir [LICENSE](LICENSE) pour plus de détails.

## 📧 Contact

- **Développeur** : [99ch](https://github.com/99ch)
- **Projet** : [Koutonou](https://github.com/99ch/koutonou)
- **Issues** : [GitHub Issues](https://github.com/99ch/koutonou/issues)

---

**🎯 Mission** : Démontrer et valider l'intégration PrestaShop dans un écosystème mobile moderne avec Flutter.

**🏆 Status** : MVP Phase 1 - ✅ **SUCCÈS COMPLET**
