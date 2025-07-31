// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'order_carrier_model.g.dart';

@JsonSerializable()
class OrderCarrierModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_order (optionnel)
  @JsonKey(name: 'id_order')
  final int? id_order;

  /// id_carrier (optionnel)
  @JsonKey(name: 'id_carrier')
  final int? id_carrier;

  /// weight (optionnel)
  @JsonKey(name: 'weight')
  final String? weight;

  /// shipping_cost_tax_excl (optionnel)
  @JsonKey(name: 'shipping_cost_tax_excl')
  final String? shipping_cost_tax_excl;

  /// tracking_number (optionnel)
  @JsonKey(name: 'tracking_number')
  final String? tracking_number;

  /// date_add (optionnel)
  @JsonKey(name: 'date_add')
  final String? date_add;

  const OrderCarrierModel({
    required this.id,
    this.id_order,
    this.id_carrier,
    this.weight,
    this.shipping_cost_tax_excl,
    this.tracking_number,
    this.date_add,
  });

  factory OrderCarrierModel.fromJson(Map<String, dynamic> json) =>
      _$OrderCarrierModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderCarrierModelToJson(this);

  @override
  String toString() => 'OrderCarrierModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderCarrierModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
