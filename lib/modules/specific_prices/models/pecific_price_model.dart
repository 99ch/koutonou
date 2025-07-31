// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'pecific_price_model.g.dart';

@JsonSerializable()
class SpecificPriceModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_product (optionnel)
  @JsonKey(name: 'id_product')
  final int? id_product;

  /// id_customer (optionnel)
  @JsonKey(name: 'id_customer')
  final int? id_customer;

  /// price (optionnel)
  @JsonKey(name: 'price')
  final String? price;

  /// reduction (optionnel)
  @JsonKey(name: 'reduction')
  final String? reduction;

  /// reduction_type (optionnel)
  @JsonKey(name: 'reduction_type')
  final String? reduction_type;

  /// from_quantity (optionnel)
  @JsonKey(name: 'from_quantity')
  final int? from_quantity;

  const SpecificPriceModel({
    required this.id,
    this.id_product,
    this.id_customer,
    this.price,
    this.reduction,
    this.reduction_type,
    this.from_quantity,
  });

  factory SpecificPriceModel.fromJson(Map<String, dynamic> json) =>
      _$SpecificPriceModelFromJson(json);

  Map<String, dynamic> toJson() => _$SpecificPriceModelToJson(this);

  @override
  String toString() => 'SpecificPriceModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpecificPriceModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
