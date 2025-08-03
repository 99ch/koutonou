// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'languagemodel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanguageModel _$LanguageModelFromJson(Map<String, dynamic> json) =>
    LanguageModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      iso_code: json['iso_code'] as String?,
      locale: json['locale'] as String?,
      language_code: json['language_code'] as String?,
      active: (json['active'] as num?)?.toInt(),
      date_format_lite: json['date_format_lite'] as String?,
      date_format_full: json['date_format_full'] as String?,
    );

Map<String, dynamic> _$LanguageModelToJson(LanguageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iso_code': instance.iso_code,
      'locale': instance.locale,
      'language_code': instance.language_code,
      'active': instance.active,
      'date_format_lite': instance.date_format_lite,
      'date_format_full': instance.date_format_full,
    };
