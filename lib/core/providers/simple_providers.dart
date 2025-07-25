// Providers simplifiés pour les tests du router
// Ces providers n'ont pas de dépendances complexes et permettent de tester l'architecture

import 'package:flutter/material.dart';

/// Version simplifiée du UserProvider pour les tests
class SimpleUserProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  bool get hasError => _errorMessage != null;

  /// Simule le chargement des données utilisateur
  Future<void> loadUserData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      _userData = {
        'id': '1',
        'name': 'Utilisateur Test',
        'email': 'test@example.com',
        'preferences': {'theme': 'auto', 'language': 'fr'},
      };
      print('✅ SimpleUserProvider: Données utilisateur chargées');
    } catch (e) {
      _errorMessage = 'Erreur de chargement';
      print('❌ SimpleUserProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Simule la mise à jour du profil
  Future<void> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 200));

    try {
      _userData = {..._userData ?? {}, ...data};
      print('✅ SimpleUserProvider: Profil mis à jour');
    } catch (e) {
      _errorMessage = 'Erreur de mise à jour';
      print('❌ SimpleUserProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Version simplifiée du NotificationProvider pour les tests
class SimpleNotificationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  // Getters
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  /// Simule l'ajout d'une notification
  void addNotification(String title, String message, {String type = 'info'}) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };

    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
    print('📱 SimpleNotificationProvider: Notification ajoutée - $title');
  }

  /// Marque une notification comme lue
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1 && !_notifications[index]['isRead']) {
      _notifications[index]['isRead'] = true;
      _unreadCount = (_unreadCount - 1).clamp(0, _notifications.length);
      notifyListeners();
      print('✅ SimpleNotificationProvider: Notification marquée comme lue');
    }
  }

  /// Marque toutes les notifications comme lues
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    _unreadCount = 0;
    notifyListeners();
    print(
      '✅ SimpleNotificationProvider: Toutes les notifications marquées comme lues',
    );
  }

  /// Simule le chargement des notifications
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    // Ajouter quelques notifications de test
    _notifications = [
      {
        'id': '1',
        'title': 'Bienvenue !',
        'message': 'Bienvenue dans l\'application Koutonou',
        'type': 'success',
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      },
      {
        'id': '2',
        'title': 'Test des notifications',
        'message': 'Ceci est une notification de test',
        'type': 'info',
        'timestamp': DateTime.now()
            .subtract(const Duration(hours: 1))
            .toIso8601String(),
        'isRead': true,
      },
    ];

    _unreadCount = _notifications.where((n) => !n['isRead']).length;
    _isLoading = false;
    notifyListeners();
    print('✅ SimpleNotificationProvider: Notifications chargées');
  }
}

/// Version simplifiée du CacheProvider pour les tests
class SimpleCacheProvider with ChangeNotifier {
  final Map<String, dynamic> _cache = {};
  bool _isLoading = false;
  int _cacheSize = 0;

  // Getters
  bool get isLoading => _isLoading;
  int get cacheSize => _cacheSize;
  int get itemCount => _cache.length;

  /// Simule la mise en cache d'une valeur
  Future<void> cache(String key, dynamic value) async {
    _cache[key] = {
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'size': value.toString().length,
    };

    _updateCacheSize();
    notifyListeners();
    print('💾 SimpleCacheProvider: Valeur mise en cache - $key');
  }

  /// Récupère une valeur du cache
  T? get<T>(String key) {
    final cached = _cache[key];
    if (cached != null) {
      print('✅ SimpleCacheProvider: Valeur récupérée du cache - $key');
      return cached['value'] as T?;
    }
    print('❌ SimpleCacheProvider: Valeur non trouvée dans le cache - $key');
    return null;
  }

  /// Vérifie si une clé existe dans le cache
  bool contains(String key) {
    return _cache.containsKey(key);
  }

  /// Supprime une valeur du cache
  void remove(String key) {
    if (_cache.remove(key) != null) {
      _updateCacheSize();
      notifyListeners();
      print('🗑️ SimpleCacheProvider: Valeur supprimée du cache - $key');
    }
  }

  /// Vide le cache
  void clear() {
    _cache.clear();
    _cacheSize = 0;
    notifyListeners();
    print('🧹 SimpleCacheProvider: Cache vidé');
  }

  /// Simule un nettoyage du cache
  Future<void> cleanup() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 200));

    // Supprimer les entrées anciennes (simulation)
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiredKeys = _cache.entries
        .where((entry) => now - entry.value['timestamp'] > 60000) // 1 minute
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    _updateCacheSize();
    _isLoading = false;
    notifyListeners();
    print(
      '🧹 SimpleCacheProvider: Nettoyage terminé, ${expiredKeys.length} entrées supprimées',
    );
  }

  /// Met à jour la taille du cache
  void _updateCacheSize() {
    _cacheSize = _cache.values
        .map((v) => v['size'] as int)
        .fold(0, (sum, size) => sum + size);
  }
}
