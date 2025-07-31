// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactModel _$ContactModelFromJson(Map<String, dynamic> json) => ContactModel(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String?,
      customer_service: (json['customer_service'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ContactModelToJson(ContactModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'customer_service': instance.customer_service,
    };
