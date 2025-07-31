// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'tax_rule_group_model.g.dart';

@JsonSerializable()
class TaxRuleGroupModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// name (optionnel)
  @JsonKey(name: 'name')
  final String? name;

  /// active (optionnel)
  @JsonKey(name: 'active')
  final int? active;

  /// deleted (optionnel)
  @JsonKey(name: 'deleted')
  final int? deleted;

  /// date_add (optionnel)
  @JsonKey(name: 'date_add')
  final String? date_add;

  /// date_upd (optionnel)
  @JsonKey(name: 'date_upd')
  final String? date_upd;

  const TaxRuleGroupModel({
    required this.id,
    this.name,
    this.active,
    this.deleted,
    this.date_add,
    this.date_upd,
  });

  factory TaxRuleGroupModel.fromJson(Map<String, dynamic> json) =>
      _$TaxRuleGroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaxRuleGroupModelToJson(this);

  @override
  String toString() => 'TaxRuleGroupModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxRuleGroupModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
