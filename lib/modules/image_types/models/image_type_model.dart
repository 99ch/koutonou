// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'image_type_model.g.dart';

@JsonSerializable()
class ImageTypeModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// name (optionnel)
  @JsonKey(name: 'name')
  final String? name;

  /// width (optionnel)
  @JsonKey(name: 'width')
  final int? width;

  /// height (optionnel)
  @JsonKey(name: 'height')
  final int? height;

  /// products (optionnel)
  @JsonKey(name: 'products')
  final int? products;

  /// categories (optionnel)
  @JsonKey(name: 'categories')
  final int? categories;

  /// manufacturers (optionnel)
  @JsonKey(name: 'manufacturers')
  final int? manufacturers;

  /// suppliers (optionnel)
  @JsonKey(name: 'suppliers')
  final int? suppliers;

  const ImageTypeModel({
    required this.id,
    this.name,
    this.width,
    this.height,
    this.products,
    this.categories,
    this.manufacturers,
    this.suppliers,
  });

  factory ImageTypeModel.fromJson(Map<String, dynamic> json) =>
      _$ImageTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageTypeModelToJson(this);

  @override
  String toString() => 'ImageTypeModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageTypeModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
