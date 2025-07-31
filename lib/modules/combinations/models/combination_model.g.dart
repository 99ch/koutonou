// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combination_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CombinationModel _$CombinationModelFromJson(Map<String, dynamic> json) =>
    CombinationModel(
      id: (json['id'] as num).toInt(),
      id_product: (json['id_product'] as num?)?.toInt(),
      reference: json['reference'] as String?,
      price: json['price'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      weight: json['weight'] as String?,
    );

Map<String, dynamic> _$CombinationModelToJson(CombinationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_product': instance.id_product,
      'reference': instance.reference,
      'price': instance.price,
      'quantity': instance.quantity,
      'weight': instance.weight,
    };
