// api_client.dart
// Provides a centralized HTTP client using Dio to interact with the PrestaShop API
// via the proxy PHP endpoint. Integrates secure configuration, error handling, and
// logging, ensuring no sensitive data is exposed in production.

import 'package:dio/dio.dart';
import 'package:koutonou/core/api/api_config.dart';
import 'package:koutonou/core/utils/error_handler.dart';
import 'package:koutonou/core/utils/logger.dart';

class ApiClient {
  // Singleton instance for centralized HTTP client
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // Dio instance from ApiConfig
  final Dio _dio = ApiConfig().dio;

  // Logger and error handler instances
  final _logger = AppLogger();
  final _errorHandler = ErrorHandler();

  /// Performs a GET request to the specified resource.
  /// [resource] is the API endpoint (e.g., 'products', 'customers').
  /// [queryParameters] includes optional parameters like limit, offset, or filters.
  Future<Map<String, dynamic>> get(
    String resource, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      _logger.debug('GET request to $resource with params: $queryParameters');
      final response = await _dio.get(
        '?resource=$resource',
        queryParameters: queryParameters,
      );
      _logger.info('GET response from $resource: ${response.statusCode}');
      return _validateResponse(response);
    } catch (e, stackTrace) {
      _logger.error('GET request failed for $resource', e, stackTrace);
      throw _errorHandler.handleError(e, stackTrace);
    }
  }

  /// Performs a POST request to create a new resource.
  /// [resource] is the API endpoint (e.g., 'products', 'customers').
  /// [data] is the payload to send (must be JSON-serializable).
  Future<Map<String, dynamic>> post(
    String resource, {
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger.debug('POST request to $resource with data: $data');
      final response = await _dio.post(
        '?resource=$resource',
        data: data,
      );
      _logger.info('POST response from $resource: ${response.statusCode}');
      return _validateResponse(response);
    } catch (e, stackTrace) {
      _logger.error('POST request failed for $resource', e, stackTrace);
      throw _errorHandler.handleError(e, stackTrace);
    }
  }

  /// Performs a PUT request to update an existing resource.
  /// [resource] is the API endpoint (e.g., 'products', 'customers').
  /// [id] is the resource ID to update.
  /// [data] is the payload to send (must be JSON-serializable).
  Future<Map<String, dynamic>> put(
    String resource,
    String id, {
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger.debug('PUT request to $resource/$id with data: $data');
      final response = await _dio.put(
        '?resource=$resource&id=$id',
        data: data,
      );
      _logger.info('PUT response from $resource/$id: ${response.statusCode}');
      return _validateResponse(response);
    } catch (e, stackTrace) {
      _logger.error('PUT request failed for $resource/$id', e, stackTrace);
      throw _errorHandler.handleError(e, stackTrace);
    }
  }

  /// Performs a DELETE request to remove a resource.
  /// [resource] is the API endpoint (e.g., 'products', 'customers').
  /// [id] is the resource ID to delete.
  Future<void> delete(
    String resource,
    String id,
  ) async {
    try {
      _logger.debug('DELETE request to $resource/$id');
      final response = await _dio.delete('?resource=$resource&id=$id');
      _logger.info('DELETE response from $resource/$id: ${response.statusCode}');
    } catch (e, stackTrace) {
      _logger.error('DELETE request failed for $resource/$id', e, stackTrace);
      throw _errorHandler.handleError(e, stackTrace);
    }
  }

  /// Validates the API response and ensures it is a valid JSON map.
  Map<String, dynamic> _validateResponse(Response response) {
    if (response.data == null) {
      throw Exception('Empty response received');
    }
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format: expected JSON object');
    }
    return response.data as Map<String, dynamic>;
  }
}