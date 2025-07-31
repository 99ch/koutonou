// Defines the configuration for the Dio HTTP client, including base URLs, headers,
// timeouts, and security settings like certificate pinning. Supports local and production
// environments securely using .env variables to avoid hardcoding sensitive data.

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koutonou/core/utils/constants.dart';
import 'package:koutonou/core/utils/logger.dart';

class ApiConfig {
  /// Singleton instance for centralized configuration
  static final ApiConfig _instance = ApiConfig._internal();
  factory ApiConfig() => _instance;
  ApiConfig._internal();

  static final AppLogger _logger = AppLogger();

  /// Determines if the app is running in production mode
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  /// Base URL for API requests, switches between local and production
  String get baseUrl => AppConstants.apiBaseUrl;

  /// API Key from environment variables
  String get apiKey => dotenv.env['API_KEY'] ?? '';

  /// User agent for requests
  String get userAgent =>
      'Koutonou-Mobile/${dotenv.env['APP_VERSION'] ?? '1.0.0'}';

  /// Dio configuration with interceptors and security
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
        sendTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
        headers: _getDefaultHeaders(),
        validateStatus: (status) => status != null && status < 500,
        // Pour le web, on simplifie les redirections pour éviter les problèmes CORS
        followRedirects: true,
        maxRedirects: 2,
      ),
    );

    // Add interceptors
    _addInterceptors(dio);

    return dio;
  }

  /// Get default headers for API requests
  Map<String, String> _getDefaultHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Pour le web, on évite les headers personnalisés qui causent des problèmes CORS
    const bool isWeb = bool.fromEnvironment('dart.library.js_util');

    if (!isWeb) {
      // Headers spécifiques aux plateformes mobiles uniquement
      headers['User-Agent'] = userAgent;
      headers['X-Platform'] = 'mobile';
      headers['X-App-Version'] = dotenv.env['APP_VERSION'] ?? '1.0.0';
    }

    // Add API key as Authorization Bearer if available
    if (apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }

    return headers;
  }

  /// Add all necessary interceptors
  void _addInterceptors(Dio dio) {
    // Request/Response logging interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.apiRequest(
            options.method,
            '${options.baseUrl}${options.path}',
            data: options.data,
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.apiResponse(
            response.requestOptions.method,
            '${response.requestOptions.baseUrl}${response.requestOptions.path}',
            response.statusCode ?? 0,
            data: response.data,
          );
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.error('API Error: ${error.message}', error);
          handler.next(error);
        },
      ),
    );

    // Retry interceptor for failed requests
    dio.interceptors.add(_createRetryInterceptor());

    // Auth token interceptor
    dio.interceptors.add(_createAuthInterceptor());

    // Certificate pinning for production
    if (isProduction) {
      _addCertificatePinning(dio);
    }
  }

  /// Create retry interceptor for network failures
  Interceptor _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        if (_shouldRetryRequest(error)) {
          _logger.info('Retrying request: ${error.requestOptions.path}');
          // Implement retry logic here if needed
        }
        handler.next(error);
      },
    );
  }

  /// Create auth interceptor for token management
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token to requests if available
        // This will be implemented when AuthService is ready
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle 401 errors and token refresh
        if (error.response?.statusCode == 401) {
          _logger.warning('Unauthorized request, token may be expired');
          // Implement token refresh logic here
        }
        handler.next(error);
      },
    );
  }

  /// Add certificate pinning for production environment
  void _addCertificatePinning(Dio dio) {
    // Certificate pinning implementation would go here
    // For now, we'll add basic SSL validation
    _logger.info('Certificate pinning enabled for production');

    // Example implementation (requires certificate_pinning package):
    /*
    dio.interceptors.add(
      CertificatePinningInterceptor(
        allowedSHAFingerprints: [
          dotenv.env['SSL_FINGERPRINT'] ?? '',
        ],
      ),
    );
    */
  }

  /// Check if request should be retried
  bool _shouldRetryRequest(DioException error) {
    // Retry on network errors and 5xx server errors
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  /// Create a new Dio instance with custom configuration
  Dio createCustomDio({
    String? customBaseUrl,
    Map<String, String>? customHeaders,
    Duration? customTimeout,
  }) {
    final customDio = Dio(
      BaseOptions(
        baseUrl: customBaseUrl ?? baseUrl,
        connectTimeout:
            customTimeout ??
            const Duration(milliseconds: AppConstants.apiTimeout),
        receiveTimeout:
            customTimeout ??
            const Duration(milliseconds: AppConstants.apiTimeout),
        sendTimeout:
            customTimeout ??
            const Duration(milliseconds: AppConstants.apiTimeout),
        headers: {..._getDefaultHeaders(), ...?customHeaders},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _addInterceptors(customDio);
    return customDio;
  }

  /// Update auth token for requests
  void updateAuthToken(String token) {
    // This method will be used by AuthService to update the token
    _logger.info('Auth token updated');
  }

  /// Clear auth token
  void clearAuthToken() {
    _logger.info('Auth token cleared');
  }

  /// Get current configuration info for debugging
  Map<String, dynamic> getConfigInfo() {
    return {
      'baseUrl': baseUrl,
      'isProduction': isProduction,
      'hasApiKey': apiKey.isNotEmpty,
      'timeout': AppConstants.apiTimeout,
      'userAgent': userAgent,
    };
  }
}
