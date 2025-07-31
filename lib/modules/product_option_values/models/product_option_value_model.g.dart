// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_option_value_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductOptionValueModel _$ProductOptionValueModelFromJson(
        Map<String, dynamic> json) =>
    ProductOptionValueModel(
      id: (json['id'] as num).toInt(),
      id_attribute_group: (json['id_attribute_group'] as num?)?.toInt(),
      color: json['color'] as String?,
      position: (json['position'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProductOptionValueModelToJson(
        ProductOptionValueModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_attribute_group': instance.id_attribute_group,
      'color': instance.color,
      'position': instance.position,
    };
