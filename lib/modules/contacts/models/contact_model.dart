// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'contact_model.g.dart';

@JsonSerializable()
class ContactModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// email (optionnel)
  @JsonKey(name: 'email')
  final String? email;

  /// customer_service (optionnel)
  @JsonKey(name: 'customer_service')
  final int? customer_service;

  const ContactModel({
    required this.id,
    this.email,
    this.customer_service,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) =>
      _$ContactModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContactModelToJson(this);

  @override
  String toString() => 'ContactModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
