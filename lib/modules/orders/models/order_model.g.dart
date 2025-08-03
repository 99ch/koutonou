// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: (json['id'] as num).toInt(),
  reference: json['reference'] as String?,
  id_customer: (json['id_customer'] as num?)?.toInt(),
  current_state: (json['current_state'] as num?)?.toInt(),
  total_paid: json['total_paid'] as String?,
  date_add: json['date_add'] as String?,
  date_upd: json['date_upd'] as String?,
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'id_customer': instance.id_customer,
      'current_state': instance.current_state,
      'total_paid': instance.total_paid,
      'date_add': instance.date_add,
      'date_upd': instance.date_upd,
    };
