// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_feature_value_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductFeatureValueModel _$ProductFeatureValueModelFromJson(
        Map<String, dynamic> json) =>
    ProductFeatureValueModel(
      id: (json['id'] as num).toInt(),
      id_feature: (json['id_feature'] as num?)?.toInt(),
      custom: (json['custom'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProductFeatureValueModelToJson(
        ProductFeatureValueModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_feature': instance.id_feature,
      'custom': instance.custom,
    };
