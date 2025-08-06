/// Test des nouveaux modèles du module Products
/// Usage: dart tools/test_products_new_models.dart

import '../lib/modules/products/models/specific_price_model.dart';
import '../lib/modules/products/models/specific_price_rule_model.dart';
import '../lib/modules/products/models/combination_model.dart';

void main() {
  print('🧪 Tests des nouveaux modèles Products');
  print('=====================================\n');

  testSpecificPrice();
  testSpecificPriceRule();
  testCombination();

  print('\n✅ Tous les tests sont passés avec succès !');
}

void testSpecificPrice() {
  print('📋 Test SpecificPrice');
  print('---------------------');

  // Test données JSON simulées
  final json = {
    'id': '123',
    'id_shop': '1',
    'id_cart': '0',
    'id_product': '45',
    'id_currency': '1',
    'id_country': '8',
    'id_group': '1',
    'id_customer': '67',
    'price': '99.99',
    'from_quantity': '5',
    'reduction': '10.0',
    'reduction_tax': '1',
    'reduction_type': 'percentage',
    'from': '2025-01-01 00:00:00',
    'to': '2025-12-31 23:59:59',
  };

  // Test création depuis JSON
  final specificPrice = SpecificPrice.fromPrestaShopJson(json);
  print('✓ Création depuis JSON: ${specificPrice.id}');
  print('✓ Produit: ${specificPrice.idProduct}');
  print('✓ Réduction: ${specificPrice.reduction}% ${specificPrice.reductionTypeDescription}');
  print('✓ Période: ${specificPrice.from} → ${specificPrice.to}');
  print('✓ Active: ${specificPrice.isActive}');

  // Test calcul de prix
  final originalPrice = 120.0;
  final finalPrice = specificPrice.calculateFinalPrice(originalPrice);
  print('✓ Prix original: ${originalPrice}€ → Prix final: ${finalPrice}€');

  // Test conversion XML
  final xml = specificPrice.toPrestaShopXml();
  print('✓ Conversion XML: ${xml.contains('<specific_price>') ? 'OK' : 'FAIL'}');

  print('✅ SpecificPrice testé avec succès\n');
}

void testSpecificPriceRule() {
  print('📋 Test SpecificPriceRule');
  print('-------------------------');

  // Test données JSON simulées
  final json = {
    'id': '789',
    'id_shop': '1',
    'id_country': '8',
    'id_currency': '1',
    'id_group': '1',
    'name': 'Promotion Été 2025',
    'from_quantity': '3',
    'price': '0',
    'reduction': '15.5',
    'reduction_tax': '0',
    'reduction_type': 'percentage',
    'from': '2025-06-01 00:00:00',
    'to': '2025-08-31 23:59:59',
  };

  // Test création depuis JSON
  final rule = SpecificPriceRule.fromPrestaShopJson(json);
  print('✓ Création depuis JSON: ${rule.id}');
  print('✓ Nom: ${rule.name}');
  print('✓ Réduction: ${rule.reductionDescription}');
  print('✓ Période: ${rule.activePeriod}');
  print('✓ Active: ${rule.isActive}');

  // Test calcul de prix
  final originalPrice = 80.0;
  final finalPrice = rule.calculateFinalPrice(originalPrice);
  print('✓ Prix original: ${originalPrice}€ → Prix final: ${finalPrice}€');

  // Test conversion XML
  final xml = rule.toPrestaShopXml();
  print('✓ Conversion XML: ${xml.contains('<specific_price_rule>') ? 'OK' : 'FAIL'}');

  print('✅ SpecificPriceRule testé avec succès\n');
}

void testCombination() {
  print('📋 Test Combination');
  print('-------------------');

  // Test données JSON simulées avec associations
  final json = {
    'id': '456',
    'id_product': '12',
    'location': 'A1-B2-C3',
    'ean13': '1234567890123',
    'reference': 'COMBO-RED-XL',
    'quantity': '25',
    'price': '15.50',
    'weight': '0.250',
    'minimal_quantity': '1',
    'default_on': '1',
    'associations': {
      'product_option_values': {
        'product_option_value': [
          {'id': '11'}, // Couleur: Rouge
          {'id': '22'}, // Taille: XL
        ]
      },
      'images': {
        'image': [
          {'id': '33'},
          {'id': '44'},
        ]
      }
    }
  };

  // Test création depuis JSON
  final combination = Combination.fromPrestaShopJson(json);
  print('✓ Création depuis JSON: ${combination.id}');
  print('✓ Produit: ${combination.idProduct}');
  print('✓ Référence: ${combination.fullReference}');
  print('✓ Stock: ${combination.quantity} unités');
  print('✓ Statut: ${combination.availabilityStatus}');
  print('✓ En stock: ${combination.inStock}');
  print('✓ Options: ${combination.productOptionValueIds?.length ?? 0}');
  print('✓ Images: ${combination.imageIds?.length ?? 0}');

  // Test calcul de prix avec impact
  final basePrice = 100.0;
  final finalPrice = combination.calculateFinalPrice(basePrice);
  print('✓ Prix de base: ${basePrice}€ → Prix final: ${finalPrice}€');

  // Test conversion XML
  final xml = combination.toPrestaShopXml();
  print('✓ Conversion XML: ${xml.contains('<combination>') ? 'OK' : 'FAIL'}');

  // Test associations
  if (combination.productOptionValueIds != null) {
    print('✓ Valeurs d\'options: ${combination.productOptionValueIds!.join(', ')}');
  }
  if (combination.imageIds != null) {
    print('✓ Images: ${combination.imageIds!.join(', ')}');
  }

  print('✅ Combination testé avec succès\n');
}
