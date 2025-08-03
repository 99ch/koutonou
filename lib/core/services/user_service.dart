// Provides advanced user management services for the Koutonou application.
// This service handles user profiles, preferences, addresses, activity history,
// favorites, and verification processes. Built on top of AuthService.

import 'package:flutter/material.dart';
import 'package:koutonou/core/api/api_client.dart';
import 'package:koutonou/core/exceptions/api_exception.dart';
import 'package:koutonou/core/exceptions/validation_exception.dart';
import 'package:koutonou/core/services/auth_service.dart';
import 'package:koutonou/core/services/cache_service.dart';
import 'package:koutonou/core/utils/logger.dart';

class UserService {
  /// Singleton instance for centralized user service
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  /// Dependencies
  final _apiClient = ApiClient();
  final _authService = AuthService();
  final _cacheService = CacheService();
  static final _logger = AppLogger();

  /// Cache keys
  static const String _preferencesCacheKey = 'user_preferences_';
  static const String _addressesCacheKey = 'user_addresses_';
  static const String _favoritesCacheKey = 'user_favorites_';
  static const String _activityCacheKey = 'user_activity_';
  static const String _ordersCacheKey = 'user_orders_';

  /// Profile Management

  /// Get user profile with caching
  Future<UserProfile> getProfile(String userId) async {
    try {
      _logger.debug('Getting profile for user: $userId');

      // Try cache first
      final cached = await _cacheService.getCachedUserData(userId);
      if (cached != null) {
        _logger.debug('Profile loaded from cache for user: $userId');
        return UserProfile.fromJson(cached);
      }

      // Fetch from server
      final response = await _apiClient.get('users/$userId/profile');

      if (!response.success || response.data == null) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      final profile = UserProfile.fromJson(response.data!);

      // Cache the profile
      await _cacheService.cacheUserData(userId, response.data!);

      _logger.info('Profile loaded for user: $userId');
      return profile;
    } catch (e, stackTrace) {
      _logger.error('Failed to get profile for user: $userId', e, stackTrace);
      rethrow;
    }
  }

  /// Update user profile
  Future<UserProfile> updateProfile(UserProfile profile) async {
    try {
      _validateProfile(profile);

      final userId = await _getCurrentUserId();
      _logger.debug('Updating profile for user: $userId');

      final response = await _apiClient.put(
        'users/$userId/profile',
        userId,
        data: profile.toJson(),
      );

      if (!response.success || response.data == null) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      final updatedProfile = UserProfile.fromJson(response.data!);

      // Update cache
      await _cacheService.cacheUserData(userId, response.data!);

      // Invalidate related caches
      await _cacheService.invalidateCache('user_${userId}_.*');

      _logger.info('Profile updated for user: $userId');
      return updatedProfile;
    } catch (e, stackTrace) {
      _logger.error('Failed to update profile', e, stackTrace);
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final userId = await _getCurrentUserId();
      _logger.debug('Deleting account for user: $userId');

      final response = await _apiClient.delete('users', userId);

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      // Clear all user data
      await _authService.logout();
      await _cacheService.invalidateCache('user_${userId}_.*');

      _logger.info('Account deleted for user: $userId');
    } catch (e, stackTrace) {
      _logger.error('Failed to delete account', e, stackTrace);
      rethrow;
    }
  }

  /// Change user password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      _validatePassword(newPassword);

      final userId = await _getCurrentUserId();
      _logger.debug('Changing password for user: $userId');

      final response = await _apiClient.post(
        'users/$userId/change-password',
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      _logger.info('Password changed for user: $userId');
    } catch (e, stackTrace) {
      _logger.error('Failed to change password', e, stackTrace);
      rethrow;
    }
  }

  /// Preferences Management

  /// Get user preferences
  Future<UserPreferences> getPreferences() async {
    try {
      final userId = await _getCurrentUserId();
      final cacheKey = '$_preferencesCacheKey$userId';

      // Try cache first
      final cached = await _cacheService.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        return UserPreferences.fromJson(cached);
      }

      _logger.debug('Getting preferences for user: $userId');

      final response = await _apiClient.get('users/$userId/preferences');

      if (!response.success || response.data == null) {
        // Return default preferences if none exist
        return UserPreferences.defaultPreferences();
      }

      final preferences = UserPreferences.fromJson(response.data!);

      // Cache preferences
      await _cacheService.set(
        cacheKey,
        response.data!,
        ttl: const Duration(hours: 24),
      );

      return preferences;
    } catch (e, stackTrace) {
      _logger.error('Failed to get preferences', e, stackTrace);
      return UserPreferences.defaultPreferences();
    }
  }

  /// Update user preferences
  Future<void> updatePreferences(UserPreferences preferences) async {
    try {
      final userId = await _getCurrentUserId();
      _logger.debug('Updating preferences for user: $userId');

      final response = await _apiClient.put(
        'users/$userId/preferences',
        userId,
        data: preferences.toJson(),
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      // Update cache
      final cacheKey = '$_preferencesCacheKey$userId';
      await _cacheService.set(
        cacheKey,
        preferences.toJson(),
        ttl: const Duration(hours: 24),
      );

      _logger.info('Preferences updated for user: $userId');
    } catch (e, stackTrace) {
      _logger.error('Failed to update preferences', e, stackTrace);
      rethrow;
    }
  }

  /// Set language preference
  Future<void> setLanguage(String languageCode) async {
    final preferences = await getPreferences();
    preferences.language = languageCode;
    await updatePreferences(preferences);
  }

  /// Set theme preference
  Future<void> setTheme(ThemeMode theme) async {
    final preferences = await getPreferences();
    preferences.themeMode = theme;
    await updatePreferences(preferences);
  }

  /// Address Management

  /// Get user addresses
  Future<List<Address>> getUserAddresses() async {
    try {
      final userId = await _getCurrentUserId();
      final cacheKey = '$_addressesCacheKey$userId';

      // Try cache first
      final cached = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        return cached.map((json) => Address.fromJson(json)).toList();
      }

      _logger.debug('Getting addresses for user: $userId');

      final response = await _apiClient.get('users/$userId/addresses');

      if (!response.success || response.data == null) {
        return [];
      }

      final addressesData = response.data!['addresses'] as List<dynamic>? ?? [];
      final addresses = addressesData
          .map((json) => Address.fromJson(json))
          .toList();

      // Cache addresses
      await _cacheService.set(
        cacheKey,
        addressesData,
        ttl: const Duration(hours: 6),
      );

      return addresses;
    } catch (e, stackTrace) {
      _logger.error('Failed to get addresses', e, stackTrace);
      return [];
    }
  }

  /// Add new address
  Future<Address> addAddress(Address address) async {
    try {
      _validateAddress(address);

      final userId = await _getCurrentUserId();
      _logger.debug('Adding address for user: $userId');

      final response = await _apiClient.post(
        'users/$userId/addresses',
        data: address.toJson(),
      );

      if (!response.success || response.data == null) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      final newAddress = Address.fromJson(response.data!);

      // Invalidate address cache
      await _cacheService.delete('$_addressesCacheKey$userId');

      _logger.info('Address added for user: $userId');
      return newAddress;
    } catch (e, stackTrace) {
      _logger.error('Failed to add address', e, stackTrace);
      rethrow;
    }
  }

  /// Update existing address
  Future<Address> updateAddress(String addressId, Address address) async {
    try {
      _validateAddress(address);

      final userId = await _getCurrentUserId();
      _logger.debug('Updating address $addressId for user: $userId');

      final response = await _apiClient.put(
        'users/$userId/addresses',
        addressId,
        data: address.toJson(),
      );

      if (!response.success || response.data == null) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      final updatedAddress = Address.fromJson(response.data!);

      // Invalidate address cache
      await _cacheService.delete('$_addressesCacheKey$userId');

      _logger.info('Address updated for user: $userId');
      return updatedAddress;
    } catch (e, stackTrace) {
      _logger.error('Failed to update address', e, stackTrace);
      rethrow;
    }
  }

  /// Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      final userId = await _getCurrentUserId();
      _logger.debug('Deleting address $addressId for user: $userId');

      final response = await _apiClient.delete(
        'users/$userId/addresses',
        addressId,
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      // Invalidate address cache
      await _cacheService.delete('$_addressesCacheKey$userId');

      _logger.info('Address deleted for user: $userId');
    } catch (e, stackTrace) {
      _logger.error('Failed to delete address', e, stackTrace);
      rethrow;
    }
  }

  /// Set default address
  Future<void> setDefaultAddress(String addressId) async {
    try {
      final userId = await _getCurrentUserId();
      _logger.debug('Setting default address $addressId for user: $userId');

      final response = await _apiClient.post(
        'users/$userId/addresses/$addressId/set-default',
        data: {},
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      // Invalidate address cache
      await _cacheService.delete('$_addressesCacheKey$userId');

      _logger.info('Default address set for user: $userId');
    } catch (e, stackTrace) {
      _logger.error('Failed to set default address', e, stackTrace);
      rethrow;
    }
  }

  /// Activity and History

  /// Get user activity history
  Future<List<UserActivity>> getActivityHistory({int limit = 50}) async {
    try {
      final userId = await _getCurrentUserId();
      final cacheKey = '$_activityCacheKey${userId}_$limit';

      // Try cache first
      final cached = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        return cached.map((json) => UserActivity.fromJson(json)).toList();
      }

      _logger.debug('Getting activity history for user: $userId');

      final response = await _apiClient.get(
        'users/$userId/activity',
        queryParameters: {'limit': limit},
      );

      if (!response.success || response.data == null) {
        return [];
      }

      final activitiesData =
          response.data!['activities'] as List<dynamic>? ?? [];
      final activities = activitiesData
          .map((json) => UserActivity.fromJson(json))
          .toList();

      // Cache activities
      await _cacheService.set(
        cacheKey,
        activitiesData,
        ttl: const Duration(minutes: 30),
      );

      return activities;
    } catch (e, stackTrace) {
      _logger.error('Failed to get activity history', e, stackTrace);
      return [];
    }
  }

  /// Get user order history
  Future<List<Order>> getOrderHistory({int limit = 20}) async {
    try {
      final userId = await _getCurrentUserId();
      final cacheKey = '$_ordersCacheKey${userId}_$limit';

      // Try cache first
      final cached = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        return cached.map((json) => Order.fromJson(json)).toList();
      }

      _logger.debug('Getting order history for user: $userId');

      final response = await _apiClient.get(
        'users/$userId/orders',
        queryParameters: {'limit': limit},
      );

      if (!response.success || response.data == null) {
        return [];
      }

      final ordersData = response.data!['orders'] as List<dynamic>? ?? [];
      final orders = ordersData.map((json) => Order.fromJson(json)).toList();

      // Cache orders
      await _cacheService.set(
        cacheKey,
        ordersData,
        ttl: const Duration(minutes: 15),
      );

      return orders;
    } catch (e, stackTrace) {
      _logger.error('Failed to get order history', e, stackTrace);
      return [];
    }
  }

  /// Get user statistics
  Future<UserStats> getUserStats() async {
    try {
      final userId = await _getCurrentUserId();
      _logger.debug('Getting stats for user: $userId');

      final response = await _apiClient.get('users/$userId/stats');

      if (!response.success || response.data == null) {
        return UserStats.empty();
      }

      return UserStats.fromJson(response.data!);
    } catch (e, stackTrace) {
      _logger.error('Failed to get user stats', e, stackTrace);
      return UserStats.empty();
    }
  }

  /// Favorites Management

  /// Get user favorites
  Future<List<Product>> getFavorites() async {
    try {
      final userId = await _getCurrentUserId();
      final cacheKey = '$_favoritesCacheKey$userId';

      // Try cache first
      final cached = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        return cached.map((json) => Product.fromJson(json)).toList();
      }

      _logger.debug('Getting favorites for user: $userId');

      final response = await _apiClient.get('users/$userId/favorites');

      if (!response.success || response.data == null) {
        return [];
      }

      final favoritesData = response.data!['products'] as List<dynamic>? ?? [];
      final favorites = favoritesData
          .map((json) => Product.fromJson(json))
          .toList();

      // Cache favorites
      await _cacheService.set(
        cacheKey,
        favoritesData,
        ttl: const Duration(hours: 2),
      );

      return favorites;
    } catch (e, stackTrace) {
      _logger.error('Failed to get favorites', e, stackTrace);
      return [];
    }
  }

  /// Add product to favorites
  Future<void> addToFavorites(String productId) async {
    try {
      final userId = await _getCurrentUserId();
      _logger.debug('Adding product $productId to favorites for user: $userId');

      final response = await _apiClient.post(
        'users/$userId/favorites',
        data: {'product_id': productId},
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      // Invalidate favorites cache
      await _cacheService.delete('$_favoritesCacheKey$userId');

      _logger.info('Product $productId added to favorites for user: $userId');
    } catch (e, stackTrace) {
      _logger.error('Failed to add to favorites', e, stackTrace);
      rethrow;
    }
  }

  /// Remove product from favorites
  Future<void> removeFromFavorites(String productId) async {
    try {
      final userId = await _getCurrentUserId();
      _logger.debug(
        'Removing product $productId from favorites for user: $userId',
      );

      final response = await _apiClient.delete(
        'users/$userId/favorites',
        productId,
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      // Invalidate favorites cache
      await _cacheService.delete('$_favoritesCacheKey$userId');

      _logger.info(
        'Product $productId removed from favorites for user: $userId',
      );
    } catch (e, stackTrace) {
      _logger.error('Failed to remove from favorites', e, stackTrace);
      rethrow;
    }
  }

  /// Verification Management

  /// Send email verification
  Future<void> sendVerificationEmail() async {
    try {
      final userId = await _getCurrentUserId();
      _logger.debug('Sending verification email for user: $userId');

      final response = await _apiClient.post(
        'users/$userId/send-verification-email',
        data: {},
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      _logger.info('Verification email sent for user: $userId');
    } catch (e, stackTrace) {
      _logger.error('Failed to send verification email', e, stackTrace);
      rethrow;
    }
  }

  /// Verify email with token
  Future<bool> verifyEmail(String token) async {
    try {
      _logger.debug('Verifying email with token');

      final response = await _apiClient.post(
        'verify-email',
        data: {'token': token},
      );

      if (!response.success) {
        return false;
      }

      // Clear user cache to refresh verification status
      final userId = await _getCurrentUserId();
      await _cacheService.invalidateCache('user_${userId}_.*');

      _logger.info('Email verified successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to verify email', e, stackTrace);
      return false;
    }
  }

  /// Send phone verification
  Future<void> sendPhoneVerification(String phoneNumber) async {
    try {
      final userId = await _getCurrentUserId();
      _logger.debug('Sending phone verification for user: $userId');

      final response = await _apiClient.post(
        'users/$userId/send-phone-verification',
        data: {'phone_number': phoneNumber},
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      _logger.info('Phone verification sent for user: $userId');
    } catch (e, stackTrace) {
      _logger.error('Failed to send phone verification', e, stackTrace);
      rethrow;
    }
  }

  /// Verify phone with code
  Future<bool> verifyPhone(String code) async {
    try {
      final userId = await _getCurrentUserId();
      _logger.debug('Verifying phone for user: $userId');

      final response = await _apiClient.post(
        'users/$userId/verify-phone',
        data: {'verification_code': code},
      );

      if (!response.success) {
        return false;
      }

      // Clear user cache to refresh verification status
      await _cacheService.invalidateCache('user_${userId}_.*');

      _logger.info('Phone verified successfully for user: $userId');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to verify phone', e, stackTrace);
      return false;
    }
  }

  /// Private helper methods

  /// Get current user ID
  Future<String> _getCurrentUserId() async {
    final userData = await _authService.getUserData();
    if (userData == null || !userData.containsKey('id')) {
      throw AuthenticationException('User not logged in');
    }
    return userData['id'].toString();
  }

  /// Validate profile data
  void _validateProfile(UserProfile profile) {
    final errors = <String, List<String>>{};

    if (profile.firstName.isEmpty) {
      errors['firstName'] = ['First name is required'];
    }

    if (profile.lastName.isEmpty) {
      errors['lastName'] = ['Last name is required'];
    }

    if (profile.email.isEmpty || !_isValidEmail(profile.email)) {
      errors['email'] = ['Valid email is required'];
    }

    if (errors.isNotEmpty) {
      throw ValidationException.fields(errors);
    }
  }

  /// Validate password
  void _validatePassword(String password) {
    if (password.length < 6) {
      throw ValidationException.field(
        'password',
        'Password must be at least 6 characters long',
      );
    }
  }

  /// Validate address
  void _validateAddress(Address address) {
    final errors = <String, List<String>>{};

    if (address.street.isEmpty) {
      errors['street'] = ['Street address is required'];
    }

    if (address.city.isEmpty) {
      errors['city'] = ['City is required'];
    }

    if (address.postalCode.isEmpty) {
      errors['postalCode'] = ['Postal code is required'];
    }

    if (address.country.isEmpty) {
      errors['country'] = ['Country is required'];
    }

    if (errors.isNotEmpty) {
      throw ValidationException.fields(errors);
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}

// Data Models

// User profile model
class UserProfile {
  String id;
  String firstName;
  String lastName;
  String email;
  String? phone;
  String? avatar;
  String? bio;
  DateTime? birthDate;
  String? gender;
  bool isEmailVerified;
  bool isPhoneVerified;
  DateTime createdAt;
  DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.avatar,
    this.bio,
    this.birthDate,
    this.gender,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      bio: json['bio'],
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      gender: json['gender'],
      isEmailVerified: json['is_email_verified'] ?? false,
      isPhoneVerified: json['is_phone_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// User preferences model
class UserPreferences {
  String language;
  ThemeMode themeMode;
  bool pushNotifications;
  bool emailNotifications;
  bool smsNotifications;
  String currency;
  String timezone;

  UserPreferences({
    required this.language,
    required this.themeMode,
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.currency = 'XOF',
    this.timezone = 'Africa/Abidjan',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      language: json['language'] ?? 'fr',
      themeMode: _parseThemeMode(json['theme_mode']),
      pushNotifications: json['push_notifications'] ?? true,
      emailNotifications: json['email_notifications'] ?? true,
      smsNotifications: json['sms_notifications'] ?? false,
      currency: json['currency'] ?? 'XOF',
      timezone: json['timezone'] ?? 'Africa/Abidjan',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'theme_mode': themeMode.name,
      'push_notifications': pushNotifications,
      'email_notifications': emailNotifications,
      'sms_notifications': smsNotifications,
      'currency': currency,
      'timezone': timezone,
    };
  }

  static UserPreferences defaultPreferences() {
    return UserPreferences(language: 'fr', themeMode: ThemeMode.system);
  }

  static ThemeMode _parseThemeMode(String? themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

// Address model
class Address {
  String? id;
  String street;
  String? street2;
  String city;
  String postalCode;
  String state;
  String country;
  bool isDefault;
  String type; // 'billing', 'shipping', 'both'

  Address({
    this.id,
    required this.street,
    this.street2,
    required this.city,
    required this.postalCode,
    required this.state,
    required this.country,
    this.isDefault = false,
    this.type = 'both',
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString(),
      street: json['street'] ?? '',
      street2: json['street2'],
      city: json['city'] ?? '',
      postalCode: json['postal_code'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      isDefault: json['is_default'] ?? false,
      type: json['type'] ?? 'both',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'street': street,
      'street2': street2,
      'city': city,
      'postal_code': postalCode,
      'state': state,
      'country': country,
      'is_default': isDefault,
      'type': type,
    };
  }
}

// User activity model
class UserActivity {
  String id;
  String type;
  String description;
  Map<String, dynamic>? metadata;
  DateTime createdAt;

  UserActivity({
    required this.id,
    required this.type,
    required this.description,
    this.metadata,
    required this.createdAt,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      id: json['id'].toString(),
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// Order model (simplified)
class Order {
  String id;
  String status;
  double total;
  String currency;
  DateTime createdAt;
  List<OrderItem> items;

  Order({
    required this.id,
    required this.status,
    required this.total,
    required this.currency,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      status: json['status'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'XOF',
      createdAt: DateTime.parse(json['created_at']),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

// Order item model
class OrderItem {
  String productId;
  String productName;
  int quantity;
  double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'].toString(),
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

// Product model (simplified)
class Product {
  String id;
  String name;
  String? description;
  double price;
  String? imageUrl;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'],
    );
  }
}

// User statistics model
class UserStats {
  int totalOrders;
  double totalSpent;
  int favoriteProducts;
  DateTime? lastOrderDate;
  String membershipLevel;

  UserStats({
    required this.totalOrders,
    required this.totalSpent,
    required this.favoriteProducts,
    this.lastOrderDate,
    required this.membershipLevel,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalOrders: json['total_orders'] ?? 0,
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      favoriteProducts: json['favorite_products'] ?? 0,
      lastOrderDate: json['last_order_date'] != null
          ? DateTime.parse(json['last_order_date'])
          : null,
      membershipLevel: json['membership_level'] ?? 'Bronze',
    );
  }

  static UserStats empty() {
    return UserStats(
      totalOrders: 0,
      totalSpent: 0.0,
      favoriteProducts: 0,
      membershipLevel: 'Bronze',
    );
  }
}
