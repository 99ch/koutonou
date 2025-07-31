// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currencymodel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyModel _$CurrencyModelFromJson(Map<String, dynamic> json) =>
    CurrencyModel(
      id: (json['id'] as num).toInt(),
      names: json['names'] as String?,
      name: json['name'] as String?,
      symbol: json['symbol'] as String?,
      iso_code: json['iso_code'] as String?,
      numeric_iso_code: json['numeric_iso_code'] as String?,
      precision: (json['precision'] as num?)?.toInt(),
      conversion_rate: json['conversion_rate'] as String?,
      active: (json['active'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CurrencyModelToJson(CurrencyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'names': instance.names,
      'name': instance.name,
      'symbol': instance.symbol,
      'iso_code': instance.iso_code,
      'numeric_iso_code': instance.numeric_iso_code,
      'precision': instance.precision,
      'conversion_rate': instance.conversion_rate,
      'active': instance.active,
    };
