// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'tock_movement_reaon_model.g.dart';

@JsonSerializable()
class StockMovementReasonModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// sign (optionnel)
  @JsonKey(name: 'sign')
  final int? sign;

  /// date_add (optionnel)
  @JsonKey(name: 'date_add')
  final String? date_add;

  /// date_upd (optionnel)
  @JsonKey(name: 'date_upd')
  final String? date_upd;

  /// deleted (optionnel)
  @JsonKey(name: 'deleted')
  final int? deleted;

  const StockMovementReasonModel({
    required this.id,
    this.sign,
    this.date_add,
    this.date_upd,
    this.deleted,
  });

  factory StockMovementReasonModel.fromJson(Map<String, dynamic> json) =>
      _$StockMovementReasonModelFromJson(json);

  Map<String, dynamic> toJson() => _$StockMovementReasonModelToJson(this);

  @override
  String toString() => 'StockMovementReasonModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockMovementReasonModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
