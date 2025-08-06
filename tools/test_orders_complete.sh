#!/bin/bash

API_KEY="RLSSKE1B7DKGC9Z8MRR1WFECLTE7H2PV"
BASE_URL="https://marketplace.koutonou.com/api"

echo "=== Testing Orders API & Related Resources ==="

# 1. Test Orders
echo "\n1. Testing Orders:"
curl -s -H "Accept: application/json" \
  "${BASE_URL}/orders?ws_key=${API_KEY}&output_format=JSON&display=full&limit=5" | json_pp

# 2. Test Order States
echo "\n2. Testing Order States:"
curl -s -H "Accept: application/json" \
  "${BASE_URL}/order_states?ws_key=${API_KEY}&output_format=JSON&display=full" | json_pp

# 3. Test Order Slips (Avoirs)
echo "\n3. Testing Order Slips:"
curl -s -H "Accept: application/json" \
  "${BASE_URL}/order_slip?ws_key=${API_KEY}&output_format=JSON&display=full&limit=5" | json_pp

# 4. Test Order Payments
echo "\n4. Testing Order Payments:"
curl -s -H "Accept: application/json" \
  "${BASE_URL}/order_payments?ws_key=${API_KEY}&output_format=JSON&display=full&limit=5" | json_pp

# 5. Test Order Invoices
echo "\n5. Testing Order Invoices:"
curl -s -H "Accept: application/json" \
  "${BASE_URL}/order_invoices?ws_key=${API_KEY}&output_format=JSON&display=full&limit=5" | json_pp

# 6. Test Order Histories
echo "\n6. Testing Order Histories:"
curl -s -H "Accept: application/json" \
  "${BASE_URL}/order_histories?ws_key=${API_KEY}&output_format=JSON&display=full&limit=5" | json_pp

# 7. Test Order Details
echo "\n7. Testing Order Details:"
curl -s -H "Accept: application/json" \
  "${BASE_URL}/order_details?ws_key=${API_KEY}&output_format=JSON&display=full&limit=5" | json_pp

# 8. Test Order Cart Rules
echo "\n8. Testing Order Cart Rules:"
curl -s -H "Accept: application/json" \
  "${BASE_URL}/order_cart_rules?ws_key=${API_KEY}&output_format=JSON&display=full&limit=5" | json_pp

# 9. Test Order Carriers
echo "\n9. Testing Order Carriers:"
curl -s -H "Accept: application/json" \
  "${BASE_URL}/order_carriers?ws_key=${API_KEY}&output_format=JSON&display=full&limit=5" | json_pp

# 10. Test Schema for Orders
echo "\n10. Testing Order Schema:"
curl -s -H "Accept: application/json" \
  "${BASE_URL}/orders?ws_key=${API_KEY}&schema=synopsis" | json_pp
