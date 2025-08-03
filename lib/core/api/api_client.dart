// Provides a centralized HTTP client using Dio to interact with the PrestaShop API
// via the proxy PHP endpoint. Integrates secure configuration, error handling, and
// logging, ensuring no sensitive data is exposed in production.

import 'package:dio/dio.dart';
import 'package:koutonou/core/api/api_config.dart';
import 'package:koutonou/core/exceptions/api_exception.dart';
import 'package:koutonou/core/models/base_response.dart';
import 'package:koutonou/core/utils/error_handler.dart';
import 'package:koutonou/core/utils/logger.dart';

class ApiClient {
  /// Singleton instance for centralized HTTP client
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  /// Dio instance from ApiConfig
  final Dio _dio = ApiConfig().dio;

  /// Logger instance
  static final _logger = AppLogger();

  /// Performs a GET request to the specified resource.
  /// [resource] is the API endpoint (e.g., 'products', 'customers').
  /// [queryParameters] includes optional parameters like limit, offset, or filters.
  /// Returns a [BaseResponse] with the data or error information.
  Future<BaseResponse<Map<String, dynamic>>> get(
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
      return _handleResponse(response);
    } catch (e, stackTrace) {
      _logger.error('GET request failed for $resource', e, stackTrace);
      return _handleError(e, stackTrace);
    }
  }

  /// Performs a POST request to create a new resource.
  /// [resource] is the API endpoint (e.g., 'products', 'customers').
  /// [data] is the payload to send (must be JSON-serializable).
  /// Returns a [BaseResponse] with the created data or error information.
  Future<BaseResponse<Map<String, dynamic>>> post(
    String resource, {
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger.debug('POST request to $resource with data: $data');

      final response = await _dio.post('?resource=$resource', data: data);

      _logger.info('POST response from $resource: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e, stackTrace) {
      _logger.error('POST request failed for $resource', e, stackTrace);
      return _handleError(e, stackTrace);
    }
  }

  /// Performs a PUT request to update an existing resource.
  /// [resource] is the API endpoint (e.g., 'products', 'customers').
  /// [id] is the resource ID to update.
  /// [data] is the payload to send (must be JSON-serializable).
  /// Returns a [BaseResponse] with the updated data or error information.
  Future<BaseResponse<Map<String, dynamic>>> put(
    String resource,
    String id, {
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger.debug('PUT request to $resource/$id with data: $data');

      final response = await _dio.put('?resource=$resource&id=$id', data: data);

      _logger.info('PUT response from $resource/$id: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e, stackTrace) {
      _logger.error('PUT request failed for $resource/$id', e, stackTrace);
      return _handleError(e, stackTrace);
    }
  }

  /// Performs a PATCH request to partially update an existing resource.
  /// [resource] is the API endpoint (e.g., 'products', 'customers').
  /// [id] is the resource ID to update.
  /// [data] is the partial payload to send (must be JSON-serializable).
  /// Returns a [BaseResponse] with the updated data or error information.
  Future<BaseResponse<Map<String, dynamic>>> patch(
    String resource,
    String id, {
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger.debug('PATCH request to $resource/$id with data: $data');

      final response = await _dio.patch(
        '?resource=$resource&id=$id',
        data: data,
      );

      _logger.info('PATCH response from $resource/$id: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e, stackTrace) {
      _logger.error('PATCH request failed for $resource/$id', e, stackTrace);
      return _handleError(e, stackTrace);
    }
  }

  /// Performs a DELETE request to remove a resource.
  /// [resource] is the API endpoint (e.g., 'products', 'customers').
  /// [id] is the resource ID to delete.
  /// Returns a [BaseResponse] indicating success or error.
  Future<BaseResponse<bool>> delete(String resource, String id) async {
    try {
      _logger.debug('DELETE request to $resource/$id');

      final response = await _dio.delete('?resource=$resource&id=$id');

      _logger.info(
        'DELETE response from $resource/$id: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return BaseResponse<bool>.success(
          data: true,
          message: 'Resource deleted successfully',
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return BaseResponse<bool>.error(
          message: 'Failed to delete resource',
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e, stackTrace) {
      _logger.error('DELETE request failed for $resource/$id', e, stackTrace);
      return _handleErrorBool(e, stackTrace);
    }
  }

  /// Performs a GET request with pagination support.
  /// [resource] is the API endpoint.
  /// [page] is the page number (1-based).
  /// [limit] is the number of items per page.
  /// [filters] are additional query parameters for filtering.
  Future<BaseResponse<Map<String, dynamic>>> getPaginated(
    String resource, {
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      ...?filters,
    };

    return get(resource, queryParameters: queryParams);
  }

  /// Uploads a file to the specified resource endpoint.
  /// [resource] is the API endpoint for file upload.
  /// [filePath] is the path to the file to upload.
  /// [fieldName] is the form field name for the file (default: 'file').
  /// [additionalData] contains any additional form data.
  Future<BaseResponse<Map<String, dynamic>>> uploadFile(
    String resource,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _logger.debug('File upload request to $resource: $filePath');

      final formData = FormData();

      // Add the file
      formData.files.add(
        MapEntry(fieldName, await MultipartFile.fromFile(filePath)),
      );

      // Add additional data if provided
      if (additionalData != null) {
        for (final entry in additionalData.entries) {
          formData.fields.add(MapEntry(entry.key, entry.value.toString()));
        }
      }

      final response = await _dio.post(
        '?resource=$resource&action=upload',
        data: formData,
      );

      _logger.info(
        'File upload response from $resource: ${response.statusCode}',
      );
      return _handleResponse(response);
    } catch (e, stackTrace) {
      _logger.error('File upload failed for $resource', e, stackTrace);
      return _handleError(e, stackTrace);
    }
  }

  /// Downloads a file from the specified URL.
  /// [url] is the file URL to download.
  /// [savePath] is the local path where the file will be saved.
  Future<BaseResponse<String>> downloadFile(String url, String savePath) async {
    try {
      _logger.debug('File download request: $url -> $savePath');

      final response = await _dio.download(url, savePath);

      _logger.info('File download completed: ${response.statusCode}');

      if (response.statusCode == 200) {
        return BaseResponse<String>.success(
          data: savePath,
          message: 'File downloaded successfully',
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return BaseResponse<String>.error(
          message: 'Failed to download file',
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e, stackTrace) {
      _logger.error('File download failed: $url', e, stackTrace);
      return _handleErrorString(e, stackTrace);
    }
  }

  /// Handles successful responses and converts them to BaseResponse.
  BaseResponse<Map<String, dynamic>> _handleResponse(Response response) {
    try {
      // Validate response status
      if (response.statusCode == null || response.statusCode! >= 400) {
        return BaseResponse<Map<String, dynamic>>.error(
          message: 'HTTP Error: ${response.statusCode}',
          statusCode: response.statusCode ?? 500,
        );
      }

      // Handle empty responses
      if (response.data == null) {
        return BaseResponse<Map<String, dynamic>>.success(
          data: <String, dynamic>{},
          message: 'Success',
          statusCode: response.statusCode ?? 200,
        );
      }

      // Validate response format
      if (response.data is! Map<String, dynamic>) {
        return BaseResponse<Map<String, dynamic>>.error(
          message: 'Invalid response format: expected JSON object',
          statusCode: response.statusCode ?? 500,
        );
      }

      final data = response.data as Map<String, dynamic>;

      // Check for API-level errors in the response
      if (data.containsKey('error') && data['error'] != null) {
        return BaseResponse<Map<String, dynamic>>.error(
          message: data['error'].toString(),
          statusCode: response.statusCode ?? 500,
        );
      }

      return BaseResponse<Map<String, dynamic>>.success(
        data: data,
        message: 'Success',
        statusCode: response.statusCode ?? 200,
      );
    } catch (e) {
      _logger.error('Error handling response', e);
      return BaseResponse<Map<String, dynamic>>.error(
        message: 'Failed to process response: $e',
        statusCode: response.statusCode ?? 500,
      );
    }
  }

  /// Handles errors and converts them to BaseResponse.
  BaseResponse<Map<String, dynamic>> _handleError(
    Object error,
    StackTrace stackTrace,
  ) {
    final apiException = _convertToApiException(error);
    final result = ErrorHandler.handleApiError(
      apiException,
      contextInfo: 'API Client Request',
      showUserMessage: false,
    );

    return BaseResponse<Map<String, dynamic>>.error(
      message: result.userMessage,
      statusCode: _extractStatusCode(error) ?? 500,
    );
  }

  /// Handles errors for bool responses.
  BaseResponse<bool> _handleErrorBool(Object error, StackTrace stackTrace) {
    final apiException = _convertToApiException(error);
    final result = ErrorHandler.handleApiError(
      apiException,
      contextInfo: 'API Client Request',
      showUserMessage: false,
    );

    return BaseResponse<bool>.error(
      message: result.userMessage,
      statusCode: _extractStatusCode(error) ?? 500,
    );
  }

  /// Handles errors for string responses.
  BaseResponse<String> _handleErrorString(Object error, StackTrace stackTrace) {
    final apiException = _convertToApiException(error);
    final result = ErrorHandler.handleApiError(
      apiException,
      contextInfo: 'API Client Request',
      showUserMessage: false,
    );

    return BaseResponse<String>.error(
      message: result.userMessage,
      statusCode: _extractStatusCode(error) ?? 500,
    );
  }

  /// Converts any error to ApiException.
  ApiException _convertToApiException(Object error) {
    if (error is ApiException) {
      return error;
    } else if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException(
            'Connection timeout: ${error.message}',
            timeout: const Duration(seconds: 30),
            endpoint: error.requestOptions.path,
          );
        case DioExceptionType.connectionError:
          return ClientException(
            'Network connection error: ${error.message}',
            statusCode: error.response?.statusCode,
            endpoint: error.requestOptions.path,
          );
        case DioExceptionType.badResponse:
          return ApiExceptionFactory.fromStatusCode(
            error.response?.statusCode ?? 500,
            'Server error: ${error.message}',
            endpoint: error.requestOptions.path,
            responseData: error.response?.data,
          );
        case DioExceptionType.cancel:
          return ClientException(
            'Request cancelled',
            statusCode: 499,
            endpoint: error.requestOptions.path,
          );
        default:
          return ApiException.create(
            'Unknown error: ${error.message}',
            statusCode: error.response?.statusCode,
            endpoint: error.requestOptions.path,
          );
      }
    } else {
      return ApiException.create('Unexpected error: $error');
    }
  }

  /// Extracts status code from DioException or returns null.
  int? _extractStatusCode(Object error) {
    if (error is DioException) {
      return error.response?.statusCode;
    }
    return null;
  }

  /// Cancels all pending requests.
  void cancelAllRequests() {
    _dio.close();
    _logger.info('All API requests cancelled');
  }

  /// Creates a new ApiClient instance with custom configuration.
  /// Useful for different API endpoints or special configurations.
  static ApiClient createCustom({
    String? baseUrl,
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    final customClient = ApiClient._internal();
    // Implementation would create a new Dio instance with custom config
    return customClient;
  }

  /// Gets current client configuration for debugging.
  Map<String, dynamic> getClientInfo() {
    return {
      'baseUrl': _dio.options.baseUrl,
      'timeout': _dio.options.connectTimeout?.inMilliseconds,
      'headers': _dio.options.headers,
    };
  }
}
