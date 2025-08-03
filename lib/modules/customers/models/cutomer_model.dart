// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'cutomer_model.g.dart';

@JsonSerializable()
class CustomerModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// lastname (optionnel)
  @JsonKey(name: 'lastname')
  final String? lastname;

  /// firstname (optionnel)
  @JsonKey(name: 'firstname')
  final String? firstname;

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

  const CustomerModel({
    required this.id,
    this.lastname,
    this.firstname,
    this.email,
    this.active,
    this.date_add,
    this.date_upd,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);

  @override
  String toString() => 'CustomerModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
