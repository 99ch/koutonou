// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'tore_model.g.dart';

@JsonSerializable()
class StoreModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_country (optionnel)
  @JsonKey(name: 'id_country')
  final int? id_country;

  /// id_state (optionnel)
  @JsonKey(name: 'id_state')
  final int? id_state;

  /// city (optionnel)
  @JsonKey(name: 'city')
  final String? city;

  /// postcode (optionnel)
  @JsonKey(name: 'postcode')
  final String? postcode;

  /// phone (optionnel)
  @JsonKey(name: 'phone')
  final String? phone;

  /// email (optionnel)
  @JsonKey(name: 'email')
  final String? email;

  /// active (optionnel)
  @JsonKey(name: 'active')
  final int? active;

  /// date_add (optionnel)
  @JsonKey(name: 'date_add')
  final String? date_add;

  /// date_upd (optionnel)
  @JsonKey(name: 'date_upd')
  final String? date_upd;

  const StoreModel({
    required this.id,
    this.id_country,
    this.id_state,
    this.city,
    this.postcode,
    this.phone,
    this.email,
    this.active,
    this.date_add,
    this.date_upd,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) =>
      _$StoreModelFromJson(json);

  Map<String, dynamic> toJson() => _$StoreModelToJson(this);

  @override
  String toString() => 'StoreModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
