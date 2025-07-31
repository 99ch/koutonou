// Modèle généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet
// Ne pas modifier manuellement

import 'package:json_annotation/json_annotation.dart';

part 'group_model.g.dart';

@JsonSerializable()
class GroupModel {
  /// id (requis)
  @JsonKey(name: 'id')
  final int id;

  /// reduction (optionnel)
  @JsonKey(name: 'reduction')
  final String? reduction;

  /// price_display_method (optionnel)
  @JsonKey(name: 'price_display_method')
  final int? price_display_method;

  /// show_prices (optionnel)
  @JsonKey(name: 'show_prices')
  final int? show_prices;

  /// date_add (optionnel)
  @JsonKey(name: 'date_add')
  final String? date_add;

  /// date_upd (optionnel)
  @JsonKey(name: 'date_upd')
  final String? date_upd;

  const GroupModel({
    required this.id,
    this.reduction,
    this.price_display_method,
    this.show_prices,
    this.date_add,
    this.date_upd,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroupModelToJson(this);

  @override
  String toString() => 'GroupModel(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
