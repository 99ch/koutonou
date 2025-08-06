import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/base_response.dart';
import '../models/error_model.dart';

class BasePrestaShopService {
  late final Dio _dio;
  final String _baseUrl;
  final String _apiKey;

  BasePrestaShopService()
    : _baseUrl =
          dotenv.env['PRESTASHOP_BASE_URL'] ??
          'https://marketplace.koutonou.com',
      _apiKey =
          dotenv.env['PRESTASHOP_API_KEY'] ??
          'RLSSKE1B7DKGC9Z8MRR1WFECLTE7H2PV' {
    // Debug pour vérifier les valeurs du .env
    print('=== DEBUG PRESTASHOP SERVICE ===');
    print(
      'PRESTASHOP_BASE_URL from .env: ${dotenv.env['PRESTASHOP_BASE_URL']}',
    );
    print('PRESTASHOP_API_KEY from .env: ${dotenv.env['PRESTASHOP_API_KEY']}');
    print('Final _baseUrl: $_baseUrl');
    print('Final _apiKey: $_apiKey');
    print('=== END DEBUG ===');

    // Vérification que nous n'utilisons pas les valeurs de demo
    if (_baseUrl.contains('demo.prestashop.com') || _apiKey == 'DEMO_KEY') {
      throw Exception(
        'ERREUR: Utilisation des valeurs de demo détectée! baseUrl: $_baseUrl, apiKey: $_apiKey',
      );
    }

    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '$_baseUrl/api/',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          // Pas de Content-Type par défaut - sera défini selon le type de requête
        },
      ),
    );

    // Intercepteur pour les logs
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );

    // Intercepteur pour la gestion des erreurs
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) {
          final errorModel = _handleError(e);
          handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: errorModel,
              type: e.type,
            ),
          );
        },
      ),
    );
  }

  ErrorModel _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ErrorModel.network(
          code: 'CONNECTION_TIMEOUT',
          message: 'Délai de connexion dépassé',
        );
      case DioExceptionType.sendTimeout:
        return ErrorModel.network(
          code: 'SEND_TIMEOUT',
          message: 'Délai d\'envoi dépassé',
        );
      case DioExceptionType.receiveTimeout:
        return ErrorModel.network(
          code: 'RECEIVE_TIMEOUT',
          message: 'Délai de réception dépassé',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return ErrorModel.validation(message: 'Requête incorrecte');
          case 401:
            return ErrorModel.authentication(
              message: 'Non autorisé',
              statusCode: 401,
            );
          case 403:
            return ErrorModel.authentication(
              message: 'Accès interdit',
              statusCode: 403,
            );
          case 404:
            return ErrorModel.server(
              code: 'NOT_FOUND',
              message: 'Ressource non trouvée',
              statusCode: 404,
            );
          case 500:
            return ErrorModel.server(
              code: 'INTERNAL_SERVER_ERROR',
              message: 'Erreur interne du serveur',
              statusCode: 500,
            );
          default:
            return ErrorModel.server(
              code: 'HTTP_ERROR',
              message: 'Erreur HTTP: $statusCode',
              statusCode: statusCode,
            );
        }
      case DioExceptionType.cancel:
        return ErrorModel.unknown(message: 'Requête annulée');
      case DioExceptionType.unknown:
      default:
        return ErrorModel.unknown(message: 'Erreur inconnue: ${error.message}');
    }
  }

  // Méthodes CRUD génériques
  Future<BaseResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // Ajouter la clé API et le format JSON aux paramètres
      final params = {
        'ws_key': _apiKey,
        'output_format': 'JSON',
        ...?queryParameters,
      };

      final response = await _dio.get(endpoint, queryParameters: params);

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      if (e.error is ErrorModel) {
        throw e.error as ErrorModel;
      }
      throw _handleError(e);
    }
  }

  Future<BaseResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // Ajouter la clé API aux paramètres
      final params = {
        'ws_key': _apiKey,
        'output_format': 'JSON',
        ...?queryParameters,
      };

      // Convertir les données en XML pour PrestaShop
      String xmlData;
      if (data is Map<String, dynamic>) {
        xmlData = _convertToXml(data);
      } else {
        xmlData = data?.toString() ?? '';
      }

      final response = await _dio.post(
        endpoint,
        data: xmlData,
        queryParameters: params,
        options: Options(
          headers: {
            'Content-Type': 'application/xml',
            'Accept': 'application/json',
          },
        ),
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      if (e.error is ErrorModel) {
        throw e.error as ErrorModel;
      }
      throw _handleError(e);
    }
  }

  Future<BaseResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // Ajouter la clé API aux paramètres
      final params = {
        'ws_key': _apiKey,
        'output_format': 'JSON',
        ...?queryParameters,
      };

      // Convertir les données en XML pour PrestaShop
      String xmlData;
      if (data is Map<String, dynamic>) {
        xmlData = _convertToXml(data);
      } else {
        xmlData = data?.toString() ?? '';
      }

      final response = await _dio.put(
        endpoint,
        data: xmlData,
        queryParameters: params,
        options: Options(
          headers: {
            'Content-Type': 'application/xml',
            'Accept': 'application/json',
          },
        ),
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      if (e.error is ErrorModel) {
        throw e.error as ErrorModel;
      }
      throw _handleError(e);
    }
  }

  Future<BaseResponse<void>> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      // Ajouter la clé API aux paramètres
      final params = {'ws_key': _apiKey, ...?queryParameters};

      final response = await _dio.delete(endpoint, queryParameters: params);

      return BaseResponse<void>(
        success: response.statusCode == 200,
        message: 'Suppression réussie',
      );
    } on DioException catch (e) {
      if (e.error is ErrorModel) {
        throw e.error as ErrorModel;
      }
      throw _handleError(e);
    }
  }

  BaseResponse<T> _handleResponse<T>(
    Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    try {
      final data = response.data;

      if (data is Map<String, dynamic>) {
        // Si nous avons une fonction fromJson, l'utiliser
        if (fromJson != null) {
          final result = fromJson(data);
          return BaseResponse<T>(
            success: true,
            data: result,
            message: 'Succès',
          );
        }

        // Sinon, retourner les données telles quelles (cast)
        return BaseResponse<T>(
          success: true,
          data: data as T,
          message: 'Succès',
        );
      }

      // Si les données sont une liste
      if (data is List) {
        return BaseResponse<T>(
          success: true,
          data: data as T,
          message: 'Succès',
        );
      }

      return BaseResponse<T>(success: true, data: data as T, message: 'Succès');
    } catch (e) {
      throw ErrorModel.validation(message: 'Erreur lors du parsing: $e');
    }
  }

  void dispose() {
    _dio.close();
  }

  /// Convertit un Map en XML pour PrestaShop
  String _convertToXml(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.write('<?xml version="1.0" encoding="UTF-8"?>\n');
    buffer.write('<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">\n');

    _writeMapToXml(data, buffer, 1);

    buffer.write('</prestashop>');
    return buffer.toString();
  }

  /// Méthode récursive pour écrire un Map en XML
  void _writeMapToXml(
    Map<String, dynamic> map,
    StringBuffer buffer,
    int indent,
  ) {
    final indentStr = '  ' * indent;

    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is Map<String, dynamic>) {
        buffer.write('$indentStr<$key>\n');
        _writeMapToXml(value, buffer, indent + 1);
        buffer.write('$indentStr</$key>\n');
      } else if (value is List) {
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            buffer.write('$indentStr<$key>\n');
            _writeMapToXml(item, buffer, indent + 1);
            buffer.write('$indentStr</$key>\n');
          } else {
            buffer.write(
              '$indentStr<$key>${_escapeXml(item.toString())}</$key>\n',
            );
          }
        }
      } else {
        buffer.write(
          '$indentStr<$key>${_escapeXml(value.toString())}</$key>\n',
        );
      }
    }
  }

  /// Échappe les caractères spéciaux XML
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
