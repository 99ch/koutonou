// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_range_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceRangeModel _$PriceRangeModelFromJson(Map<String, dynamic> json) =>
    PriceRangeModel(
      id: (json['id'] as num).toInt(),
      id_carrier: (json['id_carrier'] as num?)?.toInt(),
      delimiter1: json['delimiter1'] as String?,
      delimiter2: json['delimiter2'] as String?,
    );

Map<String, dynamic> _$PriceRangeModelToJson(PriceRangeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_carrier': instance.id_carrier,
      'delimiter1': instance.delimiter1,
      'delimiter2': instance.delimiter2,
    };
