// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'tate_model.g.dart';

@JsonSerializable()
class StateModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_country (optionnel)
  @JsonKey(name: 'id_country')
  final int? id_country;

  /// id_zone (optionnel)
  @JsonKey(name: 'id_zone')
  final int? id_zone;

  /// name (optionnel)
  @JsonKey(name: 'name')
  final String? name;

  /// iso_code (optionnel)
  @JsonKey(name: 'iso_code')
  final String? iso_code;

  /// active (optionnel)
  @JsonKey(name: 'active')
  final int? active;

  const StateModel({
    required this.id,
    this.id_country,
    this.id_zone,
    this.name,
    this.iso_code,
    this.active,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) =>
      _$StateModelFromJson(json);

  Map<String, dynamic> toJson() => _$StateModelToJson(this);

  @override
  String toString() => 'StateModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StateModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
