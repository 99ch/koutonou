// Modèle généré automatiquement pour PrestaShop
// Phase 1 MVP - Ne pas modifier manuellement
// Utiliser les générateurs pour les modifications

import 'package:json_annotation/json_annotation.dart';

part 'countrymodel.g.dart';

@JsonSerializable()
class CountryModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_zone (optionnel)
  @JsonKey(name: 'id_zone')
  final int? id_zone;

  /// call_prefix (optionnel)
  @JsonKey(name: 'call_prefix')
  final int? call_prefix;

  /// iso_code (optionnel)
  @JsonKey(name: 'iso_code')
  final String? iso_code;

  /// need_zip_code (optionnel)
  @JsonKey(name: 'need_zip_code')
  final String? need_zip_code;

  /// zip_code_format (optionnel)
  @JsonKey(name: 'zip_code_format')
  final String? zip_code_format;

  /// display_tax_label (optionnel)
  @JsonKey(name: 'display_tax_label')
  final String? display_tax_label;

  /// name (optionnel)
  @JsonKey(name: 'name')
  final String? name;

  const CountryModel({
    required this.id,
    this.id_zone,
    this.call_prefix,
    this.iso_code,
    this.need_zip_code,
    this.zip_code_format,
    this.display_tax_label,
    this.name,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) =>
      _$CountryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CountryModelToJson(this);

  @override
  String toString() =>
      'CountryModel(id: $id, id_zone: $id_zone, call_prefix: $call_prefix)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
