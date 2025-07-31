// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartModel _$CartModelFromJson(Map<String, dynamic> json) => CartModel(
      id: (json['id'] as num).toInt(),
      id_customer: (json['id_customer'] as num?)?.toInt(),
      id_carrier: (json['id_carrier'] as num?)?.toInt(),
      secure_key: json['secure_key'] as String?,
      date_add: json['date_add'] as String?,
      date_upd: json['date_upd'] as String?,
    );

Map<String, dynamic> _$CartModelToJson(CartModel instance) => <String, dynamic>{
      'id': instance.id,
      'id_customer': instance.id_customer,
      'id_carrier': instance.id_carrier,
      'secure_key': instance.secure_key,
      'date_add': instance.date_add,
      'date_upd': instance.date_upd,
    };
