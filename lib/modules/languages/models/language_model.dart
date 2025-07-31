// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'language_model.g.dart';

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

  /// language_code (optionnel)
  @JsonKey(name: 'language_code')
  final String? language_code;

  /// active (optionnel)
  @JsonKey(name: 'active')
  final int? active;

  /// is_rtl (optionnel)
  @JsonKey(name: 'is_rtl')
  final int? is_rtl;

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
    this.language_code,
    this.active,
    this.is_rtl,
    this.date_format_lite,
    this.date_format_full,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) =>
      _$LanguageModelFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageModelToJson(this);

  @override
  String toString() => 'LanguageModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
