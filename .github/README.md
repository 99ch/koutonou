# 🚀 GitHub Actions CI/CD

Ce dossier contient tous les workflows GitHub Actions pour l'intégration continue et le déploiement continu du projet Koutonou.

## 📋 Workflows Disponibles

### 🔄 `ci-cd.yml` - Pipeline Principal

**Déclenché par** : Push sur branches principales, PR, manual
**Durée** : ~25-40 minutes

- ✅ **Analyse de code** : Formatting, linting, sécurité
- 🧪 **Tests automatisés** : Unitaires avec coverage
- 🏗️ **Builds** : Android (APK + AAB), iOS, Web
- 📊 **Rapports** : Coverage, performance, sécurité
- 🚀 **Release** : Automatique sur branche main

### ✅ `pr-validation.yml` - Validation Pull Request

**Déclenché par** : Ouverture/MAJ de PR
**Durée** : ~15-20 minutes

- 📋 **Validation PR** : Format du titre, informations
- 🚀 **Checks rapides** : Formatting, analyse, fichiers modifiés
- 🧪 **Tests PR** : Tests unitaires avec coverage
- 🏗️ **Build validation** : Android et Web debug
- 📝 **Checklist** : Guide de review automatique

### 🔒 `security.yml` - Audit Sécurité

**Déclenché par** : Hebdomadaire (lundi 9h), changements deps, manual
**Durée** : ~10-15 minutes

- 🔒 **Audit sécurité** : Scan des dépendances
- 📦 **Analyse deps** : Packages obsolètes, vulnérabilités
- 🚨 **Scan vulnérabilités** : Trivy security scanner
- 📈 **MAJ automatique** : PR de mise à jour des dépendances

### 🚀 `deployment.yml` - Déploiement

**Déclenché par** : Release, manual avec sélection environnement
**Durée** : ~30-60 minutes

- 🔍 **Pré-déploiement** : Validation et planification
- 🌐 **Web** : GitHub Pages (prod), Netlify/Vercel (staging)
- 🤖 **Android** : Google Play Store (prod), artifacts (staging)
- 🍎 **iOS** : App Store (prod), artifacts (staging)
- 📊 **Résumé** : Rapport de déploiement complet

## 🔧 Configuration Requise

### 📋 Secrets Repository

Consultez [`ACTIONS_SETUP.md`](./ACTIONS_SETUP.md) pour la liste complète des secrets requis.

**Essentiels pour commencer** :

- `GITHUB_TOKEN` (automatique)
- `ANDROID_KEYSTORE` + mots de passe (pour Android)
- `IOS_CERTIFICATE` + profils (pour iOS)

### 🌍 Environments

- **staging** : Déploiements de test
- **production** : Déploiements finaux avec approbation manuelle

## 📊 Badges de Status

Ajoutez ces badges à votre README principal :

```markdown
![CI/CD](https://github.com/99ch/koutonou/workflows/🚀%20Koutonou%20CI/CD%20Pipeline/badge.svg)
![Security](https://github.com/99ch/koutonou/workflows/🔒%20Security%20&%20Dependencies/badge.svg)
![Coverage](https://codecov.io/gh/99ch/koutonou/branch/main/graph/badge.svg)
```

## 🔄 Flux de Travail Recommandé

### 👨‍💻 Développement

1. Créer une branche feature depuis `develop`
2. Développer et commit (format conventional commits)
3. Push et ouvrir une PR vers `develop`
4. **Workflow `pr-validation.yml`** se déclenche automatiquement
5. Review et merge après validation

### 🚀 Release

1. Merge `develop` → `production_ready`
2. **Workflow `ci-cd.yml`** se déclenche
3. Créer une release GitHub
4. **Workflow `deployment.yml`** déploie automatiquement

### 🔒 Maintenance

- **Workflow `security.yml`** s'exécute chaque lundi
- PRs automatiques pour les mises à jour de dépendances
- Review mensuel des rapports de sécurité

## 📈 Métriques et Monitoring

### 🧪 Tests et Coverage

- Tests unitaires exécutés sur chaque PR/push
- Coverage reports sur Codecov
- Seuil minimum : 70%

### 🔒 Sécurité

- Scan hebdomadaire des vulnérabilités
- Rapports SARIF dans l'onglet Security
- Notifications automatiques des issues critiques

### ⚡ Performance

- Temps de build trackés
- Taille des artifacts monitorée
- Rapports de performance dans les summaries

## 🆘 Troubleshooting

### ❌ Builds Failed

1. Vérifier les logs dans l'onglet Actions
2. Tester localement avec la même version Flutter
3. Vérifier les dépendances et conflits

### 🔐 Secrets Issues

1. Vérifier que tous les secrets requis sont configurés
2. Tester la validité des certificats/clés
3. Vérifier les permissions d'accès

### 🚀 Deployment Issues

1. Vérifier la configuration des environnements
2. Tester les credentials des stores
3. Vérifier les profils de provisioning iOS

## 📚 Resources

- [Configuration détaillée](./ACTIONS_SETUP.md)
- [Conventional Commits](https://conventionalcommits.org/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Flutter CI/CD Guide](https://docs.flutter.dev/deployment/cd)

---

🔄 **Auto-mise à jour** : Ce système CI/CD s'auto-maintient avec des mises à jour automatiques des dépendances et des rapports de sécurité réguliers.
