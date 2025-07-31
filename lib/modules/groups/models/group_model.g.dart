// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => GroupModel(
      id: (json['id'] as num).toInt(),
      reduction: json['reduction'] as String?,
      price_display_method: (json['price_display_method'] as num?)?.toInt(),
      show_prices: (json['show_prices'] as num?)?.toInt(),
      date_add: json['date_add'] as String?,
      date_upd: json['date_upd'] as String?,
    );

Map<String, dynamic> _$GroupModelToJson(GroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reduction': instance.reduction,
      'price_display_method': instance.price_display_method,
      'show_prices': instance.show_prices,
      'date_add': instance.date_add,
      'date_upd': instance.date_upd,
    };
