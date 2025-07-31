// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pecific_price_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpecificPriceModel _$SpecificPriceModelFromJson(Map<String, dynamic> json) =>
    SpecificPriceModel(
      id: (json['id'] as num).toInt(),
      id_product: (json['id_product'] as num?)?.toInt(),
      id_customer: (json['id_customer'] as num?)?.toInt(),
      price: json['price'] as String?,
      reduction: json['reduction'] as String?,
      reduction_type: json['reduction_type'] as String?,
      from_quantity: (json['from_quantity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SpecificPriceModelToJson(SpecificPriceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_product': instance.id_product,
      'id_customer': instance.id_customer,
      'price': instance.price,
      'reduction': instance.reduction,
      'reduction_type': instance.reduction_type,
      'from_quantity': instance.from_quantity,
    };
