#!/bin/bash

# Script de lancement des tests complets pour Koutonou
# Usage: ./run_tests.sh

echo "🚀 Koutonou - Lancement des Tests Complets"
echo "=========================================="

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis la racine du projet Koutonou"
    exit 1
fi

# Vérifier que Dart est installé
if ! command -v dart &> /dev/null; then
    echo "❌ Erreur: Dart n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Erreur: Flutter n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

echo "✅ Environnement vérifié"
echo ""

# Installer les dépendances si nécessaire
echo "📦 Vérification des dépendances..."
flutter pub get

echo ""
echo "🧪 Lancement de la suite de tests complète..."
echo ""

# Exécuter le script de test
dart tools/test_complete_project.dart

echo ""
echo "✨ Tests terminés!"

# Optionnel: Ouvrir le rapport dans un navigateur (si généré)
# if [ -f "test_report.html" ]; then
#     echo "📊 Ouverture du rapport détaillé..."
#     open test_report.html
# fi
