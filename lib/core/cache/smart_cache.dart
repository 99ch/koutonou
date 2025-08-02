// Cache intelligent avec support mémoire
// Système de cache adaptatif avec TTL et invalidation

import 'dart:async';
import 'dart:convert';
import 'package:koutonou/core/utils/logger.dart';

/// Stratégies de cache
enum CacheStrategy {
  memoryOnly, // Cache en mémoire uniquement
  memoryFirst, // Mémoire en priorité, disque en backup
  diskFirst, // Disque en priorité, mémoire en backup
  hybrid, // Adaptatif selon la taille et la fréquence
}

/// Élément de cache avec métadonnées
class CacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int accessCount;
  final DateTime lastAccessed;
  final int sizeBytes;

  const CacheEntry({
    required this.value,
    required this.createdAt,
    this.expiresAt,
    required this.accessCount,
    required this.lastAccessed,
    required this.sizeBytes,
  });

  /// Vérifie si l'entrée est expirée
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Vérifie si l'entrée est valide
  bool get isValid => !isExpired;

  /// Crée une copie avec accès incrémenté
  CacheEntry<T> withAccess() {
    return CacheEntry<T>(
      value: value,
      createdAt: createdAt,
      expiresAt: expiresAt,
      accessCount: accessCount + 1,
      lastAccessed: DateTime.now(),
      sizeBytes: sizeBytes,
    );
  }

  /// Calcule la taille approximative en bytes
  static int calculateSize(dynamic value) {
    try {
      if (value == null) return 0;
      if (value is String) return value.length * 2; // UTF-16
      if (value is num) return 8;
      if (value is bool) return 1;
      if (value is List) return value.length * 8;
      if (value is Map) return value.length * 16;

      // Pour les objets complexes, utiliser JSON
      final jsonString = jsonEncode(value);
      return jsonString.length * 2;
    } catch (e) {
      return 1024; // Taille par défaut
    }
  }
}

/// Configuration du cache
class CacheConfig {
  final CacheStrategy strategy;
  final int maxMemoryEntries;
  final int maxMemorySizeMB;
  final int maxDiskEntries;
  final int maxDiskSizeMB;
  final Duration defaultTTL;
  final Duration cleanupInterval;
  final bool enableCompression;
  final bool enableEncryption;

  const CacheConfig({
    this.strategy = CacheStrategy.memoryFirst,
    this.maxMemoryEntries = 1000,
    this.maxMemorySizeMB = 50,
    this.maxDiskEntries = 5000,
    this.maxDiskSizeMB = 500,
    this.defaultTTL = const Duration(hours: 1),
    this.cleanupInterval = const Duration(minutes: 5),
    this.enableCompression = false,
    this.enableEncryption = false,
  });

  /// Configuration pour le développement
  factory CacheConfig.development() {
    return const CacheConfig(
      strategy: CacheStrategy.memoryOnly,
      maxMemoryEntries: 500,
      maxMemorySizeMB: 25,
      defaultTTL: Duration(minutes: 30),
      cleanupInterval: Duration(minutes: 2),
    );
  }

  /// Configuration pour la production
  factory CacheConfig.production() {
    return const CacheConfig(
      strategy: CacheStrategy.hybrid,
      maxMemoryEntries: 2000,
      maxMemorySizeMB: 100,
      maxDiskEntries: 10000,
      maxDiskSizeMB: 1000,
      defaultTTL: Duration(hours: 6),
      cleanupInterval: Duration(minutes: 10),
      enableCompression: true,
    );
  }
}

/// Cache intelligent PrestaShop
class PrestaShopSmartCache {
  static final AppLogger _logger = AppLogger();

  final CacheConfig _config;
  final Map<String, CacheEntry> _memoryCache = {};
  Timer? _cleanupTimer;

  // Statistiques
  int _hits = 0;
  int _misses = 0;
  int _evictions = 0;

  PrestaShopSmartCache({CacheConfig? config})
    : _config = config ?? CacheConfig.development() {
    _startCleanupTimer();
  }

  /// Démarre le timer de nettoyage automatique
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(_config.cleanupInterval, (_) {
      _cleanupExpired();
    });
  }

  /// Obtient une valeur du cache
  Future<T?> get<T>(String key) async {
    try {
      // Vérifier le cache mémoire
      final memoryEntry = _memoryCache[key];
      if (memoryEntry != null) {
        if (memoryEntry.isValid) {
          _hits++;
          // Mettre à jour les statistiques d'accès
          _memoryCache[key] = memoryEntry.withAccess();
          _logger.debug('Cache hit mémoire pour: $key');
          return memoryEntry.value as T;
        } else {
          // Entrée expirée
          _memoryCache.remove(key);
          _logger.debug('Entrée expirée supprimée: $key');
        }
      }

      _misses++;
      _logger.debug('Cache miss pour: $key');
      return null;
    } catch (e) {
      _logger.error('Erreur get cache: $e');
      return null;
    }
  }

  /// Stocke une valeur dans le cache
  Future<void> set<T>(String key, T value, {Duration? duration}) async {
    try {
      final ttl = duration ?? _config.defaultTTL;
      final expiresAt = DateTime.now().add(ttl);
      final sizeBytes = CacheEntry.calculateSize(value);

      final entry = CacheEntry<T>(
        value: value,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        accessCount: 0,
        lastAccessed: DateTime.now(),
        sizeBytes: sizeBytes,
      );

      // Stocker en mémoire
      await _setInMemory(key, entry);

      _logger.debug('Valeur mise en cache: $key (TTL: ${ttl.inMinutes}min)');
    } catch (e) {
      _logger.error('Erreur set cache: $e');
    }
  }

  /// Stocke en mémoire avec gestion de la limite
  Future<void> _setInMemory(String key, CacheEntry entry) async {
    // Vérifier les limites de mémoire
    if (_memoryCache.length >= _config.maxMemoryEntries) {
      await _evictFromMemory();
    }

    _memoryCache[key] = entry;
  }

  /// Éviction LRU du cache mémoire
  Future<void> _evictFromMemory() async {
    if (_memoryCache.isEmpty) return;

    // Trouver l'entrée la moins récemment utilisée
    String? oldestKey;
    DateTime? oldestAccess;

    for (final entry in _memoryCache.entries) {
      if (oldestAccess == null ||
          entry.value.lastAccessed.isBefore(oldestAccess)) {
        oldestAccess = entry.value.lastAccessed;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _memoryCache.remove(oldestKey);
      _evictions++;
      _logger.debug('Éviction mémoire: $oldestKey');
    }
  }

  /// Supprime une clé du cache
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    _logger.debug('Clé supprimée: $key');
  }

  /// Vide complètement le cache
  Future<void> clear() async {
    _memoryCache.clear();
    _logger.debug('Cache vidé');
  }

  /// Invalide les clés correspondant à un pattern
  Future<void> invalidatePattern(String pattern) async {
    final regex = RegExp(pattern);
    final keysToRemove = <String>[];

    for (final key in _memoryCache.keys) {
      if (regex.hasMatch(key)) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      await remove(key);
    }

    _logger.debug('Pattern invalidé: $pattern (${keysToRemove.length} clés)');
  }

  /// Nettoyage automatique des entrées expirées
  Future<void> _cleanupExpired() async {
    final expiredKeys = <String>[];

    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      _logger.debug(
        'Nettoyage automatique: ${expiredKeys.length} entrées expirées',
      );
    }
  }

  /// Obtient les statistiques du cache
  Future<Map<String, dynamic>> getStats() async {
    final memorySize = _memoryCache.values.fold<int>(
      0,
      (sum, entry) => sum + entry.sizeBytes,
    );

    final totalRequests = _hits + _misses;
    final hitRate = totalRequests > 0 ? (_hits / totalRequests * 100) : 0.0;

    return {
      'strategy': _config.strategy.toString(),
      'memoryEntries': _memoryCache.length,
      'memorySizeMB': (memorySize / (1024 * 1024)).toStringAsFixed(2),
      'diskEntries': 0, // Pas de disque pour l'instant
      'diskSizeMB': '0.00',
      'hits': _hits,
      'misses': _misses,
      'evictions': _evictions,
      'hitRate': '${hitRate.toStringAsFixed(1)}%',
      'totalRequests': totalRequests,
      'config': {
        'maxMemoryEntries': _config.maxMemoryEntries,
        'maxMemorySizeMB': _config.maxMemorySizeMB,
        'defaultTTLMinutes': _config.defaultTTL.inMinutes,
        'cleanupIntervalMinutes': _config.cleanupInterval.inMinutes,
      },
    };
  }

  /// Vérifie si une clé existe et est valide
  Future<bool> exists(String key) async {
    final entry = _memoryCache[key];
    return entry != null && entry.isValid;
  }

  /// Ferme le cache et nettoie les ressources
  Future<void> dispose() async {
    _cleanupTimer?.cancel();
    _memoryCache.clear();
    _logger.debug('Cache fermé');
  }

  /// Réinitialise les statistiques
  void resetStats() {
    _hits = 0;
    _misses = 0;
    _evictions = 0;
    _logger.debug('Statistiques réinitialisées');
  }
}
