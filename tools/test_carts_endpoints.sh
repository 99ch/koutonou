#!/bin/bash

# Script de test pour les endpoints Cart et CartRule de l'API PrestaShop
# Usage: ./test_carts_endpoints.sh

# Configuration
API_URL="https://your-prestashop-url.com/api"
API_KEY="your-api-key-here"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Test des endpoints Cart et CartRule ===${NC}\n"

# Fonction pour afficher les résultats
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
    fi
}

# Fonction pour tester un endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local description=$3
    local data=$4
    
    echo -e "${YELLOW}Testing: $description${NC}"
    
    if [ -z "$data" ]; then
        response=$(curl -s -w "%{http_code}" -X "$method" \
            -H "Authorization: Basic $(echo -n "$API_KEY:" | base64)" \
            -H "Content-Type: application/json" \
            "$API_URL$endpoint" \
            -o /tmp/response.json)
    else
        response=$(curl -s -w "%{http_code}" -X "$method" \
            -H "Authorization: Basic $(echo -n "$API_KEY:" | base64)" \
            -H "Content-Type: application/xml" \
            -d "$data" \
            "$API_URL$endpoint" \
            -o /tmp/response.json)
    fi
    
    http_code="${response: -3}"
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        print_result 0 "$description - HTTP $http_code"
        return 0
    else
        print_result 1 "$description - HTTP $http_code"
        echo -e "${RED}Response: $(cat /tmp/response.json)${NC}"
        return 1
    fi
}

echo -e "${BLUE}--- Tests des endpoints Carts ---${NC}"

# Test GET /carts
test_endpoint "GET" "/carts" "Récupérer tous les paniers"

# Test GET /carts avec paramètres
test_endpoint "GET" "/carts?display=full&limit=10" "Récupérer paniers avec paramètres"

# Test GET /carts avec filtres
test_endpoint "GET" "/carts?filter[active]=1" "Récupérer paniers actifs"

# Test GET /carts/{id} (utiliser un ID existant)
CART_ID=1
test_endpoint "GET" "/carts/$CART_ID" "Récupérer panier spécifique ID=$CART_ID"

# Test POST /carts (création)
cart_xml='<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
  <cart>
    <id_currency><![CDATA[1]]></id_currency>
    <id_lang><![CDATA[1]]></id_lang>
    <id_customer><![CDATA[1]]></id_customer>
    <recyclable><![CDATA[0]]></recyclable>
    <gift><![CDATA[0]]></gift>
    <mobile_theme><![CDATA[0]]></mobile_theme>
    <allow_seperated_package><![CDATA[0]]></allow_seperated_package>
  </cart>
</prestashop>'

test_endpoint "POST" "/carts" "Créer un nouveau panier" "$cart_xml"

# Récupérer l'ID du panier créé (si succès)
if [ $? -eq 0 ]; then
    CREATED_CART_ID=$(grep -o '<id><!\[CDATA\[\([0-9]*\)\]\]></id>' /tmp/response.json | sed 's/<id><!\[CDATA\[\([0-9]*\)\]\]><\/id>/\1/')
    if [ ! -z "$CREATED_CART_ID" ]; then
        echo -e "${GREEN}Panier créé avec ID: $CREATED_CART_ID${NC}"
        
        # Test PUT /carts/{id} (mise à jour)
        updated_cart_xml='<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
          <cart>
            <id><![CDATA['"$CREATED_CART_ID"']]></id>
            <id_currency><![CDATA[1]]></id_currency>
            <id_lang><![CDATA[1]]></id_lang>
            <id_customer><![CDATA[1]]></id_customer>
            <recyclable><![CDATA[1]]></recyclable>
            <gift><![CDATA[1]]></gift>
            <gift_message><![CDATA[Joyeux anniversaire!]]></gift_message>
          </cart>
        </prestashop>'
        
        test_endpoint "PUT" "/carts/$CREATED_CART_ID" "Mettre à jour le panier" "$updated_cart_xml"
        
        # Test DELETE /carts/{id}
        test_endpoint "DELETE" "/carts/$CREATED_CART_ID" "Supprimer le panier"
    fi
fi

echo ""
echo -e "${BLUE}--- Tests des endpoints Cart Rules ---${NC}"

# Test GET /cart_rules
test_endpoint "GET" "/cart_rules" "Récupérer toutes les règles de panier"

# Test GET /cart_rules avec paramètres
test_endpoint "GET" "/cart_rules?display=full&limit=5" "Récupérer règles avec paramètres"

# Test GET /cart_rules avec filtres (règles actives)
test_endpoint "GET" "/cart_rules?filter[active]=1" "Récupérer règles actives"

# Test GET /cart_rules/{id}
CART_RULE_ID=1
test_endpoint "GET" "/cart_rules/$CART_RULE_ID" "Récupérer règle spécifique ID=$CART_RULE_ID"

# Test POST /cart_rules (création)
cart_rule_xml='<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
  <cart_rule>
    <date_from><![CDATA[2024-01-01 00:00:00]]></date_from>
    <date_to><![CDATA[2024-12-31 23:59:59]]></date_to>
    <active><![CDATA[1]]></active>
    <code><![CDATA[TEST2024]]></code>
    <reduction_percent><![CDATA[10]]></reduction_percent>
    <minimum_amount><![CDATA[50]]></minimum_amount>
    <name>
      <language id="1"><![CDATA[Promotion Test]]></language>
      <language id="2"><![CDATA[Test Promotion]]></language>
    </name>
  </cart_rule>
</prestashop>'

test_endpoint "POST" "/cart_rules" "Créer une nouvelle règle de panier" "$cart_rule_xml"

# Récupérer l'ID de la règle créée
if [ $? -eq 0 ]; then
    CREATED_RULE_ID=$(grep -o '<id><!\[CDATA\[\([0-9]*\)\]\]></id>' /tmp/response.json | sed 's/<id><!\[CDATA\[\([0-9]*\)\]\]><\/id>/\1/')
    if [ ! -z "$CREATED_RULE_ID" ]; then
        echo -e "${GREEN}Règle créée avec ID: $CREATED_RULE_ID${NC}"
        
        # Test PUT /cart_rules/{id}
        updated_rule_xml='<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
          <cart_rule>
            <id><![CDATA['"$CREATED_RULE_ID"']]></id>
            <date_from><![CDATA[2024-01-01 00:00:00]]></date_from>
            <date_to><![CDATA[2024-12-31 23:59:59]]></date_to>
            <active><![CDATA[1]]></active>
            <code><![CDATA[TESTUPDATE]]></code>
            <reduction_percent><![CDATA[15]]></reduction_percent>
            <minimum_amount><![CDATA[75]]></minimum_amount>
            <free_shipping><![CDATA[1]]></free_shipping>
            <name>
              <language id="1"><![CDATA[Promotion Test Mise à jour]]></language>
              <language id="2"><![CDATA[Updated Test Promotion]]></language>
            </name>
          </cart_rule>
        </prestashop>'
        
        test_endpoint "PUT" "/cart_rules/$CREATED_RULE_ID" "Mettre à jour la règle" "$updated_rule_xml"
        
        # Test DELETE /cart_rules/{id}
        test_endpoint "DELETE" "/cart_rules/$CREATED_RULE_ID" "Supprimer la règle"
    fi
fi

echo ""
echo -e "${BLUE}--- Tests des endpoints spécialisés ---${NC}"

# Test recherche de paniers par client
CUSTOMER_ID=1
test_endpoint "GET" "/carts?filter[id_customer]=$CUSTOMER_ID" "Rechercher paniers par client ID=$CUSTOMER_ID"

# Test recherche de règles par code
test_endpoint "GET" "/cart_rules?filter[code]=WELCOME10" "Rechercher règles par code"

# Test des règles avec livraison gratuite
test_endpoint "GET" "/cart_rules?filter[free_shipping]=1" "Règles avec livraison gratuite"

# Test des règles avec réduction pourcentage
test_endpoint "GET" "/cart_rules?filter[reduction_percent]=[1 TO *]" "Règles avec réduction pourcentage"

# Test des règles avec réduction montant
test_endpoint "GET" "/cart_rules?filter[reduction_amount]=[1 TO *]" "Règles avec réduction montant"

# Test des règles avec produit cadeau
test_endpoint "GET" "/cart_rules?filter[gift_product]=[1 TO *]" "Règles avec produit cadeau"

# Test des paniers avec produits
test_endpoint "GET" "/carts?display=[id,id_customer,associations]" "Paniers avec associations"

echo ""
echo -e "${BLUE}--- Tests des associations ---${NC}"

# Test panier avec ses produits
test_endpoint "GET" "/carts?display=full&associations[cart_rows]=[id_product,quantity]" "Paniers avec produits détaillés"

echo ""
echo -e "${BLUE}--- Résumé des tests ---${NC}"

# Compter les succès et échecs
success_count=$(grep -c "✓" /tmp/test_results 2>/dev/null || echo "0")
failure_count=$(grep -c "✗" /tmp/test_results 2>/dev/null || echo "0")

echo -e "${GREEN}Tests réussis: $success_count${NC}"
echo -e "${RED}Tests échoués: $failure_count${NC}"

if [ "$failure_count" -eq 0 ]; then
    echo -e "${GREEN}🎉 Tous les tests sont passés avec succès !${NC}"
    exit 0
else
    echo -e "${RED}❌ Certains tests ont échoué. Vérifiez la configuration de l'API.${NC}"
    exit 1
fi

# Instructions d'utilisation
echo ""
echo -e "${YELLOW}Instructions:${NC}"
echo "1. Modifiez les variables API_URL et API_KEY au début du script"
echo "2. Assurez-vous que votre PrestaShop API est configurée pour accepter les requêtes"
echo "3. Exécutez le script: ./test_carts_endpoints.sh"
echo ""
echo -e "${YELLOW}Endpoints testés:${NC}"
echo "- GET    /carts (liste des paniers)"
echo "- GET    /carts/{id} (panier spécifique)"
echo "- POST   /carts (création)"
echo "- PUT    /carts/{id} (mise à jour)"
echo "- DELETE /carts/{id} (suppression)"
echo "- GET    /cart_rules (liste des règles)"
echo "- GET    /cart_rules/{id} (règle spécifique)"
echo "- POST   /cart_rules (création)"
echo "- PUT    /cart_rules/{id} (mise à jour)"
echo "- DELETE /cart_rules/{id} (suppression)"
echo "- Filtres et recherches avancées"
