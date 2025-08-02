// Client HTTP pour l'API PrestaShop - Phase 3
// Gestion des requêtes, authentification et parsing des réponses

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:koutonou/core/api/prestashop_config.dart';
import 'package:koutonou/core/api/prestashop_exceptions.dart';
import 'package:koutonou/core/utils/logger.dart';

/// Client HTTP pour l'API PrestaShop
class PrestaShopHttpClient {
  final PrestaShopConfig _config;
  final http.Client _httpClient;
  final AppLogger _logger;

  PrestaShopHttpClient({PrestaShopConfig? config, http.Client? httpClient})
    : _config = config ?? PrestaShopConfigManager.instance,
      _httpClient = httpClient ?? http.Client(),
      _logger = AppLogger();

  /// Effectue une requête GET
  Future<Map<String, dynamic>> get(
    String resource, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      'GET',
      resource,
      queryParams: queryParams,
      headers: headers,
    );
  }

  /// Effectue une requête POST
  Future<Map<String, dynamic>> post(
    String resource, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      'POST',
      resource,
      body: body,
      queryParams: queryParams,
      headers: headers,
    );
  }

  /// Effectue une requête PUT
  Future<Map<String, dynamic>> put(
    String resource, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      'PUT',
      resource,
      body: body,
      queryParams: queryParams,
      headers: headers,
    );
  }

  /// Effectue une requête DELETE
  Future<Map<String, dynamic>> delete(
    String resource, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      'DELETE',
      resource,
      queryParams: queryParams,
      headers: headers,
    );
  }

  /// Effectue une requête HTTP générique
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String resource, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    // Construire l'URL
    final url = _config.getResourceUrl(resource, params: queryParams);
    final uri = Uri.parse(url);

    // Préparer les headers
    final requestHeaders = <String, String>{
      ..._config.defaultHeaders,
      ...?headers,
    };

    // Encoder l'authentification Basic
    final credentials = '${_config.apiKey}:';
    final encodedCredentials = base64Encode(utf8.encode(credentials));
    requestHeaders['Authorization'] = 'Basic $encodedCredentials';

    // Logger la requête en mode debug
    if (_config.debug) {
      _logger.debug('$method $uri');
      if (body != null) {
        _logger.debug('Body: ${json.encode(body)}');
      }
    }

    try {
      late http.Response response;

      // Effectuer la requête selon la méthode
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _httpClient
              .get(uri, headers: requestHeaders)
              .timeout(_config.timeout);
          break;
        case 'POST':
          final bodyStr = body != null ? json.encode(body) : '';
          response = await _httpClient
              .post(uri, headers: requestHeaders, body: bodyStr)
              .timeout(_config.timeout);
          break;
        case 'PUT':
          final bodyStr = body != null ? json.encode(body) : '';
          response = await _httpClient
              .put(uri, headers: requestHeaders, body: bodyStr)
              .timeout(_config.timeout);
          break;
        case 'DELETE':
          response = await _httpClient
              .delete(uri, headers: requestHeaders)
              .timeout(_config.timeout);
          break;
        default:
          throw PrestaShopException.configuration(
            'Méthode HTTP non supportée: $method',
          );
      }

      // Logger la réponse en mode debug
      if (_config.debug) {
        _logger.debug('Response ${response.statusCode}: ${response.body}');
      }

      // Vérifier le statut HTTP
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw PrestaShopException.fromHttpResponse(
          response.statusCode,
          response.body,
        );
      }

      // Parser la réponse JSON
      return _parseResponse(response.body);
    } on SocketException catch (e) {
      throw PrestaShopException.network(
        'Erreur de connexion réseau: ${e.message}',
        originalException: e,
      );
    } on HttpException catch (e) {
      throw PrestaShopException.network(
        'Erreur HTTP: ${e.message}',
        originalException: e,
      );
    } on TimeoutException catch (e) {
      throw PrestaShopException.timeout(
        'Timeout de requête après ${_config.timeoutMs}ms',
        originalException: e,
      );
    } on FormatException catch (e) {
      throw PrestaShopException.parsing(
        'Erreur de parsing JSON: ${e.message}',
        originalException: e,
      );
    }
  }

  /// Parse la réponse JSON de PrestaShop
  Map<String, dynamic> _parseResponse(String responseBody) {
    try {
      final decoded = json.decode(responseBody);

      if (decoded is! Map<String, dynamic>) {
        throw PrestaShopException.parsing(
          'Réponse JSON invalide: attendu un objet, reçu ${decoded.runtimeType}',
        );
      }

      // PrestaShop peut retourner des erreurs même avec un statut 200
      if (decoded.containsKey('errors') && decoded['errors'] != null) {
        final errors = decoded['errors'];
        String errorMessage = 'Erreur PrestaShop';

        if (errors is List && errors.isNotEmpty) {
          errorMessage = errors.first.toString();
        } else if (errors is Map) {
          errorMessage = errors.toString();
        } else {
          errorMessage = errors.toString();
        }

        throw PrestaShopException(
          type: PrestaShopErrorType.validation,
          message: errorMessage,
          details: decoded,
        );
      }

      return decoded;
    } on FormatException catch (e) {
      throw PrestaShopException.parsing(
        'Impossible de parser la réponse JSON: ${e.message}',
        originalException: e,
      );
    }
  }

  /// Ferme le client HTTP
  void close() {
    _httpClient.close();
  }
}

/// Client HTTP singleton
class PrestaShopApiClient {
  static PrestaShopHttpClient? _instance;

  /// Instance singleton du client
  static PrestaShopHttpClient get instance {
    if (_instance == null) {
      if (!PrestaShopConfigManager.isInitialized) {
        throw StateError(
          'PrestaShop configuration not initialized. '
          'Call PrestaShopConfigManager.initialize() first.',
        );
      }
      _instance = PrestaShopHttpClient();
    }
    return _instance!;
  }

  /// Reset l'instance (utile pour les tests)
  static void reset() {
    _instance?.close();
    _instance = null;
  }

  /// Vérifie si le client est initialisé
  static bool get isInitialized => _instance != null;
}
