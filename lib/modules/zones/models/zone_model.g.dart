// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoneModel _$ZoneModelFromJson(Map<String, dynamic> json) => ZoneModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      active: (json['active'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ZoneModelToJson(ZoneModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'active': instance.active,
    };
