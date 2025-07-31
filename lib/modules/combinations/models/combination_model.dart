// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'combination_model.g.dart';

@JsonSerializable()
class CombinationModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_product (optionnel)
  @JsonKey(name: 'id_product')
  final int? id_product;

  /// reference (optionnel)
  @JsonKey(name: 'reference')
  final String? reference;

  /// price (optionnel)
  @JsonKey(name: 'price')
  final String? price;

  /// quantity (optionnel)
  @JsonKey(name: 'quantity')
  final int? quantity;

  /// weight (optionnel)
  @JsonKey(name: 'weight')
  final String? weight;

  const CombinationModel({
    required this.id,
    this.id_product,
    this.reference,
    this.price,
    this.quantity,
    this.weight,
  });

  factory CombinationModel.fromJson(Map<String, dynamic> json) =>
      _$CombinationModelFromJson(json);

  Map<String, dynamic> toJson() => _$CombinationModelToJson(this);

  @override
  String toString() => 'CombinationModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CombinationModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
