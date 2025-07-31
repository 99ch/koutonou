// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'tax_rule_model.g.dart';

@JsonSerializable()
class TaxRuleModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_tax_rules_group (optionnel)
  @JsonKey(name: 'id_tax_rules_group')
  final int? id_tax_rules_group;

  /// id_country (optionnel)
  @JsonKey(name: 'id_country')
  final int? id_country;

  /// id_state (optionnel)
  @JsonKey(name: 'id_state')
  final int? id_state;

  /// zipcode_from (optionnel)
  @JsonKey(name: 'zipcode_from')
  final String? zipcode_from;

  /// zipcode_to (optionnel)
  @JsonKey(name: 'zipcode_to')
  final String? zipcode_to;

  /// id_tax (optionnel)
  @JsonKey(name: 'id_tax')
  final int? id_tax;

  /// behavior (optionnel)
  @JsonKey(name: 'behavior')
  final int? behavior;

  const TaxRuleModel({
    required this.id,
    this.id_tax_rules_group,
    this.id_country,
    this.id_state,
    this.zipcode_from,
    this.zipcode_to,
    this.id_tax,
    this.behavior,
  });

  factory TaxRuleModel.fromJson(Map<String, dynamic> json) =>
      _$TaxRuleModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaxRuleModelToJson(this);

  @override
  String toString() => 'TaxRuleModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxRuleModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
