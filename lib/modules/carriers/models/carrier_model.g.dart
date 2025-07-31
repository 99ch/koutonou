// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carrier_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarrierModel _$CarrierModelFromJson(Map<String, dynamic> json) => CarrierModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      active: (json['active'] as num?)?.toInt(),
      is_free: (json['is_free'] as num?)?.toInt(),
      shipping_method: (json['shipping_method'] as num?)?.toInt(),
      max_weight: json['max_weight'] as String?,
    );

Map<String, dynamic> _$CarrierModelToJson(CarrierModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'active': instance.active,
      'is_free': instance.is_free,
      'shipping_method': instance.shipping_method,
      'max_weight': instance.max_weight,
    };
