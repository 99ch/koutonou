// Manages the global notification state using ChangeNotifier for reactive UI updates.
// Integrates with NotificationService for push notifications, settings, history,
// and badge count management. Provides real-time streams and error handling.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:koutonou/core/services/notification_service.dart';
import 'package:koutonou/core/utils/error_handler.dart';
import 'package:koutonou/core/utils/logger.dart';

class NotificationProvider with ChangeNotifier {
  /// NotificationService instance for notification operations
  final _notificationService = NotificationService();

  /// Logger instance for debugging
  final _logger = AppLogger();

  /// Helper method to get readable error message
  String _getReadableError(dynamic error) {
    final result = ErrorHandler.handle(error, logError: false);
    return result.userMessage;
  }

  /// Stream subscriptions
  StreamSubscription<AppNotification>? _notificationSubscription;
  StreamSubscription<int>? _badgeCountSubscription;

  /// Notification settings
  NotificationSettings? _settings;

  /// Notification history
  List<AppNotification> _notifications = [];

  /// Badge count
  int _badgeCount = 0;

  /// Notification statistics
  NotificationStats? _stats;

  /// Loading states
  bool _isLoadingSettings = false;
  bool _isLoadingNotifications = false;
  bool _isLoadingStats = false;
  bool _isInitializing = false;

  /// Error states
  String? _settingsError;
  String? _notificationsError;
  String? _statsError;
  String? _initError;

  /// Permissions state
  bool _permissionsGranted = false;
  bool _permissionsRequested = false;

  /// Getters
  NotificationSettings? get settings => _settings;
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get badgeCount => _badgeCount;
  NotificationStats? get stats => _stats;

  /// Loading state getters
  bool get isLoadingSettings => _isLoadingSettings;
  bool get isLoadingNotifications => _isLoadingNotifications;
  bool get isLoadingStats => _isLoadingStats;
  bool get isInitializing => _isInitializing;

  /// Error getters
  String? get settingsError => _settingsError;
  String? get notificationsError => _notificationsError;
  String? get statsError => _statsError;
  String? get initError => _initError;

  /// Permission getters
  bool get permissionsGranted => _permissionsGranted;
  bool get permissionsRequested => _permissionsRequested;

  /// Helper getters
  bool get hasSettings => _settings != null;
  bool get hasNotifications => _notifications.isNotEmpty;
  bool get hasUnreadNotifications => _badgeCount > 0;
  bool get isAnyLoading =>
      _isLoadingSettings ||
      _isLoadingNotifications ||
      _isLoadingStats ||
      _isInitializing;

  /// Filtered notification getters
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  List<AppNotification> get orderNotifications => _notifications
      .where((n) => n.type == NotificationService.typeOrder)
      .toList();

  List<AppNotification> get promotionNotifications => _notifications
      .where((n) => n.type == NotificationService.typePromotion)
      .toList();

  List<AppNotification> get deliveryNotifications => _notifications
      .where((n) => n.type == NotificationService.typeDelivery)
      .toList();

  /// Initialize notification provider
  Future<void> initialize() async {
    if (_isInitializing) return;

    _isInitializing = true;
    _initError = null;
    notifyListeners();

    try {
      _logger.debug('Initializing notification provider');

      // Initialize notification service
      await _notificationService.initialize();

      // Subscribe to streams
      _subscribeToStreams();

      // Load initial data
      await Future.wait([
        loadSettings(),
        loadNotifications(),
        _loadBadgeCount(),
      ]);

      _logger.info('Notification provider initialized successfully');
    } catch (e, stackTrace) {
      _initError = _getReadableError(e);
      _logger.error(
        'Failed to initialize notification provider',
        e,
        stackTrace,
      );
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Subscribe to notification streams
  void _subscribeToStreams() {
    // Subscribe to new notifications
    _notificationSubscription = _notificationService.notificationStream.listen(
      (notification) {
        _logger.debug('Received new notification: ${notification.id}');
        _notifications.insert(0, notification);
        notifyListeners();
      },
      onError: (error) {
        _logger.error('Error in notification stream', error);
      },
    );

    // Subscribe to badge count changes
    _badgeCountSubscription = _notificationService.badgeCountStream.listen(
      (count) {
        _logger.debug('Badge count updated: $count');
        _badgeCount = count;
        notifyListeners();
      },
      onError: (error) {
        _logger.error('Error in badge count stream', error);
      },
    );
  }

  /// Dispose resources
  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _badgeCountSubscription?.cancel();
    _notificationService.dispose();
    super.dispose();
  }

  /// Permissions Management

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (_permissionsRequested) return _permissionsGranted;

    try {
      _logger.debug('Requesting notification permissions');
      _permissionsRequested = true;
      _permissionsGranted = await _notificationService.requestPermissions();

      if (_permissionsGranted) {
        _logger.info('Notification permissions granted');
      } else {
        _logger.warning('Notification permissions denied');
      }

      notifyListeners();
      return _permissionsGranted;
    } catch (e, stackTrace) {
      _initError = _getReadableError(e);
      _logger.error('Failed to request permissions', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Settings Management

  /// Load notification settings
  Future<void> loadSettings() async {
    if (_isLoadingSettings) return;

    _isLoadingSettings = true;
    _settingsError = null;
    notifyListeners();

    try {
      _logger.debug('Loading notification settings');
      _settings = await _notificationService.getSettings();
      _logger.info('Notification settings loaded successfully');
    } catch (e, stackTrace) {
      _settingsError = _getReadableError(e);
      _logger.error('Failed to load notification settings', e, stackTrace);
    } finally {
      _isLoadingSettings = false;
      notifyListeners();
    }
  }

  /// Update notification settings
  Future<bool> updateSettings(NotificationSettings settings) async {
    if (_isLoadingSettings) return false;

    _isLoadingSettings = true;
    _settingsError = null;
    notifyListeners();

    try {
      _logger.debug('Updating notification settings');
      await _notificationService.updateSettings(settings);
      _settings = settings;
      _logger.info('Notification settings updated successfully');
      return true;
    } catch (e, stackTrace) {
      _settingsError = _getReadableError(e);
      _logger.error('Failed to update notification settings', e, stackTrace);
      return false;
    } finally {
      _isLoadingSettings = false;
      notifyListeners();
    }
  }

  /// Toggle specific notification types
  Future<bool> togglePushNotifications(bool enabled) async {
    if (_settings == null) return false;

    final updatedSettings = NotificationSettings(
      pushNotifications: enabled,
      emailNotifications: _settings!.emailNotifications,
      smsNotifications: _settings!.smsNotifications,
      orderNotifications: _settings!.orderNotifications,
      promotionNotifications: _settings!.promotionNotifications,
      reminderNotifications: _settings!.reminderNotifications,
      deliveryNotifications: _settings!.deliveryNotifications,
      quietHoursStart: _settings!.quietHoursStart,
      quietHoursEnd: _settings!.quietHoursEnd,
      mutedTypes: _settings!.mutedTypes,
    );

    return await updateSettings(updatedSettings);
  }

  Future<bool> toggleOrderNotifications(bool enabled) async {
    if (_settings == null) return false;

    final updatedSettings = NotificationSettings(
      pushNotifications: _settings!.pushNotifications,
      emailNotifications: _settings!.emailNotifications,
      smsNotifications: _settings!.smsNotifications,
      orderNotifications: enabled,
      promotionNotifications: _settings!.promotionNotifications,
      reminderNotifications: _settings!.reminderNotifications,
      deliveryNotifications: _settings!.deliveryNotifications,
      quietHoursStart: _settings!.quietHoursStart,
      quietHoursEnd: _settings!.quietHoursEnd,
      mutedTypes: _settings!.mutedTypes,
    );

    return await updateSettings(updatedSettings);
  }

  Future<bool> togglePromotionNotifications(bool enabled) async {
    if (_settings == null) return false;

    final updatedSettings = NotificationSettings(
      pushNotifications: _settings!.pushNotifications,
      emailNotifications: _settings!.emailNotifications,
      smsNotifications: _settings!.smsNotifications,
      orderNotifications: _settings!.orderNotifications,
      promotionNotifications: enabled,
      reminderNotifications: _settings!.reminderNotifications,
      deliveryNotifications: _settings!.deliveryNotifications,
      quietHoursStart: _settings!.quietHoursStart,
      quietHoursEnd: _settings!.quietHoursEnd,
      mutedTypes: _settings!.mutedTypes,
    );

    return await updateSettings(updatedSettings);
  }

  /// Notification History Management

  /// Load notification history
  Future<void> loadNotifications({
    int limit = 50,
    String? type,
    bool unreadOnly = false,
    bool refresh = false,
  }) async {
    if (_isLoadingNotifications && !refresh) return;

    _isLoadingNotifications = true;
    if (refresh) {
      _notificationsError = null;
    }
    notifyListeners();

    try {
      _logger.debug('Loading notification history');
      final notifications = await _notificationService.getNotificationHistory(
        limit: limit,
        type: type,
        unreadOnly: unreadOnly,
      );

      if (refresh) {
        _notifications = notifications;
      } else {
        // Merge with existing notifications, avoiding duplicates
        final existingIds = _notifications.map((n) => n.id).toSet();
        final newNotifications = notifications
            .where((n) => !existingIds.contains(n.id))
            .toList();
        _notifications.addAll(newNotifications);
      }

      _logger.info('Notification history loaded successfully');
    } catch (e, stackTrace) {
      _notificationsError = _getReadableError(e);
      _logger.error('Failed to load notification history', e, stackTrace);
    } finally {
      _isLoadingNotifications = false;
      notifyListeners();
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await loadNotifications(refresh: true);
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      _logger.debug('Marking notification as read: $notificationId');
      await _notificationService.markAsRead(notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index].isRead = true;
        notifyListeners();
      }

      _logger.info('Notification marked as read successfully');
      return true;
    } catch (e, stackTrace) {
      _notificationsError = _getReadableError(e);
      _logger.error('Failed to mark notification as read', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      _logger.debug('Marking all notifications as read');
      await _notificationService.markAllAsRead();

      // Update local state
      for (final notification in _notifications) {
        notification.isRead = true;
      }

      _logger.info('All notifications marked as read successfully');
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _notificationsError = _getReadableError(e);
      _logger.error('Failed to mark all notifications as read', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      _logger.debug('Deleting notification: $notificationId');
      await _notificationService.deleteNotification(notificationId);

      // Remove from local state
      _notifications.removeWhere((n) => n.id == notificationId);

      _logger.info('Notification deleted successfully');
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _notificationsError = _getReadableError(e);
      _logger.error('Failed to delete notification', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Badge Count Management

  /// Load badge count
  Future<void> _loadBadgeCount() async {
    try {
      _badgeCount = await _notificationService.getUnreadCount();
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.error('Failed to load badge count', e, stackTrace);
    }
  }

  /// Business Notification Methods

  /// Send order notification (admin/system use)
  Future<bool> sendOrderNotification({
    required String userId,
    required String orderId,
    required String status,
    String? message,
  }) async {
    try {
      await _notificationService.sendOrderNotification(
        userId: userId,
        orderId: orderId,
        status: status,
        message: message,
      );
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to send order notification', e, stackTrace);
      return false;
    }
  }

  /// Send promotion notification (admin/system use)
  Future<bool> sendPromotionNotification({
    required String userId,
    required String title,
    required String message,
    String? imageUrl,
    Map<String, dynamic>? promotionData,
  }) async {
    try {
      await _notificationService.sendPromotionNotification(
        userId: userId,
        title: title,
        message: message,
        imageUrl: imageUrl,
        promotionData: promotionData,
      );
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to send promotion notification', e, stackTrace);
      return false;
    }
  }

  /// Send reminder notification (admin/system use)
  Future<bool> sendReminderNotification({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? reminderData,
  }) async {
    try {
      await _notificationService.sendReminderNotification(
        userId: userId,
        title: title,
        message: message,
        reminderData: reminderData,
      );
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to send reminder notification', e, stackTrace);
      return false;
    }
  }

  /// Statistics Management

  /// Load notification statistics
  Future<void> loadStats() async {
    if (_isLoadingStats) return;

    _isLoadingStats = true;
    _statsError = null;
    notifyListeners();

    try {
      _logger.debug('Loading notification statistics');
      _stats = await _notificationService.getNotificationStats();
      _logger.info('Notification statistics loaded successfully');
    } catch (e, stackTrace) {
      _statsError = _getReadableError(e);
      _logger.error('Failed to load notification statistics', e, stackTrace);
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  /// Utility Methods

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    return await _notificationService.areNotificationsEnabled();
  }

  /// Get notification by ID
  AppNotification? getNotificationById(String notificationId) {
    try {
      return _notifications.firstWhere((n) => n.id == notificationId);
    } catch (e) {
      return null;
    }
  }

  /// Get notifications by type
  List<AppNotification> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Get recent notifications (last 24 hours)
  List<AppNotification> get recentNotifications {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _notifications.where((n) => n.createdAt.isAfter(yesterday)).toList();
  }

  /// Clear all data (on logout)
  void clearAllData() {
    _settings = null;
    _notifications.clear();
    _badgeCount = 0;
    _stats = null;

    // Clear errors
    _settingsError = null;
    _notificationsError = null;
    _statsError = null;
    _initError = null;

    // Reset loading states
    _isLoadingSettings = false;
    _isLoadingNotifications = false;
    _isLoadingStats = false;
    _isInitializing = false;

    // Reset permissions
    _permissionsGranted = false;
    _permissionsRequested = false;

    _logger.info('Notification provider data cleared');
    notifyListeners();
  }

  /// Clear specific error
  void clearError(String errorType) {
    switch (errorType) {
      case 'settings':
        _settingsError = null;
        break;
      case 'notifications':
        _notificationsError = null;
        break;
      case 'stats':
        _statsError = null;
        break;
      case 'init':
        _initError = null;
        break;
    }
    notifyListeners();
  }

  /// Clear all errors
  void clearAllErrors() {
    _settingsError = null;
    _notificationsError = null;
    _statsError = null;
    _initError = null;
    notifyListeners();
  }

  /// Load all data
  Future<void> loadAllData() async {
    await Future.wait([loadSettings(), loadNotifications(), loadStats()]);
  }

  /// Refresh all data
  Future<void> refreshAllData() async {
    await Future.wait([
      loadSettings(),
      refreshNotifications(),
      loadStats(),
      _loadBadgeCount(),
    ]);
  }
}
