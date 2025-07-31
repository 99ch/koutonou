// Générateur de services basés sur les modèles générés
// Phase 1 MVP : Services CRUD basiques avec cache et gestion d'erreurs
// Intégration avec ApiClient existant

import 'dart:io';

/// Générateur de services
class ServiceGenerator {
  static const String _outputBaseDir = 'lib/modules';

  /// Mapping des ressources vers leurs modules
  static const Map<String, String> _resourceToModule = {
    'languages': 'configs',
    'currencies': 'configs',
    'countries': 'configs',
  };

  /// Génère tous les services MVP
  static Future<void> generateMvpServices() async {
    print('🛠️  Début de la génération des services MVP');

    for (final resourceName in _resourceToModule.keys) {
      try {
        print('📝 Génération du service pour: $resourceName');
        await _generateServiceForResource(resourceName);
        print('✅ Service généré pour $resourceName');
      } catch (e, stackTrace) {
        print('❌ Erreur génération service $resourceName: $e');
        print('Stack: $stackTrace');
      }
    }

    print('✅ Génération des services MVP terminée');
  }

  /// Génère un service pour une ressource
  static Future<void> _generateServiceForResource(String resourceName) async {
    final className = _generateServiceClassName(resourceName);
    final modelName = _generateModelClassName(resourceName);
    final dartCode = _generateServiceCode(resourceName, className, modelName);

    await _writeServiceFile(resourceName, className, dartCode);
  }

  /// Génère le nom de classe du service
  static String _generateServiceClassName(String resourceName) {
    final singular = _getSingularName(resourceName);
    return '${_capitalize(singular)}Service';
  }

  /// Génère le nom de classe du modèle
  static String _generateModelClassName(String resourceName) {
    final singular = _getSingularName(resourceName);
    return '${_capitalize(singular)}Model';
  }

  /// Convertit au singulier
  static String _getSingularName(String resource) {
    switch (resource) {
      case 'languages':
        return 'language';
      case 'currencies':
        return 'currency';
      case 'countries':
        return 'country';
      default:
        return resource.endsWith('s')
            ? resource.substring(0, resource.length - 1)
            : resource;
    }
  }

  /// Capitalise
  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Génère le code du service
  static String _generateServiceCode(
    String resourceName,
    String className,
    String modelName,
  ) {
    final imports = _generateServiceImports(resourceName, modelName);
    final classContent = _generateServiceClass(
      resourceName,
      className,
      modelName,
    );

    return '''$imports

$classContent''';
  }

  /// Génère les imports du service
  static String _generateServiceImports(String resourceName, String modelName) {
    final moduleName = _resourceToModule[resourceName];
    final modelFileName = modelName.toLowerCase();

    return '''// Service généré automatiquement pour PrestaShop
// Phase 1 MVP - CRUD basique avec cache et gestion d'erreurs
// Intégration avec l'ApiClient existant

import 'package:koutonou/core/api/api_client.dart';
import 'package:koutonou/core/models/base_response.dart';
import 'package:koutonou/core/services/cache_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import 'package:koutonou/core/exceptions/api_exception.dart';
import 'package:koutonou/modules/$moduleName/models/$modelFileName.dart';''';
  }

  /// Génère la classe du service
  static String _generateServiceClass(
    String resourceName,
    String className,
    String modelName,
  ) {
    final cacheKey = '_${resourceName}CacheKey';
    final resourceEndpoint = resourceName;

    return '''
/// Service pour la gestion des $resourceName
class $className {
  static final $className _instance = $className._internal();
  factory $className() => _instance;
  $className._internal();

  final ApiClient _apiClient = ApiClient();
  final CacheService _cacheService = CacheService();
  static final AppLogger _logger = AppLogger();

  /// Clé de cache pour les $resourceName
  static const String $cacheKey = '${resourceName}_cache';

  /// Récupère tous les $resourceName
  Future<List<$modelName>> getAll({
    Map<String, dynamic>? filters,
    bool useCache = true,
  }) async {
    try {
      _logger.debug('Récupération des $resourceName (cache: \$useCache)');

      // Vérifier le cache d'abord
      if (useCache) {
        final cached = await _getCachedData();
        if (cached.isNotEmpty) {
          _logger.debug('$resourceName trouvés dans le cache: \${cached.length}');
          return cached;
        }
      }

      // Appel API
      final response = await _apiClient.get(
        '$resourceEndpoint',
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
      
      // Mettre en cache
      if (useCache) {
        await _cacheData(items);
      }

      _logger.info('$resourceName récupérés: \${items.length}');
      return items;
    } catch (e, stackTrace) {
      _logger.error('Erreur récupération $resourceName', e, stackTrace);
      rethrow;
    }
  }

  /// Récupère un $modelName par son ID
  Future<$modelName?> getById(String id) async {
    try {
      _logger.debug('Récupération $resourceName ID: \$id');

      final response = await _apiClient.get(
        '$resourceEndpoint/\$id',
        queryParameters: {'output_format': 'JSON'},
      );

      if (!response.success) {
        if (response.statusCode == 404) {
          _logger.debug('$modelName \$id non trouvé');
          return null;
        }
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      final item = _parseSingleApiResponse(response.data);
      _logger.info('$modelName \$id récupéré');
      return item;
    } catch (e, stackTrace) {
      _logger.error('Erreur récupération $modelName \$id', e, stackTrace);
      rethrow;
    }
  }

  /// Crée un nouveau $modelName
  Future<$modelName> create($modelName model) async {
    try {
      _logger.debug('Création $modelName');

      final response = await _apiClient.post(
        '$resourceEndpoint',
        data: {
          '${_getSingularName(resourceName)}': model.toJson(),
        },
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
      
      _logger.info('$modelName créé avec ID: \${created?.id ?? "unknown"}');
      return created!;
    } catch (e, stackTrace) {
      _logger.error('Erreur création $modelName', e, stackTrace);
      rethrow;
    }
  }

  /// Met à jour un $modelName
  Future<$modelName> update(String id, $modelName model) async {
    try {
      _logger.debug('Mise à jour $modelName ID: \$id');

      final response = await _apiClient.put(
        '$resourceEndpoint/\$id',
        data: {
          '${_getSingularName(resourceName)}': model.toJson(),
        },
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
      
      _logger.info('$modelName \$id mis à jour');
      return updated!;
    } catch (e, stackTrace) {
      _logger.error('Erreur mise à jour $modelName \$id', e, stackTrace);
      rethrow;
    }
  }

  /// Supprime un $modelName
  Future<bool> delete(String id) async {
    try {
      _logger.debug('Suppression $modelName ID: \$id');

      final response = await _apiClient.delete('$resourceEndpoint/\$id');

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      // Invalider le cache
      await _invalidateCache();
      
      _logger.info('$modelName \$id supprimé');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Erreur suppression $modelName \$id', e, stackTrace);
      return false;
    }
  }

  /// Parse la réponse API pour une liste
  List<$modelName> _parseApiResponse(dynamic data) {
    final items = <$modelName>[];
    
    if (data is Map<String, dynamic>) {
      // PrestaShop retourne {resource: [...]}
      final list = data['$resourceName'] ?? data['${_getSingularName(resourceName)}s'] ?? [];
      
      if (list is List) {
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            try {
              items.add($modelName.fromJson(item));
            } catch (e) {
              _logger.warning('Erreur parsing item $resourceName: \$e');
            }
          }
        }
      }
    }
    
    return items;
  }

  /// Parse la réponse API pour un seul item
  $modelName? _parseSingleApiResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Extraire l'objet principal
      final itemData = data['${_getSingularName(resourceName)}'] ?? data;
      
      if (itemData is Map<String, dynamic>) {
        try {
          return $modelName.fromJson(itemData);
        } catch (e) {
          _logger.error('Erreur parsing $modelName: \$e');
        }
      }
    }
    
    return null;
  }

  /// Récupère les données du cache
  Future<List<$modelName>> _getCachedData() async {
    try {
      final cached = await _cacheService.get<List<dynamic>>($cacheKey);
      if (cached != null) {
        return cached
            .map((item) => $modelName.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _logger.warning('Erreur lecture cache $resourceName: \$e');
    }
    
    return [];
  }

  /// Met en cache les données
  Future<void> _cacheData(List<$modelName> items) async {
    try {
      final jsonList = items.map((item) => item.toJson()).toList();
      await _cacheService.set(
        $cacheKey,
        jsonList,
        ttl: const Duration(hours: 1), // Cache 1h pour les configs
      );
    } catch (e) {
      _logger.warning('Erreur mise en cache $resourceName: \$e');
    }
  }

  /// Invalide le cache
  Future<void> _invalidateCache() async {
    try {
      await _cacheService.delete($cacheKey);
      _logger.debug('Cache $resourceName invalidé');
    } catch (e) {
      _logger.warning('Erreur invalidation cache $resourceName: \$e');
    }
  }

  /// Rafraîchit les données (force un appel API)
  Future<List<$modelName>> refresh() async {
    await _invalidateCache();
    return getAll(useCache: false);
  }
}''';
  }

  /// Écrit le fichier service
  static Future<void> _writeServiceFile(
    String resourceName,
    String className,
    String dartCode,
  ) async {
    final moduleName = _resourceToModule[resourceName];
    if (moduleName == null) {
      throw Exception('Module non trouvé pour $resourceName');
    }

    final fileName = '${className.toLowerCase()}.dart';
    final dirPath = '$_outputBaseDir/$moduleName/services';
    final filePath = '$dirPath/$fileName';

    // Créer le dossier si nécessaire
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Écrire le fichier
    final file = File(filePath);
    await file.writeAsString(dartCode);

    print('📄 Service créé: $filePath');
  }
}
