import 'package:equatable/equatable.dart';

/// Classe de base pour tous les modèles PrestaShop
abstract class BaseModel extends Equatable {
  final int? id;

  const BaseModel({this.id});

  /// Méthode pour créer une copie modifiée de l'objet
  BaseModel copyWith();

  /// Méthode pour convertir en JSON
  Map<String, dynamic> toJson();

  /// Méthode pour convertir en XML PrestaShop
  String toXml();
}
