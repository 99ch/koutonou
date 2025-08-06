#!/bin/bash

API_KEY="RLSSKE1B7DKGC9Z8MRR1WFECLTE7H2PV"
BASE_URL="https://marketplace.koutonou.com/api"

echo "=== Creating Test Category ==="

# Create a test category under "Accueil" (ID 2)
cat << 'EOF' > /tmp/test_category.xml
<?xml version="1.0" encoding="UTF-8"?>
<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
  <category>
    <id_parent><![CDATA[2]]></id_parent>
    <active><![CDATA[1]]></active>
    <id_shop_default><![CDATA[1]]></id_shop_default>
    <is_root_category><![CDATA[0]]></is_root_category>
    <position><![CDATA[1]]></position>
    <name>
      <language id="1"><![CDATA[Test Category]]></language>
      <language id="2"><![CDATA[Catégorie Test]]></language>
    </name>
    <link_rewrite>
      <language id="1"><![CDATA[test-category]]></language>
      <language id="2"><![CDATA[categorie-test]]></language>
    </link_rewrite>
    <description>
      <language id="1"><![CDATA[This is a test category created via API]]></language>
      <language id="2"><![CDATA[Ceci est une catégorie test créée via API]]></language>
    </description>
    <meta_title>
      <language id="1"><![CDATA[Test Category]]></language>
      <language id="2"><![CDATA[Catégorie Test]]></language>
    </meta_title>
    <meta_description>
      <language id="1"><![CDATA[Test category for API validation]]></language>
      <language id="2"><![CDATA[Catégorie test pour validation API]]></language>
    </meta_description>
    <meta_keywords>
      <language id="1"><![CDATA[test, category, api]]></language>
      <language id="2"><![CDATA[test, catégorie, api]]></language>
    </meta_keywords>
  </category>
</prestashop>
EOF

echo "1. Creating test category..."
curl -X POST \
  -H "Content-Type: application/xml" \
  -H "Accept: application/json" \
  --data @/tmp/test_category.xml \
  "${BASE_URL}/categories?ws_key=${API_KEY}&output_format=JSON" | json_pp

echo -e "\n2. Fetching all categories after creation..."
curl -s -H "Accept: application/json" \
  "${BASE_URL}/categories?ws_key=${API_KEY}&output_format=JSON&display=full" | json_pp

# Clean up
rm -f /tmp/test_category.xml
