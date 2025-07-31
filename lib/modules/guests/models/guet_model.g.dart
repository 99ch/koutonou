// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuestModel _$GuestModelFromJson(Map<String, dynamic> json) => GuestModel(
      id: (json['id'] as num).toInt(),
      id_customer: (json['id_customer'] as num?)?.toInt(),
      javascript: (json['javascript'] as num?)?.toInt(),
      screen_resolution_x: (json['screen_resolution_x'] as num?)?.toInt(),
      screen_resolution_y: (json['screen_resolution_y'] as num?)?.toInt(),
      accept_language: json['accept_language'] as String?,
      mobile_theme: (json['mobile_theme'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GuestModelToJson(GuestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_customer': instance.id_customer,
      'javascript': instance.javascript,
      'screen_resolution_x': instance.screen_resolution_x,
      'screen_resolution_y': instance.screen_resolution_y,
      'accept_language': instance.accept_language,
      'mobile_theme': instance.mobile_theme,
    };
