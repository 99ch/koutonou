// auth_provider.dart
// Manages the global authentication state using ChangeNotifier, allowing reactive updates
// to the UI. Integrates with AuthService for login, signup, and logout operations, and
// ensures secure handling of user data and errors.

import 'package:flutter/foundation.dart';
import 'package:koutonou/core/services/auth_service.dart';
import 'package:koutonou/core/utils/error_handler.dart';
import 'package:koutonou/core/utils/logger.dart';

class AuthProvider with ChangeNotifier {
  // AuthService instance for authentication operations
  final _authService = AuthService();

  // Logger instance for debugging
  final _logger = AppLogger();

  // Error handler instance for user-friendly error messages
  final _errorHandler = ErrorHandler();

  // Current user data (null if not logged in)
  Map<String, dynamic>? _userData;

  // Indicates if the user is logged in
  bool _isLoggedIn = false;

  // Indicates if an authentication operation is in progress
  bool _isLoading = false;

  // Error message for the UI (null if no error)
  String? _errorMessage;

  // Getters
  Map<String, dynamic>? get userData => _userData;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initializes the provider by checking for existing user data.
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
      _errorMessage = _errorHandler.handleError(e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs in a user with email and password.
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
      _errorMessage = _errorHandler.handleError(e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Signs up a new user with the provided customer data.
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
      _logger.error('Signup failed for email: ${customerData['email']}', e, stackTrace);
      _errorMessage = _errorHandler.handleError(e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs out the current user.
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
      _errorMessage = _errorHandler.handleError(e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}