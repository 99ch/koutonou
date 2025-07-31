// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upplier_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupplierModel _$SupplierModelFromJson(Map<String, dynamic> json) =>
    SupplierModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      active: (json['active'] as num?)?.toInt(),
      date_add: json['date_add'] as String?,
      date_upd: json['date_upd'] as String?,
    );

Map<String, dynamic> _$SupplierModelToJson(SupplierModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'active': instance.active,
      'date_add': instance.date_add,
      'date_upd': instance.date_upd,
    };
