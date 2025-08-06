/// Modèle OrderCartRule pour PrestaShop API
/// Représente une règle de panier appliquée à une commande
class OrderCartRule {
  final int? id;
  final int idOrder;
  final int idCartRule;
  final int? idOrderInvoice;
  final String name;
  final double value;
  final double valueTaxExcl;
  final bool? freeShipping;
  final bool deleted;

  const OrderCartRule({
    this.id,
    required this.idOrder,
    required this.idCartRule,
    this.idOrderInvoice,
    required this.name,
    required this.value,
    required this.valueTaxExcl,
    this.freeShipping,
    this.deleted = false,
  });

  factory OrderCartRule.fromPrestaShopJson(Map<String, dynamic> json) {
    return OrderCartRule(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idOrder: int.tryParse(json['id_order']?.toString() ?? '0') ?? 0,
      idCartRule: int.tryParse(json['id_cart_rule']?.toString() ?? '0') ?? 0,
      idOrderInvoice: int.tryParse(json['id_order_invoice']?.toString() ?? '0'),
      name: json['name']?.toString() ?? '',
      value: double.tryParse(json['value']?.toString() ?? '0') ?? 0.0,
      valueTaxExcl:
          double.tryParse(json['value_tax_excl']?.toString() ?? '0') ?? 0.0,
      freeShipping: json['free_shipping']?.toString() == '1',
      deleted: json['deleted']?.toString() == '1',
    );
  }

  /// Alias pour fromPrestaShopJson pour compatibilité avec les services
  factory OrderCartRule.fromJson(Map<String, dynamic> json) =>
      OrderCartRule.fromPrestaShopJson(json);

  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_order': idOrder.toString(),
      'id_cart_rule': idCartRule.toString(),
      'name': name,
      'value': value.toString(),
      'value_tax_excl': valueTaxExcl.toString(),
      'deleted': deleted ? '1' : '0',
    };

    if (idOrderInvoice != null)
      json['id_order_invoice'] = idOrderInvoice.toString();
    if (freeShipping != null) json['free_shipping'] = freeShipping! ? '1' : '0';

    return json;
  }

  /// Alias pour toPrestaShopJson pour compatibilité avec les services
  Map<String, dynamic> toJson() => toPrestaShopJson();

  /// Copie cette OrderCartRule avec des modifications
  OrderCartRule copyWith({
    int? id,
    int? idOrder,
    int? idCartRule,
    int? idOrderInvoice,
    String? name,
    double? value,
    double? valueTaxExcl,
    bool? freeShipping,
    bool? deleted,
  }) {
    return OrderCartRule(
      id: id ?? this.id,
      idOrder: idOrder ?? this.idOrder,
      idCartRule: idCartRule ?? this.idCartRule,
      idOrderInvoice: idOrderInvoice ?? this.idOrderInvoice,
      name: name ?? this.name,
      value: value ?? this.value,
      valueTaxExcl: valueTaxExcl ?? this.valueTaxExcl,
      freeShipping: freeShipping ?? this.freeShipping,
      deleted: deleted ?? this.deleted,
    );
  }
}

/// Modèle OrderCarrier pour PrestaShop API
/// Représente un transporteur assigné à une commande
class OrderCarrier {
  final int? id;
  final int idOrder;
  final int idCarrier;
  final int? idOrderInvoice;
  final double? weight;
  final double? shippingCostTaxExcl;
  final double? shippingCostTaxIncl;
  final String? trackingNumber;
  final DateTime? dateAdd;

  const OrderCarrier({
    this.id,
    required this.idOrder,
    required this.idCarrier,
    this.idOrderInvoice,
    this.weight,
    this.shippingCostTaxExcl,
    this.shippingCostTaxIncl,
    this.trackingNumber,
    this.dateAdd,
  });

  factory OrderCarrier.fromPrestaShopJson(Map<String, dynamic> json) {
    return OrderCarrier(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idOrder: int.tryParse(json['id_order']?.toString() ?? '0') ?? 0,
      idCarrier: int.tryParse(json['id_carrier']?.toString() ?? '0') ?? 0,
      idOrderInvoice: int.tryParse(json['id_order_invoice']?.toString() ?? '0'),
      weight: double.tryParse(json['weight']?.toString() ?? '0'),
      shippingCostTaxExcl: double.tryParse(
        json['shipping_cost_tax_excl']?.toString() ?? '0',
      ),
      shippingCostTaxIncl: double.tryParse(
        json['shipping_cost_tax_incl']?.toString() ?? '0',
      ),
      trackingNumber: json['tracking_number']?.toString(),
      dateAdd: DateTime.tryParse(json['date_add']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_order': idOrder.toString(),
      'id_carrier': idCarrier.toString(),
    };

    if (idOrderInvoice != null)
      json['id_order_invoice'] = idOrderInvoice.toString();
    if (weight != null) json['weight'] = weight.toString();
    if (shippingCostTaxExcl != null)
      json['shipping_cost_tax_excl'] = shippingCostTaxExcl.toString();
    if (shippingCostTaxIncl != null)
      json['shipping_cost_tax_incl'] = shippingCostTaxIncl.toString();
    if (trackingNumber != null) json['tracking_number'] = trackingNumber;

    return json;
  }
}
