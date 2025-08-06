/// Modèle OrderDetail pour PrestaShop API
/// Représente le détail d'une ligne de commande avec tous ses attributs
class OrderDetail {
  final int? id;
  final int idOrder;
  final int? productId;
  final int? productAttributeId;
  final int? productQuantityReinjected;
  final double? groupReduction;
  final int? discountQuantityApplied;
  final String? downloadHash;
  final DateTime? downloadDeadline;
  final int? idOrderInvoice;
  final int idWarehouse;
  final int idShop;
  final int? idCustomization;
  final String productName;
  final int productQuantity;
  final int? productQuantityInStock;
  final int? productQuantityReturn;
  final int? productQuantityRefunded;
  final double productPrice;
  final double? reductionPercent;
  final double? reductionAmount;
  final double? reductionAmountTaxIncl;
  final double? reductionAmountTaxExcl;
  final double? productQuantityDiscount;
  final String? productEan13;
  final String? productIsbn;
  final String? productUpc;
  final String? productMpn;
  final String? productReference;
  final String? productSupplierReference;
  final double? productWeight;
  final int? taxComputationMethod;
  final int? idTaxRulesGroup;
  final double? ecotax;
  final double? ecotaxTaxRate;
  final int? downloadNb;
  final double? unitPriceTaxIncl;
  final double? unitPriceTaxExcl;
  final double? totalPriceTaxIncl;
  final double? totalPriceTaxExcl;
  final double? totalShippingPriceTaxExcl;
  final double? totalShippingPriceTaxIncl;
  final double? purchaseSupplierPrice;
  final double? originalProductPrice;
  final double? originalWholesalePrice;
  final double? totalRefundedTaxExcl;
  final double? totalRefundedTaxIncl;
  final List<int> taxIds;

  const OrderDetail({
    this.id,
    required this.idOrder,
    this.productId,
    this.productAttributeId,
    this.productQuantityReinjected,
    this.groupReduction,
    this.discountQuantityApplied,
    this.downloadHash,
    this.downloadDeadline,
    this.idOrderInvoice,
    required this.idWarehouse,
    required this.idShop,
    this.idCustomization,
    required this.productName,
    required this.productQuantity,
    this.productQuantityInStock,
    this.productQuantityReturn,
    this.productQuantityRefunded,
    required this.productPrice,
    this.reductionPercent,
    this.reductionAmount,
    this.reductionAmountTaxIncl,
    this.reductionAmountTaxExcl,
    this.productQuantityDiscount,
    this.productEan13,
    this.productIsbn,
    this.productUpc,
    this.productMpn,
    this.productReference,
    this.productSupplierReference,
    this.productWeight,
    this.taxComputationMethod,
    this.idTaxRulesGroup,
    this.ecotax,
    this.ecotaxTaxRate,
    this.downloadNb,
    this.unitPriceTaxIncl,
    this.unitPriceTaxExcl,
    this.totalPriceTaxIncl,
    this.totalPriceTaxExcl,
    this.totalShippingPriceTaxExcl,
    this.totalShippingPriceTaxIncl,
    this.purchaseSupplierPrice,
    this.originalProductPrice,
    this.originalWholesalePrice,
    this.totalRefundedTaxExcl,
    this.totalRefundedTaxIncl,
    this.taxIds = const [],
  });

  /// Crée un OrderDetail à partir de la réponse JSON de PrestaShop
  factory OrderDetail.fromPrestaShopJson(Map<String, dynamic> json) {
    // Extraction des taxes associées
    List<int> taxIds = [];
    if (json['associations'] != null) {
      final associations = json['associations'] as Map<String, dynamic>;
      if (associations['taxes'] is List) {
        final taxesList = associations['taxes'] as List;
        taxIds = taxesList
            .map((tax) {
              if (tax is Map<String, dynamic>) {
                return int.tryParse(tax['id']?.toString() ?? '0') ?? 0;
              }
              return 0;
            })
            .where((id) => id > 0)
            .toList();
      } else if (associations['taxes']?['tax'] is List) {
        final taxesList = associations['taxes']['tax'] as List;
        taxIds = taxesList
            .map((tax) => int.tryParse(tax['id']?.toString() ?? '0') ?? 0)
            .where((id) => id > 0)
            .toList();
      }
    }

    return OrderDetail(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idOrder: int.tryParse(json['id_order']?.toString() ?? '0') ?? 0,
      productId: int.tryParse(json['product_id']?.toString() ?? '0'),
      productAttributeId: int.tryParse(
        json['product_attribute_id']?.toString() ?? '0',
      ),
      productQuantityReinjected: int.tryParse(
        json['product_quantity_reinjected']?.toString() ?? '0',
      ),
      groupReduction: double.tryParse(
        json['group_reduction']?.toString() ?? '0',
      ),
      discountQuantityApplied: int.tryParse(
        json['discount_quantity_applied']?.toString() ?? '0',
      ),
      downloadHash: json['download_hash']?.toString(),
      downloadDeadline: DateTime.tryParse(
        json['download_deadline']?.toString() ?? '',
      ),
      idOrderInvoice: int.tryParse(json['id_order_invoice']?.toString() ?? '0'),
      idWarehouse: int.tryParse(json['id_warehouse']?.toString() ?? '0') ?? 0,
      idShop: int.tryParse(json['id_shop']?.toString() ?? '0') ?? 0,
      idCustomization: int.tryParse(
        json['id_customization']?.toString() ?? '0',
      ),
      productName: json['product_name']?.toString() ?? '',
      productQuantity:
          int.tryParse(json['product_quantity']?.toString() ?? '0') ?? 0,
      productQuantityInStock: int.tryParse(
        json['product_quantity_in_stock']?.toString() ?? '0',
      ),
      productQuantityReturn: int.tryParse(
        json['product_quantity_return']?.toString() ?? '0',
      ),
      productQuantityRefunded: int.tryParse(
        json['product_quantity_refunded']?.toString() ?? '0',
      ),
      productPrice:
          double.tryParse(json['product_price']?.toString() ?? '0') ?? 0.0,
      reductionPercent: double.tryParse(
        json['reduction_percent']?.toString() ?? '0',
      ),
      reductionAmount: double.tryParse(
        json['reduction_amount']?.toString() ?? '0',
      ),
      reductionAmountTaxIncl: double.tryParse(
        json['reduction_amount_tax_incl']?.toString() ?? '0',
      ),
      reductionAmountTaxExcl: double.tryParse(
        json['reduction_amount_tax_excl']?.toString() ?? '0',
      ),
      productQuantityDiscount: double.tryParse(
        json['product_quantity_discount']?.toString() ?? '0',
      ),
      productEan13: json['product_ean13']?.toString(),
      productIsbn: json['product_isbn']?.toString(),
      productUpc: json['product_upc']?.toString(),
      productMpn: json['product_mpn']?.toString(),
      productReference: json['product_reference']?.toString(),
      productSupplierReference: json['product_supplier_reference']?.toString(),
      productWeight: double.tryParse(json['product_weight']?.toString() ?? '0'),
      taxComputationMethod: int.tryParse(
        json['tax_computation_method']?.toString() ?? '0',
      ),
      idTaxRulesGroup: int.tryParse(
        json['id_tax_rules_group']?.toString() ?? '0',
      ),
      ecotax: double.tryParse(json['ecotax']?.toString() ?? '0'),
      ecotaxTaxRate: double.tryParse(
        json['ecotax_tax_rate']?.toString() ?? '0',
      ),
      downloadNb: int.tryParse(json['download_nb']?.toString() ?? '0'),
      unitPriceTaxIncl: double.tryParse(
        json['unit_price_tax_incl']?.toString() ?? '0',
      ),
      unitPriceTaxExcl: double.tryParse(
        json['unit_price_tax_excl']?.toString() ?? '0',
      ),
      totalPriceTaxIncl: double.tryParse(
        json['total_price_tax_incl']?.toString() ?? '0',
      ),
      totalPriceTaxExcl: double.tryParse(
        json['total_price_tax_excl']?.toString() ?? '0',
      ),
      totalShippingPriceTaxExcl: double.tryParse(
        json['total_shipping_price_tax_excl']?.toString() ?? '0',
      ),
      totalShippingPriceTaxIncl: double.tryParse(
        json['total_shipping_price_tax_incl']?.toString() ?? '0',
      ),
      purchaseSupplierPrice: double.tryParse(
        json['purchase_supplier_price']?.toString() ?? '0',
      ),
      originalProductPrice: double.tryParse(
        json['original_product_price']?.toString() ?? '0',
      ),
      originalWholesalePrice: double.tryParse(
        json['original_wholesale_price']?.toString() ?? '0',
      ),
      totalRefundedTaxExcl: double.tryParse(
        json['total_refunded_tax_excl']?.toString() ?? '0',
      ),
      totalRefundedTaxIncl: double.tryParse(
        json['total_refunded_tax_incl']?.toString() ?? '0',
      ),
      taxIds: taxIds,
    );
  }

  /// Convertit l'OrderDetail en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_order': idOrder.toString(),
      'id_warehouse': idWarehouse.toString(),
      'id_shop': idShop.toString(),
      'product_name': productName,
      'product_quantity': productQuantity.toString(),
      'product_price': productPrice.toString(),
    };

    // Ajouter les champs optionnels
    if (productId != null) json['product_id'] = productId.toString();
    if (productAttributeId != null)
      json['product_attribute_id'] = productAttributeId.toString();
    if (productQuantityReinjected != null)
      json['product_quantity_reinjected'] = productQuantityReinjected
          .toString();
    if (groupReduction != null)
      json['group_reduction'] = groupReduction.toString();
    if (discountQuantityApplied != null)
      json['discount_quantity_applied'] = discountQuantityApplied.toString();
    if (downloadHash != null) json['download_hash'] = downloadHash;
    if (downloadDeadline != null)
      json['download_deadline'] = downloadDeadline!.toIso8601String();
    if (idOrderInvoice != null)
      json['id_order_invoice'] = idOrderInvoice.toString();
    if (idCustomization != null)
      json['id_customization'] = idCustomization.toString();

    // Associations des taxes
    if (taxIds.isNotEmpty) {
      json['associations'] = {
        'taxes': {
          'tax': taxIds.map((id) => {'id': id.toString()}).toList(),
        },
      };
    }

    return json;
  }

  @override
  String toString() =>
      'OrderDetail(id: $id, productName: $productName, quantity: $productQuantity, price: $productPrice)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderDetail && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
