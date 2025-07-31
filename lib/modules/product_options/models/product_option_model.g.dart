// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductOptionModel _$ProductOptionModelFromJson(Map<String, dynamic> json) =>
    ProductOptionModel(
      id: (json['id'] as num).toInt(),
      is_color_group: (json['is_color_group'] as num?)?.toInt(),
      group_type: json['group_type'] as String?,
      position: (json['position'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProductOptionModelToJson(ProductOptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'is_color_group': instance.is_color_group,
      'group_type': instance.group_type,
      'position': instance.position,
    };
