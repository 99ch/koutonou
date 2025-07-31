// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'order_tate_model.g.dart';

@JsonSerializable()
class OrderStateModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// invoice (optionnel)
  @JsonKey(name: 'invoice')
  final int? invoice;

  /// send_email (optionnel)
  @JsonKey(name: 'send_email')
  final int? send_email;

  /// color (optionnel)
  @JsonKey(name: 'color')
  final String? color;

  /// delivery (optionnel)
  @JsonKey(name: 'delivery')
  final int? delivery;

  /// shipped (optionnel)
  @JsonKey(name: 'shipped')
  final int? shipped;

  /// paid (optionnel)
  @JsonKey(name: 'paid')
  final int? paid;

  const OrderStateModel({
    required this.id,
    this.invoice,
    this.send_email,
    this.color,
    this.delivery,
    this.shipped,
    this.paid,
  });

  factory OrderStateModel.fromJson(Map<String, dynamic> json) =>
      _$OrderStateModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStateModelToJson(this);

  @override
  String toString() => 'OrderStateModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderStateModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
