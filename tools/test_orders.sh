#!/bin/bash

API_KEY="RLSSKE1B7DKGC9Z8MRR1WFECLTE7H2PV"
BASE_URL="https://marketplace.koutonou.com/api"

echo "=== Testing Orders API ==="

# 1. Get all orders
echo -e "\n1. Getting all orders:"
curl -s -H "Output-Format: JSON" -H "Accept: application/json" \
  "${BASE_URL}/orders?ws_key=${API_KEY}&output_format=JSON&display=full&limit=5" | json_pp

# 2. Get order states
echo -e "\n2. Getting order states:"
curl -s -H "Output-Format: JSON" -H "Accept: application/json" \
  "${BASE_URL}/order_states?ws_key=${API_KEY}&output_format=JSON&display=full" | json_pp

# 3. Get order details (if any orders exist)
echo -e "\n3. Getting order details:"
curl -s -H "Output-Format: JSON" -H "Accept: application/json" \
  "${BASE_URL}/order_details?ws_key=${API_KEY}&output_format=JSON&display=full&limit=5" | json_pp

# 4. Get order histories
echo -e "\n4. Getting order histories:"
curl -s -H "Output-Format: JSON" -H "Accept: application/json" \
  "${BASE_URL}/order_histories?ws_key=${API_KEY}&output_format=JSON&display=full&limit=5" | json_pp

# 5. Get orders schema
echo -e "\n5. Getting orders schema:"
curl -s -H "Output-Format: JSON" -H "Accept: application/json" \
  "${BASE_URL}/orders?ws_key=${API_KEY}&schema=synopsis" | json_pp
