// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cutomer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerModel _$CustomerModelFromJson(Map<String, dynamic> json) =>
    CustomerModel(
      id: (json['id'] as num).toInt(),
      lastname: json['lastname'] as String?,
      firstname: json['firstname'] as String?,
      email: json['email'] as String?,
      active: (json['active'] as num?)?.toInt(),
      date_add: json['date_add'] as String?,
      date_upd: json['date_upd'] as String?,
    );

Map<String, dynamic> _$CustomerModelToJson(CustomerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lastname': instance.lastname,
      'firstname': instance.firstname,
      'email': instance.email,
      'active': instance.active,
      'date_add': instance.date_add,
      'date_upd': instance.date_upd,
    };
