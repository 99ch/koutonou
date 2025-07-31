// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StateModel _$StateModelFromJson(Map<String, dynamic> json) => StateModel(
      id: (json['id'] as num).toInt(),
      id_country: (json['id_country'] as num?)?.toInt(),
      id_zone: (json['id_zone'] as num?)?.toInt(),
      name: json['name'] as String?,
      iso_code: json['iso_code'] as String?,
      active: (json['active'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StateModelToJson(StateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_country': instance.id_country,
      'id_zone': instance.id_zone,
      'name': instance.name,
      'iso_code': instance.iso_code,
      'active': instance.active,
    };
