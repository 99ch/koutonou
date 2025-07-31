// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'order_detail_model.g.dart';

@JsonSerializable()
class OrderDetailModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_order (optionnel)
  @JsonKey(name: 'id_order')
  final int? id_order;

  /// product_id (optionnel)
  @JsonKey(name: 'product_id')
  final int? product_id;

  /// product_name (optionnel)
  @JsonKey(name: 'product_name')
  final String? product_name;

  /// product_quantity (optionnel)
  @JsonKey(name: 'product_quantity')
  final int? product_quantity;

  /// product_price (optionnel)
  @JsonKey(name: 'product_price')
  final String? product_price;

  /// total_price_tax_incl (optionnel)
  @JsonKey(name: 'total_price_tax_incl')
  final String? total_price_tax_incl;

  /// total_price_tax_excl (optionnel)
  @JsonKey(name: 'total_price_tax_excl')
  final String? total_price_tax_excl;

  const OrderDetailModel({
    required this.id,
    this.id_order,
    this.product_id,
    this.product_name,
    this.product_quantity,
    this.product_price,
    this.total_price_tax_incl,
    this.total_price_tax_excl,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDetailModelToJson(this);

  @override
  String toString() => 'OrderDetailModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderDetailModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
