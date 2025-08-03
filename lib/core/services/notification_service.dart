// Provides comprehensive notification management for the Koutonou application.
// This service handles push notifications, local notifications, notification preferences,
// history, and business-specific notifications (orders, promotions, reminders).

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:koutonou/core/api/api_client.dart';
import 'package:koutonou/core/exceptions/api_exception.dart';
import 'package:koutonou/core/services/auth_service.dart';
import 'package:koutonou/core/services/cache_service.dart';
import 'package:koutonou/core/utils/logger.dart';

class NotificationService {
  /// Singleton instance for centralized notification service
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Dependencies
  final _apiClient = ApiClient();
  final _authService = AuthService();
  final _cacheService = CacheService();
  static final _logger = AppLogger();

  /// Device token for push notifications
  String? _deviceToken;

  /// Notification settings cache
  Map<String, dynamic>? _cachedSettings;

  /// Stream controllers for real-time notifications
  final _notificationStreamController =
      StreamController<AppNotification>.broadcast();
  final _badgeCountStreamController = StreamController<int>.broadcast();

  /// Current badge count
  int _currentBadgeCount = 0;

  /// Notification streams
  Stream<AppNotification> get notificationStream =>
      _notificationStreamController.stream;
  Stream<int> get badgeCountStream => _badgeCountStreamController.stream;

  /// Cache keys
  static const String _settingsCacheKey = 'notification_settings';
  static const String _historyCacheKey = 'notification_history';
  static const String _unreadCountCacheKey = 'unread_notification_count';

  /// Notification types
  static const String typeOrder = 'order';
  static const String typePromotion = 'promotion';
  static const String typeReminder = 'reminder';
  static const String typeSystem = 'system';
  static const String typeChat = 'chat';
  static const String typeDelivery = 'delivery';

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      _logger.debug('Initializing notification service');

      // Load cached settings
      await _loadCachedSettings();

      // Initialize push notification token
      await _initializePushToken();

      // Load unread count
      await _loadUnreadCount();

      _logger.info('Notification service initialized successfully');
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize notification service', e, stackTrace);
    }
  }

  /// Dispose resources
  void dispose() {
    _notificationStreamController.close();
    _badgeCountStreamController.close();
  }

  /// Push Notification Management

  /// Initialize push notification token
  Future<void> _initializePushToken() async {
    try {
      // In a real implementation, you would use Firebase Messaging or similar
      // For now, we'll simulate token generation
      if (kIsWeb) {
        _deviceToken = 'web_token_${DateTime.now().millisecondsSinceEpoch}';
      } else if (Platform.isIOS) {
        _deviceToken = 'ios_token_${DateTime.now().millisecondsSinceEpoch}';
      } else if (Platform.isAndroid) {
        _deviceToken = 'android_token_${DateTime.now().millisecondsSinceEpoch}';
      }

      if (_deviceToken != null) {
        await _registerDeviceToken(_deviceToken!);
        _logger.debug(
          'Push token initialized: ${_deviceToken!.substring(0, 20)}...',
        );
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize push token', e, stackTrace);
    }
  }

  /// Register device token with server
  Future<void> _registerDeviceToken(String token) async {
    try {
      if (!await _authService.isLoggedIn()) {
        _logger.debug('User not logged in, skipping token registration');
        return;
      }

      final userData = await _authService.getUserData();
      final userId = userData?['id']?.toString();

      if (userId == null) return;

      final response = await _apiClient.post(
        'users/$userId/device-token',
        data: {
          'token': token,
          'platform': _getCurrentPlatform(),
          'app_version': '1.0.0', // Should come from package info
        },
      );

      if (response.success) {
        _logger.info('Device token registered successfully');
      } else {
        _logger.warning('Failed to register device token: ${response.message}');
      }
    } catch (e, stackTrace) {
      _logger.error('Error registering device token', e, stackTrace);
    }
  }

  /// Get current platform string
  String _getCurrentPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      _logger.debug('Requesting notification permissions');

      // In a real implementation, you would request actual permissions
      // For simulation, we'll assume permission is granted based on platform
      bool granted = true;

      // Simulate permission request logic
      if (kIsWeb) {
        granted = true; // Web notifications usually work
      } else {
        granted = true; // Mobile permissions assumed granted for demo
      }

      if (granted) {
        await _initializePushToken();
        _logger.info('Notification permissions granted');
      } else {
        _logger.warning('Notification permissions denied');
      }

      return granted;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to request notification permissions',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Notification Settings Management

  /// Get notification settings
  Future<NotificationSettings> getSettings() async {
    try {
      if (_cachedSettings != null) {
        return NotificationSettings.fromJson(_cachedSettings!);
      }

      if (!await _authService.isLoggedIn()) {
        return NotificationSettings.defaultSettings();
      }

      final userData = await _authService.getUserData();
      final userId = userData?['id']?.toString();

      if (userId == null) {
        return NotificationSettings.defaultSettings();
      }

      // Try cache first
      final cached = await _cacheService.get<Map<String, dynamic>>(
        _settingsCacheKey,
      );
      if (cached != null) {
        _cachedSettings = cached;
        return NotificationSettings.fromJson(cached);
      }

      _logger.debug('Fetching notification settings for user: $userId');

      final response = await _apiClient.get(
        'users/$userId/notification-settings',
      );

      if (!response.success || response.data == null) {
        final defaultSettings = NotificationSettings.defaultSettings();
        _cachedSettings = defaultSettings.toJson();
        return defaultSettings;
      }

      final settings = NotificationSettings.fromJson(response.data!);
      _cachedSettings = response.data!;

      // Cache settings
      await _cacheService.set(
        _settingsCacheKey,
        response.data!,
        ttl: const Duration(hours: 24),
      );

      return settings;
    } catch (e, stackTrace) {
      _logger.error('Failed to get notification settings', e, stackTrace);
      return NotificationSettings.defaultSettings();
    }
  }

  /// Update notification settings
  Future<void> updateSettings(NotificationSettings settings) async {
    try {
      if (!await _authService.isLoggedIn()) {
        throw AuthenticationException('User not logged in');
      }

      final userData = await _authService.getUserData();
      final userId = userData?['id']?.toString();

      if (userId == null) {
        throw AuthenticationException('Invalid user data');
      }

      _logger.debug('Updating notification settings for user: $userId');

      final response = await _apiClient.put(
        'users/$userId/notification-settings',
        userId,
        data: settings.toJson(),
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      // Update cache
      _cachedSettings = settings.toJson();
      await _cacheService.set(
        _settingsCacheKey,
        settings.toJson(),
        ttl: const Duration(hours: 24),
      );

      _logger.info('Notification settings updated for user: $userId');
    } catch (e, stackTrace) {
      _logger.error('Failed to update notification settings', e, stackTrace);
      rethrow;
    }
  }

  /// Load cached settings
  Future<void> _loadCachedSettings() async {
    try {
      final cached = await _cacheService.get<Map<String, dynamic>>(
        _settingsCacheKey,
      );
      if (cached != null) {
        _cachedSettings = cached;
      }
    } catch (e) {
      _logger.debug('No cached settings found');
    }
  }

  /// Notification History Management

  /// Get notification history
  Future<List<AppNotification>> getNotificationHistory({
    int limit = 50,
    String? type,
    bool unreadOnly = false,
  }) async {
    try {
      if (!await _authService.isLoggedIn()) {
        return [];
      }

      final userData = await _authService.getUserData();
      final userId = userData?['id']?.toString();

      if (userId == null) return [];

      final cacheKey =
          '${_historyCacheKey}_${userId}_${limit}_${type ?? 'all'}_$unreadOnly';

      // Try cache first for recent requests
      final cached = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        return cached.map((json) => AppNotification.fromJson(json)).toList();
      }

      _logger.debug('Fetching notification history for user: $userId');

      final queryParameters = <String, dynamic>{
        'limit': limit,
        if (type != null) 'type': type,
        if (unreadOnly) 'unread_only': true,
      };

      final response = await _apiClient.get(
        'users/$userId/notifications',
        queryParameters: queryParameters,
      );

      if (!response.success || response.data == null) {
        return [];
      }

      final notificationsData =
          response.data!['notifications'] as List<dynamic>? ?? [];
      final notifications = notificationsData
          .map((json) => AppNotification.fromJson(json))
          .toList();

      // Cache for short period
      await _cacheService.set(
        cacheKey,
        notificationsData,
        ttl: const Duration(minutes: 5),
      );

      return notifications;
    } catch (e, stackTrace) {
      _logger.error('Failed to get notification history', e, stackTrace);
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      if (!await _authService.isLoggedIn()) return;

      final userData = await _authService.getUserData();
      final userId = userData?['id']?.toString();

      if (userId == null) return;

      _logger.debug('Marking notification as read: $notificationId');

      final response = await _apiClient.post(
        'users/$userId/notifications/$notificationId/mark-read',
        data: {},
      );

      if (response.success) {
        // Update badge count
        await _decrementBadgeCount();

        // Clear history cache
        await _cacheService.invalidateCache('${_historyCacheKey}_$userId.*');

        _logger.debug('Notification marked as read: $notificationId');
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to mark notification as read', e, stackTrace);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      if (!await _authService.isLoggedIn()) return;

      final userData = await _authService.getUserData();
      final userId = userData?['id']?.toString();

      if (userId == null) return;

      _logger.debug('Marking all notifications as read for user: $userId');

      final response = await _apiClient.post(
        'users/$userId/notifications/mark-all-read',
        data: {},
      );

      if (response.success) {
        // Reset badge count
        await _setBadgeCount(0);

        // Clear history cache
        await _cacheService.invalidateCache('${_historyCacheKey}_$userId.*');

        _logger.info('All notifications marked as read for user: $userId');
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to mark all notifications as read', e, stackTrace);
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      if (!await _authService.isLoggedIn()) return;

      final userData = await _authService.getUserData();
      final userId = userData?['id']?.toString();

      if (userId == null) return;

      _logger.debug('Deleting notification: $notificationId');

      final response = await _apiClient.delete(
        'users/$userId/notifications',
        notificationId,
      );

      if (response.success) {
        // Clear history cache
        await _cacheService.invalidateCache('${_historyCacheKey}_$userId.*');

        _logger.debug('Notification deleted: $notificationId');
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to delete notification', e, stackTrace);
    }
  }

  /// Badge Count Management

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      if (!await _authService.isLoggedIn()) return 0;

      final userData = await _authService.getUserData();
      final userId = userData?['id']?.toString();

      if (userId == null) return 0;

      // Try cache first
      final cached = await _cacheService.get<int>(_unreadCountCacheKey);
      if (cached != null) {
        _currentBadgeCount = cached;
        return cached;
      }

      final response = await _apiClient.get(
        'users/$userId/notifications/unread-count',
      );

      if (!response.success || response.data == null) {
        return 0;
      }

      final count = response.data!['count'] ?? 0;
      _currentBadgeCount = count;

      // Cache count
      await _cacheService.set(
        _unreadCountCacheKey,
        count,
        ttl: const Duration(minutes: 5),
      );

      return count;
    } catch (e, stackTrace) {
      _logger.error('Failed to get unread count', e, stackTrace);
      return 0;
    }
  }

  /// Load unread count and update badge
  Future<void> _loadUnreadCount() async {
    final count = await getUnreadCount();
    _badgeCountStreamController.add(count);
  }

  /// Set badge count
  Future<void> _setBadgeCount(int count) async {
    _currentBadgeCount = count;
    _badgeCountStreamController.add(count);

    // Update cache
    await _cacheService.set(
      _unreadCountCacheKey,
      count,
      ttl: const Duration(minutes: 5),
    );
  }

  /// Increment badge count
  Future<void> _incrementBadgeCount() async {
    await _setBadgeCount(_currentBadgeCount + 1);
  }

  /// Decrement badge count
  Future<void> _decrementBadgeCount() async {
    if (_currentBadgeCount > 0) {
      await _setBadgeCount(_currentBadgeCount - 1);
    }
  }

  /// Business Notification Methods

  /// Send order notification
  Future<void> sendOrderNotification({
    required String userId,
    required String orderId,
    required String status,
    String? message,
  }) async {
    try {
      final notification = AppNotification(
        id: 'order_${orderId}_${DateTime.now().millisecondsSinceEpoch}',
        title: _getOrderNotificationTitle(status),
        body: message ?? _getOrderNotificationBody(status, orderId),
        type: typeOrder,
        data: {'order_id': orderId, 'status': status},
        createdAt: DateTime.now(),
        isRead: false,
      );

      await _sendNotification(userId, notification);
    } catch (e, stackTrace) {
      _logger.error('Failed to send order notification', e, stackTrace);
    }
  }

  /// Send promotion notification
  Future<void> sendPromotionNotification({
    required String userId,
    required String title,
    required String message,
    String? imageUrl,
    Map<String, dynamic>? promotionData,
  }) async {
    try {
      final notification = AppNotification(
        id: 'promo_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: message,
        type: typePromotion,
        imageUrl: imageUrl,
        data: promotionData ?? {},
        createdAt: DateTime.now(),
        isRead: false,
      );

      await _sendNotification(userId, notification);
    } catch (e, stackTrace) {
      _logger.error('Failed to send promotion notification', e, stackTrace);
    }
  }

  /// Send reminder notification
  Future<void> sendReminderNotification({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? reminderData,
  }) async {
    try {
      final notification = AppNotification(
        id: 'reminder_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: message,
        type: typeReminder,
        data: reminderData ?? {},
        createdAt: DateTime.now(),
        isRead: false,
      );

      await _sendNotification(userId, notification);
    } catch (e, stackTrace) {
      _logger.error('Failed to send reminder notification', e, stackTrace);
    }
  }

  /// Send delivery notification
  Future<void> sendDeliveryNotification({
    required String userId,
    required String orderId,
    required String status,
    String? trackingNumber,
    String? estimatedDelivery,
  }) async {
    try {
      final notification = AppNotification(
        id: 'delivery_${orderId}_${DateTime.now().millisecondsSinceEpoch}',
        title: _getDeliveryNotificationTitle(status),
        body: _getDeliveryNotificationBody(status, orderId, trackingNumber),
        type: typeDelivery,
        data: {
          'order_id': orderId,
          'status': status,
          'tracking_number': trackingNumber,
          'estimated_delivery': estimatedDelivery,
        },
        createdAt: DateTime.now(),
        isRead: false,
      );

      await _sendNotification(userId, notification);
    } catch (e, stackTrace) {
      _logger.error('Failed to send delivery notification', e, stackTrace);
    }
  }

  /// Internal notification sending
  Future<void> _sendNotification(
    String userId,
    AppNotification notification,
  ) async {
    try {
      _logger.debug('Sending notification to user: $userId');

      // Send to server
      final response = await _apiClient.post(
        'users/$userId/notifications/send',
        data: notification.toJson(),
      );

      if (response.success) {
        // Add to local stream for real-time updates
        _notificationStreamController.add(notification);

        // Increment badge count
        await _incrementBadgeCount();

        // Clear relevant caches
        await _cacheService.invalidateCache('${_historyCacheKey}_$userId.*');

        _logger.info('Notification sent successfully: ${notification.id}');
      } else {
        _logger.warning('Failed to send notification: ${response.message}');
      }
    } catch (e, stackTrace) {
      _logger.error('Error sending notification', e, stackTrace);
    }
  }

  /// Notification message helpers

  String _getOrderNotificationTitle(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Commande confirmée';
      case 'processing':
        return 'Commande en préparation';
      case 'shipped':
        return 'Commande expédiée';
      case 'delivered':
        return 'Commande livrée';
      case 'cancelled':
        return 'Commande annulée';
      default:
        return 'Mise à jour de commande';
    }
  }

  String _getOrderNotificationBody(String status, String orderId) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Votre commande #$orderId a été confirmée et sera bientôt préparée.';
      case 'processing':
        return 'Votre commande #$orderId est en cours de préparation.';
      case 'shipped':
        return 'Votre commande #$orderId a été expédiée.';
      case 'delivered':
        return 'Votre commande #$orderId a été livrée avec succès.';
      case 'cancelled':
        return 'Votre commande #$orderId a été annulée.';
      default:
        return 'Votre commande #$orderId a été mise à jour.';
    }
  }

  String _getDeliveryNotificationTitle(String status) {
    switch (status.toLowerCase()) {
      case 'picked_up':
        return 'Colis récupéré';
      case 'in_transit':
        return 'Colis en transit';
      case 'out_for_delivery':
        return 'Colis en livraison';
      case 'delivered':
        return 'Colis livré';
      case 'failed':
        return 'Échec de livraison';
      default:
        return 'Mise à jour livraison';
    }
  }

  String _getDeliveryNotificationBody(
    String status,
    String orderId,
    String? trackingNumber,
  ) {
    final tracking = trackingNumber != null ? ' (Suivi: $trackingNumber)' : '';

    switch (status.toLowerCase()) {
      case 'picked_up':
        return 'Votre colis pour la commande #$orderId a été récupéré$tracking.';
      case 'in_transit':
        return 'Votre colis est en route vers sa destination$tracking.';
      case 'out_for_delivery':
        return 'Votre colis sera livré aujourd\'hui$tracking.';
      case 'delivered':
        return 'Votre colis a été livré avec succès$tracking.';
      case 'failed':
        return 'La livraison de votre colis a échoué$tracking. Veuillez nous contacter.';
      default:
        return 'Mise à jour de votre livraison$tracking.';
    }
  }

  /// Utility Methods

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await getSettings();
    return settings.pushNotifications;
  }

  /// Get notification statistics
  Future<NotificationStats> getNotificationStats() async {
    try {
      if (!await _authService.isLoggedIn()) {
        return NotificationStats.empty();
      }

      final userData = await _authService.getUserData();
      final userId = userData?['id']?.toString();

      if (userId == null) return NotificationStats.empty();

      final response = await _apiClient.get(
        'users/$userId/notifications/stats',
      );

      if (!response.success || response.data == null) {
        return NotificationStats.empty();
      }

      return NotificationStats.fromJson(response.data!);
    } catch (e, stackTrace) {
      _logger.error('Failed to get notification stats', e, stackTrace);
      return NotificationStats.empty();
    }
  }

  /// Clear all notification data
  Future<void> clearAllData() async {
    try {
      _logger.debug('Clearing all notification data');

      // Clear cache
      await _cacheService.delete(_settingsCacheKey);
      await _cacheService.delete(_unreadCountCacheKey);
      await _cacheService.invalidateCache('${_historyCacheKey}_.*');

      // Reset local state
      _deviceToken = null;
      _cachedSettings = null;
      _currentBadgeCount = 0;

      // Update streams
      _badgeCountStreamController.add(0);

      _logger.info('All notification data cleared');
    } catch (e, stackTrace) {
      _logger.error('Failed to clear notification data', e, stackTrace);
    }
  }
}

// Data Models

// App notification model
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.imageUrl,
    required this.data,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'system',
      imageUrl: json['image_url'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'image_url': imageUrl,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}

// Notification settings model
class NotificationSettings {
  bool pushNotifications;
  bool emailNotifications;
  bool smsNotifications;
  bool orderNotifications;
  bool promotionNotifications;
  bool reminderNotifications;
  bool deliveryNotifications;
  String quietHoursStart;
  String quietHoursEnd;
  List<String> mutedTypes;

  NotificationSettings({
    required this.pushNotifications,
    required this.emailNotifications,
    required this.smsNotifications,
    required this.orderNotifications,
    required this.promotionNotifications,
    required this.reminderNotifications,
    required this.deliveryNotifications,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.mutedTypes,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushNotifications: json['push_notifications'] ?? true,
      emailNotifications: json['email_notifications'] ?? true,
      smsNotifications: json['sms_notifications'] ?? false,
      orderNotifications: json['order_notifications'] ?? true,
      promotionNotifications: json['promotion_notifications'] ?? true,
      reminderNotifications: json['reminder_notifications'] ?? true,
      deliveryNotifications: json['delivery_notifications'] ?? true,
      quietHoursStart: json['quiet_hours_start'] ?? '22:00',
      quietHoursEnd: json['quiet_hours_end'] ?? '07:00',
      mutedTypes: List<String>.from(json['muted_types'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_notifications': pushNotifications,
      'email_notifications': emailNotifications,
      'sms_notifications': smsNotifications,
      'order_notifications': orderNotifications,
      'promotion_notifications': promotionNotifications,
      'reminder_notifications': reminderNotifications,
      'delivery_notifications': deliveryNotifications,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
      'muted_types': mutedTypes,
    };
  }

  static NotificationSettings defaultSettings() {
    return NotificationSettings(
      pushNotifications: true,
      emailNotifications: true,
      smsNotifications: false,
      orderNotifications: true,
      promotionNotifications: true,
      reminderNotifications: true,
      deliveryNotifications: true,
      quietHoursStart: '22:00',
      quietHoursEnd: '07:00',
      mutedTypes: [],
    );
  }
}

// Notification statistics model
class NotificationStats {
  final int totalSent;
  final int totalRead;
  final int totalUnread;
  final Map<String, int> byType;
  final DateTime? lastNotification;

  NotificationStats({
    required this.totalSent,
    required this.totalRead,
    required this.totalUnread,
    required this.byType,
    this.lastNotification,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      totalSent: json['total_sent'] ?? 0,
      totalRead: json['total_read'] ?? 0,
      totalUnread: json['total_unread'] ?? 0,
      byType: Map<String, int>.from(json['by_type'] ?? {}),
      lastNotification: json['last_notification'] != null
          ? DateTime.parse(json['last_notification'])
          : null,
    );
  }

  static NotificationStats empty() {
    return NotificationStats(
      totalSent: 0,
      totalRead: 0,
      totalUnread: 0,
      byType: {},
    );
  }
}

// Custom exception for authentication errors
class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}
