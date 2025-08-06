#!/bin/bash

# Script de test pour les sous-ressources des produits PrestaShop
# Ce script teste toutes les sous-ressources : suppliers, options, features, etc.

# Configuration
BASE_URL="https://marketplace.koutonou.com"
API_KEY="RLSSKE1B7DKGC9Z8MRR1WFECLTE7H2PV"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== TEST DES SOUS-RESSOURCES PRODUITS PRESTASHOP ===${NC}"
echo "Base URL: $BASE_URL"
echo "API Key: ${API_KEY:0:10}..."
echo ""

# Fonction pour tester une endpoint
test_endpoint() {
    local endpoint=$1
    local description=$2
    
    echo -e "${YELLOW}Testing: $description${NC}"
    echo "URL: $BASE_URL/api/$endpoint?ws_key=$API_KEY"
    
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        "$BASE_URL/api/$endpoint?ws_key=$API_KEY&output_format=JSON&display=full")
    
    http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo $response | sed -e 's/HTTPSTATUS:.*//')
    
    if [ "$http_code" -eq 200 ]; then
        echo -e "${GREEN}✓ SUCCESS (HTTP $http_code)${NC}"
        # Compter les éléments si possible
        count=$(echo "$body" | jq 'if type == "object" then (if .product_suppliers then (.product_suppliers | if type == "array" then length else 1 end) elif .product_options then (.product_options | if type == "array" then length else 1 end) elif .product_option_values then (.product_option_values | if type == "array" then length else 1 end) elif .product_features then (.product_features | if type == "array" then length else 1 end) elif .product_feature_values then (.product_feature_values | if type == "array" then length else 1 end) elif .customization_fields then (.customization_fields | if type == "array" then length else 1 end) elif .price_ranges then (.price_ranges | if type == "array" then length else 1 end) else 0 end) else 0 end' 2>/dev/null || echo "0")
        echo "Éléments trouvés: $count"
    else
        echo -e "${RED}✗ FAILED (HTTP $http_code)${NC}"
        echo "Response: $body" | head -3
    fi
    echo ""
}

# Test des Product Suppliers
echo -e "${BLUE}=== PRODUCT SUPPLIERS ===${NC}"
test_endpoint "product_suppliers" "Liste des fournisseurs de produits"

# Test d'un fournisseur spécifique (ID 1)
test_endpoint "product_suppliers/1" "Fournisseur de produit ID 1"

# Test des Product Options
echo -e "${BLUE}=== PRODUCT OPTIONS ===${NC}"
test_endpoint "product_options" "Liste des groupes d'options de produits"

# Test d'une option spécifique (ID 1)
test_endpoint "product_options/1" "Groupe d'options ID 1"

# Test des Product Option Values
echo -e "${BLUE}=== PRODUCT OPTION VALUES ===${NC}"
test_endpoint "product_option_values" "Liste des valeurs d'options de produits"

# Test d'une valeur d'option spécifique (ID 1)
test_endpoint "product_option_values/1" "Valeur d'option ID 1"

# Test des Product Features
echo -e "${BLUE}=== PRODUCT FEATURES ===${NC}"
test_endpoint "product_features" "Liste des caractéristiques de produits"

# Test d'une caractéristique spécifique (ID 1)
test_endpoint "product_features/1" "Caractéristique ID 1"

# Test des Product Feature Values
echo -e "${BLUE}=== PRODUCT FEATURE VALUES ===${NC}"
test_endpoint "product_feature_values" "Liste des valeurs de caractéristiques"

# Test d'une valeur de caractéristique spécifique (ID 1)
test_endpoint "product_feature_values/1" "Valeur de caractéristique ID 1"

# Test des Customization Fields
echo -e "${BLUE}=== CUSTOMIZATION FIELDS ===${NC}"
test_endpoint "product_customization_fields" "Liste des champs de personnalisation"

# Test d'un champ de personnalisation spécifique (ID 1)
test_endpoint "product_customization_fields/1" "Champ de personnalisation ID 1"

# Test des Price Ranges
echo -e "${BLUE}=== PRICE RANGES ===${NC}"
test_endpoint "price_ranges" "Liste des plages de prix"

# Test d'une plage de prix spécifique (ID 1)
test_endpoint "price_ranges/1" "Plage de prix ID 1"

# Résumé
echo -e "${BLUE}=== TESTS DE FILTRES ===${NC}"

# Test avec filtres sur les fournisseurs de produits
echo -e "${YELLOW}Testing: Fournisseurs pour le produit ID 1${NC}"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    "$BASE_URL/api/product_suppliers?ws_key=$API_KEY&output_format=JSON&filter[id_product]=1")

http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
if [ "$http_code" -eq 200 ]; then
    echo -e "${GREEN}✓ Filtre par produit fonctionne${NC}"
else
    echo -e "${RED}✗ Filtre par produit échoué (HTTP $http_code)${NC}"
fi
echo ""

# Test avec filtres sur les champs de personnalisation
echo -e "${YELLOW}Testing: Champs de personnalisation pour le produit ID 1${NC}"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    "$BASE_URL/api/product_customization_fields?ws_key=$API_KEY&output_format=JSON&filter[id_product]=1")

http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
if [ "$http_code" -eq 200 ]; then
    echo -e "${GREEN}✓ Filtre de personnalisation fonctionne${NC}"
else
    echo -e "${RED}✗ Filtre de personnalisation échoué (HTTP $http_code)${NC}"
fi
echo ""

# Test avec limite
echo -e "${YELLOW}Testing: Limitation à 5 éléments pour les options${NC}"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    "$BASE_URL/api/product_options?ws_key=$API_KEY&output_format=JSON&limit=5")

http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
if [ "$http_code" -eq 200 ]; then
    echo -e "${GREEN}✓ Limitation fonctionne${NC}"
else
    echo -e "${RED}✗ Limitation échouée (HTTP $http_code)${NC}"
fi
echo ""

echo -e "${BLUE}=== FIN DES TESTS ===${NC}"
echo "Tous les tests des sous-ressources produits sont terminés."
