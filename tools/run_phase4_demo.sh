#!/bin/bash
# Script pour lancer la démo Phase 4 - Cache & UI Widgets

set -e

echo "🚀 Lancement de la démo Phase 4 - Cache & UI Widgets"
echo "=================================================="

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé ou pas dans le PATH"
    exit 1
fi

# Aller au répertoire du projet
cd "$(dirname "$0")/.."

echo "📦 Installation des dépendances..."
flutter pub get

echo "🧹 Nettoyage du build..."
flutter clean

echo "🔧 Analyse du code..."
dart analyze --fatal-infos

echo "🧪 Test Phase 4 (cache & widgets)..."
dart tools/test_phase4.dart

echo ""
echo "🎯 Lancement de l'application Flutter..."
echo "Naviguez vers 'Demo Phase 4' dans l'onglet Tests du router"
echo ""

# Lancer l'application Flutter
flutter run --debug

echo ""
echo "✅ Démo Phase 4 terminée !"
