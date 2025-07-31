// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tock_movement_reaon_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockMovementReasonModel _$StockMovementReasonModelFromJson(
        Map<String, dynamic> json) =>
    StockMovementReasonModel(
      id: (json['id'] as num).toInt(),
      sign: (json['sign'] as num?)?.toInt(),
      date_add: json['date_add'] as String?,
      date_upd: json['date_upd'] as String?,
      deleted: (json['deleted'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StockMovementReasonModelToJson(
        StockMovementReasonModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sign': instance.sign,
      'date_add': instance.date_add,
      'date_upd': instance.date_upd,
      'deleted': instance.deleted,
    };
