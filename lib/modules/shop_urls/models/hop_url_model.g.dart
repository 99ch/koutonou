// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hop_url_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShopUrlModel _$ShopUrlModelFromJson(Map<String, dynamic> json) => ShopUrlModel(
      id: (json['id'] as num).toInt(),
      id_shop: (json['id_shop'] as num?)?.toInt(),
      domain: json['domain'] as String?,
      domain_ssl: json['domain_ssl'] as String?,
      main: (json['main'] as num?)?.toInt(),
      active: (json['active'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ShopUrlModelToJson(ShopUrlModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_shop': instance.id_shop,
      'domain': instance.domain,
      'domain_ssl': instance.domain_ssl,
      'main': instance.main,
      'active': instance.active,
    };
