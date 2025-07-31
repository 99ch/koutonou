// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'price_range_model.g.dart';

@JsonSerializable()
class PriceRangeModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_carrier (optionnel)
  @JsonKey(name: 'id_carrier')
  final int? id_carrier;

  /// delimiter1 (optionnel)
  @JsonKey(name: 'delimiter1')
  final String? delimiter1;

  /// delimiter2 (optionnel)
  @JsonKey(name: 'delimiter2')
  final String? delimiter2;

  const PriceRangeModel({
    required this.id,
    this.id_carrier,
    this.delimiter1,
    this.delimiter2,
  });

  factory PriceRangeModel.fromJson(Map<String, dynamic> json) =>
      _$PriceRangeModelFromJson(json);

  Map<String, dynamic> toJson() => _$PriceRangeModelToJson(this);

  @override
  String toString() => 'PriceRangeModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceRangeModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
