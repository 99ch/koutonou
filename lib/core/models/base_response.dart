// base_response.dart
// Defines a generic model for parsing API responses from the PrestaShop proxy PHP.
// Handles both successful responses (data) and error responses (error) in a typed and
// secure manner, integrating with ErrorModel for error handling.

import 'package:koutonou/core/models/error_model.dart';
import 'package:koutonou/core/utils/error_handler.dart';

class BaseResponse<T> {
  // Indicates if the API request was successful
  final bool success;

  // Data returned by the API (e.g., list of products, customer details)
  final T? data;

  // Error details if the request failed
  final ErrorModel? error;

  // Error handler for sanitizing and formatting messages
  static final _errorHandler = ErrorHandler();

  BaseResponse({
    required this.success,
    this.data,
    this.error,
  });

  /// Creates a BaseResponse from a JSON response.
  /// Expects format: { "success": true, "data": {...} } or { "success": false, "error": {...} }
  factory BaseResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    final bool success = json['success'] as bool? ?? false;

    if (success) {
      return BaseResponse<T>(
        success: true,
        data: json['data'] != null ? fromJsonT(json['data']) : null,
        error: null,
      );
    } else {
      return BaseResponse<T>(
        success: false,
        data: null,
        error: json['error'] != null ? ErrorModel.fromJson(json) : null,
      );
    }
  }

  /// Converts the response to JSON (for logging or debugging purposes).
  Map<String, dynamic> toJson(dynamic Function(T) toJsonT) {
    return {
      'success': success,
      'data': data != null ? toJsonT(data as T) : null,
      'error': error?.toJson(),
    };
  }

  /// Returns a user-friendly error message if the response contains an error.
  String? get userMessage {
    if (!success && error != null) {
      return error!.userMessage;
    }
    return null;
  }
}