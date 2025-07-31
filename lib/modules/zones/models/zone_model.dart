// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'zone_model.g.dart';

@JsonSerializable()
class ZoneModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// name (optionnel)
  @JsonKey(name: 'name')
  final String? name;

  /// active (optionnel)
  @JsonKey(name: 'active')
  final int? active;

  const ZoneModel({
    required this.id,
    this.name,
    this.active,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) =>
      _$ZoneModelFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneModelToJson(this);

  @override
  String toString() => 'ZoneModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZoneModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
