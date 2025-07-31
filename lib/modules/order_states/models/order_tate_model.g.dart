// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_tate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderStateModel _$OrderStateModelFromJson(Map<String, dynamic> json) =>
    OrderStateModel(
      id: (json['id'] as num).toInt(),
      invoice: (json['invoice'] as num?)?.toInt(),
      send_email: (json['send_email'] as num?)?.toInt(),
      color: json['color'] as String?,
      delivery: (json['delivery'] as num?)?.toInt(),
      shipped: (json['shipped'] as num?)?.toInt(),
      paid: (json['paid'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OrderStateModelToJson(OrderStateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoice': instance.invoice,
      'send_email': instance.send_email,
      'color': instance.color,
      'delivery': instance.delivery,
      'shipped': instance.shipped,
      'paid': instance.paid,
    };
