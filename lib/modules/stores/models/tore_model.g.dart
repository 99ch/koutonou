// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tore_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreModel _$StoreModelFromJson(Map<String, dynamic> json) => StoreModel(
      id: (json['id'] as num).toInt(),
      id_country: (json['id_country'] as num?)?.toInt(),
      id_state: (json['id_state'] as num?)?.toInt(),
      city: json['city'] as String?,
      postcode: json['postcode'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      active: (json['active'] as num?)?.toInt(),
      date_add: json['date_add'] as String?,
      date_upd: json['date_upd'] as String?,
    );

Map<String, dynamic> _$StoreModelToJson(StoreModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_country': instance.id_country,
      'id_state': instance.id_state,
      'city': instance.city,
      'postcode': instance.postcode,
      'phone': instance.phone,
      'email': instance.email,
      'active': instance.active,
      'date_add': instance.date_add,
      'date_upd': instance.date_upd,
    };
