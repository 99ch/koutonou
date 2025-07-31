// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'employee_model.g.dart';

@JsonSerializable()
class EmployeeModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_profile (optionnel)
  @JsonKey(name: 'id_profile')
  final int? id_profile;

  /// id_lang (optionnel)
  @JsonKey(name: 'id_lang')
  final int? id_lang;

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

  /// last_connection_date (optionnel)
  @JsonKey(name: 'last_connection_date')
  final String? last_connection_date;

  const EmployeeModel({
    required this.id,
    this.id_profile,
    this.id_lang,
    this.lastname,
    this.firstname,
    this.email,
    this.active,
    this.last_connection_date,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeModelToJson(this);

  @override
  String toString() => 'EmployeeModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
