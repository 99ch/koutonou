// api_config.dart
// Defines the configuration for the Dio HTTP client, including base URLs, headers,
// timeouts, and security settings like certificate pinning. Supports local and production
// environments securely using .env variables to avoid hardcoding sensitive data.

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import 'package:koutonou/core/utils/constants.dart';

class ApiConfig {
  // Singleton instance for centralized configuration
  static final ApiConfig _instance = ApiConfig._internal();
  factory ApiConfig() => _instance;
  ApiConfig._internal();

  // Determines if the app is running in production mode
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  // Base URL for API requests, switches between local and production
  String get baseUrl => isProduction
      ? AppConstants.apiBaseUrlProd
      : AppConstants.apiBaseUrlLocal;

  // Dio configuration
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
        sendTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': AppConstants.apiKey, // Securely loaded from .env
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add certificate pinning for production HTTPS requests
    if (isProduction) {
      dio.interceptors.add(
        CertificatePinningInterceptor(
          allowedSHAFingerprints: [
            // Replace with the SHA-256 fingerprint of your production server's SSL certificate
            'DetjYhiwAa895Ox3qAYvcp86557C+tQAGTk6i7W0kRs=',
          ],
        ),
      );
    }

    return dio;
  }
}