// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_carrier_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderCarrierModel _$OrderCarrierModelFromJson(Map<String, dynamic> json) =>
    OrderCarrierModel(
      id: (json['id'] as num).toInt(),
      id_order: (json['id_order'] as num?)?.toInt(),
      id_carrier: (json['id_carrier'] as num?)?.toInt(),
      weight: json['weight'] as String?,
      shipping_cost_tax_excl: json['shipping_cost_tax_excl'] as String?,
      tracking_number: json['tracking_number'] as String?,
      date_add: json['date_add'] as String?,
    );

Map<String, dynamic> _$OrderCarrierModelToJson(OrderCarrierModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_order': instance.id_order,
      'id_carrier': instance.id_carrier,
      'weight': instance.weight,
      'shipping_cost_tax_excl': instance.shipping_cost_tax_excl,
      'tracking_number': instance.tracking_number,
      'date_add': instance.date_add,
    };
