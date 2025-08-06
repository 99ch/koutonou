import '../../../core/models/base_model.dart';

/// Represents a cart rule (promotion) in PrestaShop
class CartRule extends BaseModel {
  final int? idCustomer;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String? description;
  final int? quantity;
  final int? quantityPerUser;
  final int? priority;
  final bool partialUse;
  final String? code;
  final double? minimumAmount;
  final bool minimumAmountTax;
  final int? minimumAmountCurrency;
  final bool minimumAmountShipping;
  final bool countryRestriction;
  final bool carrierRestriction;
  final bool groupRestriction;
  final bool cartRuleRestriction;
  final bool productRestriction;
  final bool shopRestriction;
  final bool freeShipping;
  final double? reductionPercent;
  final double? reductionAmount;
  final bool reductionTax;
  final int? reductionCurrency;
  final int? reductionProduct;
  final bool reductionExcludeSpecial;
  final int? giftProduct;
  final int? giftProductAttribute;
  final bool highlight;
  final bool active;
  final DateTime? dateAdd;
  final DateTime? dateUpd;
  final Map<String, String> name;

  CartRule({
    super.id,
    this.idCustomer,
    required this.dateFrom,
    required this.dateTo,
    this.description,
    this.quantity,
    this.quantityPerUser,
    this.priority,
    this.partialUse = false,
    this.code,
    this.minimumAmount,
    this.minimumAmountTax = false,
    this.minimumAmountCurrency,
    this.minimumAmountShipping = false,
    this.countryRestriction = false,
    this.carrierRestriction = false,
    this.groupRestriction = false,
    this.cartRuleRestriction = false,
    this.productRestriction = false,
    this.shopRestriction = false,
    this.freeShipping = false,
    this.reductionPercent,
    this.reductionAmount,
    this.reductionTax = false,
    this.reductionCurrency,
    this.reductionProduct,
    this.reductionExcludeSpecial = false,
    this.giftProduct,
    this.giftProductAttribute,
    this.highlight = false,
    this.active = true,
    this.dateAdd,
    this.dateUpd,
    this.name = const {},
  });

  @override
  CartRule copyWith({
    int? id,
    int? idCustomer,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? description,
    int? quantity,
    int? quantityPerUser,
    int? priority,
    bool? partialUse,
    String? code,
    double? minimumAmount,
    bool? minimumAmountTax,
    int? minimumAmountCurrency,
    bool? minimumAmountShipping,
    bool? countryRestriction,
    bool? carrierRestriction,
    bool? groupRestriction,
    bool? cartRuleRestriction,
    bool? productRestriction,
    bool? shopRestriction,
    bool? freeShipping,
    double? reductionPercent,
    double? reductionAmount,
    bool? reductionTax,
    int? reductionCurrency,
    int? reductionProduct,
    bool? reductionExcludeSpecial,
    int? giftProduct,
    int? giftProductAttribute,
    bool? highlight,
    bool? active,
    DateTime? dateAdd,
    DateTime? dateUpd,
    Map<String, String>? name,
  }) {
    return CartRule(
      id: id ?? this.id,
      idCustomer: idCustomer ?? this.idCustomer,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      quantityPerUser: quantityPerUser ?? this.quantityPerUser,
      priority: priority ?? this.priority,
      partialUse: partialUse ?? this.partialUse,
      code: code ?? this.code,
      minimumAmount: minimumAmount ?? this.minimumAmount,
      minimumAmountTax: minimumAmountTax ?? this.minimumAmountTax,
      minimumAmountCurrency:
          minimumAmountCurrency ?? this.minimumAmountCurrency,
      minimumAmountShipping:
          minimumAmountShipping ?? this.minimumAmountShipping,
      countryRestriction: countryRestriction ?? this.countryRestriction,
      carrierRestriction: carrierRestriction ?? this.carrierRestriction,
      groupRestriction: groupRestriction ?? this.groupRestriction,
      cartRuleRestriction: cartRuleRestriction ?? this.cartRuleRestriction,
      productRestriction: productRestriction ?? this.productRestriction,
      shopRestriction: shopRestriction ?? this.shopRestriction,
      freeShipping: freeShipping ?? this.freeShipping,
      reductionPercent: reductionPercent ?? this.reductionPercent,
      reductionAmount: reductionAmount ?? this.reductionAmount,
      reductionTax: reductionTax ?? this.reductionTax,
      reductionCurrency: reductionCurrency ?? this.reductionCurrency,
      reductionProduct: reductionProduct ?? this.reductionProduct,
      reductionExcludeSpecial:
          reductionExcludeSpecial ?? this.reductionExcludeSpecial,
      giftProduct: giftProduct ?? this.giftProduct,
      giftProductAttribute: giftProductAttribute ?? this.giftProductAttribute,
      highlight: highlight ?? this.highlight,
      active: active ?? this.active,
      dateAdd: dateAdd ?? this.dateAdd,
      dateUpd: dateUpd ?? this.dateUpd,
      name: name ?? this.name,
    );
  }

  factory CartRule.fromJson(Map<String, dynamic> json) {
    Map<String, String> nameMap = {};
    if (json['name'] != null) {
      if (json['name'] is Map) {
        final nameData = json['name'] as Map;
        if (nameData.containsKey('language')) {
          // Handle multiple languages
          if (nameData['language'] is List) {
            for (var lang in nameData['language']) {
              if (lang['id'] != null && lang['#text'] != null) {
                nameMap[lang['id'].toString()] = lang['#text'].toString();
              }
            }
          } else if (nameData['language'] is Map) {
            final lang = nameData['language'];
            if (lang['id'] != null && lang['#text'] != null) {
              nameMap[lang['id'].toString()] = lang['#text'].toString();
            }
          }
        } else {
          // Direct language mapping
          nameData.forEach((key, value) {
            nameMap[key.toString()] = value.toString();
          });
        }
      } else {
        nameMap['1'] = json['name'].toString();
      }
    }

    return CartRule(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      idCustomer: json['id_customer'] != null
          ? int.tryParse(json['id_customer'].toString())
          : null,
      dateFrom:
          DateTime.tryParse(json['date_from'].toString()) ?? DateTime.now(),
      dateTo:
          DateTime.tryParse(json['date_to'].toString()) ??
          DateTime.now().add(Duration(days: 30)),
      description: json['description']?.toString(),
      quantity: json['quantity'] != null
          ? int.tryParse(json['quantity'].toString())
          : null,
      quantityPerUser: json['quantity_per_user'] != null
          ? int.tryParse(json['quantity_per_user'].toString())
          : null,
      priority: json['priority'] != null
          ? int.tryParse(json['priority'].toString())
          : null,
      partialUse: _parseBool(json['partial_use']),
      code: json['code']?.toString(),
      minimumAmount: json['minimum_amount'] != null
          ? double.tryParse(json['minimum_amount'].toString())
          : null,
      minimumAmountTax: _parseBool(json['minimum_amount_tax']),
      minimumAmountCurrency: json['minimum_amount_currency'] != null
          ? int.tryParse(json['minimum_amount_currency'].toString())
          : null,
      minimumAmountShipping: _parseBool(json['minimum_amount_shipping']),
      countryRestriction: _parseBool(json['country_restriction']),
      carrierRestriction: _parseBool(json['carrier_restriction']),
      groupRestriction: _parseBool(json['group_restriction']),
      cartRuleRestriction: _parseBool(json['cart_rule_restriction']),
      productRestriction: _parseBool(json['product_restriction']),
      shopRestriction: _parseBool(json['shop_restriction']),
      freeShipping: _parseBool(json['free_shipping']),
      reductionPercent: json['reduction_percent'] != null
          ? double.tryParse(json['reduction_percent'].toString())
          : null,
      reductionAmount: json['reduction_amount'] != null
          ? double.tryParse(json['reduction_amount'].toString())
          : null,
      reductionTax: _parseBool(json['reduction_tax']),
      reductionCurrency: json['reduction_currency'] != null
          ? int.tryParse(json['reduction_currency'].toString())
          : null,
      reductionProduct: json['reduction_product'] != null
          ? int.tryParse(json['reduction_product'].toString())
          : null,
      reductionExcludeSpecial: _parseBool(json['reduction_exclude_special']),
      giftProduct: json['gift_product'] != null
          ? int.tryParse(json['gift_product'].toString())
          : null,
      giftProductAttribute: json['gift_product_attribute'] != null
          ? int.tryParse(json['gift_product_attribute'].toString())
          : null,
      highlight: _parseBool(json['highlight']),
      active: _parseBool(json['active']),
      dateAdd: json['date_add'] != null
          ? DateTime.tryParse(json['date_add'].toString())
          : null,
      dateUpd: json['date_upd'] != null
          ? DateTime.tryParse(json['date_upd'].toString())
          : null,
      name: nameMap,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (idCustomer != null) 'id_customer': idCustomer,
      'date_from': dateFrom.toIso8601String(),
      'date_to': dateTo.toIso8601String(),
      if (description != null) 'description': description,
      if (quantity != null) 'quantity': quantity,
      if (quantityPerUser != null) 'quantity_per_user': quantityPerUser,
      if (priority != null) 'priority': priority,
      'partial_use': partialUse ? 1 : 0,
      if (code != null) 'code': code,
      if (minimumAmount != null) 'minimum_amount': minimumAmount,
      'minimum_amount_tax': minimumAmountTax ? 1 : 0,
      if (minimumAmountCurrency != null)
        'minimum_amount_currency': minimumAmountCurrency,
      'minimum_amount_shipping': minimumAmountShipping ? 1 : 0,
      'country_restriction': countryRestriction ? 1 : 0,
      'carrier_restriction': carrierRestriction ? 1 : 0,
      'group_restriction': groupRestriction ? 1 : 0,
      'cart_rule_restriction': cartRuleRestriction ? 1 : 0,
      'product_restriction': productRestriction ? 1 : 0,
      'shop_restriction': shopRestriction ? 1 : 0,
      'free_shipping': freeShipping ? 1 : 0,
      if (reductionPercent != null) 'reduction_percent': reductionPercent,
      if (reductionAmount != null) 'reduction_amount': reductionAmount,
      'reduction_tax': reductionTax ? 1 : 0,
      if (reductionCurrency != null) 'reduction_currency': reductionCurrency,
      if (reductionProduct != null) 'reduction_product': reductionProduct,
      'reduction_exclude_special': reductionExcludeSpecial ? 1 : 0,
      if (giftProduct != null) 'gift_product': giftProduct,
      if (giftProductAttribute != null)
        'gift_product_attribute': giftProductAttribute,
      'highlight': highlight ? 1 : 0,
      'active': active ? 1 : 0,
      if (dateAdd != null) 'date_add': dateAdd!.toIso8601String(),
      if (dateUpd != null) 'date_upd': dateUpd!.toIso8601String(),
      'name': name,
    };
  }

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">');
    buffer.writeln('  <cart_rule>');

    if (id != null) buffer.writeln('    <id><![CDATA[$id]]></id>');
    if (idCustomer != null)
      buffer.writeln('    <id_customer><![CDATA[$idCustomer]]></id_customer>');
    buffer.writeln(
      '    <date_from><![CDATA[${dateFrom.toIso8601String()}]]></date_from>',
    );
    buffer.writeln(
      '    <date_to><![CDATA[${dateTo.toIso8601String()}]]></date_to>',
    );
    if (description != null)
      buffer.writeln('    <description><![CDATA[$description]]></description>');
    if (quantity != null)
      buffer.writeln('    <quantity><![CDATA[$quantity]]></quantity>');
    if (quantityPerUser != null)
      buffer.writeln(
        '    <quantity_per_user><![CDATA[$quantityPerUser]]></quantity_per_user>',
      );
    if (priority != null)
      buffer.writeln('    <priority><![CDATA[$priority]]></priority>');
    buffer.writeln(
      '    <partial_use><![CDATA[${partialUse ? 1 : 0}]]></partial_use>',
    );
    if (code != null) buffer.writeln('    <code><![CDATA[$code]]></code>');
    if (minimumAmount != null)
      buffer.writeln(
        '    <minimum_amount><![CDATA[$minimumAmount]]></minimum_amount>',
      );
    buffer.writeln(
      '    <minimum_amount_tax><![CDATA[${minimumAmountTax ? 1 : 0}]]></minimum_amount_tax>',
    );
    if (minimumAmountCurrency != null)
      buffer.writeln(
        '    <minimum_amount_currency><![CDATA[$minimumAmountCurrency]]></minimum_amount_currency>',
      );
    buffer.writeln(
      '    <minimum_amount_shipping><![CDATA[${minimumAmountShipping ? 1 : 0}]]></minimum_amount_shipping>',
    );
    buffer.writeln(
      '    <country_restriction><![CDATA[${countryRestriction ? 1 : 0}]]></country_restriction>',
    );
    buffer.writeln(
      '    <carrier_restriction><![CDATA[${carrierRestriction ? 1 : 0}]]></carrier_restriction>',
    );
    buffer.writeln(
      '    <group_restriction><![CDATA[${groupRestriction ? 1 : 0}]]></group_restriction>',
    );
    buffer.writeln(
      '    <cart_rule_restriction><![CDATA[${cartRuleRestriction ? 1 : 0}]]></cart_rule_restriction>',
    );
    buffer.writeln(
      '    <product_restriction><![CDATA[${productRestriction ? 1 : 0}]]></product_restriction>',
    );
    buffer.writeln(
      '    <shop_restriction><![CDATA[${shopRestriction ? 1 : 0}]]></shop_restriction>',
    );
    buffer.writeln(
      '    <free_shipping><![CDATA[${freeShipping ? 1 : 0}]]></free_shipping>',
    );
    if (reductionPercent != null)
      buffer.writeln(
        '    <reduction_percent><![CDATA[$reductionPercent]]></reduction_percent>',
      );
    if (reductionAmount != null)
      buffer.writeln(
        '    <reduction_amount><![CDATA[$reductionAmount]]></reduction_amount>',
      );
    buffer.writeln(
      '    <reduction_tax><![CDATA[${reductionTax ? 1 : 0}]]></reduction_tax>',
    );
    if (reductionCurrency != null)
      buffer.writeln(
        '    <reduction_currency><![CDATA[$reductionCurrency]]></reduction_currency>',
      );
    if (reductionProduct != null)
      buffer.writeln(
        '    <reduction_product><![CDATA[$reductionProduct]]></reduction_product>',
      );
    buffer.writeln(
      '    <reduction_exclude_special><![CDATA[${reductionExcludeSpecial ? 1 : 0}]]></reduction_exclude_special>',
    );
    if (giftProduct != null)
      buffer.writeln(
        '    <gift_product><![CDATA[$giftProduct]]></gift_product>',
      );
    if (giftProductAttribute != null)
      buffer.writeln(
        '    <gift_product_attribute><![CDATA[$giftProductAttribute]]></gift_product_attribute>',
      );
    buffer.writeln(
      '    <highlight><![CDATA[${highlight ? 1 : 0}]]></highlight>',
    );
    buffer.writeln('    <active><![CDATA[${active ? 1 : 0}]]></active>');
    if (dateAdd != null)
      buffer.writeln(
        '    <date_add><![CDATA[${dateAdd!.toIso8601String()}]]></date_add>',
      );
    if (dateUpd != null)
      buffer.writeln(
        '    <date_upd><![CDATA[${dateUpd!.toIso8601String()}]]></date_upd>',
      );

    buffer.writeln('    <name>');
    for (var entry in name.entries) {
      buffer.writeln(
        '      <language id="${entry.key}"><![CDATA[${entry.value}]]></language>',
      );
    }
    buffer.writeln('    </name>');

    buffer.writeln('  </cart_rule>');
    buffer.writeln('</prestashop>');
    return buffer.toString();
  }

  // Business logic methods
  bool get isActive =>
      active &&
      DateTime.now().isBefore(dateTo) &&
      DateTime.now().isAfter(dateFrom);

  bool get isExpired => DateTime.now().isAfter(dateTo);

  bool get isNotYetValid => DateTime.now().isBefore(dateFrom);

  bool get hasPercentageDiscount =>
      reductionPercent != null && reductionPercent! > 0;

  bool get hasAmountDiscount => reductionAmount != null && reductionAmount! > 0;

  bool get hasGiftProduct => giftProduct != null && giftProduct! > 0;

  bool get hasMinimumAmount => minimumAmount != null && minimumAmount! > 0;

  bool get hasCode => code != null && code!.isNotEmpty;

  String getNameForLanguage(String langId) {
    return name[langId] ?? name['1'] ?? '';
  }

  Duration get remainingTime {
    if (isExpired) return Duration.zero;
    return dateTo.difference(DateTime.now());
  }

  List<Object?> get props => [
    id,
    idCustomer,
    dateFrom,
    dateTo,
    description,
    quantity,
    quantityPerUser,
    priority,
    partialUse,
    code,
    minimumAmount,
    minimumAmountTax,
    minimumAmountCurrency,
    minimumAmountShipping,
    countryRestriction,
    carrierRestriction,
    groupRestriction,
    cartRuleRestriction,
    productRestriction,
    shopRestriction,
    freeShipping,
    reductionPercent,
    reductionAmount,
    reductionTax,
    reductionCurrency,
    reductionProduct,
    reductionExcludeSpecial,
    giftProduct,
    giftProductAttribute,
    highlight,
    active,
    dateAdd,
    dateUpd,
    name,
  ];

  @override
  String toString() {
    return 'CartRule{id: $id, name: ${getNameForLanguage('1')}, active: $active, isActive: $isActive}';
  }
}
