// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_rule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxRuleModel _$TaxRuleModelFromJson(Map<String, dynamic> json) => TaxRuleModel(
      id: (json['id'] as num).toInt(),
      id_tax_rules_group: (json['id_tax_rules_group'] as num?)?.toInt(),
      id_country: (json['id_country'] as num?)?.toInt(),
      id_state: (json['id_state'] as num?)?.toInt(),
      zipcode_from: json['zipcode_from'] as String?,
      zipcode_to: json['zipcode_to'] as String?,
      id_tax: (json['id_tax'] as num?)?.toInt(),
      behavior: (json['behavior'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TaxRuleModelToJson(TaxRuleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_tax_rules_group': instance.id_tax_rules_group,
      'id_country': instance.id_country,
      'id_state': instance.id_state,
      'zipcode_from': instance.zipcode_from,
      'zipcode_to': instance.zipcode_to,
      'id_tax': instance.id_tax,
      'behavior': instance.behavior,
    };
