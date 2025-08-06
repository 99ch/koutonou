#!/bin/bash

# Script pour tester manuellement l'API PrestaShop de PRODUCTION
# Utilise uniquement les paramètres de votre fichier .env
# AUCUNE donnée de démonstration

echo "🏪 TEST MANUEL API PRESTASHOP DE PRODUCTION"
echo "=========================================="

# Vérifier que le fichier .env existe
if [ ! -f ".env" ]; then
    echo "❌ ERREUR: Fichier .env non trouvé"
    echo "   Créez un fichier .env avec vos paramètres PrestaShop:"
    echo "   PRESTASHOP_BASE_URL=https://votre-boutique.com"
    echo "   PRESTASHOP_API_KEY=votre-cle-api"
    exit 1
fi

# Charger les variables depuis .env
source .env

if [ -z "$PRESTASHOP_BASE_URL" ]; then
    echo "❌ ERREUR: Variable PRESTASHOP_BASE_URL manquante dans .env"
    exit 1
fi

if [ -z "$PRESTASHOP_API_KEY" ]; then
    echo "❌ ERREUR: Variable PRESTASHOP_API_KEY manquante dans .env"
    exit 1
fi

echo "🔗 URL de production: $PRESTASHOP_BASE_URL"
echo "🔑 Clé API: ${PRESTASHOP_API_KEY:0:8}..."
echo ""

# Test 1: Connexion API racine
echo "🔌 Test connexion API racine..."
curl -s -w "Status: %{http_code}\n" \
     "$PRESTASHOP_BASE_URL/api/?ws_key=$PRESTASHOP_API_KEY&output_format=JSON" \
     | head -5
echo ""

# Test 2: Liste des produits (limite 3)
echo "📦 Test récupération produits..."
curl -s -w "Status: %{http_code}\n" \
     "$PRESTASHOP_BASE_URL/api/products?ws_key=$PRESTASHOP_API_KEY&output_format=JSON&limit=3" \
     | head -10
echo ""

# Test 3: Produit spécifique (ID=1)
echo "🎯 Test produit spécifique (ID=1)..."
curl -s -w "Status: %{http_code}\n" \
     "$PRESTASHOP_BASE_URL/api/products/1?ws_key=$PRESTASHOP_API_KEY&output_format=JSON" \
     | head -10
echo ""

# Test 4: Catégories
echo "📁 Test récupération catégories..."
curl -s -w "Status: %{http_code}\n" \
     "$PRESTASHOP_BASE_URL/api/categories?ws_key=$PRESTASHOP_API_KEY&output_format=JSON&limit=3" \
     | head -10
echo ""

echo "✅ Tests manuels terminés"
echo "💡 Si vous voyez du JSON, votre API fonctionne correctement"
echo "💡 Si vous voyez Status: 200, la connexion est réussie"
echo "💡 Si vous voyez Status: 401, vérifiez votre clé API"
echo "💡 Si vous voyez Status: 404, vérifiez votre URL"
