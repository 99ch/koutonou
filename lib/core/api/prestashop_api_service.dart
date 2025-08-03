import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';
import 'prestashop_api_client.dart';
import 'prestashop_api_config.dart';
import 'prestashop_api_endpoints.dart';
import 'prestashop_xml_parser.dart';
import '../exceptions/prestashop_api_exception.dart';

/// Service principal pour l'API PrestaShop
/// 
/// Cette classe fournit une interface haut niveau pour interagir
/// avec l'API PrestaShop de manière type-safe et efficace.
class PrestashopApiService extends ChangeNotifier {
  final PrestashopApiClient _client;
  final Map<String, dynamic> _cache = {};
  bool _isInitialized = false;
  
  PrestashopApiService({
    PrestashopApiClient? client,
  }) : _client = client ?? PrestashopApiClient();

  /// Vérifier si le service est initialisé
  bool get isInitialized => _isInitialized;

  /// Initialiser le service avec la configuration
  Future<void> initialize(PrestashopApiConfig config) async {
    try {
      PrestashopConfig.initialize(config);
      
      // Test de connectivité
      await testConnection();
      
      _isInitialized = true;
      notifyListeners();
      
      if (config.debugMode) {
        print('✅ [PrestaShop API] Service initialized successfully');
      }
    } catch (e) {
      _isInitialized = false;
      
      if (config.debugMode) {
        print('❌ [PrestaShop API] Failed to initialize: $e');
      }
      
      rethrow;
    }
  }

  /// Tester la connexion à l'API
  Future<bool> testConnection() async {
    try {
      // Tenter de récupérer les configurations (endpoint minimal)
      final response = await _client.getList(
        PrestashopApiEndpoints.configurations,
        limit: 1,
      );
      
      return response.rootElement.localName == 'prestashop';
    } catch (e) {
      throw PrestashopApiException(
        'Failed to connect to PrestaShop API: $e',
        originalException: e,
      );
    }
  }

  // ==================== MÉTHODES GÉNÉRIQUES CRUD ====================

  /// Récupérer une liste d'objets
  Future<PrestashopApiResponse<List<Map<String, dynamic>>>> getList(
    String resource, {
    Map<String, dynamic>? filters,
    String? searchTerm,
    String? sortBy,
    String? sortOrder = 'ASC',
    int? limit = 20,
    int? offset = 0,
    bool useCache = true,
  }) async {
    _ensureInitialized();
    
    // Construire la clé de cache
    final cacheKey = _buildCacheKey('list', resource, {
      'filters': filters,
      'search': searchTerm,
      'sort': sortBy,
      'order': sortOrder,
      'limit': limit,
      'offset': offset,
    });
    
    // Vérifier le cache
    if (useCache && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as PrestashopApiResponse<List<Map<String, dynamic>>>;
    }
    
    try {
      XmlDocument xmlResponse;
      
      if (filters != null || searchTerm != null) {
        xmlResponse = await _client.search(
          resource,
          filters: filters,
          searchTerm: searchTerm,
          sortBy: sortBy,
          sortOrder: sortOrder,
          limit: limit,
          offset: offset,
        );
      } else {
        xmlResponse = await _client.getList(
          resource,
          limit: limit,
          offset: offset,
        );
      }
      
      final data = PrestashopXmlParser.parseList(xmlResponse, resource);
      final meta = PrestashopXmlParser.parsePaginationMeta(xmlResponse);
      
      final response = PrestashopApiResponse<List<Map<String, dynamic>>>(
        data: data,
        meta: meta,
        originalDocument: xmlResponse,
      );
      
      // Mettre en cache
      if (useCache) {
        _cache[cacheKey] = response;
      }
      
      return response;
    } catch (e) {
      if (e is PrestashopApiException) rethrow;
      throw PrestashopApiException(
        'Failed to get $resource list: $e',
        originalException: e,
      );
    }
  }

  /// Récupérer un objet par ID
  Future<PrestashopApiResponse<Map<String, dynamic>>> getById(
    String resource,
    int id, {
    bool useCache = true,
  }) async {
    _ensureInitialized();
    
    final cacheKey = _buildCacheKey('object', resource, {'id': id});
    
    // Vérifier le cache
    if (useCache && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as PrestashopApiResponse<Map<String, dynamic>>;
    }
    
    try {
      final xmlResponse = await _client.getById(resource, id);
      final data = PrestashopXmlParser.parseObject(xmlResponse, resource);
      
      final response = PrestashopApiResponse<Map<String, dynamic>>(
        data: data,
        originalDocument: xmlResponse,
      );
      
      // Mettre en cache
      if (useCache) {
        _cache[cacheKey] = response;
      }
      
      return response;
    } catch (e) {
      if (e is PrestashopApiException) rethrow;
      throw PrestashopApiException(
        'Failed to get $resource with ID $id: $e',
        originalException: e,
      );
    }
  }

  /// Créer un nouvel objet
  Future<PrestashopApiResponse<Map<String, dynamic>>> create(
    String resource,
    Map<String, dynamic> data,
  ) async {
    _ensureInitialized();
    
    try {
      final xmlDocument = PrestashopXmlParser.createRequestDocument(resource, data);
      final xmlResponse = await _client.create(resource, xmlDocument);
      final responseData = PrestashopXmlParser.parseObject(xmlResponse, resource);
      
      // Invalider le cache pour ce resource
      _invalidateCache(resource);
      
      notifyListeners();
      
      return PrestashopApiResponse<Map<String, dynamic>>(
        data: responseData,
        originalDocument: xmlResponse,
      );
    } catch (e) {
      if (e is PrestashopApiException) rethrow;
      throw PrestashopApiException(
        'Failed to create $resource: $e',
        originalException: e,
      );
    }
  }

  /// Mettre à jour un objet
  Future<PrestashopApiResponse<Map<String, dynamic>>> update(
    String resource,
    int id,
    Map<String, dynamic> data,
  ) async {
    _ensureInitialized();
    
    try {
      final xmlDocument = PrestashopXmlParser.createRequestDocument(resource, data);
      final xmlResponse = await _client.update(resource, id, xmlDocument);
      final responseData = PrestashopXmlParser.parseObject(xmlResponse, resource);
      
      // Invalider le cache pour ce resource
      _invalidateCache(resource);
      
      notifyListeners();
      
      return PrestashopApiResponse<Map<String, dynamic>>(
        data: responseData,
        originalDocument: xmlResponse,
      );
    } catch (e) {
      if (e is PrestashopApiException) rethrow;
      throw PrestashopApiException(
        'Failed to update $resource with ID $id: $e',
        originalException: e,
      );
    }
  }

  /// Supprimer un objet
  Future<bool> delete(String resource, int id) async {
    _ensureInitialized();
    
    try {
      final success = await _client.delete(resource, id);
      
      if (success) {
        // Invalider le cache pour ce resource
        _invalidateCache(resource);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      if (e is PrestashopApiException) rethrow;
      throw PrestashopApiException(
        'Failed to delete $resource with ID $id: $e',
        originalException: e,
      );
    }
  }

  // ==================== MÉTHODES SPÉCIALISÉES ====================

  /// Recherche avancée avec plusieurs critères
  Future<PrestashopApiResponse<List<Map<String, dynamic>>>> advancedSearch({
    required String resource,
    String? query,
    Map<String, dynamic>? filters,
    List<String>? fields,
    String? sortBy,
    String? sortOrder = 'ASC',
    int page = 1,
    int itemsPerPage = 20,
  }) async {
    final offset = (page - 1) * itemsPerPage;
    
    return getList(
      resource,
      filters: filters,
      searchTerm: query,
      sortBy: sortBy,
      sortOrder: sortOrder,
      limit: itemsPerPage,
      offset: offset,
    );
  }

  /// Récupérer l'image d'un produit
  Future<List<int>> getProductImage(int productId, int imageId) async {
    _ensureInitialized();
    
    try {
      return await _client.getProductImage(productId, imageId);
    } catch (e) {
      if (e is PrestashopApiException) rethrow;
      throw PrestashopApiException(
        'Failed to get product image: $e',
        originalException: e,
      );
    }
  }

  /// Obtenir les options d'un resource (schema)
  Future<Map<String, dynamic>> getResourceSchema(String resource) async {
    _ensureInitialized();
    
    try {
      final xmlResponse = await _client.getResourceOptions(resource);
      return PrestashopXmlParser.parseObject(xmlResponse, 'schema');
    } catch (e) {
      if (e is PrestashopApiException) rethrow;
      throw PrestashopApiException(
        'Failed to get $resource schema: $e',
        originalException: e,
      );
    }
  }

  // ==================== GESTION DU CACHE ====================

  /// Vider tout le cache
  void clearCache() {
    _cache.clear();
    notifyListeners();
  }

  /// Vider le cache pour un resource spécifique
  void clearCacheFor(String resource) {
    _invalidateCache(resource);
    notifyListeners();
  }

  /// Obtenir la taille du cache
  int get cacheSize => _cache.length;

  /// Obtenir les statistiques du cache
  Map<String, dynamic> getCacheStats() {
    final stats = <String, int>{};
    
    for (final key in _cache.keys) {
      final resource = key.split(':')[1];
      stats[resource] = (stats[resource] ?? 0) + 1;
    }
    
    return {
      'totalEntries': _cache.length,
      'byResource': stats,
    };
  }

  // ==================== MÉTHODES PRIVÉES ====================

  /// Vérifier que le service est initialisé
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('PrestashopApiService not initialized. Call initialize() first.');
    }
  }

  /// Construire une clé de cache
  String _buildCacheKey(String type, String resource, Map<String, dynamic> params) {
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    final paramsString = jsonEncode(sortedParams);
    return '$type:$resource:${paramsString.hashCode}';
  }

  /// Invalider le cache pour un resource
  void _invalidateCache(String resource) {
    final keysToRemove = _cache.keys
        .where((key) => key.contains(':$resource:'))
        .toList();
    
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  /// Nettoyer les ressources
  @override
  void dispose() {
    _client.dispose();
    _cache.clear();
    super.dispose();
  }
}
