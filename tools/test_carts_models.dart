import 'dart:convert';
import '../lib/modules/carts/models/cart_model.dart';
import '../lib/modules/carts/models/cart_rule_model.dart';

void main() {
  print('=== Test des modèles Cart et CartRule ===\n');

  testCartModel();
  print('');
  testCartRuleModel();
  print('');
  testCartRow();

  print('\n✅ Tous les tests des modèles Cart et CartRule sont réussis !');
}

void testCartModel() {
  print('--- Test du modèle Cart ---');

  // Test création d'un cart avec données minimales
  final cart1 = Cart(
    id: 1,
    idCurrency: 1,
    idLang: 1,
    idCustomer: 123,
    recyclable: true,
    gift: false,
  );

  print('✓ Création cart basique réussie');
  print('  ID: ${cart1.id}');
  print('  Client: ${cart1.idCustomer}');
  print('  Devise: ${cart1.idCurrency}');
  print('  Recyclable: ${cart1.recyclable}');
  print('  Articles: ${cart1.totalItems}');
  print('  Quantité totale: ${cart1.totalQuantity}');

  // Test avec produits
  final cartRows = [
    CartRow(idProduct: 1, quantity: 2),
    CartRow(idProduct: 2, quantity: 1, idProductAttribute: 5),
  ];

  final cart2 = cart1.copyWith(
    cartRows: cartRows,
    gift: true,
    giftMessage: 'Joyeux anniversaire !',
  );

  print('✓ Cart avec produits créé');
  print('  Articles: ${cart2.totalItems}');
  print('  Quantité totale: ${cart2.totalQuantity}');
  print('  Cadeau: ${cart2.gift}');
  print('  Message: ${cart2.hasGiftMessage}');

  // Test JSON serialization
  final json = cart2.toJson();
  print('✓ Sérialisation JSON réussie');

  final cartFromJson = Cart.fromJson(json);
  print('✓ Désérialisation JSON réussie');
  print('  ID restauré: ${cartFromJson.id}');
  print('  Articles restaurés: ${cartFromJson.totalItems}');

  // Test XML serialization
  final xml = cart2.toXml();
  print('✓ Sérialisation XML réussie (${xml.length} caractères)');

  // Test business logic
  print('✓ Tests logique métier:');
  print('  Panier vide: ${Cart(idCurrency: 1, idLang: 1).isEmpty}');
  print('  Panier non vide: ${cart2.isNotEmpty}');
  print('  A un message cadeau: ${cart2.hasGiftMessage}');
}

void testCartRuleModel() {
  print('--- Test du modèle CartRule ---');

  // Test création d'une règle basique
  final now = DateTime.now();
  final futureDate = now.add(const Duration(days: 30));

  final cartRule1 = CartRule(
    id: 1,
    dateFrom: now,
    dateTo: futureDate,
    name: {'1': 'Promotion été', '2': 'Summer promotion'},
    active: true,
    reductionPercent: 10.0,
    code: 'SUMMER10',
  );

  print('✓ Création cart rule basique réussie');
  print('  ID: ${cartRule1.id}');
  print('  Nom (FR): ${cartRule1.getNameForLanguage('1')}');
  print('  Nom (EN): ${cartRule1.getNameForLanguage('2')}');
  print('  Code: ${cartRule1.code}');
  print('  Réduction: ${cartRule1.reductionPercent}%');
  print('  Actif: ${cartRule1.isActive}');

  // Test avec différents types de réductions
  final cartRule2 = CartRule(
    id: 2,
    dateFrom: now,
    dateTo: futureDate,
    name: {'1': 'Livraison gratuite'},
    active: true,
    freeShipping: true,
    minimumAmount: 50.0,
  );

  print('✓ Cart rule avec livraison gratuite créée');
  print('  Livraison gratuite: ${cartRule2.freeShipping}');
  print('  Montant minimum: ${cartRule2.minimumAmount}');
  print('  A un montant minimum: ${cartRule2.hasMinimumAmount}');

  // Test avec produit cadeau
  final cartRule3 = CartRule(
    id: 3,
    dateFrom: now,
    dateTo: futureDate,
    name: {'1': 'Produit cadeau'},
    active: true,
    giftProduct: 123,
    giftProductAttribute: 456,
  );

  print('✓ Cart rule avec produit cadeau créée');
  print('  Produit cadeau: ${cartRule3.giftProduct}');
  print('  A un produit cadeau: ${cartRule3.hasGiftProduct}');

  // Test JSON serialization
  final json = cartRule1.toJson();
  print('✓ Sérialisation JSON réussie');

  final ruleFromJson = CartRule.fromJson(json);
  print('✓ Désérialisation JSON réussie');
  print('  ID restauré: ${ruleFromJson.id}');
  print('  Code restauré: ${ruleFromJson.code}');

  // Test XML serialization
  final xml = cartRule1.toXml();
  print('✓ Sérialisation XML réussie (${xml.length} caractères)');

  // Test business logic
  print('✓ Tests logique métier:');
  print('  Est active: ${cartRule1.isActive}');
  print('  A un code: ${cartRule1.hasCode}');
  print('  A réduction pourcentage: ${cartRule1.hasPercentageDiscount}');
  print('  Jours restants: ${cartRule1.remainingTime.inDays}');

  // Test règle expirée
  final expiredRule = CartRule(
    id: 4,
    dateFrom: now.subtract(const Duration(days: 60)),
    dateTo: now.subtract(const Duration(days: 30)),
    name: {'1': 'Promotion expirée'},
    active: true,
  );

  print('✓ Test règle expirée:');
  print('  Est expirée: ${expiredRule.isExpired}');
  print('  Est active: ${expiredRule.isActive}');

  // Test règle future
  final futureRule = CartRule(
    id: 5,
    dateFrom: now.add(const Duration(days: 10)),
    dateTo: now.add(const Duration(days: 40)),
    name: {'1': 'Promotion future'},
    active: true,
  );

  print('✓ Test règle future:');
  print('  Pas encore valide: ${futureRule.isNotYetValid}');
  print('  Est active: ${futureRule.isActive}');
}

void testCartRow() {
  print('--- Test du modèle CartRow ---');

  final row1 = CartRow(idProduct: 1, quantity: 3);
  print('✓ CartRow basique créée');
  print('  Produit: ${row1.idProduct}');
  print('  Quantité: ${row1.quantity}');

  final row2 = CartRow(
    idProduct: 2,
    quantity: 1,
    idProductAttribute: 5,
    idCustomization: 10,
    idAddressDelivery: 15,
  );
  print('✓ CartRow complète créée');
  print('  Produit: ${row2.idProduct}');
  print('  Attribut: ${row2.idProductAttribute}');
  print('  Customisation: ${row2.idCustomization}');
  print('  Adresse livraison: ${row2.idAddressDelivery}');

  // Test JSON
  final json = row2.toJson();
  final rowFromJson = CartRow.fromJson(json);
  print('✓ Sérialisation/Désérialisation JSON réussie');
  print('  ID produit restauré: ${rowFromJson.idProduct}');
  print('  Quantité restaurée: ${rowFromJson.quantity}');
}

// Test avec données JSON complexes
void testComplexJsonData() {
  print('--- Test avec données JSON complexes ---');

  final complexCartJson = {
    'id': '123',
    'id_currency': '1',
    'id_lang': '2',
    'id_customer': '456',
    'recyclable': '1',
    'gift': '0',
    'mobile_theme': 'false',
    'allow_seperated_package': true,
    'date_add': '2024-01-15T10:30:00',
    'date_upd': '2024-01-16T14:20:00',
    'associations': {
      'cart_rows': [
        {'id_product': '1', 'id_product_attribute': '5', 'quantity': '2'},
        {'id_product': '2', 'quantity': '1'},
      ],
    },
  };

  final cart = Cart.fromJson(complexCartJson);
  print('✓ Cart complexe créé depuis JSON');
  print('  ID: ${cart.id}');
  print('  Date création: ${cart.dateAdd}');
  print('  Nombre de produits: ${cart.cartRows?.length}');

  final complexRuleJson = {
    'id': '789',
    'date_from': '2024-01-01T00:00:00',
    'date_to': '2024-12-31T23:59:59',
    'active': '1',
    'reduction_percent': '15.5',
    'minimum_amount': '100.0',
    'free_shipping': '1',
    'name': {
      'language': [
        {'id': '1', '#text': 'Super promo'},
        {'id': '2', '#text': 'Super deal'},
      ],
    },
  };

  final cartRule = CartRule.fromJson(complexRuleJson);
  print('✓ CartRule complexe créée depuis JSON');
  print('  ID: ${cartRule.id}');
  print('  Nom FR: ${cartRule.getNameForLanguage('1')}');
  print('  Nom EN: ${cartRule.getNameForLanguage('2')}');
  print('  Réduction: ${cartRule.reductionPercent}%');
}
