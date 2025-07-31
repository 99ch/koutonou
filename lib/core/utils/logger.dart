// Provides a secure logging utility for debugging API requests, errors, and app events.
// Logging is enabled only in debug mode to prevent sensitive data exposure in production.
// Uses the `logger` package for structured and readable logs.

import 'package:logger/logger.dart';

class AppLogger {
  /// Singleton instance of the logger
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  /// Logger instance from the `logger` package
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,

      /// Show 2 levels of stack trace
      errorMethodCount: 8,

      /// Show 8 levels of stack trace for errors
      lineLength: 120,

      /// Line length for output
      colors: true,

      /// Colorize output
      printEmojis: true,

      /// Include emojis
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,

      /// Show time and elapsed time since start
      noBoxingByDefault: true,

      /// No boxing for cleaner output
    ),
  );

  /// Logs a debug message, only in debug mode.
  void debug(String message) {
    // Use a safer debug mode check that doesn't rely on dotenv
    const bool isDebug = !bool.fromEnvironment('dart.vm.product');
    if (isDebug) {
      _logger.d(_sanitizeMessage(message));
    }
  }

  /// Logs an info message, only in debug mode.
  void info(String message) {
    const bool isDebug = !bool.fromEnvironment('dart.vm.product');
    if (isDebug) {
      _logger.i(_sanitizeMessage(message));
    }
  }

  /// Logs a warning message, only in debug mode.
  void warning(String message) {
    const bool isDebug = !bool.fromEnvironment('dart.vm.product');
    if (isDebug) {
      _logger.w(_sanitizeMessage(message));
    }
  }

  /// Logs an error message with optional stack trace, only in debug mode.
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    const bool isDebug = !bool.fromEnvironment('dart.vm.product');
    if (isDebug) {
      _logger.e(
        _sanitizeMessage(message),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Logs API requests for debugging
  void apiRequest(String method, String url, {Map<String, dynamic>? data}) {
    const bool isDebug = !bool.fromEnvironment('dart.vm.product');
    if (isDebug) {
      final sanitizedUrl = _sanitizeMessage(url);
      final sanitizedData = data != null
          ? _sanitizeMessage(data.toString())
          : 'No data';
      _logger.i('🌐 API REQUEST [$method] $sanitizedUrl\nData: $sanitizedData');
    }
  }

  /// Logs API responses for debugging
  void apiResponse(String method, String url, int statusCode, {dynamic data}) {
    const bool isDebug = !bool.fromEnvironment('dart.vm.product');
    if (isDebug) {
      final sanitizedUrl = _sanitizeMessage(url);
      final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
      _logger.i(
        '$emoji API RESPONSE [$method] $sanitizedUrl\nStatus: $statusCode',
      );
      if (data != null) {
        _logger.d('Response data: ${_sanitizeMessage(data.toString())}');
      }
    }
  }

  /// Logs navigation events
  void navigation(String fromRoute, String toRoute) {
    const bool isDebug = !bool.fromEnvironment('dart.vm.product');
    if (isDebug) {
      _logger.i('🧭 NAVIGATION: $fromRoute → $toRoute');
    }
  }

  /// Logs user actions for analytics
  void userAction(String action, {Map<String, dynamic>? parameters}) {
    const bool isDebug = !bool.fromEnvironment('dart.vm.product');
    if (isDebug) {
      final params = parameters != null ? ' | Params: $parameters' : '';
      _logger.i('👤 USER ACTION: $action$params');
    }
  }

  /// Sanitizes messages to prevent logging sensitive data (e.g., API keys, passwords).
  String _sanitizeMessage(String message) {
    String sanitized = message;

    /// Replace sensitive data patterns (e.g., API keys, tokens)
    sanitized = sanitized.replaceAll(
      RegExp(r'api_key=[^&\s]*'),
      'api_key=****',
    );
    sanitized = sanitized.replaceAll(RegExp(r'passwd=[^&\s]*'), 'passwd=****');
    sanitized = sanitized.replaceAll(
      RegExp(r'password=[^&\s]*'),
      'password=****',
    );
    sanitized = sanitized.replaceAll(RegExp(r'token=[^&\s]*'), 'token=****');
    sanitized = sanitized.replaceAll(
      RegExp(r'authorization:\s*[^\s]*', caseSensitive: false),
      'authorization: ****',
    );
    sanitized = sanitized.replaceAll(
      RegExp(r'"password"\s*:\s*"[^"]*"'),
      '"password": "****"',
    );
    sanitized = sanitized.replaceAll(
      RegExp(r'"token"\s*:\s*"[^"]*"'),
      '"token": "****"',
    );
    return sanitized;
  }

  /// Static methods for quick access without instantiation
  static void logDebug(String message) => AppLogger().debug(message);
  static void logInfo(String message) => AppLogger().info(message);
  static void logWarning(String message) => AppLogger().warning(message);
  static void logError(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) => AppLogger().error(message, error, stackTrace);
}
