#!/bin/bash

# Test des endpoints Media (Images et Types d'Images) pour PrestaShop
# Usage: ./test_media_endpoints.sh

# Configuration PRODUCTION (depuis .env)
BASE_URL="https://marketplace.koutonou.com/api"
API_KEY="RLSSKE1B7DKGC9Z8MRR1WFECLTE7H2PV"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les résultats
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
    fi
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

echo "=================================="
echo "🖼️  TEST ENDPOINTS MEDIA - PRODUCTION"
echo "=================================="
echo "Base URL: $BASE_URL"
echo "API Key: ${API_KEY:0:10}..."
echo "Environment: PRODUCTION"
echo "=================================="

# ===================
# TESTS TYPES D'IMAGES
# ===================

echo -e "\n${BLUE}📋 TESTS TYPES D'IMAGES${NC}"
echo "-----------------------------------"

print_info "Test GET /image_types - Liste des types d'images"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    -X GET "$BASE_URL/image_types?ws_key=$API_KEY" \
    -H "Accept: application/json")
http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
body=$(echo "$response" | sed -E 's/HTTPSTATUS:[0-9]*$//')

if [ "$http_code" -eq 200 ]; then
    print_result 0 "GET /image_types - Success ($http_code)"
    echo "$body" | jq -r '.image_types[0:3]' 2>/dev/null || echo "Réponse (format XML): $(echo "$body" | head -c 200)..."
else
    print_result 1 "GET /image_types - Failed ($http_code)"
    echo "Response: $body"
fi

print_info "Test GET /image_types/1 - Détails d'un type d'image"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    -X GET "$BASE_URL/image_types/1?ws_key=$API_KEY" \
    -H "Accept: application/json")
http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
body=$(echo "$response" | sed -E 's/HTTPSTATUS:[0-9]*$//')

if [ "$http_code" -eq 200 ]; then
    print_result 0 "GET /image_types/1 - Success ($http_code)"
    echo "$body" | jq -r '.image_type.name // .image_type.@attributes.name' 2>/dev/null || echo "Réponse: $(echo "$body" | head -c 150)..."
else
    print_result 1 "GET /image_types/1 - Failed ($http_code)"
    echo "Response: $body"
fi

print_info "Test GET /image_types avec filtres"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    -X GET "$BASE_URL/image_types?ws_key=$API_KEY&filter[products]=1" \
    -H "Accept: application/json")
http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
body=$(echo "$response" | sed -E 's/HTTPSTATUS:[0-9]*$//')

if [ -n "$http_code" ] && [ "$http_code" -eq 200 ]; then
    print_result 0 "GET /image_types?filter[products]=1 - Success ($http_code)"
else
    print_result 1 "GET /image_types?filter[products]=1 - Failed (${http_code:-"unknown"})"
fi

print_info "Test création d'un type d'image (POST /image_types)"
xml_data='<?xml version="1.0" encoding="UTF-8"?>
<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
    <image_type>
        <name>test_type</name>
        <width>200</width>
        <height>200</height>
        <products>1</products>
        <categories>0</categories>
        <manufacturers>0</manufacturers>
        <suppliers>0</suppliers>
        <stores>0</stores>
    </image_type>
</prestashop>'

response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    -X POST "$BASE_URL/image_types?ws_key=$API_KEY" \
    -H "Content-Type: application/xml" \
    -d "$xml_data")
http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
body=$(echo "$response" | sed -E 's/HTTPSTATUS:[0-9]*$//')

if [ "$http_code" -eq 201 ]; then
    print_result 0 "POST /image_types - Success ($http_code)"
    # Extraire l'ID du nouveau type créé
    new_type_id=$(echo "$body" | grep -o '<id>[0-9]*</id>' | grep -o '[0-9]*' | head -1)
    echo "Nouveau type d'image créé avec l'ID: $new_type_id"
else
    print_result 1 "POST /image_types - Failed ($http_code)"
    echo "Response: $body"
    new_type_id=""
fi

# Nettoyage: supprimer le type créé pour le test
if [ -n "$new_type_id" ]; then
    print_info "Nettoyage: suppression du type d'image test (ID: $new_type_id)"
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        -X DELETE "$BASE_URL/image_types/$new_type_id?ws_key=$API_KEY")
    http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
    
    if [ "$http_code" -eq 200 ]; then
        print_result 0 "DELETE /image_types/$new_type_id - Success ($http_code)"
    else
        print_warning "DELETE /image_types/$new_type_id - Failed ($http_code)"
    fi
fi

# ===================
# TESTS IMAGES PRODUITS
# ===================

echo -e "\n${BLUE}🖼️  TESTS IMAGES PRODUITS${NC}"
echo "-----------------------------------"

print_info "Test GET /images/products/1 - Images d'un produit"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    -X GET "$BASE_URL/images/products/1?ws_key=$API_KEY" \
    -H "Accept: application/json")
http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
body=$(echo "$response" | sed -E 's/HTTPSTATUS:[0-9]*$//')

if [ "$http_code" -eq 200 ]; then
    print_result 0 "GET /images/products/1 - Success ($http_code)"
    echo "$body" | jq -r '.images[0:3]' 2>/dev/null || echo "Réponse (format XML): $(echo "$body" | head -c 200)..."
else
    print_result 1 "GET /images/products/1 - Failed ($http_code) - Normal si pas d'images"
    echo "Response: $body"
fi

print_info "Test GET /images/products/1/1 - Image spécifique d'un produit"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    -X GET "$BASE_URL/images/products/1/1?ws_key=$API_KEY" \
    -H "Accept: application/json")
http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)

if [ -n "$http_code" ] && [ "$http_code" -eq 200 ]; then
    print_result 0 "GET /images/products/1/1 - Success ($http_code)"
    echo "Image trouvée pour le produit 1"
elif [ -n "$http_code" ] && [ "$http_code" -eq 404 ]; then
    print_warning "GET /images/products/1/1 - Image non trouvée ($http_code) - Normal"
else
    print_result 1 "GET /images/products/1/1 - Failed (${http_code:-"unknown"})"
fi

# Test d'upload d'une image (nécessite un fichier image)
print_info "Test upload d'image produit (POST /images/products/1)"
if command -v convert >/dev/null 2>&1; then
    # Créer une image de test avec ImageMagick
    convert -size 100x100 xc:red /tmp/test_image.jpg 2>/dev/null
    
    if [ -f "/tmp/test_image.jpg" ]; then
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
            -X POST "$BASE_URL/images/products/1?ws_key=$API_KEY" \
            -F "image=@/tmp/test_image.jpg")
        http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
        body=$(echo "$response" | sed -E 's/HTTPSTATUS:[0-9]*$//')

        if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
            print_result 0 "POST /images/products/1 (upload) - Success ($http_code)"
            uploaded_image_id=$(echo "$body" | grep -o '<id>[0-9]*</id>' | grep -o '[0-9]*' | head -1)
            echo "Image uploadée avec l'ID: $uploaded_image_id"
        else
            print_result 1 "POST /images/products/1 (upload) - Failed ($http_code)"
            echo "Response: $body"
            uploaded_image_id=""
        fi
        
        # Nettoyage du fichier temporaire
        rm -f /tmp/test_image.jpg
        
        # Nettoyage: supprimer l'image uploadée
        if [ -n "$uploaded_image_id" ]; then
            print_info "Nettoyage: suppression de l'image test (ID: $uploaded_image_id)"
            response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
                -X DELETE "$BASE_URL/images/products/1/$uploaded_image_id?ws_key=$API_KEY")
            http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
            
            if [ "$http_code" -eq 200 ]; then
                print_result 0 "DELETE image test - Success ($http_code)"
            else
                print_warning "DELETE image test - Failed ($http_code)"
            fi
        fi
    else
        print_warning "Impossible de créer l'image de test"
    fi
else
    print_warning "ImageMagick non disponible - test d'upload ignoré"
fi

# ===================
# TESTS IMAGES CATÉGORIES
# ===================

echo -e "\n${BLUE}📁 TESTS IMAGES CATÉGORIES${NC}"
echo "-----------------------------------"

print_info "Test GET /images/categories/1 - Images d'une catégorie"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    -X GET "$BASE_URL/images/categories/1?ws_key=$API_KEY" \
    -H "Accept: application/json")
http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)

if [ "$http_code" -eq 200 ]; then
    print_result 0 "GET /images/categories/1 - Success ($http_code)"
elif [ "$http_code" -eq 404 ]; then
    print_warning "GET /images/categories/1 - Pas d'images ($http_code) - Normal"
else
    print_result 1 "GET /images/categories/1 - Failed ($http_code)"
fi

# ===================
# TESTS IMAGES FABRICANTS
# ===================

echo -e "\n${BLUE}🏭 TESTS IMAGES FABRICANTS${NC}"
echo "-----------------------------------"

print_info "Test GET /images/manufacturers/1 - Images d'un fabricant"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    -X GET "$BASE_URL/images/manufacturers/1?ws_key=$API_KEY" \
    -H "Accept: application/json")
http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)

if [ "$http_code" -eq 200 ]; then
    print_result 0 "GET /images/manufacturers/1 - Success ($http_code)"
elif [ "$http_code" -eq 404 ]; then
    print_warning "GET /images/manufacturers/1 - Pas d'images ($http_code) - Normal"
else
    print_result 1 "GET /images/manufacturers/1 - Failed ($http_code)"
fi

# ===================
# TESTS IMAGES FOURNISSEURS
# ===================

echo -e "\n${BLUE}🚚 TESTS IMAGES FOURNISSEURS${NC}"
echo "-----------------------------------"

print_info "Test GET /images/suppliers/1 - Images d'un fournisseur"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    -X GET "$BASE_URL/images/suppliers/1?ws_key=$API_KEY" \
    -H "Accept: application/json")
http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)

if [ "$http_code" -eq 200 ]; then
    print_result 0 "GET /images/suppliers/1 - Success ($http_code)"
elif [ "$http_code" -eq 404 ]; then
    print_warning "GET /images/suppliers/1 - Pas d'images ($http_code) - Normal"
else
    print_result 1 "GET /images/suppliers/1 - Failed ($http_code)"
fi

# ===================
# TESTS IMAGES MAGASINS
# ===================

echo -e "\n${BLUE}🏪 TESTS IMAGES MAGASINS${NC}"
echo "-----------------------------------"

print_info "Test GET /images/stores/1 - Images d'un magasin"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    -X GET "$BASE_URL/images/stores/1?ws_key=$API_KEY" \
    -H "Accept: application/json")
http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)

if [ "$http_code" -eq 200 ]; then
    print_result 0 "GET /images/stores/1 - Success ($http_code)"
elif [ "$http_code" -eq 404 ]; then
    print_warning "GET /images/stores/1 - Pas d'images ($http_code) - Normal"
else
    print_result 1 "GET /images/stores/1 - Failed ($http_code)"
fi

# ===================
# TESTS MÉTADONNÉES
# ===================

echo -e "\n${BLUE}📊 TESTS MÉTADONNÉES${NC}"
echo "-----------------------------------"

print_info "Test GET /images/products (métadonnées globales)"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    -X GET "$BASE_URL/images/products?ws_key=$API_KEY" \
    -H "Accept: application/json")
http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)

if [ "$http_code" -eq 200 ]; then
    print_result 0 "GET /images/products (métadonnées) - Success ($http_code)"
else
    print_result 1 "GET /images/products (métadonnées) - Failed ($http_code)"
fi

# ===================
# RÉSUMÉ
# ===================

echo -e "\n${BLUE}📋 RÉSUMÉ DES TESTS${NC}"
echo "=================================="
echo "Tests effectués:"
echo "• Types d'images: GET, POST, DELETE"
echo "• Images produits: GET, POST (upload), DELETE"
echo "• Images catégories: GET"
echo "• Images fabricants: GET"
echo "• Images fournisseurs: GET"
echo "• Images magasins: GET"
echo "• Métadonnées globales: GET"
echo ""
echo "✅ Les codes 200/201 indiquent un succès"
echo "⚠️  Les codes 404 sont normaux si aucune donnée n'existe"
echo "❌ Les autres codes indiquent des erreurs"
echo ""
echo "📝 Note: Certains endpoints peuvent nécessiter:"
echo "   - Des données existantes (produits, catégories, etc.)"
echo "   - Des permissions spécifiques"
echo "   - Une configuration particulière de PrestaShop"
echo "=================================="
