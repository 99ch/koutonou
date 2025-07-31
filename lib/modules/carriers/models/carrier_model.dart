// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'carrier_model.g.dart';

@JsonSerializable()
class CarrierModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// name (optionnel)
  @JsonKey(name: 'name')
  final String? name;

  /// active (optionnel)
  @JsonKey(name: 'active')
  final int? active;

  /// is_free (optionnel)
  @JsonKey(name: 'is_free')
  final int? is_free;

  /// shipping_method (optionnel)
  @JsonKey(name: 'shipping_method')
  final int? shipping_method;

  /// max_weight (optionnel)
  @JsonKey(name: 'max_weight')
  final String? max_weight;

  const CarrierModel({
    required this.id,
    this.name,
    this.active,
    this.is_free,
    this.shipping_method,
    this.max_weight,
  });

  factory CarrierModel.fromJson(Map<String, dynamic> json) =>
      _$CarrierModelFromJson(json);

  Map<String, dynamic> toJson() => _$CarrierModelToJson(this);

  @override
  String toString() => 'CarrierModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarrierModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
