// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'cart_model.g.dart';

@JsonSerializable()
class CartModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_customer (optionnel)
  @JsonKey(name: 'id_customer')
  final int? id_customer;

  /// id_carrier (optionnel)
  @JsonKey(name: 'id_carrier')
  final int? id_carrier;

  /// secure_key (optionnel)
  @JsonKey(name: 'secure_key')
  final String? secure_key;

  /// date_add (optionnel)
  @JsonKey(name: 'date_add')
  final String? date_add;

  /// date_upd (optionnel)
  @JsonKey(name: 'date_upd')
  final String? date_upd;

  const CartModel({
    required this.id,
    this.id_customer,
    this.id_carrier,
    this.secure_key,
    this.date_add,
    this.date_upd,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) =>
      _$CartModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartModelToJson(this);

  @override
  String toString() => 'CartModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
