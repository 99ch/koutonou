// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'configuration_model.g.dart';

@JsonSerializable()
class ConfigurationModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_shop_group (optionnel)
  @JsonKey(name: 'id_shop_group')
  final int? id_shop_group;

  /// id_shop (optionnel)
  @JsonKey(name: 'id_shop')
  final int? id_shop;

  /// name (optionnel)
  @JsonKey(name: 'name')
  final String? name;

  /// value (optionnel)
  @JsonKey(name: 'value')
  final String? value;

  /// date_add (optionnel)
  @JsonKey(name: 'date_add')
  final String? date_add;

  /// date_upd (optionnel)
  @JsonKey(name: 'date_upd')
  final String? date_upd;

  const ConfigurationModel({
    required this.id,
    this.id_shop_group,
    this.id_shop,
    this.name,
    this.value,
    this.date_add,
    this.date_upd,
  });

  factory ConfigurationModel.fromJson(Map<String, dynamic> json) =>
      _$ConfigurationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigurationModelToJson(this);

  @override
  String toString() => 'ConfigurationModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigurationModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
