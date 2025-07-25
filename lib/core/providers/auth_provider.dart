
// Manages the global authentication state using ChangeNotifier, allowing reactive updates
// to the UI. Integrates with AuthService for login, signup, and logout operations, and
// ensures secure handling of user data and errors.

import 'package:flutter/foundation.dart';
import 'package:koutonou/core/services/auth_service.dart';
import 'package:koutonou/core/utils/error_handler.dart';
import 'package:koutonou/core/utils/logger.dart';

class AuthProvider with ChangeNotifier {
  /// AuthService instance for authentication operations
  final _authService = AuthService();

  /// Logger instance for debugging
  final _logger = AppLogger();

  /// Helper method to get readable error message
  String _getReadableError(dynamic error) {
    final result = ErrorHandler.handle(error, logError: false);
    return result.userMessage;
  }

  /// Current user data (null if not logged in)
  Map<String, dynamic>? _userData;

  /// Indicates if the user is logged in
  bool _isLoggedIn = false;

  /// Indicates if an authentication operation is in progress
  bool _isLoading = false;

  /// Error message for the UI (null if no error)
  String? _errorMessage;

  /// Getters
  Map<String, dynamic>? get userData => _userData;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Helper getters
  bool get hasError => _errorMessage != null;
  String? get userEmail => _userData?['email'];
  String? get userId => _userData?['id']?.toString();
  String? get userName =>
      _userData?['firstname'] != null && _userData?['lastname'] != null
      ? '${_userData!['firstname']} ${_userData!['lastname']}'
      : _userData?['email'];

  //// Initializes the provider by checking for existing user data.
  Future<void> initialize() async {
    _logger.debug('Initializing AuthProvider');
    try {
      _isLoading = true;
      notifyListeners();

      _userData = await _authService.getUserData();
      _isLoggedIn = _userData != null;
      _logger.info('AuthProvider initialized: isLoggedIn=$_isLoggedIn');
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize AuthProvider', e, stackTrace);
      _errorMessage = _getReadableError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //// Logs in a user with email and password.
  Future<void> login(String email, String password) async {
    _logger.debug('Login attempt for email: $email');
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _userData = await _authService.login(email, password);
      _isLoggedIn = true;
      _logger.info('Login successful for email: $email');
    } catch (e, stackTrace) {
      _logger.error('Login failed for email: $email', e, stackTrace);
      _errorMessage = _getReadableError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //// Signs up a new user with the provided customer data.
  Future<void> signup(Map<String, dynamic> customerData) async {
    _logger.debug('Signup attempt for email: ${customerData['email']}');
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _userData = await _authService.signup(customerData);
      _isLoggedIn = true;
      _logger.info('Signup successful for email: ${customerData['email']}');
    } catch (e, stackTrace) {
      _logger.error(
        'Signup failed for email: ${customerData['email']}',
        e,
        stackTrace,
      );
      _errorMessage = _getReadableError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //// Logs out the current user.
  Future<void> logout() async {
    _logger.debug('Logout attempt');
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.logout();
      _userData = null;
      _isLoggedIn = false;
      _logger.info('Logout successful');
    } catch (e, stackTrace) {
      _logger.error('Logout failed', e, stackTrace);
      _errorMessage = _getReadableError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Check if user has specific role
  bool hasRole(String role) {
    return _userData?['role'] == role;
  }

  /// Check if user is admin
  bool get isAdmin => hasRole('admin');

  /// Check if user is verified
  bool get isEmailVerified => _userData?['is_email_verified'] == true;
  bool get isPhoneVerified => _userData?['is_phone_verified'] == true;

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (!_isLoggedIn) return;

    try {
      _userData = await _authService.getUserData();
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.error('Failed to refresh user data', e, stackTrace);
      _errorMessage = _getReadableError(e);
      notifyListeners();
    }
  }

  /// Request password reset
  Future<bool> requestPasswordReset(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.requestPasswordReset(email);
      _logger.info('Password reset requested for email: $email');
      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Password reset request failed for email: $email',
        e,
        stackTrace,
      );
      _errorMessage = _getReadableError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset password with token
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(token, newPassword);
      _logger.info('Password reset successful');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Password reset failed', e, stackTrace);
      _errorMessage = _getReadableError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _userData = await _authService.updateProfile(profileData);
      _logger.info('Profile updated successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Profile update failed', e, stackTrace);
      _errorMessage = _getReadableError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get auth token
  Future<String?> getAuthToken() async {
    return await _authService.getAuthToken();
  }

  /// Refresh auth token
  Future<bool> refreshAuthToken() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final newToken = await _authService.refreshToken();
      if (newToken != null) {
        _logger.info('Auth token refreshed successfully');
        return true;
      } else {
        // Token refresh failed, user logged out automatically
        _userData = null;
        _isLoggedIn = false;
        _errorMessage = 'Session expired. Please login again.';
        return false;
      }
    } catch (e, stackTrace) {
      _logger.error('Token refresh failed', e, stackTrace);
      _errorMessage = _getReadableError(e);

      // If refresh fails, logout the user
      _userData = null;
      _isLoggedIn = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get debug information
  Future<Map<String, dynamic>> getDebugInfo() async {
    return await _authService.getDebugInfo();
  }
}
