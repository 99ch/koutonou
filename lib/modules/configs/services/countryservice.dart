// Service généré automatiquement pour PrestaShop
// Phase 1 MVP - CRUD basique avec cache et gestion d'erreurs
// Intégration avec l'ApiClient existant

import 'package:koutonou/core/api/api_client.dart';
import 'package:koutonou/core/exceptions/api_exception.dart';
import 'package:koutonou/core/services/cache_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import 'package:koutonou/modules/configs/models/countrymodel.dart';

/// Service pour la gestion des countries
class CountryService {
  static final CountryService _instance = CountryService._internal();
  factory CountryService() => _instance;
  CountryService._internal();

  final ApiClient _apiClient = ApiClient();
  CacheService? _cacheService;
  static final AppLogger _logger = AppLogger();

  /// Clé de cache pour les countries
  static const String _countriesCacheKey = 'countries_cache';

  /// Initialise le service de cache de manière paresseuse
  Future<void> _initCacheIfNeeded() async {
    if (_cacheService == null) {
      try {
        final cache = CacheService();
        await cache.initialize();
        _cacheService = cache;
        _logger.debug('CacheService initialisé pour CountryService');
      } catch (e) {
        _logger.warning(
          'Impossible d\'initialiser le cache pour CountryService: $e',
        );
        // Continue sans cache
      }
    }
  }

  /// Récupère tous les countries
  Future<List<CountryModel>> getAll({
    Map<String, dynamic>? filters,
    bool useCache = true,
  }) async {
    try {
      _logger.debug('Récupération des countries (cache: $useCache)');

      // Vérifier le cache d'abord
      if (useCache) {
        await _initCacheIfNeeded();
        final cached = await _getCachedData();
        if (cached.isNotEmpty) {
          _logger.debug('countries trouvés dans le cache: ${cached.length}');
          return cached;
        }
      }

      // Appel API
      final response = await _apiClient.get(
        'countries',
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

      // Mettre en cache
      if (useCache) {
        await _cacheData(items);
      }

      _logger.info('countries récupérés: ${items.length}');
      return items;
    } catch (e, stackTrace) {
      _logger.error('Erreur récupération countries', e, stackTrace);
      rethrow;
    }
  }

  /// Récupère un CountryModel par son ID
  Future<CountryModel?> getById(String id) async {
    try {
      _logger.debug('Récupération countries ID: $id');

      final response = await _apiClient.get(
        'countries/$id',
        queryParameters: {
          'output_format': 'JSON',
          'display': 'full', // Récupère toutes les données
        },
      );

      if (!response.success) {
        if (response.statusCode == 404) {
          _logger.debug('CountryModel $id non trouvé');
          return null;
        }
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      final item = _parseSingleApiResponse(response.data);
      _logger.info('CountryModel $id récupéré');
      return item;
    } catch (e, stackTrace) {
      _logger.error('Erreur récupération CountryModel $id', e, stackTrace);
      rethrow;
    }
  }

  /// Crée un nouveau CountryModel
  Future<CountryModel> create(CountryModel model) async {
    try {
      _logger.debug('Création CountryModel');

      final response = await _apiClient.post(
        'countries',
        data: {'country': model.toJson()},
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

      _logger.info('CountryModel créé avec ID: ${created?.id ?? "unknown"}');
      return created!;
    } catch (e, stackTrace) {
      _logger.error('Erreur création CountryModel', e, stackTrace);
      rethrow;
    }
  }

  /// Met à jour un CountryModel
  Future<CountryModel> update(String id, CountryModel model) async {
    try {
      _logger.debug('Mise à jour CountryModel ID: $id');

      final response = await _apiClient.put(
        'countries',
        id,
        data: {'country': model.toJson()},
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

      _logger.info('CountryModel $id mis à jour');
      return updated!;
    } catch (e, stackTrace) {
      _logger.error('Erreur mise à jour CountryModel $id', e, stackTrace);
      rethrow;
    }
  }

  /// Supprime un CountryModel
  Future<bool> delete(String id) async {
    try {
      _logger.debug('Suppression CountryModel ID: $id');

      final response = await _apiClient.delete('countries', id);

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      // Invalider le cache
      await _invalidateCache();

      _logger.info('CountryModel $id supprimé');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Erreur suppression CountryModel $id', e, stackTrace);
      return false;
    }
  }

  /// Parse la réponse API pour une liste
  List<CountryModel> _parseApiResponse(dynamic data) {
    final items = <CountryModel>[];

    if (data is Map<String, dynamic>) {
      // PrestaShop retourne {resource: [...]}
      final list = data['countries'] ?? data['countrys'] ?? [];

      if (list is List) {
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            try {
              items.add(CountryModel.fromJson(item));
            } catch (e) {
              _logger.warning('Erreur parsing item countries: $e');
            }
          }
        }
      }
    }

    return items;
  }

  /// Parse la réponse API pour un seul item
  CountryModel? _parseSingleApiResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Extraire l'objet principal
      final itemData = data['country'] ?? data;

      if (itemData is Map<String, dynamic>) {
        try {
          return CountryModel.fromJson(itemData);
        } catch (e) {
          _logger.error('Erreur parsing CountryModel: $e');
        }
      }
    }

    return null;
  }

  /// Récupère les données du cache
  Future<List<CountryModel>> _getCachedData() async {
    try {
      if (_cacheService == null) return [];

      final cached = await _cacheService!.get<List<dynamic>>(
        _countriesCacheKey,
      );
      if (cached != null) {
        return cached
            .map((item) => CountryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _logger.warning('Erreur lecture cache countries: $e');
    }

    return [];
  }

  /// Met en cache les données
  Future<void> _cacheData(List<CountryModel> items) async {
    try {
      if (_cacheService == null) return;

      final jsonList = items.map((item) => item.toJson()).toList();
      await _cacheService!.set(
        _countriesCacheKey,
        jsonList,
        ttl: const Duration(hours: 1), // Cache 1h pour les configs
      );
    } catch (e) {
      _logger.warning('Erreur mise en cache countries: $e');
    }
  }

  /// Invalide le cache
  Future<void> _invalidateCache() async {
    try {
      if (_cacheService == null) return;

      await _cacheService!.delete(_countriesCacheKey);
      _logger.debug('Cache countries invalidé');
    } catch (e) {
      _logger.warning('Erreur invalidation cache countries: $e');
    }
  }

  /// Rafraîchit les données (force un appel API)
  Future<List<CountryModel>> refresh() async {
    await _invalidateCache();
    return getAll(useCache: false);
  }
}
