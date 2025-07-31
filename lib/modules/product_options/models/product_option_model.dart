// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'product_option_model.g.dart';

@JsonSerializable()
class ProductOptionModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// is_color_group (optionnel)
  @JsonKey(name: 'is_color_group')
  final int? is_color_group;

  /// group_type (optionnel)
  @JsonKey(name: 'group_type')
  final String? group_type;

  /// position (optionnel)
  @JsonKey(name: 'position')
  final int? position;

  const ProductOptionModel({
    required this.id,
    this.is_color_group,
    this.group_type,
    this.position,
  });

  factory ProductOptionModel.fromJson(Map<String, dynamic> json) =>
      _$ProductOptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductOptionModelToJson(this);

  @override
  String toString() => 'ProductOptionModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductOptionModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
