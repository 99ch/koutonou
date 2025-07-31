// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'guet_model.g.dart';

@JsonSerializable()
class GuestModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// id_customer (optionnel)
  @JsonKey(name: 'id_customer')
  final int? id_customer;

  /// javascript (optionnel)
  @JsonKey(name: 'javascript')
  final int? javascript;

  /// screen_resolution_x (optionnel)
  @JsonKey(name: 'screen_resolution_x')
  final int? screen_resolution_x;

  /// screen_resolution_y (optionnel)
  @JsonKey(name: 'screen_resolution_y')
  final int? screen_resolution_y;

  /// accept_language (optionnel)
  @JsonKey(name: 'accept_language')
  final String? accept_language;

  /// mobile_theme (optionnel)
  @JsonKey(name: 'mobile_theme')
  final int? mobile_theme;

  const GuestModel({
    required this.id,
    this.id_customer,
    this.javascript,
    this.screen_resolution_x,
    this.screen_resolution_y,
    this.accept_language,
    this.mobile_theme,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) =>
      _$GuestModelFromJson(json);

  Map<String, dynamic> toJson() => _$GuestModelToJson(this);

  @override
  String toString() => 'GuestModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuestModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
