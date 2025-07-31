// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hop_group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShopGroupModel _$ShopGroupModelFromJson(Map<String, dynamic> json) =>
    ShopGroupModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      share_customer: (json['share_customer'] as num?)?.toInt(),
      share_order: (json['share_order'] as num?)?.toInt(),
      active: (json['active'] as num?)?.toInt(),
      deleted: (json['deleted'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ShopGroupModelToJson(ShopGroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'share_customer': instance.share_customer,
      'share_order': instance.share_order,
      'active': instance.active,
      'deleted': instance.deleted,
    };
