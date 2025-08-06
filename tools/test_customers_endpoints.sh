#!/bin/bash

# Test des endpoints API pour le module Customers
# Usage: ./tools/test_customers_endpoints.sh

echo "🧪 Test des endpoints API Customers"
echo "===================================="
echo ""

# Configuration
BASE_URL="http://localhost:8080/api"
API_KEY="YOUR_API_KEY_HERE"

# Fonction pour tester un endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local description=$3
    
    echo "📋 Test: $description"
    echo "   → $method $endpoint"
    
    case $method in
        "GET")
            curl -s -w "   Status: %{http_code}\n" \
                 -H "Authorization: Basic $API_KEY" \
                 "$BASE_URL/$endpoint" > /dev/null
            ;;
        "POST")
            curl -s -w "   Status: %{http_code}\n" \
                 -X POST \
                 -H "Authorization: Basic $API_KEY" \
                 -H "Content-Type: application/xml" \
                 -d '<?xml version="1.0" encoding="UTF-8"?><prestashop xmlns:xlink="http://www.w3.org/1999/xlink"><customer><email><![CDATA[test@example.com]]></email><passwd><![CDATA[password]]></passwd><lastname><![CDATA[Test]]></lastname><firstname><![CDATA[Customer]]></firstname></customer></prestashop>' \
                 "$BASE_URL/$endpoint" > /dev/null
            ;;
    esac
    
    echo ""
}

# Tests des customers
echo "👤 Tests Customer endpoints"
echo "---------------------------"
test_endpoint "GET" "customers" "Récupérer tous les clients"
test_endpoint "GET" "customers/1" "Récupérer client par ID"
test_endpoint "GET" "customers?filter[email]=%test@%" "Recherche par email"
test_endpoint "GET" "customers?filter[active]=1" "Clients actifs"
test_endpoint "GET" "customers?filter[newsletter]=1" "Abonnés newsletter"
test_endpoint "POST" "customers" "Créer un client"

# Tests des addresses
echo "📍 Tests Address endpoints"
echo "-------------------------"
test_endpoint "GET" "addresses" "Récupérer toutes les adresses"
test_endpoint "GET" "addresses/1" "Récupérer adresse par ID"
test_endpoint "GET" "addresses?filter[id_customer]=1" "Adresses d'un client"

# Tests des groups
echo "👥 Tests Group endpoints"
echo "-----------------------"
test_endpoint "GET" "groups" "Récupérer tous les groupes"
test_endpoint "GET" "groups/1" "Récupérer groupe par ID"

# Tests des customer_messages
echo "💬 Tests CustomerMessage endpoints"
echo "----------------------------------"
test_endpoint "GET" "customer_messages" "Récupérer tous les messages"
test_endpoint "GET" "customer_messages/1" "Récupérer message par ID"

# Tests des customer_threads
echo "🧵 Tests CustomerThread endpoints"
echo "---------------------------------"
test_endpoint "GET" "customer_threads" "Récupérer tous les threads"
test_endpoint "GET" "customer_threads/1" "Récupérer thread par ID"

# Tests des guests
echo "👻 Tests Guest endpoints"
echo "------------------------"
test_endpoint "GET" "guests" "Récupérer tous les invités"
test_endpoint "GET" "guests/1" "Récupérer invité par ID"

echo "✅ Tests terminés !"
echo ""
echo "💡 Notes:"
echo "   - Remplacez YOUR_API_KEY_HERE par votre vraie clé API"
echo "   - Ajustez BASE_URL selon votre environnement"
echo "   - Les status 200/201 indiquent un succès"
echo "   - Les status 401 indiquent un problème d'authentification"
