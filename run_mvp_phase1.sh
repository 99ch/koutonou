#!/bin/bash

# Script d'exécution complète du MVP Phase 1
# Génère les modèles et services pour languages, currencies, countries
# Valide le code généré et prépare l'intégration

set -e

echo "🚀 Début de l'exécution MVP Phase 1"
echo "=====================================/"

# Étape 1: Génération automatique
echo ""
echo "📋 Étape 1: Génération des modèles et services..."
cd /Users/macuser/Desktop/koutonou
dart run tools/generators/mvp_generator.dart

echo ""
echo "✅ Génération terminée!"

# Étape 2: Vérification des dépendances
echo ""
echo "📋 Étape 2: Vérification des dépendances..."
if ! grep -q "json_annotation:" pubspec.yaml; then
    echo "⚠️  Ajout de json_annotation au pubspec.yaml..."
    echo "  json_annotation: ^4.8.1" >> pubspec.yaml
fi

if ! grep -q "json_serializable:" pubspec.yaml; then
    echo "⚠️  Ajout de json_serializable au pubspec.yaml..."
    echo "  json_serializable: ^6.7.1" >> pubspec.yaml
fi

if ! grep -q "build_runner:" pubspec.yaml; then
    echo "⚠️  Ajout de build_runner au pubspec.yaml..."
    echo "  build_runner: ^2.4.6" >> pubspec.yaml
fi

echo ""
echo "📋 Étape 3: Installation des dépendances..."
flutter pub get

# Étape 4: Génération du code
echo ""
echo "📋 Étape 4: Génération du code avec build_runner..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Étape 5: Vérification des fichiers générés
echo ""
echo "📋 Étape 5: Vérification des fichiers générés..."

# Modèles
MODELS_DIR="lib/modules/configs/models"
if [ -f "$MODELS_DIR/language_model.dart" ]; then
    echo "✅ Modèle Language généré"
else
    echo "❌ Modèle Language manquant"
fi

if [ -f "$MODELS_DIR/currency_model.dart" ]; then
    echo "✅ Modèle Currency généré"
else
    echo "❌ Modèle Currency manquant"
fi

if [ -f "$MODELS_DIR/country_model.dart" ]; then
    echo "✅ Modèle Country généré"
else
    echo "❌ Modèle Country manquant"
fi

# Services
SERVICES_DIR="lib/modules/configs/services"
if [ -f "$SERVICES_DIR/language_service.dart" ]; then
    echo "✅ Service Language généré"
else
    echo "❌ Service Language manquant"
fi

if [ -f "$SERVICES_DIR/currency_service.dart" ]; then
    echo "✅ Service Currency généré"
else
    echo "❌ Service Currency manquant"
fi

if [ -f "$SERVICES_DIR/country_service.dart" ]; then
    echo "✅ Service Country généré"
else
    echo "❌ Service Country manquant"
fi

# Étape 6: Test de compilation
echo ""
echo "📋 Étape 6: Test de compilation..."
if flutter analyze lib/modules/configs/models/ lib/modules/configs/services/; then
    echo "✅ Compilation réussie"
else
    echo "❌ Erreurs de compilation détectées"
    exit 1
fi

# Étape 7: Instructions finales
echo ""
echo "🎉 MVP Phase 1 - TERMINÉ AVEC SUCCÈS!"
echo "===================================="
echo ""
echo "📋 Prochaines étapes:"
echo "1. Ouvrez lib/mvp_generation_test_page.dart"
echo "2. Décommentez les imports en haut du fichier"
echo "3. Décommentez le code de test dans les méthodes _test*"
echo "4. Ajoutez la page de test au router:"
echo "   GoRoute(path: '/mvp-test', builder: (_, __) => MvpGenerationTestPage())"
echo "5. Testez les services générés"
echo ""
echo "📁 Fichiers générés:"
echo "   - lib/modules/configs/models/language_model.dart"
echo "   - lib/modules/configs/models/currency_model.dart" 
echo "   - lib/modules/configs/models/country_model.dart"
echo "   - lib/modules/configs/services/language_service.dart"
echo "   - lib/modules/configs/services/currency_service.dart"
echo "   - lib/modules/configs/services/country_service.dart"
echo ""
echo "🔧 Pour régénérer:"
echo "   dart run tools/generators/mvp_generator.dart"
echo ""
echo "Phase 2 prête: Étendre à toutes les ressources PrestaShop! 🚀"
