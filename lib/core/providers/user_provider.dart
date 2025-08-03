// Manages the global user state using ChangeNotifier for reactive UI updates.
// Integrates with UserService for profile management, preferences, addresses,
// favorites, and activity history. Provides caching and error handling.

import 'package:flutter/material.dart';
import 'package:koutonou/core/services/user_service.dart';
import 'package:koutonou/core/utils/error_handler.dart';
import 'package:koutonou/core/utils/logger.dart';

class UserProvider with ChangeNotifier {
  /// UserService instance for user operations
  final _userService = UserService();

  /// Logger instance for debugging
  final _logger = AppLogger();

  /// Helper method to get readable error message
  String _getReadableError(dynamic error) {
    final result = ErrorHandler.handle(error, logError: false);
    return result.userMessage;
  }

  /// Current user profile
  UserProfile? _userProfile;

  /// User preferences
  UserPreferences? _userPreferences;

  /// User addresses
  List<Address> _addresses = [];

  /// User favorites
  List<Product> _favorites = [];

  /// User order history
  List<Order> _orderHistory = [];

  /// User activity history
  List<UserActivity> _activityHistory = [];

  /// User statistics
  UserStats? _userStats;

  /// Loading states
  bool _isLoadingProfile = false;
  bool _isLoadingPreferences = false;
  bool _isLoadingAddresses = false;
  bool _isLoadingFavorites = false;
  bool _isLoadingOrders = false;
  bool _isLoadingActivity = false;
  bool _isLoadingStats = false;

  /// Error states
  String? _profileError;
  String? _preferencesError;
  String? _addressesError;
  String? _favoritesError;
  String? _ordersError;
  String? _activityError;
  String? _statsError;

  /// Getters
  UserProfile? get userProfile => _userProfile;
  UserPreferences? get userPreferences => _userPreferences;
  List<Address> get addresses => List.unmodifiable(_addresses);
  List<Product> get favorites => List.unmodifiable(_favorites);
  List<Order> get orderHistory => List.unmodifiable(_orderHistory);
  List<UserActivity> get activityHistory => List.unmodifiable(_activityHistory);
  UserStats? get userStats => _userStats;

  /// Loading state getters
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isLoadingPreferences => _isLoadingPreferences;
  bool get isLoadingAddresses => _isLoadingAddresses;
  bool get isLoadingFavorites => _isLoadingFavorites;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isLoadingActivity => _isLoadingActivity;
  bool get isLoadingStats => _isLoadingStats;

  /// Error getters
  String? get profileError => _profileError;
  String? get preferencesError => _preferencesError;
  String? get addressesError => _addressesError;
  String? get favoritesError => _favoritesError;
  String? get ordersError => _ordersError;
  String? get activityError => _activityError;
  String? get statsError => _statsError;

  /// Helper getters
  bool get hasProfile => _userProfile != null;
  bool get hasPreferences => _userPreferences != null;
  bool get hasAddresses => _addresses.isNotEmpty;
  bool get hasFavorites => _favorites.isNotEmpty;
  bool get hasOrders => _orderHistory.isNotEmpty;
  bool get isAnyLoading =>
      _isLoadingProfile ||
      _isLoadingPreferences ||
      _isLoadingAddresses ||
      _isLoadingFavorites ||
      _isLoadingOrders ||
      _isLoadingActivity ||
      _isLoadingStats;

  /// Profile Management

  /// Load user profile
  Future<void> loadProfile(String userId) async {
    if (_isLoadingProfile) return;

    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    try {
      _logger.debug('Loading user profile: $userId');
      _userProfile = await _userService.getProfile(userId);
      _logger.info('User profile loaded successfully');
    } catch (e, stackTrace) {
      _profileError = _getReadableError(e);
      _logger.error('Failed to load user profile', e, stackTrace);
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile(UserProfile profile) async {
    if (_isLoadingProfile) return false;

    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    try {
      _logger.debug('Updating user profile');
      _userProfile = await _userService.updateProfile(profile);
      _logger.info('User profile updated successfully');
      return true;
    } catch (e, stackTrace) {
      _profileError = _getReadableError(e);
      _logger.error('Failed to update user profile', e, stackTrace);
      return false;
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  /// Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      _logger.debug('Changing user password');
      await _userService.changePassword(oldPassword, newPassword);
      _logger.info('Password changed successfully');
      return true;
    } catch (e, stackTrace) {
      _profileError = _getReadableError(e);
      _logger.error('Failed to change password', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Preferences Management

  /// Load user preferences
  Future<void> loadPreferences() async {
    if (_isLoadingPreferences) return;

    _isLoadingPreferences = true;
    _preferencesError = null;
    notifyListeners();

    try {
      _logger.debug('Loading user preferences');
      _userPreferences = await _userService.getPreferences();
      _logger.info('User preferences loaded successfully');
    } catch (e, stackTrace) {
      _preferencesError = _getReadableError(e);
      _logger.error('Failed to load user preferences', e, stackTrace);
    } finally {
      _isLoadingPreferences = false;
      notifyListeners();
    }
  }

  /// Update user preferences
  Future<bool> updatePreferences(UserPreferences preferences) async {
    if (_isLoadingPreferences) return false;

    _isLoadingPreferences = true;
    _preferencesError = null;
    notifyListeners();

    try {
      _logger.debug('Updating user preferences');
      await _userService.updatePreferences(preferences);
      _userPreferences = preferences;
      _logger.info('User preferences updated successfully');
      return true;
    } catch (e, stackTrace) {
      _preferencesError = _getReadableError(e);
      _logger.error('Failed to update user preferences', e, stackTrace);
      return false;
    } finally {
      _isLoadingPreferences = false;
      notifyListeners();
    }
  }

  /// Set language preference
  Future<bool> setLanguage(String languageCode) async {
    try {
      await _userService.setLanguage(languageCode);
      if (_userPreferences != null) {
        _userPreferences!.language = languageCode;
        notifyListeners();
      }
      return true;
    } catch (e, stackTrace) {
      _preferencesError = _getReadableError(e);
      _logger.error('Failed to set language', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Set theme preference
  Future<bool> setTheme(ThemeMode theme) async {
    try {
      await _userService.setTheme(theme);
      if (_userPreferences != null) {
        _userPreferences!.themeMode = theme;
        notifyListeners();
      }
      return true;
    } catch (e, stackTrace) {
      _preferencesError = _getReadableError(e);
      _logger.error('Failed to set theme', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Address Management

  /// Load user addresses
  Future<void> loadAddresses() async {
    if (_isLoadingAddresses) return;

    _isLoadingAddresses = true;
    _addressesError = null;
    notifyListeners();

    try {
      _logger.debug('Loading user addresses');
      _addresses = await _userService.getUserAddresses();
      _logger.info('User addresses loaded successfully');
    } catch (e, stackTrace) {
      _addressesError = _getReadableError(e);
      _logger.error('Failed to load user addresses', e, stackTrace);
    } finally {
      _isLoadingAddresses = false;
      notifyListeners();
    }
  }

  /// Add new address
  Future<bool> addAddress(Address address) async {
    try {
      _logger.debug('Adding new address');
      final newAddress = await _userService.addAddress(address);
      _addresses.add(newAddress);
      _logger.info('Address added successfully');
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _addressesError = _getReadableError(e);
      _logger.error('Failed to add address', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Update existing address
  Future<bool> updateAddress(String addressId, Address address) async {
    try {
      _logger.debug('Updating address: $addressId');
      final updatedAddress = await _userService.updateAddress(
        addressId,
        address,
      );

      final index = _addresses.indexWhere((addr) => addr.id == addressId);
      if (index != -1) {
        _addresses[index] = updatedAddress;
      }

      _logger.info('Address updated successfully');
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _addressesError = _getReadableError(e);
      _logger.error('Failed to update address', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Delete address
  Future<bool> deleteAddress(String addressId) async {
    try {
      _logger.debug('Deleting address: $addressId');
      await _userService.deleteAddress(addressId);
      _addresses.removeWhere((addr) => addr.id == addressId);
      _logger.info('Address deleted successfully');
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _addressesError = _getReadableError(e);
      _logger.error('Failed to delete address', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Set default address
  Future<bool> setDefaultAddress(String addressId) async {
    try {
      _logger.debug('Setting default address: $addressId');
      await _userService.setDefaultAddress(addressId);

      // Update local state
      for (final address in _addresses) {
        address.isDefault = address.id == addressId;
      }

      _logger.info('Default address set successfully');
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _addressesError = _getReadableError(e);
      _logger.error('Failed to set default address', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Get default address
  Address? get defaultAddress {
    return _addresses.firstWhere(
      (address) => address.isDefault,
      orElse: () => _addresses.isNotEmpty
          ? _addresses.first
          : Address(
              street: '',
              city: '',
              postalCode: '',
              state: '',
              country: '',
            ),
    );
  }

  /// Favorites Management

  /// Load user favorites
  Future<void> loadFavorites() async {
    if (_isLoadingFavorites) return;

    _isLoadingFavorites = true;
    _favoritesError = null;
    notifyListeners();

    try {
      _logger.debug('Loading user favorites');
      _favorites = await _userService.getFavorites();
      _logger.info('User favorites loaded successfully');
    } catch (e, stackTrace) {
      _favoritesError = _getReadableError(e);
      _logger.error('Failed to load user favorites', e, stackTrace);
    } finally {
      _isLoadingFavorites = false;
      notifyListeners();
    }
  }

  /// Add product to favorites
  Future<bool> addToFavorites(String productId) async {
    try {
      _logger.debug('Adding product to favorites: $productId');
      await _userService.addToFavorites(productId);

      // Reload favorites to get updated list
      await loadFavorites();

      _logger.info('Product added to favorites successfully');
      return true;
    } catch (e, stackTrace) {
      _favoritesError = _getReadableError(e);
      _logger.error('Failed to add to favorites', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Remove product from favorites
  Future<bool> removeFromFavorites(String productId) async {
    try {
      _logger.debug('Removing product from favorites: $productId');
      await _userService.removeFromFavorites(productId);

      // Remove from local list
      _favorites.removeWhere((product) => product.id == productId);

      _logger.info('Product removed from favorites successfully');
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _favoritesError = _getReadableError(e);
      _logger.error('Failed to remove from favorites', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Check if product is in favorites
  bool isFavorite(String productId) {
    return _favorites.any((product) => product.id == productId);
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String productId) async {
    if (isFavorite(productId)) {
      return await removeFromFavorites(productId);
    } else {
      return await addToFavorites(productId);
    }
  }

  /// Activity and History

  /// Load user activity history
  Future<void> loadActivityHistory({int limit = 50}) async {
    if (_isLoadingActivity) return;

    _isLoadingActivity = true;
    _activityError = null;
    notifyListeners();

    try {
      _logger.debug('Loading user activity history');
      _activityHistory = await _userService.getActivityHistory(limit: limit);
      _logger.info('User activity history loaded successfully');
    } catch (e, stackTrace) {
      _activityError = _getReadableError(e);
      _logger.error('Failed to load user activity history', e, stackTrace);
    } finally {
      _isLoadingActivity = false;
      notifyListeners();
    }
  }

  /// Load user order history
  Future<void> loadOrderHistory({int limit = 20}) async {
    if (_isLoadingOrders) return;

    _isLoadingOrders = true;
    _ordersError = null;
    notifyListeners();

    try {
      _logger.debug('Loading user order history');
      _orderHistory = await _userService.getOrderHistory(limit: limit);
      _logger.info('User order history loaded successfully');
    } catch (e, stackTrace) {
      _ordersError = _getReadableError(e);
      _logger.error('Failed to load user order history', e, stackTrace);
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  /// Load user statistics
  Future<void> loadUserStats() async {
    if (_isLoadingStats) return;

    _isLoadingStats = true;
    _statsError = null;
    notifyListeners();

    try {
      _logger.debug('Loading user statistics');
      _userStats = await _userService.getUserStats();
      _logger.info('User statistics loaded successfully');
    } catch (e, stackTrace) {
      _statsError = _getReadableError(e);
      _logger.error('Failed to load user statistics', e, stackTrace);
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  /// Verification Management

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      _logger.debug('Sending email verification');
      await _userService.sendVerificationEmail();
      _logger.info('Email verification sent successfully');
      return true;
    } catch (e, stackTrace) {
      _profileError = _getReadableError(e);
      _logger.error('Failed to send email verification', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Verify email with token
  Future<bool> verifyEmail(String token) async {
    try {
      _logger.debug('Verifying email with token');
      final success = await _userService.verifyEmail(token);

      if (success && _userProfile != null) {
        _userProfile!.isEmailVerified = true;
        notifyListeners();
      }

      return success;
    } catch (e, stackTrace) {
      _profileError = _getReadableError(e);
      _logger.error('Failed to verify email', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Send phone verification
  Future<bool> sendPhoneVerification(String phoneNumber) async {
    try {
      _logger.debug('Sending phone verification');
      await _userService.sendPhoneVerification(phoneNumber);
      _logger.info('Phone verification sent successfully');
      return true;
    } catch (e, stackTrace) {
      _profileError = _getReadableError(e);
      _logger.error('Failed to send phone verification', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Verify phone with code
  Future<bool> verifyPhone(String code) async {
    try {
      _logger.debug('Verifying phone with code');
      final success = await _userService.verifyPhone(code);

      if (success && _userProfile != null) {
        _userProfile!.isPhoneVerified = true;
        notifyListeners();
      }

      return success;
    } catch (e, stackTrace) {
      _profileError = _getReadableError(e);
      _logger.error('Failed to verify phone', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Utility Methods

  /// Load all user data
  Future<void> loadAllUserData(String userId) async {
    final futures = [
      loadProfile(userId),
      loadPreferences(),
      loadAddresses(),
      loadFavorites(),
      loadOrderHistory(),
      loadActivityHistory(),
      loadUserStats(),
    ];

    await Future.wait(futures);
  }

  /// Refresh all data
  Future<void> refreshAllData() async {
    if (_userProfile?.id != null) {
      await loadAllUserData(_userProfile!.id);
    }
  }

  /// Clear all data (on logout)
  void clearAllData() {
    _userProfile = null;
    _userPreferences = null;
    _addresses.clear();
    _favorites.clear();
    _orderHistory.clear();
    _activityHistory.clear();
    _userStats = null;

    // Clear errors
    _profileError = null;
    _preferencesError = null;
    _addressesError = null;
    _favoritesError = null;
    _ordersError = null;
    _activityError = null;
    _statsError = null;

    // Reset loading states
    _isLoadingProfile = false;
    _isLoadingPreferences = false;
    _isLoadingAddresses = false;
    _isLoadingFavorites = false;
    _isLoadingOrders = false;
    _isLoadingActivity = false;
    _isLoadingStats = false;

    _logger.info('User provider data cleared');
    notifyListeners();
  }

  /// Clear specific error
  void clearError(String errorType) {
    switch (errorType) {
      case 'profile':
        _profileError = null;
        break;
      case 'preferences':
        _preferencesError = null;
        break;
      case 'addresses':
        _addressesError = null;
        break;
      case 'favorites':
        _favoritesError = null;
        break;
      case 'orders':
        _ordersError = null;
        break;
      case 'activity':
        _activityError = null;
        break;
      case 'stats':
        _statsError = null;
        break;
    }
    notifyListeners();
  }

  /// Clear all errors
  void clearAllErrors() {
    _profileError = null;
    _preferencesError = null;
    _addressesError = null;
    _favoritesError = null;
    _ordersError = null;
    _activityError = null;
    _statsError = null;
    notifyListeners();
  }
}
