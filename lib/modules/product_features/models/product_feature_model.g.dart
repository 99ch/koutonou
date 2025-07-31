// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_feature_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductFeatureModel _$ProductFeatureModelFromJson(Map<String, dynamic> json) =>
    ProductFeatureModel(
      id: (json['id'] as num).toInt(),
      position: (json['position'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProductFeatureModelToJson(
        ProductFeatureModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'position': instance.position,
    };
