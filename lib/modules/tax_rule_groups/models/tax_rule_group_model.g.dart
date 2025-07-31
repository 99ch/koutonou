// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_rule_group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxRuleGroupModel _$TaxRuleGroupModelFromJson(Map<String, dynamic> json) =>
    TaxRuleGroupModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      active: (json['active'] as num?)?.toInt(),
      deleted: (json['deleted'] as num?)?.toInt(),
      date_add: json['date_add'] as String?,
      date_upd: json['date_upd'] as String?,
    );

Map<String, dynamic> _$TaxRuleGroupModelToJson(TaxRuleGroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'active': instance.active,
      'deleted': instance.deleted,
      'date_add': instance.date_add,
      'date_upd': instance.date_upd,
    };
