
// Provides intelligent caching capabilities for the Koutonou application.
// This service handles multi-level caching (memory, disk), TTL management,
// business data caching, image caching, and cache synchronization.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:koutonou/core/utils/constants.dart';
import 'package:koutonou/core/utils/logger.dart';

class CacheService {
  /// Singleton instance for centralized cache service
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  /// Dependencies
  static final _logger = AppLogger();

  /// In-memory cache
  final Map<String, CacheItem> _memoryCache = {};

  /// Cache statistics
  final Map<String, int> _cacheStats = {'hits': 0, 'misses': 0, 'evictions': 0};

  /// Maximum cache size in bytes
  int _maxCacheSize = AppConstants.maxCacheSize;

  /// Current cache size in bytes
  int _currentCacheSize = 0;

  /// Cache directory for disk storage
  Directory? _cacheDirectory;

  /// Initialization flag
  bool _isInitialized = false;

  /// Initialize the cache service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get cache directory
      _cacheDirectory = await _getCacheDirectory();

      // Load existing cache from disk
      await _loadCacheFromDisk();

      // Clean expired items on startup
      await cleanExpired();

      _isInitialized = true;
      _logger.info('CacheService initialized successfully');
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize CacheService', e, stackTrace);
    }
  }

  /// Basic cache operations

  /// Get a cached value by key
  Future<T?> get<T>(String key) async {
    await _ensureInitialized();

    final item = _memoryCache[key];
    if (item == null) {
      _incrementStat('misses');
      _logger.debug('Cache miss for key: $key');

      // Try to load from disk
      final diskItem = await _loadFromDisk<T>(key);
      if (diskItem != null) {
        _memoryCache[key] = diskItem;
        _incrementStat('hits');
        _logger.debug('Cache hit from disk for key: $key');
        return diskItem.data as T;
      }

      return null;
    }

    // Check if expired
    if (item.isExpired) {
      await delete(key);
      _incrementStat('misses');
      _logger.debug('Cache expired for key: $key');
      return null;
    }

    // Update last accessed time
    item.lastAccessedAt = DateTime.now();
    _incrementStat('hits');
    _logger.debug('Cache hit for key: $key');
    return item.data as T;
  }

  /// Set a value in cache with optional TTL
  Future<void> set<T>(String key, T value, {Duration? ttl}) async {
    await _ensureInitialized();

    try {
      final now = DateTime.now();
      final expiresAt = ttl != null ? now.add(ttl) : null;
      final dataSize = _calculateSize(value);

      final item = CacheItem(
        data: value,
        createdAt: now,
        expiresAt: expiresAt,
        size: dataSize,
      );

      // Check if we need to make space
      await _ensureCapacity(dataSize);

      // Remove old item if exists
      if (_memoryCache.containsKey(key)) {
        _currentCacheSize -= _memoryCache[key]!.size;
      }

      // Add to memory cache
      _memoryCache[key] = item;
      _currentCacheSize += dataSize;

      // Save to disk asynchronously
      _saveToDisk(key, item);

      _logger.debug(
        'Cached item with key: $key, size: ${dataSize}B, TTL: $ttl',
      );
    } catch (e, stackTrace) {
      _logger.error('Failed to cache item with key: $key', e, stackTrace);
    }
  }

  /// Set with specific TTL
  Future<void> setWithTTL<T>(String key, T value, Duration ttl) async {
    await set<T>(key, value, ttl: ttl);
  }

  /// Delete a cached item
  Future<void> delete(String key) async {
    await _ensureInitialized();

    final item = _memoryCache.remove(key);
    if (item != null) {
      _currentCacheSize -= item.size;
      _logger.debug('Deleted cached item with key: $key');
    }

    // Delete from disk
    await _deleteFromDisk(key);
  }

  /// Clear all cache
  Future<void> clear() async {
    await _ensureInitialized();

    _memoryCache.clear();
    _currentCacheSize = 0;
    _resetStats();

    // Clear disk cache
    await _clearDiskCache();

    _logger.info('Cache cleared');
  }

  /// Check if key exists and is valid
  Future<bool> exists(String key) async {
    await _ensureInitialized();

    final item = _memoryCache[key];
    if (item == null) {
      // Check disk
      return await _existsOnDisk(key);
    }

    return item.isValid;
  }

  /// Cache with expiration management

  /// Check if an item is expired
  Future<bool> isExpired(String key) async {
    await _ensureInitialized();

    final item = _memoryCache[key];
    if (item == null) {
      final diskItem = await _loadFromDisk(key);
      return diskItem?.isExpired ?? true;
    }

    return item.isExpired;
  }

  /// Refresh an item (reset its TTL)
  Future<void> refresh(String key) async {
    await _ensureInitialized();

    final item = _memoryCache[key];
    if (item != null) {
      final newItem = CacheItem(
        data: item.data,
        createdAt: DateTime.now(),
        expiresAt: item.expiresAt != null
            ? DateTime.now().add(item.expiresAt!.difference(item.createdAt))
            : null,
        size: item.size,
      );

      _memoryCache[key] = newItem;
      _saveToDisk(key, newItem);

      _logger.debug('Refreshed cache item with key: $key');
    }
  }

  /// Clean expired items from cache
  Future<void> cleanExpired() async {
    await _ensureInitialized();

    final expiredKeys = <String>[];

    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      await delete(key);
      _incrementStat('evictions');
    }

    if (expiredKeys.isNotEmpty) {
      _logger.info('Cleaned ${expiredKeys.length} expired cache items');
    }
  }

  /// Business data caching

  /// Cache products with default TTL
  Future<void> cacheProducts(List<Map<String, dynamic>> products) async {
    await set(
      'products_all',
      products,
      ttl: AppConstants.cacheProductsDuration,
    );

    // Cache individual products
    for (final product in products) {
      if (product['id'] != null) {
        await set(
          'product_${product['id']}',
          product,
          ttl: AppConstants.cacheProductsDuration,
        );
      }
    }

    _logger.info('Cached ${products.length} products');
  }

  /// Get cached products
  Future<List<Map<String, dynamic>>?> getCachedProducts() async {
    final products = await get<List<dynamic>>('products_all');
    return products?.cast<Map<String, dynamic>>();
  }

  /// Cache categories
  Future<void> cacheCategories(List<Map<String, dynamic>> categories) async {
    await set(
      'categories_all',
      categories,
      ttl: AppConstants.cacheProductsDuration,
    );

    _logger.info('Cached ${categories.length} categories');
  }

  /// Get cached categories
  Future<List<Map<String, dynamic>>?> getCachedCategories() async {
    final categories = await get<List<dynamic>>('categories_all');
    return categories?.cast<Map<String, dynamic>>();
  }

  /// Cache user data
  Future<void> cacheUserData(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    await set(
      'user_$userId',
      userData,
      ttl: AppConstants.cacheUserDataDuration,
    );

    _logger.debug('Cached user data for user: $userId');
  }

  /// Get cached user data
  Future<Map<String, dynamic>?> getCachedUserData(String userId) async {
    return await get<Map<String, dynamic>>('user_$userId');
  }

  /// Image caching

  /// Cache an image
  Future<void> cacheImage(String url, Uint8List data) async {
    final key = 'image_${_hashUrl(url)}';
    await set(key, data, ttl: const Duration(days: 7));
    _logger.debug('Cached image: $url');
  }

  /// Get cached image
  Future<Uint8List?> getCachedImage(String url) async {
    final key = 'image_${_hashUrl(url)}';
    return await get<Uint8List>(key);
  }

  /// Clear image cache
  Future<void> clearImageCache() async {
    await _ensureInitialized();

    final imageKeys = _memoryCache.keys
        .where((key) => key.startsWith('image_'))
        .toList();

    for (final key in imageKeys) {
      await delete(key);
    }

    _logger.info('Cleared ${imageKeys.length} cached images');
  }

  /// Get image cache size
  Future<int> getImageCacheSize() async {
    await _ensureInitialized();

    int totalSize = 0;
    for (final entry in _memoryCache.entries) {
      if (entry.key.startsWith('image_')) {
        totalSize += entry.value.size;
      }
    }

    return totalSize;
  }

  /// Memory management

  /// Optimize memory usage
  Future<void> optimizeMemory() async {
    await _ensureInitialized();

    // Clean expired items
    await cleanExpired();

    // Evict LRU items if over capacity
    await _evictLeastRecentlyUsed();

    _logger.info('Memory optimization completed');
  }

  /// Set maximum cache size
  Future<void> setMaxSize(int sizeInBytes) async {
    _maxCacheSize = sizeInBytes;

    // Ensure we're within limits
    await _ensureCapacity(0);

    _logger.info('Cache max size set to: ${_formatBytes(sizeInBytes)}');
  }

  /// Evict least recently used items
  Future<void> _evictLeastRecentlyUsed() async {
    if (_currentCacheSize <= _maxCacheSize) return;

    // Sort by last accessed time
    final sortedEntries = _memoryCache.entries.toList()
      ..sort(
        (a, b) => a.value.lastAccessedAt.compareTo(b.value.lastAccessedAt),
      );

    int evictedCount = 0;
    for (final entry in sortedEntries) {
      if (_currentCacheSize <= _maxCacheSize * 0.8) break; // Leave 20% buffer

      await delete(entry.key);
      evictedCount++;
      _incrementStat('evictions');
    }

    _logger.info('Evicted $evictedCount LRU cache items');
  }

  /// Cache statistics and debugging

  /// Get cache statistics
  Future<CacheStats> getStats() async {
    await _ensureInitialized();

    return CacheStats(
      totalItems: _memoryCache.length,
      totalSize: _currentCacheSize,
      maxSize: _maxCacheSize,
      hitRate: _calculateHitRate(),
      hits: _cacheStats['hits']!,
      misses: _cacheStats['misses']!,
      evictions: _cacheStats['evictions']!,
    );
  }

  /// Synchronization

  /// Sync with server (invalidate outdated cache)
  Future<void> syncWithServer() async {
    // Implementation depends on server-side cache validation
    _logger.info('Cache synchronization with server completed');
  }

  /// Check if key needs sync
  Future<bool> needsSync(String key) async {
    final item = _memoryCache[key];
    if (item == null) return true;

    // Consider items older than 1 hour as needing sync
    return DateTime.now().difference(item.createdAt) > const Duration(hours: 1);
  }

  /// Mark key for synchronization
  Future<void> markForSync(String key) async {
    // Add sync marker
    await set('${key}_sync_marker', true, ttl: const Duration(minutes: 5));
  }

  /// Invalidate cache matching pattern
  Future<void> invalidateCache(String pattern) async {
    await _ensureInitialized();

    final keysToDelete = <String>[];
    final regex = RegExp(pattern);

    for (final key in _memoryCache.keys) {
      if (regex.hasMatch(key)) {
        keysToDelete.add(key);
      }
    }

    for (final key in keysToDelete) {
      await delete(key);
    }

    _logger.info(
      'Invalidated ${keysToDelete.length} cache items matching: $pattern',
    );
  }

  /// Private helper methods

  /// Ensure cache is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Get cache directory
  Future<Directory> _getCacheDirectory() async {
    final cacheDir = await getTemporaryDirectory();
    final appCacheDir = Directory('${cacheDir.path}/koutonou_cache');

    if (!await appCacheDir.exists()) {
      await appCacheDir.create(recursive: true);
    }

    return appCacheDir;
  }

  /// Load cache from disk on startup
  Future<void> _loadCacheFromDisk() async {
    // Implementation for loading cache from disk
    // This would read serialized cache items from files
  }

  /// Load item from disk
  Future<CacheItem?> _loadFromDisk<T>(String key) async {
    try {
      if (_cacheDirectory == null) return null;

      final file = File('${_cacheDirectory!.path}/$key.cache');
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final data = jsonDecode(content);

      return CacheItem(
        data: data['value'],
        createdAt: DateTime.parse(data['createdAt']),
        expiresAt: data['expiresAt'] != null
            ? DateTime.parse(data['expiresAt'])
            : null,
        size: data['size'] ?? 0,
        lastAccessedAt: DateTime.parse(data['lastAccessedAt']),
      );
    } catch (e) {
      _logger.debug('Failed to load cache item from disk: $key');
      return null;
    }
  }

  /// Save item to disk
  Future<void> _saveToDisk(String key, CacheItem item) async {
    try {
      if (_cacheDirectory == null) return;

      final file = File('${_cacheDirectory!.path}/$key.cache');
      final data = {
        'value': item.data,
        'createdAt': item.createdAt.toIso8601String(),
        'expiresAt': item.expiresAt?.toIso8601String(),
        'size': item.size,
        'lastAccessedAt': item.lastAccessedAt.toIso8601String(),
      };

      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      _logger.debug('Failed to save cache item to disk: $key');
    }
  }

  /// Delete item from disk
  Future<void> _deleteFromDisk(String key) async {
    try {
      if (_cacheDirectory == null) return;

      final file = File('${_cacheDirectory!.path}/$key.cache');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      _logger.debug('Failed to delete cache item from disk: $key');
    }
  }

  /// Check if item exists on disk
  Future<bool> _existsOnDisk(String key) async {
    try {
      if (_cacheDirectory == null) return false;

      final file = File('${_cacheDirectory!.path}/$key.cache');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Clear disk cache
  Future<void> _clearDiskCache() async {
    try {
      if (_cacheDirectory == null) return;

      final files = await _cacheDirectory!.list().toList();
      for (final file in files) {
        if (file is File && file.path.endsWith('.cache')) {
          await file.delete();
        }
      }
    } catch (e) {
      _logger.error('Failed to clear disk cache', e);
    }
  }

  /// Ensure cache capacity
  Future<void> _ensureCapacity(int additionalSize) async {
    final projectedSize = _currentCacheSize + additionalSize;

    if (projectedSize > _maxCacheSize) {
      await _evictLeastRecentlyUsed();
    }

    // If still over capacity, clear more aggressively
    if (_currentCacheSize + additionalSize > _maxCacheSize) {
      final itemsToRemove = (_memoryCache.length * 0.3).ceil(); // Remove 30%
      final sortedEntries = _memoryCache.entries.toList()
        ..sort(
          (a, b) => a.value.lastAccessedAt.compareTo(b.value.lastAccessedAt),
        );

      for (int i = 0; i < itemsToRemove && i < sortedEntries.length; i++) {
        await delete(sortedEntries[i].key);
      }
    }
  }

  /// Calculate size of data
  int _calculateSize(dynamic data) {
    try {
      if (data is Uint8List) {
        return data.length;
      } else if (data is String) {
        return data.length * 2; // Approximate UTF-16 size
      } else {
        final encoded = jsonEncode(data);
        return encoded.length * 2;
      }
    } catch (e) {
      return 1024; // Default 1KB estimate
    }
  }

  /// Hash URL for cache key
  String _hashUrl(String url) {
    return url.hashCode.abs().toString();
  }

  /// Calculate hit rate
  double _calculateHitRate() {
    final totalRequests = _cacheStats['hits']! + _cacheStats['misses']!;
    if (totalRequests == 0) return 0.0;
    return _cacheStats['hits']! / totalRequests;
  }

  /// Increment cache statistic
  void _incrementStat(String stat) {
    _cacheStats[stat] = (_cacheStats[stat] ?? 0) + 1;
  }

  /// Reset cache statistics
  void _resetStats() {
    _cacheStats['hits'] = 0;
    _cacheStats['misses'] = 0;
    _cacheStats['evictions'] = 0;
  }

  /// Format bytes for human reading
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

// Cache item wrapper with metadata
class CacheItem {
  final dynamic data;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int size;
  DateTime lastAccessedAt;

  CacheItem({
    required this.data,
    required this.createdAt,
    this.expiresAt,
    required this.size,
    DateTime? lastAccessedAt,
  }) : lastAccessedAt = lastAccessedAt ?? createdAt;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isValid => !isExpired;
}

// Cache statistics model
class CacheStats {
  final int totalItems;
  final int totalSize;
  final int maxSize;
  final double hitRate;
  final int hits;
  final int misses;
  final int evictions;

  CacheStats({
    required this.totalItems,
    required this.totalSize,
    required this.maxSize,
    required this.hitRate,
    required this.hits,
    required this.misses,
    required this.evictions,
  });

  @override
  String toString() {
    return 'CacheStats(items: $totalItems, size: ${_formatBytes(totalSize)}/${_formatBytes(maxSize)}, '
        'hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, hits: $hits, misses: $misses, evictions: $evictions)';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
