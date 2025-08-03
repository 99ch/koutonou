// Provides centralized error handling for the Koutonou application.
// This handler processes all types of errors (API, network, validation, business)
// and provides consistent error logging, user notification, and recovery mechanisms.

import 'package:flutter/material.dart';
import 'package:koutonou/core/exceptions/api_exception.dart';
import 'package:koutonou/core/exceptions/network_exception.dart';
import 'package:koutonou/core/exceptions/validation_exception.dart';
import 'package:koutonou/core/models/error_model.dart';
import 'package:koutonou/core/utils/logger.dart';

// Centralized error handler for the application
class ErrorHandler {
  static final AppLogger _logger = AppLogger();

  /// Handle any type of error and provide appropriate user feedback
  static ErrorHandlerResult handle(
    dynamic error, {
    BuildContext? context,
    String? contextInfo,
    bool showUserMessage = true,
    bool logError = true,
  }) {
    if (logError) {
      _logError(error, contextInfo);
    }

    final errorModel = _convertToErrorModel(error);
    final result = ErrorHandlerResult(
      error: errorModel,
      userMessage: errorModel.userMessage,
      shouldRetry: errorModel.isRetryable,
      shouldLogout: _shouldLogout(errorModel),
      shouldShowDialog: _shouldShowDialog(errorModel),
    );

    if (showUserMessage && context != null) {
      _showUserMessage(context, result);
    }

    return result;
  }

  /// Handle API errors specifically
  static ErrorHandlerResult handleApiError(
    ApiException apiError, {
    BuildContext? context,
    String? contextInfo,
    bool showUserMessage = true,
  }) {
    _logger.error('API Error: ${apiError.message}', apiError);

    final errorModel = ErrorModel(
      code: 'API_${apiError.statusCode}',
      message: apiError.message,
      type: _getErrorTypeFromStatusCode(apiError.statusCode),
      details: {
        'endpoint': apiError.endpoint,
        'statusCode': apiError.statusCode,
        'responseData': apiError.responseData,
      },
    );

    final result = ErrorHandlerResult(
      error: errorModel,
      userMessage: apiError.userMessage,
      shouldRetry: _isRetryableApiError(apiError.statusCode ?? 0),
      shouldLogout: apiError.statusCode == 401,
      shouldShowDialog: apiError.statusCode != 401,
    );

    if (showUserMessage && context != null) {
      _showUserMessage(context, result);
    }

    return result;
  }

  /// Handle network errors specifically
  static ErrorHandlerResult handleNetworkError(
    NetworkException networkError, {
    BuildContext? context,
    String? contextInfo,
    bool showUserMessage = true,
  }) {
    _logger.error('Network Error: ${networkError.message}', networkError);

    final errorModel = ErrorModel.network(
      message: networkError.message,
      code: 'NETWORK_${networkError.type.name.toUpperCase()}',
      details: {
        'type': networkError.type.name,
        'endpoint': networkError.endpoint,
        'timeout': networkError.timeout?.inSeconds,
      },
    );

    final result = ErrorHandlerResult(
      error: errorModel,
      userMessage: networkError.userMessage,
      shouldRetry: networkError.isRecoverable,
      shouldLogout: false,
      shouldShowDialog: true,
    );

    if (showUserMessage && context != null) {
      _showUserMessage(context, result);
    }

    return result;
  }

  /// Handle validation errors specifically
  static ErrorHandlerResult handleValidationError(
    ValidationException validationError, {
    BuildContext? context,
    String? contextInfo,
    bool showUserMessage = true,
  }) {
    _logger.warning('Validation Error: ${validationError.message}');

    final fieldKey = validationError.fieldErrors.keys.isNotEmpty
        ? validationError.fieldErrors.keys.first
        : 'unknown';

    final errorModel = ErrorModel.validation(
      field: fieldKey,
      message: validationError.firstError,
      code: 'VALIDATION_${validationError.type.name.toUpperCase()}',
      details: {'fieldErrors': validationError.fieldErrors},
    );

    final result = ErrorHandlerResult(
      error: errorModel,
      userMessage: validationError.userMessage,
      shouldRetry: false,
      shouldLogout: false,
      shouldShowDialog: false, // Validation errors are usually shown inline
      fieldErrors: validationError.fieldErrors,
    );

    if (showUserMessage &&
        context != null &&
        validationError.fieldErrors.isEmpty) {
      _showUserMessage(context, result);
    }

    return result;
  }

  /// Handle unknown/generic errors
  static ErrorHandlerResult handleUnknownError(
    dynamic error, {
    BuildContext? context,
    String? contextInfo,
    bool showUserMessage = true,
  }) {
    _logger.error(
      'Unknown Error: ${error.toString()}',
      error,
      StackTrace.current,
    );

    final errorModel = ErrorModel.system(
      message: error.toString(),
      code: 'UNKNOWN_ERROR',
      isUserFacing: false,
    );

    final result = ErrorHandlerResult(
      error: errorModel,
      userMessage: 'Une erreur inattendue est survenue. Veuillez réessayer.',
      shouldRetry: true,
      shouldLogout: false,
      shouldShowDialog: true,
    );

    if (showUserMessage && context != null) {
      _showUserMessage(context, result);
    }

    return result;
  }

  /// Show error message to user based on error type
  static void showErrorToUser(
    BuildContext context,
    String message, {
    ErrorSeverity severity = ErrorSeverity.medium,
    Duration? duration,
    VoidCallback? onRetry,
  }) {
    switch (severity) {
      case ErrorSeverity.low:
        _showSnackBar(context, message, Colors.orange, duration);
        break;
      case ErrorSeverity.medium:
        _showSnackBar(context, message, Colors.red, duration);
        break;
      case ErrorSeverity.high:
      case ErrorSeverity.critical:
        _showErrorDialog(context, message, onRetry);
        break;
    }
  }

  // Private helper methods

  /// Convert any error to ErrorModel
  static ErrorModel _convertToErrorModel(dynamic error) {
    if (error is ApiException) {
      return ErrorModel(
        code: 'API_${error.statusCode}',
        message: error.message,
        type: _getErrorTypeFromStatusCode(error.statusCode),
      );
    } else if (error is NetworkException) {
      return ErrorModel.network(
        message: error.message,
        code: 'NETWORK_${error.type.name.toUpperCase()}',
      );
    } else if (error is ValidationException) {
      final fieldKey = error.fieldErrors.keys.isNotEmpty
          ? error.fieldErrors.keys.first
          : 'unknown';
      return ErrorModel.validation(
        field: fieldKey,
        message: error.firstError,
        code: 'VALIDATION_${error.type.name.toUpperCase()}',
      );
    } else if (error is ErrorModel) {
      return error;
    } else {
      return ErrorModel.system(
        message: error.toString(),
        code: 'UNKNOWN_ERROR',
        isUserFacing: false,
      );
    }
  }

  /// Log error with appropriate level
  static void _logError(dynamic error, String? contextInfo) {
    final context = contextInfo != null ? ' [Context: $contextInfo]' : '';

    if (error is ApiException) {
      _logger.error('API Error: ${error.message}$context', error);
    } else if (error is NetworkException) {
      _logger.error('Network Error: ${error.message}$context', error);
    } else if (error is ValidationException) {
      _logger.warning('Validation Error: ${error.message}$context');
    } else {
      _logger.error(
        'Unknown Error: ${error.toString()}$context',
        error,
        StackTrace.current,
      );
    }
  }

  /// Determine if user should be logged out
  static bool _shouldLogout(ErrorModel error) {
    return error.code == 'API_401' ||
        error.code == 'TOKEN_EXPIRED' ||
        error.code == 'TOKEN_INVALID';
  }

  /// Determine if error dialog should be shown
  static bool _shouldShowDialog(ErrorModel error) {
    return error.severity == ErrorSeverity.high ||
        error.severity == ErrorSeverity.critical ||
        error.type == ErrorType.network ||
        error.type == ErrorType.system;
  }

  /// Show appropriate user message
  static void _showUserMessage(
    BuildContext context,
    ErrorHandlerResult result,
  ) {
    if (result.shouldShowDialog) {
      _showErrorDialog(
        context,
        result.userMessage,
        result.shouldRetry ? () => Navigator.of(context).pop() : null,
      );
    } else {
      final color = result.error.severity == ErrorSeverity.low
          ? Colors.orange
          : Colors.red;
      _showSnackBar(context, result.userMessage, color);
    }
  }

  /// Show snackbar message
  static void _showSnackBar(
    BuildContext context,
    String message,
    Color color, [
    Duration? duration,
  ]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: duration ?? const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show error dialog
  static void _showErrorDialog(
    BuildContext context,
    String message, [
    VoidCallback? onRetry,
  ]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Réessayer'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Get error type from HTTP status code
  static ErrorType _getErrorTypeFromStatusCode(int? statusCode) {
    if (statusCode == null) return ErrorType.general;

    switch (statusCode) {
      case 401:
        return ErrorType.authentication;
      case 403:
        return ErrorType.authorization;
      case 422:
        return ErrorType.validation;
      case >= 500:
        return ErrorType.system;
      default:
        return ErrorType.general;
    }
  }

  /// Check if API error is retryable
  static bool _isRetryableApiError(int statusCode) {
    return statusCode >= 500 || statusCode == 408 || statusCode == 429;
  }
}

// Result of error handling
class ErrorHandlerResult {
  final ErrorModel error;
  final String userMessage;
  final bool shouldRetry;
  final bool shouldLogout;
  final bool shouldShowDialog;
  final Map<String, List<String>>? fieldErrors;

  const ErrorHandlerResult({
    required this.error,
    required this.userMessage,
    required this.shouldRetry,
    required this.shouldLogout,
    required this.shouldShowDialog,
    this.fieldErrors,
  });

  @override
  String toString() {
    return 'ErrorHandlerResult(error: ${error.code}, shouldRetry: $shouldRetry, shouldLogout: $shouldLogout)';
  }
}

// Extension for easy error handling in widgets
extension ErrorHandlerExtension on BuildContext {
  /// Handle error with context automatically
  ErrorHandlerResult handleError(
    dynamic error, {
    String? contextInfo,
    bool showUserMessage = true,
    bool logError = true,
  }) {
    return ErrorHandler.handle(
      error,
      context: this,
      contextInfo: contextInfo,
      showUserMessage: showUserMessage,
      logError: logError,
    );
  }

  /// Show error message to user
  void showError(
    String message, {
    ErrorSeverity severity = ErrorSeverity.medium,
    Duration? duration,
    VoidCallback? onRetry,
  }) {
    ErrorHandler.showErrorToUser(
      this,
      message,
      severity: severity,
      duration: duration,
      onRetry: onRetry,
    );
  }
}
