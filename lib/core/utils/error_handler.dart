// error_handler.dart
// Provides centralized error handling for API requests, local exceptions, and app errors.
// Ensures secure and user-friendly error messages, avoiding exposure of sensitive details
// in production. Uses debug mode to provide detailed logs for developers.

import 'package:dio/dio.dart';
import 'package:koutonou/core/utils/constants.dart';
import 'package:koutonou/core/utils/logger.dart';

class ErrorHandler {
  // Singleton instance for centralized error handling
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  // Logger instance for debugging errors
  final _logger = AppLogger();

  /// Handles errors and returns a user-friendly message.
  /// In debug mode, logs detailed error information.
  String handleError(dynamic error, [StackTrace? stackTrace]) {
    String userMessage = 'An unexpected error occurred. Please try again.';
    String debugMessage = '';

    if (error is DioException) {
      // Handle Dio-specific errors (HTTP-related)
      userMessage = _handleDioError(error);
      debugMessage = 'DioException: ${error.message}, Type: ${error.type}, Response: ${error.response?.data}';
    } else if (error is TypeError) {
      // Handle type casting errors
      userMessage = 'Invalid data format received. Please try again.';
      debugMessage = 'TypeError: $error';
    } else {
      // Handle generic errors
      userMessage = 'Something went wrong. Please try again later.';
      debugMessage = 'Unknown error: $error';
    }

    // Log detailed error information in debug mode only
    if (AppConstants.isDebugMode) {
      _logger.error(_sanitizeMessage(debugMessage), error, stackTrace);
    }

    return _sanitizeMessage(userMessage);
  }

  /// Handles Dio-specific errors and maps HTTP status codes to user-friendly messages.
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return _handleHttpStatusCode(error.response?.statusCode);
      case DioExceptionType.cancel:
        return 'Request was cancelled. Please try again.';
      case DioExceptionType.connectionError:
        return 'Network error. Please check your connection and try again.';
      case DioExceptionType.badCertificate:
        return 'Security certificate error. Please contact support.';
      case DioExceptionType.unknown:
      default:
        return 'An unexpected network error occurred. Please try again.';
    }
  }

  /// Maps HTTP status codes to user-friendly messages.
  String _handleHttpStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication failed. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Resource not found. Please try again.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An unexpected server error occurred. Please try again.';
    }
  }

  /// Sanitizes error messages to prevent exposure of sensitive data.
  String _sanitizeMessage(String message) {
    String sanitized = message;
    // Remove sensitive data like API keys, tokens, or passwords
    sanitized = sanitized.replaceAll(RegExp(r'api_key=[^&]*'), 'api_key=****');
    sanitized = sanitized.replaceAll(RegExp(r'passwd=[^&]*'), 'passwd=****');
    sanitized = sanitized.replaceAll(RegExp(r'token=[^&]*'), 'token=****');
    // Remove sensitive server details (e.g., internal URLs)
    sanitized = sanitized.replaceAll(RegExp(r'https?://[^/]+'), '[server]');
    return sanitized;
  }
}