// Service généré automatiquement pour PrestaShop - Version Web
// Phase 1 MVP - CRUD basique sans cache pour le web
// Intégration avec l'ApiClient existant

import 'package:koutonou/core/api/api_client.dart';
import 'package:koutonou/core/exceptions/api_exception.dart';
import 'package:koutonou/core/utils/logger.dart';
import 'package:koutonou/modules/configs/models/languagemodel.dart';

/// Service pour la gestion des languages - Version Web
class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  final ApiClient _apiClient = ApiClient();
  static final AppLogger _logger = AppLogger();

  /// Récupère tous les languages
  Future<List<LanguageModel>> getAll({
    Map<String, dynamic>? filters,
    bool useCache = true, // Ignoré sur le web
  }) async {
    try {
      _logger.debug('Récupération des languages (mode web)');

      // Appel API direct (pas de cache sur le web)
      final response = await _apiClient.get(
        'languages',
        queryParameters: {
          'output_format': 'JSON',
          'display':
              'full', // Récupère toutes les données au lieu des IDs seulement
          if (filters != null) ...filters,
        },
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      // Parser les données
      final items = _parseApiResponse(response.data);

      _logger.info('languages récupérés: ${items.length}');
      return items;
    } catch (e, stackTrace) {
      _logger.error('Erreur récupération languages', e, stackTrace);
      rethrow;
    }
  }

  /// Récupère un LanguageModel par son ID
  Future<LanguageModel?> getById(String id) async {
    try {
      _logger.debug('Récupération languages ID: $id');

      final response = await _apiClient.get(
        'languages/$id',
        queryParameters: {
          'output_format': 'JSON',
          'display': 'full', // Récupère toutes les données
        },
      );

      if (!response.success) {
        if (response.statusCode == 404) {
          _logger.debug('LanguageModel $id non trouvé');
          return null;
        }
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      final item = _parseSingleApiResponse(response.data);
      _logger.info('LanguageModel $id récupéré');
      return item;
    } catch (e, stackTrace) {
      _logger.error('Erreur récupération LanguageModel $id', e, stackTrace);
      rethrow;
    }
  }

  /// Crée un nouveau LanguageModel
  Future<LanguageModel> create(LanguageModel model) async {
    try {
      _logger.debug('Création LanguageModel');

      final response = await _apiClient.post(
        'languages',
        data: {'language': model.toJson()},
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      final created = _parseSingleApiResponse(response.data);
      _logger.info('LanguageModel créé avec ID: ${created?.id ?? "unknown"}');
      return created!;
    } catch (e, stackTrace) {
      _logger.error('Erreur création LanguageModel', e, stackTrace);
      rethrow;
    }
  }

  /// Met à jour un LanguageModel
  Future<LanguageModel> update(String id, LanguageModel model) async {
    try {
      _logger.debug('Mise à jour LanguageModel ID: $id');

      final response = await _apiClient.put(
        'languages',
        id,
        data: {'language': model.toJson()},
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      final updated = _parseSingleApiResponse(response.data);
      _logger.info('LanguageModel $id mis à jour');
      return updated!;
    } catch (e, stackTrace) {
      _logger.error('Erreur mise à jour LanguageModel $id', e, stackTrace);
      rethrow;
    }
  }

  /// Supprime un LanguageModel
  Future<bool> delete(String id) async {
    try {
      _logger.debug('Suppression LanguageModel ID: $id');

      final response = await _apiClient.delete('languages', id);

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      _logger.info('LanguageModel $id supprimé');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Erreur suppression LanguageModel $id', e, stackTrace);
      return false;
    }
  }

  /// Parse la réponse API pour une liste
  List<LanguageModel> _parseApiResponse(dynamic data) {
    final items = <LanguageModel>[];

    if (data is Map<String, dynamic>) {
      // PrestaShop retourne {resource: [...]}
      final list = data['languages'] ?? data['languages'] ?? [];

      if (list is List) {
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            try {
              items.add(LanguageModel.fromJson(item));
            } catch (e) {
              _logger.warning('Erreur parsing item languages: $e');
            }
          }
        }
      }
    }

    return items;
  }

  /// Parse la réponse API pour un seul item
  LanguageModel? _parseSingleApiResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Extraire l'objet principal
      final itemData = data['language'] ?? data;

      if (itemData is Map<String, dynamic>) {
        try {
          return LanguageModel.fromJson(itemData);
        } catch (e) {
          _logger.error('Erreur parsing LanguageModel: $e');
        }
      }
    }

    return null;
  }

  /// Rafraîchit les données (pas de cache sur le web)
  Future<List<LanguageModel>> refresh() async {
    return getAll(useCache: false);
  }
}
