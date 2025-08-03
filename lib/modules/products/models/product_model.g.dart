// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: (json['id'] as num).toInt(),
      id_manufacturer: (json['id_manufacturer'] as num?)?.toInt(),
      reference: json['reference'] as String?,
      price: json['price'] as String?,
      active: (json['active'] as num?)?.toInt(),
      date_add: json['date_add'] as String?,
      date_upd: json['date_upd'] as String?,
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_manufacturer': instance.id_manufacturer,
      'reference': instance.reference,
      'price': instance.price,
      'active': instance.active,
      'date_add': instance.date_add,
      'date_upd': instance.date_upd,
    };
