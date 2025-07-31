// Service généré automatiquement pour PrestaShop
// Phase 1 MVP - CRUD basique avec cache et gestion d'erreurs
// Intégration avec l'ApiClient existant

import 'package:koutonou/core/api/api_client.dart';
import 'package:koutonou/core/exceptions/api_exception.dart';
import 'package:koutonou/core/services/cache_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import 'package:koutonou/modules/configs/models/languagemodel.dart';

/// Service pour la gestion des languages
class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  final ApiClient _apiClient = ApiClient();
  CacheService? _cacheService;
  static final AppLogger _logger = AppLogger();
  bool _cacheInitialized = false;

  /// Clé de cache pour les languages
  static const String _languagesCacheKey = 'languages_cache';

  /// Initialise le cache de manière paresseuse
  Future<void> _ensureCacheInitialized() async {
    if (_cacheInitialized) return;

    try {
      _cacheService = CacheService();
      await _cacheService!.initialize();
      _cacheInitialized = true;
      _logger.debug('Cache initialisé pour LanguageService');
    } catch (e) {
      _logger.warning('Cache non disponible pour LanguageService: $e');
      _cacheService = null;
      _cacheInitialized = true; // Marquer comme "initialisé" même en échec
    }
  }

  /// Récupère tous les languages
  Future<List<LanguageModel>> getAll({
    Map<String, dynamic>? filters,
    bool useCache = true,
  }) async {
    try {
      _logger.debug('Récupération des languages (cache: $useCache)');

      // Initialiser le cache si nécessaire
      await _ensureCacheInitialized();

      // Vérifier le cache d'abord (seulement si cache disponible)
      if (useCache && _cacheService != null) {
        final cached = await _getCachedData();
        if (cached.isNotEmpty) {
          _logger.debug('languages trouvés dans le cache: ${cached.length}');
          return cached;
        }
      }

      // Appel API
      final response = await _apiClient.get(
        'languages',
        queryParameters: {
          'output_format': 'JSON',
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

      // Mettre en cache (seulement si cache disponible)
      if (useCache && _cacheService != null) {
        await _cacheData(items);
      }

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
        queryParameters: {'output_format': 'JSON'},
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

      // Invalider le cache
      await _invalidateCache();

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

      // Invalider le cache
      await _invalidateCache();

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

      // Invalider le cache
      await _invalidateCache();

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

  /// Récupère les données du cache
  Future<List<LanguageModel>> _getCachedData() async {
    try {
      if (_cacheService == null) return [];

      final cached = await _cacheService!.get<List<dynamic>>(
        _languagesCacheKey,
      );
      if (cached != null) {
        return cached
            .map((item) => LanguageModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _logger.warning('Erreur lecture cache languages: $e');
    }

    return [];
  }

  /// Met en cache les données
  Future<void> _cacheData(List<LanguageModel> items) async {
    try {
      if (_cacheService == null) return;

      final jsonList = items.map((item) => item.toJson()).toList();
      await _cacheService!.set(
        _languagesCacheKey,
        jsonList,
        ttl: const Duration(hours: 1), // Cache 1h pour les configs
      );
    } catch (e) {
      _logger.warning('Erreur mise en cache languages: $e');
    }
  }

  /// Invalide le cache
  Future<void> _invalidateCache() async {
    try {
      if (_cacheService == null) return;

      await _cacheService!.delete(_languagesCacheKey);
      _logger.debug('Cache languages invalidé');
    } catch (e) {
      _logger.warning('Erreur invalidation cache languages: $e');
    }
  }

  /// Rafraîchit les données (force un appel API)
  Future<List<LanguageModel>> refresh() async {
    await _invalidateCache();
    return getAll(useCache: false);
  }
}
