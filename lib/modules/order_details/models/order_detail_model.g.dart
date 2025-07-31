// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDetailModel _$OrderDetailModelFromJson(Map<String, dynamic> json) =>
    OrderDetailModel(
      id: (json['id'] as num).toInt(),
      id_order: (json['id_order'] as num?)?.toInt(),
      product_id: (json['product_id'] as num?)?.toInt(),
      product_name: json['product_name'] as String?,
      product_quantity: (json['product_quantity'] as num?)?.toInt(),
      product_price: json['product_price'] as String?,
      total_price_tax_incl: json['total_price_tax_incl'] as String?,
      total_price_tax_excl: json['total_price_tax_excl'] as String?,
    );

Map<String, dynamic> _$OrderDetailModelToJson(OrderDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_order': instance.id_order,
      'product_id': instance.product_id,
      'product_name': instance.product_name,
      'product_quantity': instance.product_quantity,
      'product_price': instance.product_price,
      'total_price_tax_incl': instance.total_price_tax_incl,
      'total_price_tax_excl': instance.total_price_tax_excl,
    };
