#!/bin/bash

# Script pour lancer les tests des modèles de sous-ressources produits

echo "🔄 Lancement des tests des modèles de sous-ressources produits..."

cd /Users/macuser/Desktop/koutonou

# Vérifier que Dart est installé
if ! command -v dart &> /dev/null; then
    echo "❌ Dart n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

# Lancer le test
echo "🚀 Exécution des tests..."
dart tools/test_product_models.dart

echo ""
echo "✅ Tests des modèles terminés!"
