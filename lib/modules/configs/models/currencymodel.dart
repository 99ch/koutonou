// Modèle généré automatiquement pour PrestaShop
// Phase 1 MVP - Ne pas modifier manuellement
// Utiliser les générateurs pour les modifications

import 'package:json_annotation/json_annotation.dart';

part 'currencymodel.g.dart';

@JsonSerializable()
class CurrencyModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// names (optionnel)
  @JsonKey(name: 'names')
  final String? names;

  /// name (optionnel)
  @JsonKey(name: 'name')
  final String? name;

  /// symbol (optionnel)
  @JsonKey(name: 'symbol')
  final String? symbol;

  /// iso_code (optionnel)
  @JsonKey(name: 'iso_code')
  final String? iso_code;

  /// numeric_iso_code (optionnel)
  @JsonKey(name: 'numeric_iso_code')
  final String? numeric_iso_code;

  /// precision (optionnel)
  @JsonKey(name: 'precision')
  final int? precision;

  /// conversion_rate (optionnel)
  @JsonKey(name: 'conversion_rate')
  final String? conversion_rate;

  /// active (optionnel)
  @JsonKey(name: 'active')
  final int? active;

  const CurrencyModel({
    required this.id,
    this.names,
    this.name,
    this.symbol,
    this.iso_code,
    this.numeric_iso_code,
    this.precision,
    this.conversion_rate,
    this.active,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) =>
      _$CurrencyModelFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyModelToJson(this);

  @override
  String toString() => 'CurrencyModel(id: $id, names: $names, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
