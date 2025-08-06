import '../lib/modules/products/models/product_supplier_model.dart';
import '../lib/modules/products/models/product_option_model.dart';
import '../lib/modules/products/models/product_option_value_model.dart';
import '../lib/modules/products/models/product_feature_model.dart';
import '../lib/modules/products/models/product_feature_value_model.dart';
import '../lib/modules/products/models/customization_field_model.dart';
import '../lib/modules/products/models/price_range_model.dart';

/// Test simple des modèles de sous-ressources de produits
void main() {
  print('=== TEST DES MODÈLES SOUS-RESSOURCES PRODUITS ===\n');

  // Test ProductSupplier
  testProductSupplier();

  // Test ProductOption
  testProductOption();

  // Test ProductOptionValue
  testProductOptionValue();

  // Test ProductFeature
  testProductFeature();

  // Test ProductFeatureValue
  testProductFeatureValue();

  // Test CustomizationField
  testCustomizationField();

  // Test PriceRange
  testPriceRange();

  print('\n=== TOUS LES TESTS SONT TERMINÉS ===');
}

void testProductSupplier() {
  print('🔄 Test ProductSupplier...');

  // Test avec données JSON simulées
  final json = {
    'id': '1',
    'id_product': '10',
    'id_product_attribute': '5',
    'id_supplier': '3',
    'id_currency': '1',
    'product_supplier_reference': 'SUP-REF-001',
    'product_supplier_price_te': '25.50',
  };

  try {
    final supplier = ProductSupplier.fromPrestaShopJson(json);

    assert(supplier.id == 1);
    assert(supplier.idProduct == 10);
    assert(supplier.idProductAttribute == 5);
    assert(supplier.idSupplier == 3);
    assert(supplier.idCurrency == 1);
    assert(supplier.productSupplierReference == 'SUP-REF-001');
    assert(supplier.productSupplierPriceTe == 25.50);

    // Test conversion XML
    final xml = supplier.toPrestaShopXml();
    assert(xml.contains('<id_product><![CDATA[10]]></id_product>'));
    assert(
      xml.contains(
        '<product_supplier_reference><![CDATA[SUP-REF-001]]></product_supplier_reference>',
      ),
    );

    print('✅ ProductSupplier: OK');
  } catch (e) {
    print('❌ ProductSupplier: ÉCHEC - $e');
  }
}

void testProductOption() {
  print('🔄 Test ProductOption...');

  // Test avec données JSON simulées (structure PrestaShop)
  final json = {
    'id': '2',
    'is_color_group': '1',
    'group_type': 'color',
    'position': '1',
    'name': {
      'language': [
        {
          '@attributes': {'id': '1'},
          '\$': 'Couleur',
        },
        {
          '@attributes': {'id': '2'},
          '\$': 'Color',
        },
      ],
    },
    'public_name': {
      'language': [
        {
          '@attributes': {'id': '1'},
          '\$': 'Couleur',
        },
        {
          '@attributes': {'id': '2'},
          '\$': 'Color',
        },
      ],
    },
    'associations': {
      'product_option_values': {
        'product_option_value': [
          {'id': '1'},
          {'id': '2'},
        ],
      },
    },
  };

  try {
    final option = ProductOption.fromPrestaShopJson(json);

    assert(option.id == 2);
    assert(option.isColorGroup == true);
    assert(option.groupType == 'color');
    assert(option.position == 1);
    assert(option.name['1'] == 'Couleur');
    assert(option.name['2'] == 'Color');
    assert(option.productOptionValueIds?.length == 2);

    // Test helpers
    assert(option.getNameInLanguage('1') == 'Couleur');
    assert(option.getPublicNameInLanguage('2') == 'Color');

    print('✅ ProductOption: OK');
  } catch (e) {
    print('❌ ProductOption: ÉCHEC - $e');
  }
}

void testProductOptionValue() {
  print('🔄 Test ProductOptionValue...');

  final json = {
    'id': '5',
    'id_attribute_group': '2',
    'color': '#FF0000',
    'position': '1',
    'name': {
      'language': [
        {
          '@attributes': {'id': '1'},
          '\$': 'Rouge',
        },
        {
          '@attributes': {'id': '2'},
          '\$': 'Red',
        },
      ],
    },
  };

  try {
    final value = ProductOptionValue.fromPrestaShopJson(json);

    assert(value.id == 5);
    assert(value.idAttributeGroup == 2);
    assert(value.color == '#FF0000');
    assert(value.position == 1);
    assert(value.name['1'] == 'Rouge');
    assert(value.isColor == true);

    print('✅ ProductOptionValue: OK');
  } catch (e) {
    print('❌ ProductOptionValue: ÉCHEC - $e');
  }
}

void testProductFeature() {
  print('🔄 Test ProductFeature...');

  final json = {
    'id': '3',
    'position': '2',
    'name': {
      'language': [
        {
          '@attributes': {'id': '1'},
          '\$': 'Poids',
        },
        {
          '@attributes': {'id': '2'},
          '\$': 'Weight',
        },
      ],
    },
  };

  try {
    final feature = ProductFeature.fromPrestaShopJson(json);

    assert(feature.id == 3);
    assert(feature.position == 2);
    assert(feature.name['1'] == 'Poids');
    assert(feature.getNameInLanguage('2') == 'Weight');

    print('✅ ProductFeature: OK');
  } catch (e) {
    print('❌ ProductFeature: ÉCHEC - $e');
  }
}

void testProductFeatureValue() {
  print('🔄 Test ProductFeatureValue...');

  final json = {
    'id': '8',
    'id_feature': '3',
    'custom': '0',
    'value': {
      'language': [
        {
          '@attributes': {'id': '1'},
          '\$': '100g',
        },
        {
          '@attributes': {'id': '2'},
          '\$': '100g',
        },
      ],
    },
  };

  try {
    final featureValue = ProductFeatureValue.fromPrestaShopJson(json);

    assert(featureValue.id == 8);
    assert(featureValue.idFeature == 3);
    assert(featureValue.custom == false);
    assert(featureValue.value['1'] == '100g');

    print('✅ ProductFeatureValue: OK');
  } catch (e) {
    print('❌ ProductFeatureValue: ÉCHEC - $e');
  }
}

void testCustomizationField() {
  print('🔄 Test CustomizationField...');

  final json = {
    'id': '1',
    'id_product': '10',
    'type': '0', // Texte
    'required': '1',
    'is_module': '0',
    'is_deleted': '0',
    'name': {
      'language': [
        {
          '@attributes': {'id': '1'},
          '\$': 'Texte personnalisé',
        },
        {
          '@attributes': {'id': '2'},
          '\$': 'Custom text',
        },
      ],
    },
  };

  try {
    final field = CustomizationField.fromPrestaShopJson(json);

    assert(field.id == 1);
    assert(field.idProduct == 10);
    assert(field.type == 0);
    assert(field.required == true);
    assert(field.isModule == false);
    assert(field.isDeleted == false);
    assert(field.name['1'] == 'Texte personnalisé');
    assert(field.typeDescription == 'Texte');

    print('✅ CustomizationField: OK');
  } catch (e) {
    print('❌ CustomizationField: ÉCHEC - $e');
  }
}

void testPriceRange() {
  print('🔄 Test PriceRange...');

  final json = {
    'id': '1',
    'id_carrier': '5',
    'delimiter1': '0.00',
    'delimiter2': '50.00',
  };

  try {
    final range = PriceRange.fromPrestaShopJson(json);

    assert(range.id == 1);
    assert(range.idCarrier == 5);
    assert(range.delimiter1 == 0.00);
    assert(range.delimiter2 == 50.00);
    assert(range.containsPrice(25.00) == true);
    assert(range.containsPrice(75.00) == false);
    assert(range.rangeDescription == '0.00 € - 50.00 €');

    print('✅ PriceRange: OK');
  } catch (e) {
    print('❌ PriceRange: ÉCHEC - $e');
  }
}
