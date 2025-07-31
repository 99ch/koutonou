// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageTypeModel _$ImageTypeModelFromJson(Map<String, dynamic> json) =>
    ImageTypeModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      products: (json['products'] as num?)?.toInt(),
      categories: (json['categories'] as num?)?.toInt(),
      manufacturers: (json['manufacturers'] as num?)?.toInt(),
      suppliers: (json['suppliers'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ImageTypeModelToJson(ImageTypeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'width': instance.width,
      'height': instance.height,
      'products': instance.products,
      'categories': instance.categories,
      'manufacturers': instance.manufacturers,
      'suppliers': instance.suppliers,
    };
