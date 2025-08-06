#!/bin/bash

API_KEY="RLSSKE1B7DKGC9Z8MRR1WFECLTE7H2PV"
BASE_URL="https://marketplace.koutonou.com/api"

echo "=== Testing Category API ==="

# 1. Get root category (ID 2 - Accueil)
echo "\n1. Getting root category (ID 2):"
curl -s -H "Output-Format: JSON" -H "Accept: application/json" \
  "${BASE_URL}/categories/2?ws_key=${API_KEY}&output_format=JSON&display=full" | json_pp

# 2. Get all categories without filters
echo "\n2. Getting all categories without filters:"
curl -s -H "Output-Format: JSON" -H "Accept: application/json" \
  "${BASE_URL}/categories?ws_key=${API_KEY}&output_format=JSON&display=full" | json_pp

# 3. Get all categories with active filter
echo "\n3. Getting all active categories:"
curl -s -H "Output-Format: JSON" -H "Accept: application/json" \
  "${BASE_URL}/categories?ws_key=${API_KEY}&output_format=JSON&display=full&filter[active]=1" | json_pp

# 4. Get category schema
echo "\n4. Getting category schema:"
curl -s -H "Output-Format: JSON" -H "Accept: application/json" \
  "${BASE_URL}/categories?ws_key=${API_KEY}&schema=synopsis" | json_pp
