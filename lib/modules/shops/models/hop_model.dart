// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'hop_model.g.dart';

@JsonSerializable()
class ShopModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_shop_group (optionnel)
  @JsonKey(name: 'id_shop_group')
  final int? id_shop_group;

  /// name (optionnel)
  @JsonKey(name: 'name')
  final String? name;

  /// id_category (optionnel)
  @JsonKey(name: 'id_category')
  final int? id_category;

  /// active (optionnel)
  @JsonKey(name: 'active')
  final int? active;

  /// deleted (optionnel)
  @JsonKey(name: 'deleted')
  final int? deleted;

  const ShopModel({
    required this.id,
    this.id_shop_group,
    this.name,
    this.id_category,
    this.active,
    this.deleted,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) =>
      _$ShopModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShopModelToJson(this);

  @override
  String toString() => 'ShopModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
