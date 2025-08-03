// Modèle généré automatiquement pour PrestaShop
// Phase 1 MVP - Ne pas modifier manuellement
// Utiliser les générateurs pour les modifications

import 'package:json_annotation/json_annotation.dart';

part 'languagemodel.g.dart';

@JsonSerializable()
class LanguageModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// name (optionnel)
  @JsonKey(name: 'name')
  final String? name;

  /// iso_code (optionnel)
  @JsonKey(name: 'iso_code')
  final String? iso_code;

  /// locale (optionnel)
  @JsonKey(name: 'locale')
  final String? locale;

  /// language_code (optionnel)
  @JsonKey(name: 'language_code')
  final String? language_code;

  /// active (optionnel)
  @JsonKey(name: 'active')
  final int? active;

  /// date_format_lite (optionnel)
  @JsonKey(name: 'date_format_lite')
  final String? date_format_lite;

  /// date_format_full (optionnel)
  @JsonKey(name: 'date_format_full')
  final String? date_format_full;

  const LanguageModel({
    required this.id,
    this.name,
    this.iso_code,
    this.locale,
    this.language_code,
    this.active,
    this.date_format_lite,
    this.date_format_full,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) =>
      _$LanguageModelFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageModelToJson(this);

  @override
  String toString() =>
      'LanguageModel(id: $id, name: $name, iso_code: $iso_code)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
