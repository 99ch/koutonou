// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'countrymodel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountryModel _$CountryModelFromJson(Map<String, dynamic> json) => CountryModel(
      id: (json['id'] as num).toInt(),
      id_zone: (json['id_zone'] as num?)?.toInt(),
      call_prefix: (json['call_prefix'] as num?)?.toInt(),
      iso_code: json['iso_code'] as String?,
      need_zip_code: json['need_zip_code'] as String?,
      zip_code_format: json['zip_code_format'] as String?,
      display_tax_label: json['display_tax_label'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$CountryModelToJson(CountryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_zone': instance.id_zone,
      'call_prefix': instance.call_prefix,
      'iso_code': instance.iso_code,
      'need_zip_code': instance.need_zip_code,
      'zip_code_format': instance.zip_code_format,
      'display_tax_label': instance.display_tax_label,
      'name': instance.name,
    };
