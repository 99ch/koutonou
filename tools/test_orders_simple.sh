#!/bin/bash

API_KEY="RLSSKE1B7DKGC9Z8MRR1WFECLTE7H2PV"
BASE_URL="https://marketplace.koutonou.com/api"

echo "=== Test Orders API ==="

# 1. Get all orders (limit 3)
echo -e "\n1. Getting first 3 orders:"
curl -s -H "Output-Format: JSON" -H "Accept: application/json" \
  "${BASE_URL}/orders?ws_key=${API_KEY}&output_format=JSON&display=full&limit=3" | json_pp | head -50

# 2. Get order states
echo -e "\n2. Getting order states:"
curl -s -H "Output-Format: JSON" -H "Accept: application/json" \
  "${BASE_URL}/order_states?ws_key=${API_KEY}&output_format=JSON&display=full&limit=5" | json_pp | head -30

# 3. Get order details for first order
echo -e "\n3. Getting order details:"
curl -s -H "Output-Format: JSON" -H "Accept: application/json" \
  "${BASE_URL}/order_details?ws_key=${API_KEY}&output_format=JSON&display=full&limit=3" | json_pp | head -30

echo -e "\n=== Tests completed ==="
