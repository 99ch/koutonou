// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShopModel _$ShopModelFromJson(Map<String, dynamic> json) => ShopModel(
      id: (json['id'] as num).toInt(),
      id_shop_group: (json['id_shop_group'] as num?)?.toInt(),
      name: json['name'] as String?,
      id_category: (json['id_category'] as num?)?.toInt(),
      active: (json['active'] as num?)?.toInt(),
      deleted: (json['deleted'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ShopModelToJson(ShopModel instance) => <String, dynamic>{
      'id': instance.id,
      'id_shop_group': instance.id_shop_group,
      'name': instance.name,
      'id_category': instance.id_category,
      'active': instance.active,
      'deleted': instance.deleted,
    };
