// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'product_option_value_model.g.dart';

@JsonSerializable()
class ProductOptionValueModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_attribute_group (optionnel)
  @JsonKey(name: 'id_attribute_group')
  final int? id_attribute_group;

  /// color (optionnel)
  @JsonKey(name: 'color')
  final String? color;

  /// position (optionnel)
  @JsonKey(name: 'position')
  final int? position;

  const ProductOptionValueModel({
    required this.id,
    this.id_attribute_group,
    this.color,
    this.position,
  });

  factory ProductOptionValueModel.fromJson(Map<String, dynamic> json) =>
      _$ProductOptionValueModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductOptionValueModelToJson(this);

  @override
  String toString() => 'ProductOptionValueModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductOptionValueModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
