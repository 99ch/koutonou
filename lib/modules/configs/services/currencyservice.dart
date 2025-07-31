// Service généré automatiquement pour PrestaShop
// Phase 1 MVP - CRUD basique avec cache et gestion d'erreurs
// Intégration avec l'ApiClient existant

import 'package:koutonou/core/api/api_client.dart';
import 'package:koutonou/core/exceptions/api_exception.dart';
import 'package:koutonou/core/services/cache_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import 'package:koutonou/modules/configs/models/currencymodel.dart';

/// Service pour la gestion des currencies
class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  final ApiClient _apiClient = ApiClient();
  CacheService? _cacheService;
  static final AppLogger _logger = AppLogger();
  bool _cacheInitialized = false;

  /// Clé de cache pour les currencies
  static const String _currenciesCacheKey = 'currencies_cache';

  /// Initialise le cache de manière paresseuse
  Future<void> _ensureCacheInitialized() async {
    if (_cacheInitialized) return;

    try {
      _cacheService = CacheService();
      await _cacheService!.initialize();
      _cacheInitialized = true;
      _logger.debug('Cache initialisé pour CurrencyService');
    } catch (e) {
      _logger.warning('Cache non disponible pour CurrencyService: $e');
      _cacheService = null;
      _cacheInitialized = true; // Marquer comme "initialisé" même en échec
    }
  }

  /// Récupère tous les currencies
  Future<List<CurrencyModel>> getAll({
    Map<String, dynamic>? filters,
    bool useCache = true,
  }) async {
    try {
      _logger.debug('Récupération des currencies (cache: $useCache)');

      // Initialiser le cache si nécessaire
      await _ensureCacheInitialized();

      // Vérifier le cache d'abord (seulement si cache disponible)
      if (useCache && _cacheService != null) {
        final cached = await _getCachedData();
        if (cached.isNotEmpty) {
          _logger.debug('currencies trouvés dans le cache: ${cached.length}');
          return cached;
        }
      }

      // Appel API
      final response = await _apiClient.get(
        'currencies',
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

      // Mettre en cache (seulement si cache disponible)
      if (useCache && _cacheService != null) {
        await _cacheData(items);
      }

      _logger.info('currencies récupérés: ${items.length}');
      return items;
    } catch (e, stackTrace) {
      _logger.error('Erreur récupération currencies', e, stackTrace);
      rethrow;
    }
  }

  /// Récupère un CurrencyModel par son ID
  Future<CurrencyModel?> getById(String id) async {
    try {
      _logger.debug('Récupération currencies ID: $id');

      final response = await _apiClient.get(
        'currencies/$id',
        queryParameters: {
          'output_format': 'JSON',
          'display': 'full', // Récupère toutes les données
        },
      );

      if (!response.success) {
        if (response.statusCode == 404) {
          _logger.debug('CurrencyModel $id non trouvé');
          return null;
        }
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      final item = _parseSingleApiResponse(response.data);
      _logger.info('CurrencyModel $id récupéré');
      return item;
    } catch (e, stackTrace) {
      _logger.error('Erreur récupération CurrencyModel $id', e, stackTrace);
      rethrow;
    }
  }

  /// Crée un nouveau CurrencyModel
  Future<CurrencyModel> create(CurrencyModel model) async {
    try {
      _logger.debug('Création CurrencyModel');

      final response = await _apiClient.post(
        'currencies',
        data: {'currency': model.toJson()},
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

      _logger.info('CurrencyModel créé avec ID: ${created?.id ?? "unknown"}');
      return created!;
    } catch (e, stackTrace) {
      _logger.error('Erreur création CurrencyModel', e, stackTrace);
      rethrow;
    }
  }

  /// Met à jour un CurrencyModel
  Future<CurrencyModel> update(String id, CurrencyModel model) async {
    try {
      _logger.debug('Mise à jour CurrencyModel ID: $id');

      final response = await _apiClient.put(
        'currencies',
        id,
        data: {'currency': model.toJson()},
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

      _logger.info('CurrencyModel $id mis à jour');
      return updated!;
    } catch (e, stackTrace) {
      _logger.error('Erreur mise à jour CurrencyModel $id', e, stackTrace);
      rethrow;
    }
  }

  /// Supprime un CurrencyModel
  Future<bool> delete(String id) async {
    try {
      _logger.debug('Suppression CurrencyModel ID: $id');

      final response = await _apiClient.delete('currencies', id);

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      // Invalider le cache
      await _invalidateCache();

      _logger.info('CurrencyModel $id supprimé');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Erreur suppression CurrencyModel $id', e, stackTrace);
      return false;
    }
  }

  /// Parse la réponse API pour une liste
  List<CurrencyModel> _parseApiResponse(dynamic data) {
    final items = <CurrencyModel>[];

    if (data is Map<String, dynamic>) {
      // PrestaShop retourne {resource: [...]}
      final list = data['currencies'] ?? data['currencys'] ?? [];

      if (list is List) {
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            try {
              items.add(CurrencyModel.fromJson(item));
            } catch (e) {
              _logger.warning('Erreur parsing item currencies: $e');
            }
          }
        }
      }
    }

    return items;
  }

  /// Parse la réponse API pour un seul item
  CurrencyModel? _parseSingleApiResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Extraire l'objet principal
      final itemData = data['currency'] ?? data;

      if (itemData is Map<String, dynamic>) {
        try {
          return CurrencyModel.fromJson(itemData);
        } catch (e) {
          _logger.error('Erreur parsing CurrencyModel: $e');
        }
      }
    }

    return null;
  }

  /// Récupère les données du cache
  Future<List<CurrencyModel>> _getCachedData() async {
    try {
      if (_cacheService == null) return [];

      final cached = await _cacheService!.get<List<dynamic>>(
        _currenciesCacheKey,
      );
      if (cached != null) {
        return cached
            .map((item) => CurrencyModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _logger.warning('Erreur lecture cache currencies: $e');
    }

    return [];
  }

  /// Met en cache les données
  Future<void> _cacheData(List<CurrencyModel> items) async {
    try {
      if (_cacheService == null) return;

      final jsonList = items.map((item) => item.toJson()).toList();
      await _cacheService!.set(
        _currenciesCacheKey,
        jsonList,
        ttl: const Duration(hours: 1), // Cache 1h pour les configs
      );
    } catch (e) {
      _logger.warning('Erreur mise en cache currencies: $e');
    }
  }

  /// Invalide le cache
  Future<void> _invalidateCache() async {
    try {
      if (_cacheService == null) return;

      await _cacheService!.delete(_currenciesCacheKey);
      _logger.debug('Cache currencies invalidé');
    } catch (e) {
      _logger.warning('Erreur invalidation cache currencies: $e');
    }
  }

  /// Rafraîchit les données (force un appel API)
  Future<List<CurrencyModel>> refresh() async {
    await _invalidateCache();
    return getAll(useCache: false);
  }
}
