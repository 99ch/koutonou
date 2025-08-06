/// Modèle OrderSlip pour PrestaShop API
/// Représente un avoir/remboursement avec tous ses attributs
class OrderSlip {
  final int? id;
  final int idCustomer;
  final int idOrder;
  final double conversionRate;
  final double totalProductsTaxExcl;
  final double totalProductsTaxIncl;
  final double totalShippingTaxExcl;
  final double totalShippingTaxIncl;
  final double? amount;
  final bool? shippingCost;
  final double? shippingCostAmount;
  final bool? partial;
  final DateTime? dateAdd;
  final DateTime? dateUpd;
  final int? orderSlipType;
  final List<OrderSlipDetail> details;

  const OrderSlip({
    this.id,
    required this.idCustomer,
    required this.idOrder,
    required this.conversionRate,
    required this.totalProductsTaxExcl,
    required this.totalProductsTaxIncl,
    required this.totalShippingTaxExcl,
    required this.totalShippingTaxIncl,
    this.amount,
    this.shippingCost,
    this.shippingCostAmount,
    this.partial,
    this.dateAdd,
    this.dateUpd,
    this.orderSlipType,
    this.details = const [],
  });

  /// Crée un OrderSlip à partir de la réponse JSON de PrestaShop
  factory OrderSlip.fromPrestaShopJson(Map<String, dynamic> json) {
    // Extraction des détails de l'avoir
    List<OrderSlipDetail> details = [];
    if (json['associations'] != null) {
      final associations = json['associations'] as Map<String, dynamic>;
      if (associations['order_slip_details'] is List) {
        final detailsList = associations['order_slip_details'] as List;
        details = detailsList
            .map(
              (detail) => OrderSlipDetail.fromPrestaShopJson(
                detail as Map<String, dynamic>,
              ),
            )
            .toList();
      } else if (associations['order_slip_details']?['order_slip_detail']
          is List) {
        final detailsList =
            associations['order_slip_details']['order_slip_detail'] as List;
        details = detailsList
            .map(
              (detail) => OrderSlipDetail.fromPrestaShopJson(
                detail as Map<String, dynamic>,
              ),
            )
            .toList();
      }
    }

    return OrderSlip(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idCustomer: int.tryParse(json['id_customer']?.toString() ?? '0') ?? 0,
      idOrder: int.tryParse(json['id_order']?.toString() ?? '0') ?? 0,
      conversionRate:
          double.tryParse(json['conversion_rate']?.toString() ?? '0') ?? 0.0,
      totalProductsTaxExcl:
          double.tryParse(json['total_products_tax_excl']?.toString() ?? '0') ??
          0.0,
      totalProductsTaxIncl:
          double.tryParse(json['total_products_tax_incl']?.toString() ?? '0') ??
          0.0,
      totalShippingTaxExcl:
          double.tryParse(json['total_shipping_tax_excl']?.toString() ?? '0') ??
          0.0,
      totalShippingTaxIncl:
          double.tryParse(json['total_shipping_tax_incl']?.toString() ?? '0') ??
          0.0,
      amount: double.tryParse(json['amount']?.toString() ?? '0'),
      shippingCost: json['shipping_cost']?.toString() == '1',
      shippingCostAmount: double.tryParse(
        json['shipping_cost_amount']?.toString() ?? '0',
      ),
      partial: json['partial']?.toString() == '1',
      dateAdd: DateTime.tryParse(json['date_add']?.toString() ?? ''),
      dateUpd: DateTime.tryParse(json['date_upd']?.toString() ?? ''),
      orderSlipType: int.tryParse(json['order_slip_type']?.toString() ?? '0'),
      details: details,
    );
  }

  /// Convertit l'OrderSlip en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_customer': idCustomer.toString(),
      'id_order': idOrder.toString(),
      'conversion_rate': conversionRate.toString(),
      'total_products_tax_excl': totalProductsTaxExcl.toString(),
      'total_products_tax_incl': totalProductsTaxIncl.toString(),
      'total_shipping_tax_excl': totalShippingTaxExcl.toString(),
      'total_shipping_tax_incl': totalShippingTaxIncl.toString(),
    };

    if (amount != null) json['amount'] = amount.toString();
    if (shippingCost != null) json['shipping_cost'] = shippingCost! ? '1' : '0';
    if (shippingCostAmount != null)
      json['shipping_cost_amount'] = shippingCostAmount.toString();
    if (partial != null) json['partial'] = partial! ? '1' : '0';
    if (orderSlipType != null)
      json['order_slip_type'] = orderSlipType.toString();

    // Associations des détails
    if (details.isNotEmpty) {
      json['associations'] = {
        'order_slip_details': {
          'order_slip_detail': details
              .map((detail) => detail.toPrestaShopJson())
              .toList(),
        },
      };
    }

    return json;
  }

  @override
  String toString() => 'OrderSlip(id: $id, idOrder: $idOrder, amount: $amount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderSlip && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Modèle pour les détails d'un avoir
class OrderSlipDetail {
  final int? id;
  final int idOrderDetail;
  final int productQuantity;
  final double amountTaxExcl;
  final double amountTaxIncl;

  const OrderSlipDetail({
    this.id,
    required this.idOrderDetail,
    required this.productQuantity,
    required this.amountTaxExcl,
    required this.amountTaxIncl,
  });

  factory OrderSlipDetail.fromPrestaShopJson(Map<String, dynamic> json) {
    return OrderSlipDetail(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idOrderDetail:
          int.tryParse(json['id_order_detail']?.toString() ?? '0') ?? 0,
      productQuantity:
          int.tryParse(json['product_quantity']?.toString() ?? '0') ?? 0,
      amountTaxExcl:
          double.tryParse(json['amount_tax_excl']?.toString() ?? '0') ?? 0.0,
      amountTaxIncl:
          double.tryParse(json['amount_tax_incl']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toPrestaShopJson() {
    return {
      'id_order_detail': idOrderDetail.toString(),
      'product_quantity': productQuantity.toString(),
      'amount_tax_excl': amountTaxExcl.toString(),
      'amount_tax_incl': amountTaxIncl.toString(),
    };
  }
}
