// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'product_feature_model.g.dart';

@JsonSerializable()
class ProductFeatureModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// position (optionnel)
  @JsonKey(name: 'position')
  final int? position;

  const ProductFeatureModel({
    required this.id,
    this.position,
  });

  factory ProductFeatureModel.fromJson(Map<String, dynamic> json) =>
      _$ProductFeatureModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductFeatureModelToJson(this);

  @override
  String toString() => 'ProductFeatureModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductFeatureModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
