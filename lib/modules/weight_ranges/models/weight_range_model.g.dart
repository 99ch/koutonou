// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_range_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightRangeModel _$WeightRangeModelFromJson(Map<String, dynamic> json) =>
    WeightRangeModel(
      id: (json['id'] as num).toInt(),
      id_carrier: (json['id_carrier'] as num?)?.toInt(),
      delimiter1: json['delimiter1'] as String?,
      delimiter2: json['delimiter2'] as String?,
    );

Map<String, dynamic> _$WeightRangeModelToJson(WeightRangeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_carrier': instance.id_carrier,
      'delimiter1': instance.delimiter1,
      'delimiter2': instance.delimiter2,
    };
