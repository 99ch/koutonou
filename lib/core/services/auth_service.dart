// auth_service.dart
// Provides authentication services for user login and signup via the PrestaShop proxy PHP.
// Ensures secure handling of credentials using flutter_secure_storage, validates inputs,
// and integrates with ApiClient for HTTP requests and BaseResponse for response parsing.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:koutonou/core/api/api_client.dart';
import 'package:koutonou/core/models/base_response.dart';
import 'package:koutonou/core/utils/error_handler.dart';
import 'package:koutonou/core/utils/logger.dart';

class AuthService {
  // Singleton instance for centralized authentication service
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ApiClient instance for HTTP requests
  final _apiClient = ApiClient();

  // Logger instance for debugging
  final _logger = AppLogger();

  // Error handler instance for user-friendly error messages
  final _errorHandler = ErrorHandler();

  // Secure storage for tokens and user data
  final _secureStorage = const FlutterSecureStorage();

  /// Logs in a user with email and password.
  /// Returns user data (e.g., { id: 1, email: "user@example.com" }) on success.
  /// Throws an error with a user-friendly message on failure.
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Validate inputs
    if (!_isValidEmail(email)) {
      throw _errorHandler.handleError(Exception('Invalid email format'));
    }
    if (password.isEmpty) {
      throw _errorHandler.handleError(Exception('Password cannot be empty'));
    }

    try {
      _logger.debug('Attempting login for email: $email');
      final response = await _apiClient.post(
        'login',
        data: {
          'email': email,
          'passwd': password,
        },
      );

      final baseResponse = BaseResponse<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      if (!baseResponse.success || baseResponse.data == null) {
        throw baseResponse.error?.userMessage ??
            'Login failed: Unknown error';
      }

      // Store user data securely
      await _secureStorage.write(
        key: 'user_data',
        value: baseResponse.data.toString(),
      );

      _logger.info('Login successful for email: $email');
      return baseResponse.data!;
    } catch (e, stackTrace) {
      _logger.error('Login failed for email: $email', e, stackTrace);
      throw _errorHandler.handleError(e, stackTrace);
    }
  }

  /// Signs up a new user with the provided customer data.
  /// Returns the user ID (e.g., { id: 1 }) on success.
  /// Throws an error with a user-friendly message on failure.
  Future<Map<String, dynamic>> signup(Map<String, dynamic> customerData) async {
    // Validate required fields
    if (!_isValidEmail(customerData['email'])) {
      throw _errorHandler.handleError(Exception('Invalid email format'));
    }
    if (customerData['passwd']?.isEmpty ?? true) {
      throw _errorHandler.handleError(Exception('Password cannot be empty'));
    }

    try {
      _logger.debug('Attempting signup for email: ${customerData['email']}');
      final response = await _apiClient.post(
        'signup',
        data: customerData,
      );

      final baseResponse = BaseResponse<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      if (!baseResponse.success || baseResponse.data == null) {
        throw baseResponse.error?.userMessage ??
            'Signup failed: Unknown error';
      }

      // Store user data securely
      await _secureStorage.write(
        key: 'user_data',
        value: baseResponse.data.toString(),
      );

      _logger.info('Signup successful for email: ${customerData['email']}');
      return baseResponse.data!;
    } catch (e, stackTrace) {
      _logger.error('Signup failed for email: ${customerData['email']}', e, stackTrace);
      throw _errorHandler.handleError(e, stackTrace);
    }
  }

  /// Logs out the user by clearing stored data.
  Future<void> logout() async {
    try {
      _logger.debug('Logging out user');
      await _secureStorage.delete(key: 'user_data');
      _logger.info('Logout successful');
    } catch (e, stackTrace) {
      _logger.error('Logout failed', e, stackTrace);
      throw _errorHandler.handleError(e, stackTrace);
    }
  }

  /// Retrieves stored user data from secure storage.
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userData = await _secureStorage.read(key: 'user_data');
      if (userData != null) {
        // Basic parsing of stored data (assumes JSON-like string)
        return Map<String, dynamic>.from(
          userData.replaceAll('{', '').replaceAll('}', '').split(',').asMap().map(
                (k, v) => MapEntry(
                  v.split(':')[0].trim(),
                  v.split(':')[1].trim(),
                ),
              ),
        );
      }
      return null;
    } catch (e, stackTrace) {
      _logger.error('Failed to retrieve user data', e, stackTrace);
      throw _errorHandler.handleError(e, stackTrace);
    }
  }

  /// Validates email format using a basic regex.
  bool _isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}