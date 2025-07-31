// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'tranlated_configuration_model.g.dart';

@JsonSerializable()
class TranslatedConfigurationModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_lang (optionnel)
  @JsonKey(name: 'id_lang')
  final int? id_lang;

  /// value (optionnel)
  @JsonKey(name: 'value')
  final String? value;

  /// date_add (optionnel)
  @JsonKey(name: 'date_add')
  final String? date_add;

  /// date_upd (optionnel)
  @JsonKey(name: 'date_upd')
  final String? date_upd;

  const TranslatedConfigurationModel({
    required this.id,
    this.id_lang,
    this.value,
    this.date_add,
    this.date_upd,
  });

  factory TranslatedConfigurationModel.fromJson(Map<String, dynamic> json) =>
      _$TranslatedConfigurationModelFromJson(json);

  Map<String, dynamic> toJson() => _$TranslatedConfigurationModelToJson(this);

  @override
  String toString() => 'TranslatedConfigurationModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslatedConfigurationModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
