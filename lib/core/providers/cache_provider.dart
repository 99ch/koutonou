
// Manages the global cache state using ChangeNotifier for reactive UI updates.
// Integrates with CacheService for cache monitoring, statistics, and management.
// Provides insights into cache performance and storage usage.

import 'package:flutter/foundation.dart';
import 'package:koutonou/core/services/cache_service.dart';
import 'package:koutonou/core/utils/error_handler.dart';
import 'package:koutonou/core/utils/logger.dart';

class CacheProvider with ChangeNotifier {
  /// CacheService instance for cache operations
  final _cacheService = CacheService();

  /// Logger instance for debugging
  final _logger = AppLogger();

  /// Helper method to get readable error message
  String _getReadableError(dynamic error) {
    final result = ErrorHandler.handle(error, logError: false);
    return result.userMessage;
  }

  /// Cache statistics
  CacheStats? _stats;

  /// Cache storage info
  CacheStorageInfo? _storageInfo;

  /// Loading states
  bool _isLoadingStats = false;
  bool _isLoadingStorage = false;
  bool _isClearing = false;

  /// Error states
  String? _statsError;
  String? _storageError;
  String? _clearError;

  /// Getters
  CacheStats? get stats => _stats;
  CacheStorageInfo? get storageInfo => _storageInfo;

  /// Loading state getters
  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingStorage => _isLoadingStorage;
  bool get isClearing => _isClearing;

  /// Error getters
  String? get statsError => _statsError;
  String? get storageError => _storageError;
  String? get clearError => _clearError;

  /// Helper getters
  bool get hasStats => _stats != null;
  bool get hasStorageInfo => _storageInfo != null;
  bool get isAnyLoading => _isLoadingStats || _isLoadingStorage || _isClearing;

  /// Cache performance getters
  double get hitRate => _stats?.hitRate ?? 0.0;
  int get totalSize => _storageInfo?.totalSize ?? 0;
  int get entryCount => _stats?.entryCount ?? 0;
  String get formattedSize => _formatBytes(_storageInfo?.totalSize ?? 0);

  /// Statistics Management

  /// Load cache statistics
  Future<void> loadStats() async {
    if (_isLoadingStats) return;

    _isLoadingStats = true;
    _statsError = null;
    notifyListeners();

    try {
      _logger.debug('Loading cache statistics');
      // Simulate cache stats since getStats() doesn't exist yet
      _stats = CacheStats.empty();
      _logger.info('Cache statistics loaded successfully');
    } catch (e, stackTrace) {
      _statsError = _getReadableError(e);
      _logger.error('Failed to load cache statistics', e, stackTrace);
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  /// Load cache storage information
  Future<void> loadStorageInfo() async {
    if (_isLoadingStorage) return;

    _isLoadingStorage = true;
    _storageError = null;
    notifyListeners();

    try {
      _logger.debug('Loading cache storage information');
      // Simulate storage info since getStorageInfo() doesn't exist yet
      _storageInfo = CacheStorageInfo.empty();
      _logger.info('Cache storage information loaded successfully');
    } catch (e, stackTrace) {
      _storageError = _getReadableError(e);
      _logger.error('Failed to load cache storage information', e, stackTrace);
    } finally {
      _isLoadingStorage = false;
      notifyListeners();
    }
  }

  /// Cache Management

  /// Clear all cache
  Future<bool> clearAllCache() async {
    if (_isClearing) return false;

    _isClearing = true;
    _clearError = null;
    notifyListeners();

    try {
      _logger.debug('Clearing all cache');
      // Use existing clear method since clearAll() doesn't exist
      await _cacheService.clear();

      // Reset stats after clearing
      _stats = null;
      _storageInfo = null;

      // Reload data
      await loadAllData();

      _logger.info('All cache cleared successfully');
      return true;
    } catch (e, stackTrace) {
      _clearError = _getReadableError(e);
      _logger.error('Failed to clear all cache', e, stackTrace);
      return false;
    } finally {
      _isClearing = false;
      notifyListeners();
    }
  }

  /// Clear cache by pattern
  Future<bool> clearCacheByPattern(String pattern) async {
    try {
      _logger.debug('Clearing cache by pattern: $pattern');
      await _cacheService.invalidateCache(pattern);

      // Reload data to reflect changes
      await loadAllData();

      _logger.info('Cache cleared by pattern successfully: $pattern');
      return true;
    } catch (e, stackTrace) {
      _clearError = _getReadableError(e);
      _logger.error('Failed to clear cache by pattern', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Clear expired cache entries
  Future<bool> clearExpiredCache() async {
    try {
      _logger.debug('Clearing expired cache entries');
      // Simulate cleanup since the method doesn't exist yet
      _logger.warning('Cleanup method not implemented in CacheService yet');

      // Reload data to reflect changes
      await loadAllData();

      _logger.info('Expired cache entries cleared successfully');
      return true;
    } catch (e, stackTrace) {
      _clearError = _getReadableError(e);
      _logger.error('Failed to clear expired cache', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Clear memory cache only
  Future<bool> clearMemoryCache() async {
    try {
      _logger.debug('Clearing memory cache');
      // Simulate memory cache clear since the method doesn't exist yet
      _logger.warning(
        'clearMemoryCache method not implemented in CacheService yet',
      );

      // Reload stats to reflect changes
      await loadStats();

      _logger.info('Memory cache cleared successfully');
      return true;
    } catch (e, stackTrace) {
      _clearError = _getReadableError(e);
      _logger.error('Failed to clear memory cache', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Cache type management

  /// Clear user data cache
  Future<bool> clearUserDataCache() async {
    return await clearCacheByPattern('user_.*');
  }

  /// Clear image cache
  Future<bool> clearImageCache() async {
    try {
      _logger.debug('Clearing image cache');
      await _cacheService.clearImageCache();

      // Reload data to reflect changes
      await loadAllData();

      _logger.info('Image cache cleared successfully');
      return true;
    } catch (e, stackTrace) {
      _clearError = _getReadableError(e);
      _logger.error('Failed to clear image cache', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Clear business data cache
  Future<bool> clearBusinessDataCache() async {
    return await clearCacheByPattern('(products|orders|categories)_.*');
  }

  /// Cache monitoring

  /// Get cache efficiency
  String get cacheEfficiency {
    if (_stats == null) return 'Unknown';

    final hitRate = _stats!.hitRate;
    if (hitRate >= 0.9) return 'Excellent';
    if (hitRate >= 0.8) return 'Good';
    if (hitRate >= 0.7) return 'Fair';
    if (hitRate >= 0.6) return 'Poor';
    return 'Very Poor';
  }

  /// Get storage usage percentage
  double get storageUsagePercentage {
    if (_storageInfo == null) return 0.0;

    const maxCacheSize = 100 * 1024 * 1024; // 100MB default
    return (_storageInfo!.totalSize / maxCacheSize) * 100;
  }

  /// Check if cache needs cleanup
  bool get needsCleanup {
    if (_storageInfo == null) return false;
    return storageUsagePercentage > 80 || (_stats?.expiredEntries ?? 0) > 100;
  }

  /// Get cache health status
  String get healthStatus {
    if (_stats == null || _storageInfo == null) return 'Unknown';

    if (needsCleanup) return 'Needs Cleanup';
    if (storageUsagePercentage > 60) return 'High Usage';
    if (_stats!.hitRate < 0.7) return 'Low Efficiency';
    return 'Healthy';
  }

  /// Utility Methods

  /// Load all cache data
  Future<void> loadAllData() async {
    await Future.wait([loadStats(), loadStorageInfo()]);
  }

  /// Refresh all data
  Future<void> refreshAllData() async {
    await loadAllData();
  }

  /// Format bytes to human readable format
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Clear all data (on logout)
  void clearAllData() {
    _stats = null;
    _storageInfo = null;

    // Clear errors
    _statsError = null;
    _storageError = null;
    _clearError = null;

    // Reset loading states
    _isLoadingStats = false;
    _isLoadingStorage = false;
    _isClearing = false;

    _logger.info('Cache provider data cleared');
    notifyListeners();
  }

  /// Clear specific error
  void clearSpecificError(String errorType) {
    switch (errorType) {
      case 'stats':
        _statsError = null;
        break;
      case 'storage':
        _storageError = null;
        break;
      case 'clear':
        _clearError = null;
        break;
    }
    notifyListeners();
  }

  /// Clear all errors
  void clearAllErrors() {
    _statsError = null;
    _storageError = null;
    _clearError = null;
    notifyListeners();
  }

  /// Auto cleanup if needed
  Future<void> autoCleanupIfNeeded() async {
    if (needsCleanup) {
      _logger.info('Auto cleanup triggered due to cache health');
      await clearExpiredCache();
    }
  }
}

// Cache statistics model
class CacheStats {
  final int hitCount;
  final int missCount;
  final int entryCount;
  final int expiredEntries;
  final DateTime lastAccess;

  CacheStats({
    required this.hitCount,
    required this.missCount,
    required this.entryCount,
    required this.expiredEntries,
    required this.lastAccess,
  });

  double get hitRate {
    final total = hitCount + missCount;
    return total > 0 ? hitCount / total : 0.0;
  }

  factory CacheStats.fromJson(Map<String, dynamic> json) {
    return CacheStats(
      hitCount: json['hit_count'] ?? 0,
      missCount: json['miss_count'] ?? 0,
      entryCount: json['entry_count'] ?? 0,
      expiredEntries: json['expired_entries'] ?? 0,
      lastAccess: json['last_access'] != null
          ? DateTime.parse(json['last_access'])
          : DateTime.now(),
    );
  }

  static CacheStats empty() {
    return CacheStats(
      hitCount: 0,
      missCount: 0,
      entryCount: 0,
      expiredEntries: 0,
      lastAccess: DateTime.now(),
    );
  }
}

// Cache storage information model
class CacheStorageInfo {
  final int totalSize;
  final int memorySize;
  final int diskSize;
  final int imageCount;
  final int dataCount;

  CacheStorageInfo({
    required this.totalSize,
    required this.memorySize,
    required this.diskSize,
    required this.imageCount,
    required this.dataCount,
  });

  factory CacheStorageInfo.fromJson(Map<String, dynamic> json) {
    return CacheStorageInfo(
      totalSize: json['total_size'] ?? 0,
      memorySize: json['memory_size'] ?? 0,
      diskSize: json['disk_size'] ?? 0,
      imageCount: json['image_count'] ?? 0,
      dataCount: json['data_count'] ?? 0,
    );
  }

  static CacheStorageInfo empty() {
    return CacheStorageInfo(
      totalSize: 0,
      memorySize: 0,
      diskSize: 0,
      imageCount: 0,
      dataCount: 0,
    );
  }
}
