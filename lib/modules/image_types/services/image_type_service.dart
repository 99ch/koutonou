// Service généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet avec cache et gestion d'erreurs

import 'dart:convert';

/// Service pour la gestion des image_types
class ImageTypeService {
  static final ImageTypeService _instance = ImageTypeService._internal();
  factory ImageTypeService() => _instance;
  ImageTypeService._internal();

  /// Simulation des méthodes de base
  
  /// Récupère tous les image_types
  Future<List<Map<String, dynamic>>> getAll() async {
    // TODO: Implémenter l'appel API réel
    print('📡 Appel API: GET /image_types');
    
    // Simulation de données
    return [
      {'id': 1, 'name': 'Exemple image_types 1'},
      {'id': 2, 'name': 'Exemple image_types 2'},
    ];
  }

  /// Récupère un ImageTypeModel par son ID
  Future<Map<String, dynamic>?> getById(String id) async {
    print('📡 Appel API: GET /image_types/$id');
    
    // Simulation
    return {'id': int.parse(id), 'name': 'Exemple image_types $id'};
  }

  /// Crée un nouveau ImageTypeModel
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    print('📡 Appel API: POST /image_types');
    
    // Simulation
    return {...data, 'id': DateTime.now().millisecondsSinceEpoch};
  }

  /// Met à jour un ImageTypeModel
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    print('📡 Appel API: PUT /image_types/$id');
    
    // Simulation
    return {...data, 'id': int.parse(id)};
  }

  /// Supprime un ImageTypeModel
  Future<bool> delete(String id) async {
    print('📡 Appel API: DELETE /image_types/$id');
    
    // Simulation
    return true;
  }
}
