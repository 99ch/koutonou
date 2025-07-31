// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'product_upplier_model.g.dart';

@JsonSerializable()
class ProductSupplierModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_product (optionnel)
  @JsonKey(name: 'id_product')
  final int? id_product;

  /// id_supplier (optionnel)
  @JsonKey(name: 'id_supplier')
  final int? id_supplier;

  /// product_supplier_reference (optionnel)
  @JsonKey(name: 'product_supplier_reference')
  final String? product_supplier_reference;

  /// product_supplier_price_te (optionnel)
  @JsonKey(name: 'product_supplier_price_te')
  final String? product_supplier_price_te;

  const ProductSupplierModel({
    required this.id,
    this.id_product,
    this.id_supplier,
    this.product_supplier_reference,
    this.product_supplier_price_te,
  });

  factory ProductSupplierModel.fromJson(Map<String, dynamic> json) =>
      _$ProductSupplierModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductSupplierModelToJson(this);

  @override
  String toString() => 'ProductSupplierModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductSupplierModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
