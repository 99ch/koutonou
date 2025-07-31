// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfigurationModel _$ConfigurationModelFromJson(Map<String, dynamic> json) =>
    ConfigurationModel(
      id: (json['id'] as num).toInt(),
      id_shop_group: (json['id_shop_group'] as num?)?.toInt(),
      id_shop: (json['id_shop'] as num?)?.toInt(),
      name: json['name'] as String?,
      value: json['value'] as String?,
      date_add: json['date_add'] as String?,
      date_upd: json['date_upd'] as String?,
    );

Map<String, dynamic> _$ConfigurationModelToJson(ConfigurationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_shop_group': instance.id_shop_group,
      'id_shop': instance.id_shop,
      'name': instance.name,
      'value': instance.value,
      'date_add': instance.date_add,
      'date_upd': instance.date_upd,
    };
