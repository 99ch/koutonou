/// logger.dart
/// Provides a secure logging utility for debugging API requests, errors, and app events.
/// Logging is enabled only in debug mode to prevent sensitive data exposure in production.
/// Uses the `logger` package for structured and readable logs.

import 'package:koutonou/core/utils/constants.dart';
import 'package:logger/logger.dart';

class AppLogger {
  /// Singleton instance of the logger
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  /// Logger instance from the `logger` package
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, /// Show 2 levels of stack trace
      errorMethodCount: 8, /// Show more stack trace for errors
      lineLength: 120, /// Line length for readable output
      colors: true, /// Enable colors in debug console
      printEmojis: true, /// Add emojis for visual clarity
      printTime: true, /// Include timestamp in logs
    ),
  );

  //// Logs a debug message, only in debug mode.
  void debug(String message) {
    if (AppConstants.isDebugMode) {
      _logger.d(_sanitizeMessage(message));
    }
  }

  //// Logs an info message, only in debug mode.
  void info(String message) {
    if (AppConstants.isDebugMode) {
      _logger.i(_sanitizeMessage(message));
    }
  }

  //// Logs a warning message, only in debug mode.
  void warning(String message) {
    if (AppConstants.isDebugMode) {
      _logger.w(_sanitizeMessage(message));
    }
  }

  //// Logs an error message with optional stack trace, only in debug mode.
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConstants.isDebugMode) {
      _logger.e(_sanitizeMessage(message), error: error, stackTrace: stackTrace);
    }
  }

  //// Sanitizes messages to prevent logging sensitive data (e.g., API keys, passwords).
  String _sanitizeMessage(String message) {
    String sanitized = message;
    /// Replace sensitive data patterns (e.g., API keys, tokens)
    sanitized = sanitized.replaceAll(RegExp(r'api_key=[^&]*'), 'api_key=****');
    sanitized = sanitized.replaceAll(RegExp(r'passwd=[^&]*'), 'passwd=****');
    sanitized = sanitized.replaceAll(RegExp(r'token=[^&]*'), 'token=****');
    return sanitized;
  }
}