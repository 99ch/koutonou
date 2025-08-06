/// Modèle OrderInvoice pour PrestaShop API
/// Représente une facture de commande avec tous ses attributs
class OrderInvoice {
  final int? id;
  final int idOrder;
  final int number;
  final int? deliveryNumber;
  final DateTime? deliveryDate;
  final double? totalDiscountTaxExcl;
  final double? totalDiscountTaxIncl;
  final double? totalPaidTaxExcl;
  final double? totalPaidTaxIncl;
  final double? totalProducts;
  final double? totalProductsWt;
  final double? totalShippingTaxExcl;
  final double? totalShippingTaxIncl;
  final int? shippingTaxComputationMethod;
  final double? totalWrappingTaxExcl;
  final double? totalWrappingTaxIncl;
  final String? shopAddress;
  final String? note;
  final DateTime? dateAdd;

  const OrderInvoice({
    this.id,
    required this.idOrder,
    required this.number,
    this.deliveryNumber,
    this.deliveryDate,
    this.totalDiscountTaxExcl,
    this.totalDiscountTaxIncl,
    this.totalPaidTaxExcl,
    this.totalPaidTaxIncl,
    this.totalProducts,
    this.totalProductsWt,
    this.totalShippingTaxExcl,
    this.totalShippingTaxIncl,
    this.shippingTaxComputationMethod,
    this.totalWrappingTaxExcl,
    this.totalWrappingTaxIncl,
    this.shopAddress,
    this.note,
    this.dateAdd,
  });

  /// Crée un OrderInvoice à partir de la réponse JSON de PrestaShop
  factory OrderInvoice.fromPrestaShopJson(Map<String, dynamic> json) {
    return OrderInvoice(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idOrder: int.tryParse(json['id_order']?.toString() ?? '0') ?? 0,
      number: int.tryParse(json['number']?.toString() ?? '0') ?? 0,
      deliveryNumber: int.tryParse(json['delivery_number']?.toString() ?? '0'),
      deliveryDate: DateTime.tryParse(json['delivery_date']?.toString() ?? ''),
      totalDiscountTaxExcl: double.tryParse(
        json['total_discount_tax_excl']?.toString() ?? '0',
      ),
      totalDiscountTaxIncl: double.tryParse(
        json['total_discount_tax_incl']?.toString() ?? '0',
      ),
      totalPaidTaxExcl: double.tryParse(
        json['total_paid_tax_excl']?.toString() ?? '0',
      ),
      totalPaidTaxIncl: double.tryParse(
        json['total_paid_tax_incl']?.toString() ?? '0',
      ),
      totalProducts: double.tryParse(json['total_products']?.toString() ?? '0'),
      totalProductsWt: double.tryParse(
        json['total_products_wt']?.toString() ?? '0',
      ),
      totalShippingTaxExcl: double.tryParse(
        json['total_shipping_tax_excl']?.toString() ?? '0',
      ),
      totalShippingTaxIncl: double.tryParse(
        json['total_shipping_tax_incl']?.toString() ?? '0',
      ),
      shippingTaxComputationMethod: int.tryParse(
        json['shipping_tax_computation_method']?.toString() ?? '0',
      ),
      totalWrappingTaxExcl: double.tryParse(
        json['total_wrapping_tax_excl']?.toString() ?? '0',
      ),
      totalWrappingTaxIncl: double.tryParse(
        json['total_wrapping_tax_incl']?.toString() ?? '0',
      ),
      shopAddress: json['shop_address']?.toString(),
      note: json['note']?.toString(),
      dateAdd: DateTime.tryParse(json['date_add']?.toString() ?? ''),
    );
  }

  /// Convertit l'OrderInvoice en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_order': idOrder.toString(),
      'number': number.toString(),
    };

    if (deliveryNumber != null)
      json['delivery_number'] = deliveryNumber.toString();
    if (deliveryDate != null)
      json['delivery_date'] = deliveryDate!.toIso8601String();
    if (totalDiscountTaxExcl != null)
      json['total_discount_tax_excl'] = totalDiscountTaxExcl.toString();
    if (totalDiscountTaxIncl != null)
      json['total_discount_tax_incl'] = totalDiscountTaxIncl.toString();
    if (totalPaidTaxExcl != null)
      json['total_paid_tax_excl'] = totalPaidTaxExcl.toString();
    if (totalPaidTaxIncl != null)
      json['total_paid_tax_incl'] = totalPaidTaxIncl.toString();
    if (totalProducts != null)
      json['total_products'] = totalProducts.toString();
    if (totalProductsWt != null)
      json['total_products_wt'] = totalProductsWt.toString();
    if (totalShippingTaxExcl != null)
      json['total_shipping_tax_excl'] = totalShippingTaxExcl.toString();
    if (totalShippingTaxIncl != null)
      json['total_shipping_tax_incl'] = totalShippingTaxIncl.toString();
    if (shippingTaxComputationMethod != null)
      json['shipping_tax_computation_method'] = shippingTaxComputationMethod
          .toString();
    if (totalWrappingTaxExcl != null)
      json['total_wrapping_tax_excl'] = totalWrappingTaxExcl.toString();
    if (totalWrappingTaxIncl != null)
      json['total_wrapping_tax_incl'] = totalWrappingTaxIncl.toString();
    if (shopAddress != null) json['shop_address'] = shopAddress;
    if (note != null) json['note'] = note;

    return json;
  }

  /// Copie cet OrderInvoice avec des modifications
  OrderInvoice copyWith({
    int? id,
    int? idOrder,
    int? number,
    int? deliveryNumber,
    DateTime? deliveryDate,
    double? totalDiscountTaxExcl,
    double? totalDiscountTaxIncl,
    double? totalPaidTaxExcl,
    double? totalPaidTaxIncl,
    double? totalProducts,
    double? totalProductsWt,
    double? totalShippingTaxExcl,
    double? totalShippingTaxIncl,
    int? shippingTaxComputationMethod,
    double? totalWrappingTaxExcl,
    double? totalWrappingTaxIncl,
    String? shopAddress,
    String? note,
    DateTime? dateAdd,
  }) {
    return OrderInvoice(
      id: id ?? this.id,
      idOrder: idOrder ?? this.idOrder,
      number: number ?? this.number,
      deliveryNumber: deliveryNumber ?? this.deliveryNumber,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      totalDiscountTaxExcl: totalDiscountTaxExcl ?? this.totalDiscountTaxExcl,
      totalDiscountTaxIncl: totalDiscountTaxIncl ?? this.totalDiscountTaxIncl,
      totalPaidTaxExcl: totalPaidTaxExcl ?? this.totalPaidTaxExcl,
      totalPaidTaxIncl: totalPaidTaxIncl ?? this.totalPaidTaxIncl,
      totalProducts: totalProducts ?? this.totalProducts,
      totalProductsWt: totalProductsWt ?? this.totalProductsWt,
      totalShippingTaxExcl: totalShippingTaxExcl ?? this.totalShippingTaxExcl,
      totalShippingTaxIncl: totalShippingTaxIncl ?? this.totalShippingTaxIncl,
      shippingTaxComputationMethod:
          shippingTaxComputationMethod ?? this.shippingTaxComputationMethod,
      totalWrappingTaxExcl: totalWrappingTaxExcl ?? this.totalWrappingTaxExcl,
      totalWrappingTaxIncl: totalWrappingTaxIncl ?? this.totalWrappingTaxIncl,
      shopAddress: shopAddress ?? this.shopAddress,
      note: note ?? this.note,
      dateAdd: dateAdd ?? this.dateAdd,
    );
  }

  @override
  String toString() =>
      'OrderInvoice(id: $id, number: $number, idOrder: $idOrder)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderInvoice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
