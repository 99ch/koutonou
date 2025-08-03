// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_manufacturer (optionnel)
  @JsonKey(name: 'id_manufacturer')
  final int? id_manufacturer;

  /// reference (optionnel)
  @JsonKey(name: 'reference')
  final String? reference;

  /// price (optionnel)
  @JsonKey(name: 'price')
  final String? price;

  /// active (optionnel)
  @JsonKey(name: 'active')
  final int? active;

  /// date_add (optionnel)
  @JsonKey(name: 'date_add')
  final String? date_add;

  /// date_upd (optionnel)
  @JsonKey(name: 'date_upd')
  final String? date_upd;

  const ProductModel({
    required this.id,
    this.id_manufacturer,
    this.reference,
    this.price,
    this.active,
    this.date_add,
    this.date_upd,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  @override
  String toString() => 'ProductModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
