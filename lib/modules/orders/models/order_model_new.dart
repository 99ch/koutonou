/// Modèle Order pour PrestaShop API
class Order {
  final int? id;
  final int idAddressDelivery;
  final int idAddressInvoice;
  final int idCart;
  final int idCurrency;
  final int idLanguage;
  final int idCustomer;
  final int idCarrier;
  final int? currentState;
  final String module;
  final String? invoiceNumber;
  final DateTime? invoiceDate;
  final String? deliveryNumber;
  final DateTime? deliveryDate;
  final bool? valid;
  final DateTime? dateAdd;
  final DateTime? dateUpd;
  final String? shippingNumber;
  final String? note;
  final int? idShopGroup;
  final int? idShop;
  final String? secureKey;
  final String payment;
  final bool recyclable;
  final bool gift;
  final String? giftMessage;
  final bool mobileTheme;
  final double totalDiscounts;
  final double totalDiscountsTaxIncl;
  final double totalDiscountsTaxExcl;
  final double totalPaid;
  final double totalPaidTaxIncl;
  final double totalPaidTaxExcl;
  final double totalPaidReal;
  final double totalProducts;
  final double totalProductsWt;
  final double totalShipping;
  final double totalShippingTaxIncl;
  final double totalShippingTaxExcl;
  final double carrierTaxRate;
  final double totalWrapping;
  final double totalWrappingTaxIncl;
  final double totalWrappingTaxExcl;
  final int roundMode;
  final int roundType;
  final double conversionRate;
  final String? reference;

  // Propriétés additionnelles pour l'interface
  final int? customerId;
  final int? addressDeliveryId;
  final int? addressInvoiceId;
  final int? carrierId;
  final String? currency;
  final String? paymentMethod;

  const Order({
    this.id,
    required this.idAddressDelivery,
    required this.idAddressInvoice,
    required this.idCart,
    required this.idCurrency,
    required this.idLanguage,
    required this.idCustomer,
    required this.idCarrier,
    this.currentState,
    required this.module,
    this.invoiceNumber,
    this.invoiceDate,
    this.deliveryNumber,
    this.deliveryDate,
    this.valid,
    this.dateAdd,
    this.dateUpd,
    this.shippingNumber,
    this.note,
    this.idShopGroup,
    this.idShop,
    this.secureKey,
    required this.payment,
    this.recyclable = false,
    this.gift = false,
    this.giftMessage,
    this.mobileTheme = false,
    this.totalDiscounts = 0.0,
    this.totalDiscountsTaxIncl = 0.0,
    this.totalDiscountsTaxExcl = 0.0,
    required this.totalPaid,
    this.totalPaidTaxIncl = 0.0,
    this.totalPaidTaxExcl = 0.0,
    required this.totalPaidReal,
    required this.totalProducts,
    required this.totalProductsWt,
    this.totalShipping = 0.0,
    this.totalShippingTaxIncl = 0.0,
    this.totalShippingTaxExcl = 0.0,
    this.carrierTaxRate = 0.0,
    this.totalWrapping = 0.0,
    this.totalWrappingTaxIncl = 0.0,
    this.totalWrappingTaxExcl = 0.0,
    this.roundMode = 0,
    this.roundType = 0,
    required this.conversionRate,
    this.reference,
    // Propriétés additionnelles
    this.customerId,
    this.addressDeliveryId,
    this.addressInvoiceId,
    this.carrierId,
    this.currency,
    this.paymentMethod,
  });

  /// Crée un Order à partir de la réponse JSON de PrestaShop
  factory Order.fromPrestaShopJson(Map<String, dynamic> json) {
    return Order(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      reference: json['reference']?.toString(),
      idCustomer: int.tryParse(json['id_customer']?.toString() ?? '0') ?? 0,
      idAddressDelivery:
          int.tryParse(json['id_address_delivery']?.toString() ?? '0') ?? 0,
      idAddressInvoice:
          int.tryParse(json['id_address_invoice']?.toString() ?? '0') ?? 0,
      idCarrier: int.tryParse(json['id_carrier']?.toString() ?? '0') ?? 0,
      idCart: int.tryParse(json['id_cart']?.toString() ?? '0') ?? 0,
      idCurrency: int.tryParse(json['id_currency']?.toString() ?? '1') ?? 1,
      idLanguage: int.tryParse(json['id_language']?.toString() ?? '1') ?? 1,
      currentState: int.tryParse(json['current_state']?.toString() ?? '0'),
      module: json['module']?.toString() ?? '',
      payment: json['payment']?.toString() ?? '',
      totalPaid: double.tryParse(json['total_paid']?.toString() ?? '0') ?? 0.0,
      totalPaidReal:
          double.tryParse(json['total_paid_real']?.toString() ?? '0') ?? 0.0,
      totalProducts:
          double.tryParse(json['total_products']?.toString() ?? '0') ?? 0.0,
      totalProductsWt:
          double.tryParse(json['total_products_wt']?.toString() ?? '0') ?? 0.0,
      totalShipping:
          double.tryParse(json['total_shipping']?.toString() ?? '0') ?? 0.0,
      totalShippingTaxIncl:
          double.tryParse(json['total_shipping_tax_incl']?.toString() ?? '0') ??
          0.0,
      totalDiscounts:
          double.tryParse(json['total_discounts']?.toString() ?? '0') ?? 0.0,
      totalDiscountsTaxIncl:
          double.tryParse(
            json['total_discounts_tax_incl']?.toString() ?? '0',
          ) ??
          0.0,
      conversionRate:
          double.tryParse(json['conversion_rate']?.toString() ?? '1') ?? 1.0,
      dateAdd: DateTime.tryParse(json['date_add']?.toString() ?? ''),
      dateUpd: DateTime.tryParse(json['date_upd']?.toString() ?? ''),
      valid: json['valid']?.toString() == '1',
      // Propriétés additionnelles pour compatibilité
      customerId: int.tryParse(json['id_customer']?.toString() ?? '0'),
      addressDeliveryId: int.tryParse(
        json['id_address_delivery']?.toString() ?? '0',
      ),
      addressInvoiceId: int.tryParse(
        json['id_address_invoice']?.toString() ?? '0',
      ),
      carrierId: int.tryParse(json['id_carrier']?.toString() ?? '0'),
      currency: json['id_currency']?.toString(),
      paymentMethod: json['payment']?.toString(),
    );
  }

  /// Convertit l'Order en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    return {
      if (id != null) 'id': id.toString(),
      'reference': reference,
      'id_customer': idCustomer.toString(),
      'id_address_delivery': idAddressDelivery.toString(),
      'id_address_invoice': idAddressInvoice.toString(),
      'id_carrier': idCarrier.toString(),
      'id_cart': idCart.toString(),
      'id_currency': idCurrency.toString(),
      'id_language': idLanguage.toString(),
      if (currentState != null) 'current_state': currentState.toString(),
      'module': module,
      'payment': payment,
      'total_paid': totalPaid.toString(),
      'total_paid_real': totalPaidReal.toString(),
      'total_products': totalProducts.toString(),
      'total_products_wt': totalProductsWt.toString(),
      'total_shipping': totalShipping.toString(),
      'total_shipping_tax_incl': totalShippingTaxIncl.toString(),
      'total_discounts': totalDiscounts.toString(),
      'total_discounts_tax_incl': totalDiscountsTaxIncl.toString(),
      'conversion_rate': conversionRate.toString(),
      if (valid != null) 'valid': valid! ? '1' : '0',
    };
  }

  /// Copie cette Order avec des modifications
  Order copyWith({
    int? id,
    String? reference,
    int? customerId,
    int? addressDeliveryId,
    int? addressInvoiceId,
    int? carrierId,
    int? currentState,
    double? totalPaid,
    double? totalProducts,
    double? totalProductsWt,
    double? totalShipping,
    double? totalShippingTaxIncl,
    double? totalDiscounts,
    double? totalDiscountsTaxIncl,
    double? totalPaidReal,
    String? currency,
    String? paymentMethod,
    DateTime? dateAdd,
    DateTime? dateUpd,
    bool? valid,
  }) {
    return Order(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      idCustomer: customerId ?? this.idCustomer,
      idAddressDelivery: addressDeliveryId ?? this.idAddressDelivery,
      idAddressInvoice: addressInvoiceId ?? this.idAddressInvoice,
      idCarrier: carrierId ?? this.idCarrier,
      idCart: this.idCart,
      idCurrency: this.idCurrency,
      idLanguage: this.idLanguage,
      currentState: currentState ?? this.currentState,
      module: this.module,
      payment: paymentMethod ?? this.payment,
      totalPaid: totalPaid ?? this.totalPaid,
      totalPaidReal: totalPaidReal ?? this.totalPaidReal,
      totalProducts: totalProducts ?? this.totalProducts,
      totalProductsWt: totalProductsWt ?? this.totalProductsWt,
      totalShipping: totalShipping ?? this.totalShipping,
      totalShippingTaxIncl: totalShippingTaxIncl ?? this.totalShippingTaxIncl,
      totalDiscounts: totalDiscounts ?? this.totalDiscounts,
      totalDiscountsTaxIncl:
          totalDiscountsTaxIncl ?? this.totalDiscountsTaxIncl,
      conversionRate: this.conversionRate,
      dateAdd: dateAdd ?? this.dateAdd,
      dateUpd: dateUpd ?? this.dateUpd,
      valid: valid ?? this.valid,
      // Propriétés additionnelles
      customerId: customerId ?? this.customerId,
      addressDeliveryId: addressDeliveryId ?? this.addressDeliveryId,
      addressInvoiceId: addressInvoiceId ?? this.addressInvoiceId,
      carrierId: carrierId ?? this.carrierId,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  String toString() =>
      'Order(id: $id, reference: $reference, total: $totalPaid)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
