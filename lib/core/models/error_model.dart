/// error_model.dart
/// Defines a typed model for parsing error responses from the PrestaShop API via the proxy PHP.
/// Ensures secure parsing and handling of error messages, avoiding exposure of sensitive details
/// in production. Integrates with ErrorHandler for user-friendly error messages.

import 'package:koutonou/core/utils/error_handler.dart';

class ErrorModel {
  /// Error code (e.g., 400, 401, etc.)
  final int code;

  /// Raw error message from the API
  final String message;

  /// Optional additional details (e.g., validation errors)
  final Map<String, dynamic>? details;

  /// Error handler for sanitizing and formatting messages
  static final _errorHandler = ErrorHandler();

  ErrorModel({
    required this.code,
    required this.message,
    this.details,
  });

  //// Creates an ErrorModel from a JSON response.
  //// Expects format: { "error": { "code": 400, "message": "Invalid request" } }
  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    final errorData = json['error'] as Map<String, dynamic>? ?? {};
    return ErrorModel(
      code: errorData['code'] as int? ?? 0,
      message: errorData['message'] as String? ?? 'Unknown error',
      details: errorData['details'] as Map<String, dynamic>?,
    );
  }

  //// Converts the error model to JSON (for logging or debugging purposes).
  Map<String, dynamic> toJson() {
    return {
      'error': {
        'code': code,
        'message': message,
        'details': details,
      },
    };
  }

  //// Returns a user-friendly error message, sanitized for safety.
  String get userMessage {
    return _errorHandler.handleError(Exception(message));
  }
}