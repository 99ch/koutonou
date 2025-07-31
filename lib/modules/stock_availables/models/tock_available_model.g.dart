// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tock_available_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockAvailableModel _$StockAvailableModelFromJson(Map<String, dynamic> json) =>
    StockAvailableModel(
      id: (json['id'] as num).toInt(),
      id_product: (json['id_product'] as num?)?.toInt(),
      id_product_attribute: (json['id_product_attribute'] as num?)?.toInt(),
      id_shop: (json['id_shop'] as num?)?.toInt(),
      quantity: (json['quantity'] as num?)?.toInt(),
      depends_on_stock: (json['depends_on_stock'] as num?)?.toInt(),
      out_of_stock: (json['out_of_stock'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StockAvailableModelToJson(
        StockAvailableModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_product': instance.id_product,
      'id_product_attribute': instance.id_product_attribute,
      'id_shop': instance.id_shop,
      'quantity': instance.quantity,
      'depends_on_stock': instance.depends_on_stock,
      'out_of_stock': instance.out_of_stock,
    };
