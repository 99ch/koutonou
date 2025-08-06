#!/bin/bash

echo "=== Testing Shipping Endpoints ==="
echo "Base URL: http://localhost:8080/api"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo -e "\n${YELLOW}Testing: $description${NC}"
    echo "Method: $method | Endpoint: $endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "$endpoint")
    else
        response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X "$method" -H "Content-Type: application/json" -d "$data" "$endpoint")
    fi
    
    http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
    body=$(echo "$response" | sed '/HTTP_CODE:/d')
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo -e "${GREEN}✅ SUCCESS (HTTP $http_code)${NC}"
        echo "Response: $(echo "$body" | head -c 200)..."
    else
        echo -e "${RED}❌ FAILED (HTTP $http_code)${NC}"
        echo "Response: $body"
    fi
}

BASE_URL="http://localhost:8080/api"

echo -e "\n${YELLOW}=== CARRIERS ENDPOINTS ===${NC}"

# Test GET /carriers
test_endpoint "GET" "$BASE_URL/carriers" "" "Get all carriers"

# Test POST /carriers
carrier_data='{
    "carrier": {
        "name": "Test Carrier",
        "delay": [
            {"id": "1", "value": "2-3 days"}
        ],
        "grade": "1",
        "url": "https://tracking.example.com/@",
        "position": "1",
        "active": "1",
        "is_free": "0",
        "is_module": "1",
        "external_module_name": "test_module",
        "shipping_handling": "1",
        "shipping_method": "1",
        "max_width": "120",
        "max_height": "80",
        "max_depth": "80",
        "max_weight": "30"
    }
}'
test_endpoint "POST" "$BASE_URL/carriers" "$carrier_data" "Create new carrier"

# Test GET /carriers/1
test_endpoint "GET" "$BASE_URL/carriers/1" "" "Get carrier by ID"

# Test PUT /carriers/1
update_data='{
    "carrier": {
        "name": "Updated Test Carrier",
        "active": "1"
    }
}'
test_endpoint "PUT" "$BASE_URL/carriers/1" "$update_data" "Update carrier"

echo -e "\n${YELLOW}=== ZONES ENDPOINTS ===${NC}"

# Test GET /zones
test_endpoint "GET" "$BASE_URL/zones" "" "Get all zones"

# Test POST /zones
zone_data='{
    "zone": {
        "name": "Test Zone",
        "active": "1"
    }
}'
test_endpoint "POST" "$BASE_URL/zones" "$zone_data" "Create new zone"

# Test GET /zones/1
test_endpoint "GET" "$BASE_URL/zones/1" "" "Get zone by ID"

echo -e "\n${YELLOW}=== DELIVERIES ENDPOINTS ===${NC}"

# Test GET /deliveries
test_endpoint "GET" "$BASE_URL/deliveries" "" "Get all deliveries"

# Test POST /deliveries
delivery_data='{
    "delivery": {
        "id_carrier": "1",
        "id_zone": "1",
        "id_range_weight": "1",
        "id_range_price": "1",
        "price": "15.99"
    }
}'
test_endpoint "POST" "$BASE_URL/deliveries" "$delivery_data" "Create new delivery"

echo -e "\n${YELLOW}=== PRICE RANGES ENDPOINTS ===${NC}"

# Test GET /price_ranges
test_endpoint "GET" "$BASE_URL/price_ranges" "" "Get all price ranges"

# Test POST /price_ranges
price_range_data='{
    "price_range": {
        "id_carrier": "1",
        "delimiter1": "0",
        "delimiter2": "50"
    }
}'
test_endpoint "POST" "$BASE_URL/price_ranges" "$price_range_data" "Create new price range"

echo -e "\n${YELLOW}=== WEIGHT RANGES ENDPOINTS ===${NC}"

# Test GET /weight_ranges
test_endpoint "GET" "$BASE_URL/weight_ranges" "" "Get all weight ranges"

# Test POST /weight_ranges
weight_range_data='{
    "weight_range": {
        "id_carrier": "1",
        "delimiter1": "0",
        "delimiter2": "10"
    }
}'
test_endpoint "POST" "$BASE_URL/weight_ranges" "$weight_range_data" "Create new weight range"

echo -e "\n${YELLOW}=== ADVANCED QUERIES ===${NC}"

# Test carrier search
test_endpoint "GET" "$BASE_URL/carriers?filter[name]=[Test]%" "" "Search carriers by name"

# Test carrier filtering by active status
test_endpoint "GET" "$BASE_URL/carriers?filter[active]=1" "" "Get active carriers only"

# Test zone with countries
test_endpoint "GET" "$BASE_URL/zones/1/countries" "" "Get zone countries"

# Test carrier deliveries
test_endpoint "GET" "$BASE_URL/carriers/1/deliveries" "" "Get carrier deliveries"

# Test zone deliveries
test_endpoint "GET" "$BASE_URL/zones/1/deliveries" "" "Get zone deliveries"

# Test delivery by price range
test_endpoint "GET" "$BASE_URL/deliveries?filter[price]=[0,20]" "" "Get deliveries in price range"

# Test sorting
test_endpoint "GET" "$BASE_URL/carriers?sort=position" "" "Get carriers sorted by position"
test_endpoint "GET" "$BASE_URL/deliveries?sort=price" "" "Get deliveries sorted by price"

echo -e "\n${GREEN}=== Shipping endpoints testing completed ===${NC}"
