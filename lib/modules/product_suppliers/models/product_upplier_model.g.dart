// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_upplier_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductSupplierModel _$ProductSupplierModelFromJson(
        Map<String, dynamic> json) =>
    ProductSupplierModel(
      id: (json['id'] as num).toInt(),
      id_product: (json['id_product'] as num?)?.toInt(),
      id_supplier: (json['id_supplier'] as num?)?.toInt(),
      product_supplier_reference: json['product_supplier_reference'] as String?,
      product_supplier_price_te: json['product_supplier_price_te'] as String?,
    );

Map<String, dynamic> _$ProductSupplierModelToJson(
        ProductSupplierModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_product': instance.id_product,
      'id_supplier': instance.id_supplier,
      'product_supplier_reference': instance.product_supplier_reference,
      'product_supplier_price_te': instance.product_supplier_price_te,
    };
