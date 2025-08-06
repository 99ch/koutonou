/// Modèle Order pour PrestaShop API
/// Représente une commande avec tous ses attributs essentiels selon l'API PrestaShop
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
  final List<OrderRow> orderRows;

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
    this.orderRows = const [],
  });

  /// Crée un Order à partir de la réponse JSON de PrestaShop
  factory Order.fromPrestaShopJson(Map<String, dynamic> json) {
    // Extraction des lignes de commande
    List<OrderRow> orderRows = [];
    if (json['associations'] != null) {
      final associations = json['associations'] as Map<String, dynamic>;

      if (associations['order_rows'] is List) {
        final rows = associations['order_rows'] as List;
        orderRows = rows
            .map(
              (row) => OrderRow.fromPrestaShopJson(row as Map<String, dynamic>),
            )
            .toList();
      } else if (associations['order_rows']?['order_row'] is List) {
        final rows = associations['order_rows']['order_row'] as List;
        orderRows = rows
            .map(
              (row) => OrderRow.fromPrestaShopJson(row as Map<String, dynamic>),
            )
            .toList();
      }
    }

    return Order(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idAddressDelivery:
          int.tryParse(json['id_address_delivery']?.toString() ?? '0') ?? 0,
      idAddressInvoice:
          int.tryParse(json['id_address_invoice']?.toString() ?? '0') ?? 0,
      idCart: int.tryParse(json['id_cart']?.toString() ?? '0') ?? 0,
      idCurrency: int.tryParse(json['id_currency']?.toString() ?? '0') ?? 0,
      idLanguage: int.tryParse(json['id_lang']?.toString() ?? '0') ?? 0,
      idCustomer: int.tryParse(json['id_customer']?.toString() ?? '0') ?? 0,
      idCarrier: int.tryParse(json['id_carrier']?.toString() ?? '0') ?? 0,
      currentState: int.tryParse(json['current_state']?.toString() ?? '0'),
      module: json['module']?.toString() ?? '',
      invoiceNumber: json['invoice_number']?.toString(),
      invoiceDate: DateTime.tryParse(json['invoice_date']?.toString() ?? ''),
      deliveryNumber: json['delivery_number']?.toString(),
      deliveryDate: DateTime.tryParse(json['delivery_date']?.toString() ?? ''),
      valid: json['valid']?.toString() == '1',
      dateAdd: DateTime.tryParse(json['date_add']?.toString() ?? ''),
      dateUpd: DateTime.tryParse(json['date_upd']?.toString() ?? ''),
      shippingNumber: json['shipping_number']?.toString(),
      note: json['note']?.toString(),
      idShopGroup: int.tryParse(json['id_shop_group']?.toString() ?? '0'),
      idShop: int.tryParse(json['id_shop']?.toString() ?? '0'),
      secureKey: json['secure_key']?.toString(),
      payment: json['payment']?.toString() ?? '',
      recyclable: json['recyclable']?.toString() == '1',
      gift: json['gift']?.toString() == '1',
      giftMessage: json['gift_message']?.toString(),
      mobileTheme: json['mobile_theme']?.toString() == '1',
      totalDiscounts:
          double.tryParse(json['total_discounts']?.toString() ?? '0') ?? 0.0,
      totalDiscountsTaxIncl:
          double.tryParse(
            json['total_discounts_tax_incl']?.toString() ?? '0',
          ) ??
          0.0,
      totalDiscountsTaxExcl:
          double.tryParse(
            json['total_discounts_tax_excl']?.toString() ?? '0',
          ) ??
          0.0,
      totalPaid: double.tryParse(json['total_paid']?.toString() ?? '0') ?? 0.0,
      totalPaidTaxIncl:
          double.tryParse(json['total_paid_tax_incl']?.toString() ?? '0') ??
          0.0,
      totalPaidTaxExcl:
          double.tryParse(json['total_paid_tax_excl']?.toString() ?? '0') ??
          0.0,
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
      totalShippingTaxExcl:
          double.tryParse(json['total_shipping_tax_excl']?.toString() ?? '0') ??
          0.0,
      carrierTaxRate:
          double.tryParse(json['carrier_tax_rate']?.toString() ?? '0') ?? 0.0,
      totalWrapping:
          double.tryParse(json['total_wrapping']?.toString() ?? '0') ?? 0.0,
      totalWrappingTaxIncl:
          double.tryParse(json['total_wrapping_tax_incl']?.toString() ?? '0') ??
          0.0,
      totalWrappingTaxExcl:
          double.tryParse(json['total_wrapping_tax_excl']?.toString() ?? '0') ??
          0.0,
      roundMode: int.tryParse(json['round_mode']?.toString() ?? '0') ?? 0,
      roundType: int.tryParse(json['round_type']?.toString() ?? '0') ?? 0,
      conversionRate:
          double.tryParse(json['conversion_rate']?.toString() ?? '1') ?? 1.0,
      reference: json['reference']?.toString(),
      orderRows: orderRows,
    );
  }

  /// Convertit l'Order en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_address_delivery': idAddressDelivery.toString(),
      'id_address_invoice': idAddressInvoice.toString(),
      'id_cart': idCart.toString(),
      'id_currency': idCurrency.toString(),
      'id_lang': idLanguage.toString(),
      'id_customer': idCustomer.toString(),
      'id_carrier': idCarrier.toString(),
      'module': module,
      'payment': payment,
      'recyclable': recyclable ? '1' : '0',
      'gift': gift ? '1' : '0',
      'mobile_theme': mobileTheme ? '1' : '0',
      'total_discounts': totalDiscounts.toStringAsFixed(2),
      'total_discounts_tax_incl': totalDiscountsTaxIncl.toStringAsFixed(2),
      'total_discounts_tax_excl': totalDiscountsTaxExcl.toStringAsFixed(2),
      'total_paid': totalPaid.toStringAsFixed(2),
      'total_paid_tax_incl': totalPaidTaxIncl.toStringAsFixed(2),
      'total_paid_tax_excl': totalPaidTaxExcl.toStringAsFixed(2),
      'total_paid_real': totalPaidReal.toStringAsFixed(2),
      'total_products': totalProducts.toStringAsFixed(2),
      'total_products_wt': totalProductsWt.toStringAsFixed(2),
      'total_shipping': totalShipping.toStringAsFixed(2),
      'total_shipping_tax_incl': totalShippingTaxIncl.toStringAsFixed(2),
      'total_shipping_tax_excl': totalShippingTaxExcl.toStringAsFixed(2),
      'carrier_tax_rate': carrierTaxRate.toStringAsFixed(2),
      'total_wrapping': totalWrapping.toStringAsFixed(2),
      'total_wrapping_tax_incl': totalWrappingTaxIncl.toStringAsFixed(2),
      'total_wrapping_tax_excl': totalWrappingTaxExcl.toStringAsFixed(2),
      'round_mode': roundMode.toString(),
      'round_type': roundType.toString(),
      'conversion_rate': conversionRate.toStringAsFixed(6),
    };

    // Ajouter les champs optionnels
    if (currentState != null) json['current_state'] = currentState.toString();
    if (invoiceNumber != null) json['invoice_number'] = invoiceNumber;
    if (invoiceDate != null)
      json['invoice_date'] = invoiceDate!.toIso8601String();
    if (deliveryNumber != null) json['delivery_number'] = deliveryNumber;
    if (deliveryDate != null)
      json['delivery_date'] = deliveryDate!.toIso8601String();
    if (valid != null) json['valid'] = valid! ? '1' : '0';
    if (shippingNumber != null) json['shipping_number'] = shippingNumber;
    if (note != null) json['note'] = note;
    if (idShopGroup != null) json['id_shop_group'] = idShopGroup.toString();
    if (idShop != null) json['id_shop'] = idShop.toString();
    if (secureKey != null) json['secure_key'] = secureKey;
    if (giftMessage != null) json['gift_message'] = giftMessage;
    if (reference != null) json['reference'] = reference;

    // Associations des lignes de commande
    if (orderRows.isNotEmpty) {
      json['associations'] = {
        'order_rows': {
          'order_row': orderRows.map((row) => row.toPrestaShopJson()).toList(),
        },
      };
    }

    return json;
  }

  /// Obtient le statut de la commande sous forme de texte
  String get statusText {
    switch (currentState) {
      case 1:
        return 'En attente de paiement par chèque';
      case 2:
        return 'Paiement accepté';
      case 3:
        return 'Préparation en cours';
      case 4:
        return 'Expédiée';
      case 5:
        return 'Livrée';
      case 6:
        return 'Annulée';
      case 7:
        return 'Remboursée';
      case 8:
        return 'Erreur de paiement';
      case 9:
        return 'En attente de réapprovisionnement';
      case 10:
        return 'En attente de paiement par virement bancaire';
      case 11:
        return 'Paiement à distance accepté';
      case 12:
        return 'En attente de paiement PayPal';
      default:
        return 'Statut inconnu';
    }
  }

  /// Obtient la couleur associée au statut
  String get statusColor {
    switch (currentState) {
      case 1:
      case 10:
      case 12:
        return 'orange'; // En attente
      case 2:
      case 11:
        return 'green'; // Accepté
      case 3:
        return 'blue'; // En préparation
      case 4:
        return 'purple'; // Expédiée
      case 5:
        return 'green'; // Livrée
      case 6:
        return 'red'; // Annulée
      case 7:
        return 'grey'; // Remboursée
      case 8:
        return 'red'; // Erreur
      case 9:
        return 'orange'; // En attente de stock
      default:
        return 'grey';
    }
  }

  @override
  String toString() =>
      'Order(id: $id, reference: $reference, totalPaid: $totalPaid)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Modèle pour les lignes de commande (produits dans la commande)
class OrderRow {
  final int? id;
  final int productId;
  final int productAttributeId;
  final int productQuantity;
  final String productName;
  final String? productReference;
  final String? productEan13;
  final String? productIsbn;
  final String? productUpc;
  final double productPrice;
  final int? idCustomization;
  final double unitPriceTaxIncl;
  final double unitPriceTaxExcl;

  const OrderRow({
    this.id,
    required this.productId,
    this.productAttributeId = 0,
    required this.productQuantity,
    required this.productName,
    this.productReference,
    this.productEan13,
    this.productIsbn,
    this.productUpc,
    required this.productPrice,
    this.idCustomization,
    required this.unitPriceTaxIncl,
    required this.unitPriceTaxExcl,
  });

  factory OrderRow.fromPrestaShopJson(Map<String, dynamic> json) {
    return OrderRow(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      productId: int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      productAttributeId:
          int.tryParse(json['product_attribute_id']?.toString() ?? '0') ?? 0,
      productQuantity:
          int.tryParse(json['product_quantity']?.toString() ?? '0') ?? 0,
      productName: json['product_name']?.toString() ?? '',
      productReference: json['product_reference']?.toString(),
      productEan13: json['product_ean13']?.toString(),
      productIsbn: json['product_isbn']?.toString(),
      productUpc: json['product_upc']?.toString(),
      productPrice:
          double.tryParse(json['product_price']?.toString() ?? '0') ?? 0.0,
      idCustomization: int.tryParse(
        json['id_customization']?.toString() ?? '0',
      ),
      unitPriceTaxIncl:
          double.tryParse(json['unit_price_tax_incl']?.toString() ?? '0') ??
          0.0,
      unitPriceTaxExcl:
          double.tryParse(json['unit_price_tax_excl']?.toString() ?? '0') ??
          0.0,
    );
  }

  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'product_id': productId.toString(),
      'product_attribute_id': productAttributeId.toString(),
      'product_quantity': productQuantity.toString(),
      'product_name': productName,
      'product_price': productPrice.toStringAsFixed(2),
      'unit_price_tax_incl': unitPriceTaxIncl.toStringAsFixed(2),
      'unit_price_tax_excl': unitPriceTaxExcl.toStringAsFixed(2),
    };

    if (id != null) json['id'] = id.toString();
    if (productReference != null) json['product_reference'] = productReference;
    if (productEan13 != null) json['product_ean13'] = productEan13;
    if (productIsbn != null) json['product_isbn'] = productIsbn;
    if (productUpc != null) json['product_upc'] = productUpc;
    if (idCustomization != null)
      json['id_customization'] = idCustomization.toString();

    return json;
  }

  /// Calcule le total de cette ligne (quantité × prix unitaire TTC)
  double get totalTaxIncl => productQuantity * unitPriceTaxIncl;

  /// Calcule le total de cette ligne (quantité × prix unitaire HT)
  double get totalTaxExcl => productQuantity * unitPriceTaxExcl;

  @override
  String toString() =>
      'OrderRow(productName: $productName, quantity: $productQuantity, price: $productPrice)';
}
