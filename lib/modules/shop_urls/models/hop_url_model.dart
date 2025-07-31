// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'hop_url_model.g.dart';

@JsonSerializable()
class ShopUrlModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_shop (optionnel)
  @JsonKey(name: 'id_shop')
  final int? id_shop;

  /// domain (optionnel)
  @JsonKey(name: 'domain')
  final String? domain;

  /// domain_ssl (optionnel)
  @JsonKey(name: 'domain_ssl')
  final String? domain_ssl;

  /// main (optionnel)
  @JsonKey(name: 'main')
  final int? main;

  /// active (optionnel)
  @JsonKey(name: 'active')
  final int? active;

  const ShopUrlModel({
    required this.id,
    this.id_shop,
    this.domain,
    this.domain_ssl,
    this.main,
    this.active,
  });

  factory ShopUrlModel.fromJson(Map<String, dynamic> json) =>
      _$ShopUrlModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShopUrlModelToJson(this);

  @override
  String toString() => 'ShopUrlModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopUrlModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
