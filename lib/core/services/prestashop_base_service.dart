// Service de base amélioré pour l'API PrestaShop - Phase 4
// Intègre la configuration, gestion d'erreurs, cache intelligent et retry automatique

import 'package:koutonou/core/api/prestashop_http_client.dart';
import 'package:koutonou/core/api/prestashop_exceptions.dart';
import 'package:koutonou/core/cache/prestashop_cache_service.dart';
import 'package:koutonou/core/utils/logger.dart';

/// Service de base pour les ressources PrestaShop
abstract class PrestaShopBaseService<T> {
  /// Nom de la ressource (ex: 'products', 'customers')
  String get resourceName;

  /// Client HTTP partagé
  final PrestaShopHttpClient _httpClient;

  /// Service de cache partagé
  final PrestaShopCacheService _cacheService;

  /// Logger partagé
  final AppLogger _logger;

  PrestaShopBaseService({
    PrestaShopHttpClient? httpClient,
    PrestaShopCacheService? cacheService,
  }) : _httpClient = httpClient ?? PrestaShopApiClient.instance,
       _cacheService = cacheService ?? PrestaShopCacheService(),
       _logger = AppLogger();

  /// Désérialise un objet depuis JSON
  T fromJson(Map<String, dynamic> json);

  /// Sérialise un objet vers JSON
  Map<String, dynamic> toJson(T item);

  /// Récupère tous les éléments
  Future<List<T>> getAll({
    int? limit,
    int? offset,
    Map<String, String>? filters,
    bool useCache = true,
  }) async {
    return await PrestaShopErrorHandler.handleWithRetry(
      () async {
        _logger.debug('Récupération de tous les $resourceName');

        // Vérifier le cache d'abord si activé
        if (useCache) {
          final cached = await _cacheService.getList<T>(resourceName);
          if (cached != null) {
            _logger.debug(
              'Cache hit pour $resourceName (${cached.length} éléments)',
            );
            return cached;
          }
        }

        final queryParams = <String, String>{};

        if (limit != null) {
          queryParams['limit'] = limit.toString();
        }
        if (offset != null) {
          queryParams['display'] = 'full';
          queryParams['limit'] = '$offset,${limit ?? 50}';
        }
        if (filters != null) {
          queryParams.addAll(filters);
        }

        final response = await _httpClient.get(
          resourceName,
          queryParams: queryParams,
        );

        final result = _parseListResponse(response);

        // Mettre en cache le résultat
        if (useCache && result.isNotEmpty) {
          await _cacheService.cacheList(resourceName, result);
        }

        return result;
      },
      onError: (error) => _logger.error('Erreur getAll $resourceName: $error'),
      onRetry: (attempt, error) => _logger.warning(
        'Retry $attempt pour getAll $resourceName: ${error.message}',
      ),
    );
  }

  /// Récupère un élément par ID
  Future<T?> getById(int id, {bool useCache = true}) async {
    return await PrestaShopErrorHandler.handleWithRetry(
      () async {
        _logger.debug('Récupération $resourceName ID: $id');

        // Vérifier le cache d'abord si activé
        if (useCache) {
          final cached = await _cacheService.getItem<T>(
            resourceName,
            id.toString(),
          );
          if (cached != null) {
            _logger.debug('Cache hit pour $resourceName/$id');
            return cached;
          }
        }

        final response = await _httpClient.get(
          '$resourceName/$id',
          queryParams: {'display': 'full'},
        );

        final result = _parseSingleResponse(response);

        // Mettre en cache le résultat
        if (useCache && result != null) {
          await _cacheService.cacheItem(resourceName, id.toString(), result);
        }

        return result;
      },
      onError: (error) {
        if (error.type == PrestaShopErrorType.notFound) {
          _logger.warning('$resourceName ID $id non trouvé');
          return; // Ne pas logger comme erreur
        }
        _logger.error('Erreur getById $resourceName $id: $error');
      },
      onRetry: (attempt, error) => _logger.warning(
        'Retry $attempt pour getById $resourceName $id: ${error.message}',
      ),
    );
  }

  /// Crée un nouvel élément
  Future<T> create(T item) async {
    return await PrestaShopErrorHandler.handleWithRetry(
      () async {
        _logger.debug('Création d\'un nouveau $resourceName');

        final itemJson = toJson(item);
        final requestBody = {
          resourceName.substring(0, resourceName.length - 1):
              itemJson, // Remove 's'
        };

        final response = await _httpClient.post(
          resourceName,
          body: requestBody,
        );

        final created = _parseSingleResponse(response);
        if (created == null) {
          throw PrestaShopException(
            type: PrestaShopErrorType.parsing,
            message: 'Réponse de création invalide pour $resourceName',
          );
        }

        // Invalider le cache après création
        await _cacheService.invalidateOnMutation(resourceName);

        _logger.info('$resourceName créé avec succès');
        return created;
      },
      onError: (error) => _logger.error('Erreur create $resourceName: $error'),
      onRetry: (attempt, error) => _logger.warning(
        'Retry $attempt pour create $resourceName: ${error.message}',
      ),
    );
  }

  /// Met à jour un élément existant
  Future<T> update(int id, T item) async {
    return await PrestaShopErrorHandler.handleWithRetry(
      () async {
        _logger.debug('Mise à jour $resourceName ID: $id');

        final itemJson = toJson(item);
        final requestBody = {
          resourceName.substring(0, resourceName.length - 1): itemJson,
        };

        final response = await _httpClient.put(
          '$resourceName/$id',
          body: requestBody,
        );

        final updated = _parseSingleResponse(response);
        if (updated == null) {
          throw PrestaShopException(
            type: PrestaShopErrorType.parsing,
            message: 'Réponse de mise à jour invalide pour $resourceName',
          );
        }

        // Invalider le cache après mise à jour
        await _cacheService.invalidateOnMutation(
          resourceName,
          id: id.toString(),
        );

        _logger.info('$resourceName ID $id mis à jour avec succès');
        return updated;
      },
      onError: (error) =>
          _logger.error('Erreur update $resourceName $id: $error'),
      onRetry: (attempt, error) => _logger.warning(
        'Retry $attempt pour update $resourceName $id: ${error.message}',
      ),
    );
  }

  /// Supprime un élément
  Future<bool> delete(int id) async {
    return await PrestaShopErrorHandler.handleWithRetry(
      () async {
        _logger.debug('Suppression $resourceName ID: $id');

        await _httpClient.delete('$resourceName/$id');

        // Invalider le cache après suppression
        await _cacheService.invalidateOnMutation(
          resourceName,
          id: id.toString(),
        );

        _logger.info('$resourceName ID $id supprimé avec succès');
        return true;
      },
      onError: (error) =>
          _logger.error('Erreur delete $resourceName $id: $error'),
      onRetry: (attempt, error) => _logger.warning(
        'Retry $attempt pour delete $resourceName $id: ${error.message}',
      ),
    );
  }

  /// Recherche avec filtres avancés
  Future<List<T>> search({
    String? query,
    Map<String, String>? filters,
    int? limit,
    int? offset,
    String? sortBy,
    String? sortOrder,
  }) async {
    return await PrestaShopErrorHandler.handleWithRetry(
      () async {
        _logger.debug('Recherche dans $resourceName avec query: $query');

        final queryParams = <String, String>{'display': 'full'};

        if (query != null && query.isNotEmpty) {
          queryParams['filter[name]'] = '%$query%';
        }

        if (filters != null) {
          filters.forEach((key, value) {
            queryParams['filter[$key]'] = value;
          });
        }

        if (limit != null) {
          final start = offset ?? 0;
          queryParams['limit'] = '$start,$limit';
        }

        if (sortBy != null) {
          queryParams['sort'] = '[${sortBy}_${sortOrder ?? 'ASC'}]';
        }

        final response = await _httpClient.get(
          resourceName,
          queryParams: queryParams,
        );

        return _parseListResponse(response);
      },
      onError: (error) => _logger.error('Erreur search $resourceName: $error'),
      onRetry: (attempt, error) => _logger.warning(
        'Retry $attempt pour search $resourceName: ${error.message}',
      ),
    );
  }

  /// Parse une réponse contenant une liste d'éléments
  List<T> _parseListResponse(Map<String, dynamic> response) {
    try {
      // PrestaShop retourne les données dans une structure spécifique
      final resourceKey = resourceName;

      if (response.containsKey(resourceKey)) {
        final data = response[resourceKey];

        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((item) => fromJson(item))
              .toList();
        } else if (data is Map<String, dynamic>) {
          // Un seul élément retourné comme objet
          return [fromJson(data)];
        }
      }

      // Essayer de parser directement si la structure est différente
      if (response is List) {
        return (response as List)
            .whereType<Map<String, dynamic>>()
            .map((item) => fromJson(item))
            .toList();
      }

      _logger.warning(
        'Structure de réponse inattendue pour $resourceName: ${response.keys}',
      );
      return [];
    } catch (e) {
      throw PrestaShopException.parsing(
        'Erreur de parsing de la liste $resourceName: $e',
        originalException: e,
      );
    }
  }

  /// Parse une réponse contenant un seul élément
  T? _parseSingleResponse(Map<String, dynamic> response) {
    try {
      final resourceKey = resourceName.substring(
        0,
        resourceName.length - 1,
      ); // Remove 's'

      if (response.containsKey(resourceKey)) {
        final data = response[resourceKey];
        if (data is Map<String, dynamic>) {
          return fromJson(data);
        }
      }

      // Essayer les clés alternatives
      final alternativeKeys = [resourceName, resourceKey, 'data'];
      for (final key in alternativeKeys) {
        if (response.containsKey(key)) {
          final data = response[key];
          if (data is Map<String, dynamic>) {
            return fromJson(data);
          }
        }
      }

      // Essayer de parser directement la réponse
      return fromJson(response);
    } catch (e) {
      throw PrestaShopException.parsing(
        'Erreur de parsing de l\'élément $resourceName: $e',
        originalException: e,
      );
    }
  }

  /// Dispose des ressources
  void dispose() {
    // Override si nécessaire dans les classes filles
  }
}
