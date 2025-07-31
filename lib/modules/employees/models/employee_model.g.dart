// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeModel _$EmployeeModelFromJson(Map<String, dynamic> json) =>
    EmployeeModel(
      id: (json['id'] as num).toInt(),
      id_profile: (json['id_profile'] as num?)?.toInt(),
      id_lang: (json['id_lang'] as num?)?.toInt(),
      lastname: json['lastname'] as String?,
      firstname: json['firstname'] as String?,
      email: json['email'] as String?,
      active: (json['active'] as num?)?.toInt(),
      last_connection_date: json['last_connection_date'] as String?,
    );

Map<String, dynamic> _$EmployeeModelToJson(EmployeeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_profile': instance.id_profile,
      'id_lang': instance.id_lang,
      'lastname': instance.lastname,
      'firstname': instance.firstname,
      'email': instance.email,
      'active': instance.active,
      'last_connection_date': instance.last_connection_date,
    };
