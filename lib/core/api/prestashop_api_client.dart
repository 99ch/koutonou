import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'prestashop_api_config.dart';
import '../exceptions/prestashop_api_exception.dart';

/// Client HTTP principal pour l'API PrestaShop
/// 
/// Cette classe gère toutes les communications avec l'API PrestaShop,
/// incluant l'authentification, la gestion des erreurs et le parsing XML.
class PrestashopApiClient {
  final PrestashopApiConfig _config;
  final http.Client _httpClient;
  
  PrestashopApiClient({
    PrestashopApiConfig? config,
    http.Client? httpClient,
  }) : _config = config ?? PrestashopConfig.instance,
       _httpClient = httpClient ?? http.Client();

  /// Dispose des ressources
  void dispose() {
    _httpClient.close();
  }

  // ==================== MÉTHODES CRUD ====================

  /// Récupérer une liste de ressources
  Future<XmlDocument> getList(
    String resource, {
    Map<String, dynamic>? queryParams,
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'output_format': 'XML',
      'display': 'full',
      if (limit != null) 'limit': '$offset,$limit',
      if (queryParams != null) ...queryParams.map((k, v) => MapEntry(k, v.toString())),
    };

    final url = _buildUrl(resource, queryParams: params);
    
    if (_config.debugMode) {
      print('📡 [PrestaShop API] GET List: $url');
    }

    return _executeRequest('GET', url);
  }

  /// Récupérer une ressource par ID
  Future<XmlDocument> getById(String resource, int id) async {
    final params = {
      'output_format': 'XML',
      'display': 'full',
    };

    final url = _buildUrl('$resource/$id', queryParams: params);
    
    if (_config.debugMode) {
      print('📡 [PrestaShop API] GET by ID: $url');
    }

    return _executeRequest('GET', url);
  }

  /// Créer une nouvelle ressource
  Future<XmlDocument> create(String resource, XmlDocument data) async {
    final url = _buildUrl(resource, queryParams: {'output_format': 'XML'});
    
    if (_config.debugMode) {
      print('📡 [PrestaShop API] POST Create: $url');
      print('📄 Data: ${data.toXmlString(pretty: true)}');
    }

    return _executeRequest('POST', url, body: data.toXmlString());
  }

  /// Mettre à jour une ressource
  Future<XmlDocument> update(String resource, int id, XmlDocument data) async {
    final url = _buildUrl('$resource/$id', queryParams: {'output_format': 'XML'});
    
    if (_config.debugMode) {
      print('📡 [PrestaShop API] PUT Update: $url');
      print('📄 Data: ${data.toXmlString(pretty: true)}');
    }

    return _executeRequest('PUT', url, body: data.toXmlString());
  }

  /// Supprimer une ressource
  Future<bool> delete(String resource, int id) async {
    final url = _buildUrl('$resource/$id');
    
    if (_config.debugMode) {
      print('📡 [PrestaShop API] DELETE: $url');
    }

    try {
      await _executeRequest('DELETE', url);
      return true;
    } on PrestashopApiException {
      return false;
    }
  }

  // ==================== MÉTHODES DE RECHERCHE ====================

  /// Rechercher des ressources avec filtres
  Future<XmlDocument> search(
    String resource, {
    Map<String, dynamic>? filters,
    String? searchTerm,
    String? sortBy,
    String? sortOrder = 'ASC',
    int? limit,
    int? offset,
  }) async {
    final params = <String, String>{
      'output_format': 'XML',
      'display': 'full',
      if (limit != null) 'limit': '$offset,$limit',
      if (sortBy != null) 'sort': '[$sortBy_$sortOrder]',
      if (searchTerm != null) 'filter[$resource][name]': '%$searchTerm%',
    };

    // Ajouter les filtres spécifiques
    if (filters != null) {
      for (final entry in filters.entries) {
        params['filter[$resource][${entry.key}]'] = entry.value.toString();
      }
    }

    final url = _buildUrl(resource, queryParams: params);
    
    if (_config.debugMode) {
      print('📡 [PrestaShop API] SEARCH: $url');
      print('🔍 Filters: $filters');
    }

    return _executeRequest('GET', url);
  }

  // ==================== MÉTHODES SPÉCIALISÉES ====================

  /// Récupérer les options de ressource
  Future<XmlDocument> getResourceOptions(String resource) async {
    final url = _buildUrl(resource, queryParams: {'output_format': 'XML'});
    
    if (_config.debugMode) {
      print('📡 [PrestaShop API] OPTIONS: $url');
    }

    return _executeRequest('HEAD', url);
  }

  /// Récupérer une image de produit
  Future<List<int>> getProductImage(int productId, int imageId) async {
    final url = _buildUrl('images/products/$productId/$imageId');
    
    if (_config.debugMode) {
      print('📡 [PrestaShop API] GET Image: $url');
    }

    final response = await _makeHttpRequest('GET', url);
    
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw PrestashopApiException(
        'Failed to get image',
        statusCode: response.statusCode,
        response: utf8.decode(response.bodyBytes),
      );
    }
  }

  // ==================== MÉTHODES PRIVÉES ====================

  /// Construire l'URL complète avec paramètres
  String _buildUrl(String endpoint, {Map<String, String>? queryParams}) {
    final baseUrl = _config.getEndpointUrl(endpoint);
    
    if (queryParams == null || queryParams.isEmpty) {
      return baseUrl;
    }

    final uri = Uri.parse(baseUrl);
    final newUri = uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParams,
    });
    
    return newUri.toString();
  }

  /// Exécuter une requête et parser le XML de réponse
  Future<XmlDocument> _executeRequest(
    String method,
    String url, {
    String? body,
  }) async {
    final response = await _makeHttpRequest(method, url, body: body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseXmlResponse(response.body);
    } else {
      throw _createApiException(response);
    }
  }

  /// Faire une requête HTTP brute
  Future<http.Response> _makeHttpRequest(
    String method,
    String url, {
    String? body,
  }) async {
    final uri = Uri.parse(url);
    final headers = Map<String, String>.from(_config.defaultHeaders);

    try {
      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _httpClient.get(uri, headers: headers)
              .timeout(Duration(seconds: _config.timeoutSeconds));
          break;
        case 'POST':
          response = await _httpClient.post(uri, headers: headers, body: body)
              .timeout(Duration(seconds: _config.timeoutSeconds));
          break;
        case 'PUT':
          response = await _httpClient.put(uri, headers: headers, body: body)
              .timeout(Duration(seconds: _config.timeoutSeconds));
          break;
        case 'DELETE':
          response = await _httpClient.delete(uri, headers: headers)
              .timeout(Duration(seconds: _config.timeoutSeconds));
          break;
        case 'HEAD':
          response = await _httpClient.head(uri, headers: headers)
              .timeout(Duration(seconds: _config.timeoutSeconds));
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }

      if (_config.debugMode) {
        print('📨 [PrestaShop API] Response ${response.statusCode}: ${response.reasonPhrase}');
        if (response.body.isNotEmpty && response.body.length < 1000) {
          print('📄 Response Body: ${response.body}');
        }
      }

      return response;
    } on SocketException catch (e) {
      throw PrestashopApiException(
        'Network error: ${e.message}',
        originalException: e,
      );
    } on TimeoutException catch (e) {
      throw PrestashopApiException(
        'Request timeout: ${e.message ?? 'Request timed out'}',
        originalException: e,
      );
    } catch (e) {
      throw PrestashopApiException(
        'Unexpected error: $e',
        originalException: e,
      );
    }
  }

  /// Parser la réponse XML
  XmlDocument _parseXmlResponse(String xmlString) {
    try {
      return XmlDocument.parse(xmlString);
    } catch (e) {
      throw PrestashopApiException(
        'Failed to parse XML response: $e',
        response: xmlString,
        originalException: e,
      );
    }
  }

  /// Créer une exception API appropriée
  PrestashopApiException _createApiException(http.Response response) {
    String message = 'API request failed';
    Map<String, dynamic>? errorDetails;

    // Tenter de parser les erreurs XML de PrestaShop
    try {
      final xmlDoc = XmlDocument.parse(response.body);
      final errorNode = xmlDoc.findAllElements('error').firstOrNull;
      
      if (errorNode != null) {
        message = errorNode.findElements('message').firstOrNull?.text ?? message;
        errorDetails = {
          'code': errorNode.findElements('code').firstOrNull?.text,
          'message': message,
        };
      }
    } catch (_) {
      // Si le parsing XML échoue, utiliser le body brut
      message = response.body.isNotEmpty ? response.body : response.reasonPhrase ?? message;
    }

    return PrestashopApiException(
      message,
      statusCode: response.statusCode,
      response: response.body,
      errorDetails: errorDetails,
    );
  }
}
