// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'product_feature_value_model.g.dart';

@JsonSerializable()
class ProductFeatureValueModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_feature (optionnel)
  @JsonKey(name: 'id_feature')
  final int? id_feature;

  /// custom (optionnel)
  @JsonKey(name: 'custom')
  final int? custom;

  const ProductFeatureValueModel({
    required this.id,
    this.id_feature,
    this.custom,
  });

  factory ProductFeatureValueModel.fromJson(Map<String, dynamic> json) =>
      _$ProductFeatureValueModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductFeatureValueModelToJson(this);

  @override
  String toString() => 'ProductFeatureValueModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductFeatureValueModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
