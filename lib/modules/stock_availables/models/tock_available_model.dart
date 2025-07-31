// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'tock_available_model.g.dart';

@JsonSerializable()
class StockAvailableModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_product (optionnel)
  @JsonKey(name: 'id_product')
  final int? id_product;

  /// id_product_attribute (optionnel)
  @JsonKey(name: 'id_product_attribute')
  final int? id_product_attribute;

  /// id_shop (optionnel)
  @JsonKey(name: 'id_shop')
  final int? id_shop;

  /// quantity (optionnel)
  @JsonKey(name: 'quantity')
  final int? quantity;

  /// depends_on_stock (optionnel)
  @JsonKey(name: 'depends_on_stock')
  final int? depends_on_stock;

  /// out_of_stock (optionnel)
  @JsonKey(name: 'out_of_stock')
  final int? out_of_stock;

  const StockAvailableModel({
    required this.id,
    this.id_product,
    this.id_product_attribute,
    this.id_shop,
    this.quantity,
    this.depends_on_stock,
    this.out_of_stock,
  });

  factory StockAvailableModel.fromJson(Map<String, dynamic> json) =>
      _$StockAvailableModelFromJson(json);

  Map<String, dynamic> toJson() => _$StockAvailableModelToJson(this);

  @override
  String toString() => 'StockAvailableModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockAvailableModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
