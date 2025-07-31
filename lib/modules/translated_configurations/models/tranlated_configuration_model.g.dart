// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tranlated_configuration_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslatedConfigurationModel _$TranslatedConfigurationModelFromJson(
        Map<String, dynamic> json) =>
    TranslatedConfigurationModel(
      id: (json['id'] as num).toInt(),
      id_lang: (json['id_lang'] as num?)?.toInt(),
      value: json['value'] as String?,
      date_add: json['date_add'] as String?,
      date_upd: json['date_upd'] as String?,
    );

Map<String, dynamic> _$TranslatedConfigurationModelToJson(
        TranslatedConfigurationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_lang': instance.id_lang,
      'value': instance.value,
      'date_add': instance.date_add,
      'date_upd': instance.date_upd,
    };
