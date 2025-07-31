// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'hop_group_model.g.dart';

@JsonSerializable()
class ShopGroupModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// name (optionnel)
  @JsonKey(name: 'name')
  final String? name;

  /// share_customer (optionnel)
  @JsonKey(name: 'share_customer')
  final int? share_customer;

  /// share_order (optionnel)
  @JsonKey(name: 'share_order')
  final int? share_order;

  /// active (optionnel)
  @JsonKey(name: 'active')
  final int? active;

  /// deleted (optionnel)
  @JsonKey(name: 'deleted')
  final int? deleted;

  const ShopGroupModel({
    required this.id,
    this.name,
    this.share_customer,
    this.share_order,
    this.active,
    this.deleted,
  });

  factory ShopGroupModel.fromJson(Map<String, dynamic> json) =>
      _$ShopGroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShopGroupModelToJson(this);

  @override
  String toString() => 'ShopGroupModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopGroupModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
