// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// reference (optionnel)
  @JsonKey(name: 'reference')
  final String? reference;

  /// id_customer (optionnel)
  @JsonKey(name: 'id_customer')
  final int? id_customer;

  /// current_state (optionnel)
  @JsonKey(name: 'current_state')
  final int? current_state;

  /// total_paid (optionnel)
  @JsonKey(name: 'total_paid')
  final String? total_paid;

  /// date_add (optionnel)
  @JsonKey(name: 'date_add')
  final String? date_add;

  /// date_upd (optionnel)
  @JsonKey(name: 'date_upd')
  final String? date_upd;

  const OrderModel({
    required this.id,
    this.reference,
    this.id_customer,
    this.current_state,
    this.total_paid,
    this.date_add,
    this.date_upd,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  @override
  String toString() => 'OrderModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
