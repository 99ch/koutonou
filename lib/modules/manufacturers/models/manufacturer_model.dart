// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'manufacturer_model.g.dart';

@JsonSerializable()
class ManufacturerModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// name (optionnel)
  @JsonKey(name: 'name')
  final String? name;

  /// active (optionnel)
  @JsonKey(name: 'active')
  final int? active;

  /// date_add (optionnel)
  @JsonKey(name: 'date_add')
  final String? date_add;

  /// date_upd (optionnel)
  @JsonKey(name: 'date_upd')
  final String? date_upd;

  const ManufacturerModel({
    required this.id,
    this.name,
    this.active,
    this.date_add,
    this.date_upd,
  });

  factory ManufacturerModel.fromJson(Map<String, dynamic> json) =>
      _$ManufacturerModelFromJson(json);

  Map<String, dynamic> toJson() => _$ManufacturerModelToJson(this);

  @override
  String toString() => 'ManufacturerModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManufacturerModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
