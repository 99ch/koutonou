// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manufacturer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ManufacturerModel _$ManufacturerModelFromJson(Map<String, dynamic> json) =>
    ManufacturerModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      active: (json['active'] as num?)?.toInt(),
      date_add: json['date_add'] as String?,
      date_upd: json['date_upd'] as String?,
    );

Map<String, dynamic> _$ManufacturerModelToJson(ManufacturerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'active': instance.active,
      'date_add': instance.date_add,
      'date_upd': instance.date_upd,
    };
