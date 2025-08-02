// Provides authentication services for user login and signup via the PrestaShop proxy PHP.
// Ensures secure handling of credentials using flutter_secure_storage, validates inputs,
// and integrates with ApiClient for HTTP requests and BaseResponse for response parsing.

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:koutonou/core/api/api_client.dart';
import 'package:koutonou/core/exceptions/api_exception.dart';
import 'package:koutonou/core/exceptions/validation_exception.dart';
import 'package:koutonou/core/utils/logger.dart';

class AuthService {
  /// Singleton instance for centralized authentication service
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// ApiClient instance for HTTP requests
  final _apiClient = ApiClient();

  /// Logger instance for debugging
  static final _logger = AppLogger();

  /// Secure storage for tokens and user data
  static const _secureStorage = FlutterSecureStorage();

  /// Storage keys
  static const String _userDataKey = 'user_data';
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Current user data cache
  Map<String, dynamic>? _cachedUserData;

  /// Logs in a user with email and password.
  /// Returns user data on success.
  /// Throws an appropriate exception on failure.
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Validate inputs
      _validateLoginInput(email, password);

      _logger.debug('Attempting login for email: $email');

      final response = await _apiClient.post(
        'login',
        data: {'email': email, 'passwd': password},
      );

      if (!response.success || response.data == null) {
        throw AuthenticationException(
          response.message,
          statusCode: response.statusCode,
        );
      }

      final userData = response.data!;

      // Store user data and tokens securely
      await _storeUserData(userData);

      // Cache user data
      _cachedUserData = userData;

      _logger.info('Login successful for email: $email');
      return userData;
    } catch (e, stackTrace) {
      _logger.error('Login failed for email: $email', e, stackTrace);

      if (e is ApiException || e is ValidationException) {
        rethrow;
      }

      throw AuthenticationException('Login failed: ${e.toString()}');
    }
  }

  /// Signs up a new user with the provided customer data.
  /// Returns the created user data on success.
  /// Throws an appropriate exception on failure.
  Future<Map<String, dynamic>> signup(Map<String, dynamic> customerData) async {
    try {
      // Validate required fields
      _validateSignupData(customerData);

      _logger.debug('Attempting signup for email: ${customerData['email']}');

      final response = await _apiClient.post('signup', data: customerData);

      if (!response.success || response.data == null) {
        throw AuthenticationException(
          response.message,
          statusCode: response.statusCode,
        );
      }

      final userData = response.data!;

      // Store user data and tokens securely
      await _storeUserData(userData);

      // Cache user data
      _cachedUserData = userData;

      _logger.info('Signup successful for email: ${customerData['email']}');
      return userData;
    } catch (e, stackTrace) {
      _logger.error(
        'Signup failed for email: ${customerData['email']}',
        e,
        stackTrace,
      );

      if (e is ApiException || e is ValidationException) {
        rethrow;
      }

      throw AuthenticationException('Signup failed: ${e.toString()}');
    }
  }

  /// Logs out the user by clearing stored data.
  Future<void> logout() async {
    try {
      _logger.debug('Logging out user');

      // Clear all stored authentication data
      await Future.wait([
        _secureStorage.delete(key: _userDataKey),
        _secureStorage.delete(key: _authTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
      ]);

      // Clear cached data
      _cachedUserData = null;

      _logger.info('Logout successful');
    } catch (e, stackTrace) {
      _logger.error('Logout failed', e, stackTrace);
      throw AuthenticationException('Logout failed: ${e.toString()}');
    }
  }

  /// Retrieves stored user data from secure storage or cache.
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      // Return cached data if available
      if (_cachedUserData != null) {
        return _cachedUserData;
      }

      // Read from secure storage
      final userData = await _secureStorage.read(key: _userDataKey);
      if (userData != null && userData.isNotEmpty) {
        final decodedData = jsonDecode(userData) as Map<String, dynamic>;
        _cachedUserData = decodedData;
        return decodedData;
      }

      return null;
    } catch (e, stackTrace) {
      _logger.error('Failed to retrieve user data', e, stackTrace);
      return null;
    }
  }

  /// Checks if user is currently logged in.
  Future<bool> isLoggedIn() async {
    final userData = await getUserData();
    return userData != null;
  }

  /// Gets the current auth token.
  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: _authTokenKey);
    } catch (e) {
      _logger.error('Failed to retrieve auth token', e);
      return null;
    }
  }

  /// Updates the auth token (called by ApiConfig when token is refreshed).
  Future<void> updateAuthToken(String token) async {
    try {
      await _secureStorage.write(key: _authTokenKey, value: token);
      _logger.debug('Auth token updated');
    } catch (e, stackTrace) {
      _logger.error('Failed to update auth token', e, stackTrace);
    }
  }

  /// Refreshes the authentication token.
  Future<String?> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        throw AuthenticationException('No refresh token available');
      }

      _logger.debug('Attempting to refresh auth token');

      final response = await _apiClient.post(
        'refresh-token',
        data: {'refresh_token': refreshToken},
      );

      if (!response.success || response.data == null) {
        throw AuthenticationException(
          'Token refresh failed: ${response.message}',
          statusCode: response.statusCode,
        );
      }

      final newToken = response.data!['access_token'] as String?;
      final newRefreshToken = response.data!['refresh_token'] as String?;

      if (newToken != null) {
        await updateAuthToken(newToken);
      }

      if (newRefreshToken != null) {
        await _secureStorage.write(
          key: _refreshTokenKey,
          value: newRefreshToken,
        );
      }

      _logger.info('Token refresh successful');
      return newToken;
    } catch (e, stackTrace) {
      _logger.error('Token refresh failed', e, stackTrace);

      // If refresh fails, logout the user
      await logout();

      if (e is AuthenticationException) {
        rethrow;
      }

      throw AuthenticationException('Token refresh failed: ${e.toString()}');
    }
  }

  /// Requests a password reset for the given email.
  Future<void> requestPasswordReset(String email) async {
    try {
      if (!_isValidEmail(email)) {
        throw ValidationException.field('email', 'Invalid email format');
      }

      _logger.debug('Requesting password reset for email: $email');

      final response = await _apiClient.post(
        'request-password-reset',
        data: {'email': email},
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      _logger.info('Password reset requested for email: $email');
    } catch (e, stackTrace) {
      _logger.error(
        'Password reset request failed for email: $email',
        e,
        stackTrace,
      );

      if (e is ApiException || e is ValidationException) {
        rethrow;
      }

      throw ApiException.create(
        'Password reset request failed: ${e.toString()}',
      );
    }
  }

  /// Resets password using a reset token.
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      if (token.isEmpty) {
        throw ValidationException.field('token', 'Reset token is required');
      }

      if (newPassword.length < 6) {
        throw ValidationException.field(
          'password',
          'Password must be at least 6 characters long',
        );
      }

      _logger.debug('Attempting password reset with token');

      final response = await _apiClient.post(
        'reset-password',
        data: {'token': token, 'new_password': newPassword},
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      _logger.info('Password reset successful');
    } catch (e, stackTrace) {
      _logger.error('Password reset failed', e, stackTrace);

      if (e is ApiException || e is ValidationException) {
        rethrow;
      }

      throw ApiException.create('Password reset failed: ${e.toString()}');
    }
  }

  /// Updates user profile data.
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      _validateProfileData(profileData);

      _logger.debug('Updating user profile');

      final response = await _apiClient.put(
        'profile',
        await _getCurrentUserId(),
        data: profileData,
      );

      if (!response.success || response.data == null) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      final updatedUserData = response.data!;

      // Update stored user data
      await _storeUserData(updatedUserData);
      _cachedUserData = updatedUserData;

      _logger.info('Profile updated successfully');
      return updatedUserData;
    } catch (e, stackTrace) {
      _logger.error('Profile update failed', e, stackTrace);

      if (e is ApiException || e is ValidationException) {
        rethrow;
      }

      throw ApiException.create('Profile update failed: ${e.toString()}');
    }
  }

  /// Private helper methods

  /// Validates login input data.
  void _validateLoginInput(String email, String password) {
    if (!_isValidEmail(email)) {
      throw ValidationException.field('email', 'Invalid email format');
    }

    if (password.isEmpty) {
      throw ValidationException.field('password', 'Password cannot be empty');
    }
  }

  /// Validates signup data.
  void _validateSignupData(Map<String, dynamic> data) {
    final errors = <String, List<String>>{};

    if (!_isValidEmail(data['email'])) {
      errors['email'] = ['Invalid email format'];
    }

    if (data['passwd']?.isEmpty ?? true) {
      errors['passwd'] = ['Password cannot be empty'];
    } else if ((data['passwd'] as String).length < 6) {
      errors['passwd'] = ['Password must be at least 6 characters long'];
    }

    if (data['firstname']?.isEmpty ?? true) {
      errors['firstname'] = ['First name is required'];
    }

    if (data['lastname']?.isEmpty ?? true) {
      errors['lastname'] = ['Last name is required'];
    }

    if (errors.isNotEmpty) {
      throw ValidationException.fields(errors);
    }
  }

  /// Validates profile update data.
  void _validateProfileData(Map<String, dynamic> data) {
    final errors = <String, List<String>>{};

    if (data.containsKey('email') && !_isValidEmail(data['email'])) {
      errors['email'] = ['Invalid email format'];
    }

    if (data.containsKey('firstname') && (data['firstname']?.isEmpty ?? true)) {
      errors['firstname'] = ['First name cannot be empty'];
    }

    if (data.containsKey('lastname') && (data['lastname']?.isEmpty ?? true)) {
      errors['lastname'] = ['Last name cannot be empty'];
    }

    if (errors.isNotEmpty) {
      throw ValidationException.fields(errors);
    }
  }

  /// Stores user data securely.
  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    final userDataJson = jsonEncode(userData);

    final futures = <Future<void>>[
      _secureStorage.write(key: _userDataKey, value: userDataJson),
    ];

    // Store auth token if present
    if (userData.containsKey('access_token')) {
      futures.add(
        _secureStorage.write(
          key: _authTokenKey,
          value: userData['access_token'],
        ),
      );
    }

    // Store refresh token if present
    if (userData.containsKey('refresh_token')) {
      futures.add(
        _secureStorage.write(
          key: _refreshTokenKey,
          value: userData['refresh_token'],
        ),
      );
    }

    await Future.wait(futures);
  }

  /// Gets current user ID from stored data.
  Future<String> _getCurrentUserId() async {
    final userData = await getUserData();
    if (userData == null || !userData.containsKey('id')) {
      throw AuthenticationException('User not logged in');
    }
    return userData['id'].toString();
  }

  /// Validates email format using a regex.
  bool _isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Clears all cached data (useful for testing).
  void clearCache() {
    _cachedUserData = null;
  }

  /// Gets debug information about the auth state.
  Future<Map<String, dynamic>> getDebugInfo() async {
    return {
      'isLoggedIn': await isLoggedIn(),
      'hasUserData': _cachedUserData != null,
      'hasCachedData': _cachedUserData != null,
      'hasAuthToken': await getAuthToken() != null,
    };
  }
}
