// Gestion d'erreurs avancée pour l'API PrestaShop - Phase 3
// Types d'erreurs, handling intelligent et retry automatique

import 'dart:convert';
import 'dart:io';

/// Types d'erreurs PrestaShop
enum PrestaShopErrorType {
  /// Erreur de réseau (pas de connexion)
  network,

  /// Timeout de requête
  timeout,

  /// Authentification invalide (401)
  authentication,

  /// Accès refusé (403)
  authorization,

  /// Ressource non trouvée (404)
  notFound,

  /// Méthode non autorisée (405)
  methodNotAllowed,

  /// Données invalides (400, 422)
  validation,

  /// Erreur serveur (500+)
  server,

  /// Limite de taux dépassée (429)
  rateLimit,

  /// Erreur de parsing JSON
  parsing,

  /// Configuration invalide
  configuration,

  /// Erreur inconnue
  unknown,
}

/// Exception personnalisée pour PrestaShop
class PrestaShopException implements Exception {
  /// Type d'erreur
  final PrestaShopErrorType type;

  /// Message d'erreur
  final String message;

  /// Code de statut HTTP (si applicable)
  final int? statusCode;

  /// Détails supplémentaires
  final Map<String, dynamic>? details;

  /// Exception originale (si disponible)
  final dynamic originalException;

  /// Timestamp de l'erreur
  final DateTime timestamp;

  PrestaShopException({
    required this.type,
    required this.message,
    this.statusCode,
    this.details,
    this.originalException,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Créé une exception depuis une réponse HTTP
  factory PrestaShopException.fromHttpResponse(
    int statusCode,
    String responseBody, {
    dynamic originalException,
  }) {
    final type = _getErrorTypeFromStatusCode(statusCode);
    String message;
    Map<String, dynamic>? details;

    try {
      final jsonData = json.decode(responseBody);
      if (jsonData is Map<String, dynamic>) {
        message =
            jsonData['message'] ??
            jsonData['error'] ??
            'Erreur HTTP $statusCode';
        details = jsonData;
      } else {
        message = 'Erreur HTTP $statusCode';
      }
    } catch (e) {
      message = responseBody.isNotEmpty
          ? responseBody.length > 200
                ? '${responseBody.substring(0, 200)}...'
                : responseBody
          : 'Erreur HTTP $statusCode';
    }

    return PrestaShopException(
      type: type,
      message: message,
      statusCode: statusCode,
      details: details,
      originalException: originalException,
    );
  }

  /// Créé une exception réseau
  factory PrestaShopException.network(
    String message, {
    dynamic originalException,
  }) {
    return PrestaShopException(
      type: PrestaShopErrorType.network,
      message: message,
      originalException: originalException,
    );
  }

  /// Créé une exception de timeout
  factory PrestaShopException.timeout(
    String message, {
    dynamic originalException,
  }) {
    return PrestaShopException(
      type: PrestaShopErrorType.timeout,
      message: message,
      originalException: originalException,
    );
  }

  /// Créé une exception de parsing
  factory PrestaShopException.parsing(
    String message, {
    dynamic originalException,
  }) {
    return PrestaShopException(
      type: PrestaShopErrorType.parsing,
      message: message,
      originalException: originalException,
    );
  }

  /// Créé une exception de configuration
  factory PrestaShopException.configuration(String message) {
    return PrestaShopException(
      type: PrestaShopErrorType.configuration,
      message: message,
    );
  }

  /// Détermine le type d'erreur depuis le code HTTP
  static PrestaShopErrorType _getErrorTypeFromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
      case 422:
        return PrestaShopErrorType.validation;
      case 401:
        return PrestaShopErrorType.authentication;
      case 403:
        return PrestaShopErrorType.authorization;
      case 404:
        return PrestaShopErrorType.notFound;
      case 405:
        return PrestaShopErrorType.methodNotAllowed;
      case 429:
        return PrestaShopErrorType.rateLimit;
      case >= 500:
        return PrestaShopErrorType.server;
      default:
        return PrestaShopErrorType.unknown;
    }
  }

  /// Indique si l'erreur est récupérable (retry possible)
  bool get isRetryable {
    switch (type) {
      case PrestaShopErrorType.network:
      case PrestaShopErrorType.timeout:
      case PrestaShopErrorType.server:
      case PrestaShopErrorType.rateLimit:
        return true;
      case PrestaShopErrorType.authentication:
      case PrestaShopErrorType.authorization:
      case PrestaShopErrorType.notFound:
      case PrestaShopErrorType.methodNotAllowed:
      case PrestaShopErrorType.validation:
      case PrestaShopErrorType.parsing:
      case PrestaShopErrorType.configuration:
      case PrestaShopErrorType.unknown:
        return false;
    }
  }

  /// Délai recommandé avant retry (en secondes)
  int get retryDelaySeconds {
    switch (type) {
      case PrestaShopErrorType.rateLimit:
        return 60; // 1 minute pour rate limit
      case PrestaShopErrorType.server:
        return 30; // 30 secondes pour erreur serveur
      case PrestaShopErrorType.network:
      case PrestaShopErrorType.timeout:
        return 5; // 5 secondes pour réseau/timeout
      default:
        return 0; // Pas de retry
    }
  }

  /// Message utilisateur convivial
  String get userFriendlyMessage {
    switch (type) {
      case PrestaShopErrorType.network:
        return 'Problème de connexion. Vérifiez votre réseau.';
      case PrestaShopErrorType.timeout:
        return 'La requête a pris trop de temps. Réessayez.';
      case PrestaShopErrorType.authentication:
        return 'Authentification invalide. Vérifiez vos identifiants.';
      case PrestaShopErrorType.authorization:
        return 'Accès refusé. Permissions insuffisantes.';
      case PrestaShopErrorType.notFound:
        return 'Ressource non trouvée.';
      case PrestaShopErrorType.validation:
        return 'Données invalides. Vérifiez les informations saisies.';
      case PrestaShopErrorType.server:
        return 'Erreur du serveur. Réessayez plus tard.';
      case PrestaShopErrorType.rateLimit:
        return 'Trop de requêtes. Attendez avant de réessayer.';
      case PrestaShopErrorType.parsing:
        return 'Erreur de traitement des données.';
      case PrestaShopErrorType.configuration:
        return 'Configuration invalide.';
      case PrestaShopErrorType.methodNotAllowed:
      case PrestaShopErrorType.unknown:
        return message;
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer('PrestaShopException: $message');
    if (statusCode != null) {
      buffer.write(' (HTTP $statusCode)');
    }
    buffer.write(' [Type: $type]');

    if (details != null) {
      buffer.write(' Details: $details');
    }

    return buffer.toString();
  }
}

/// Gestionnaire d'erreurs avec retry automatique
class PrestaShopErrorHandler {
  /// Nombre maximum de tentatives
  static const int maxRetries = 3;

  /// Délai de base entre les tentatives (en secondes)
  static const int baseRetryDelay = 2;

  /// Gère une exception et détermine si un retry est nécessaire
  static Future<T> handleWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = maxRetries,
    void Function(PrestaShopException)? onError,
    void Function(int attemptNumber, PrestaShopException)? onRetry,
  }) async {
    var attempt = 1;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        final prestashopException = _convertToPrestaShopException(e);

        // Notifier l'erreur
        onError?.call(prestashopException);

        // Vérifier si on peut/doit retry
        if (attempt >= maxRetries || !prestashopException.isRetryable) {
          throw prestashopException;
        }

        // Notifier le retry
        onRetry?.call(attempt, prestashopException);

        // Calculer le délai (exponential backoff)
        final delay = _calculateRetryDelay(attempt, prestashopException);
        await Future.delayed(Duration(seconds: delay));

        attempt++;
      }
    }
  }

  /// Convertit une exception générique en PrestaShopException
  static PrestaShopException _convertToPrestaShopException(dynamic error) {
    if (error is PrestaShopException) {
      return error;
    }

    if (error is SocketException) {
      return PrestaShopException.network(
        'Erreur de connexion réseau: ${error.message}',
        originalException: error,
      );
    }

    if (error is HttpException) {
      return PrestaShopException.network(
        'Erreur HTTP: ${error.message}',
        originalException: error,
      );
    }

    if (error is FormatException) {
      return PrestaShopException.parsing(
        'Erreur de format de données: ${error.message}',
        originalException: error,
      );
    }

    // Erreur générique
    return PrestaShopException(
      type: PrestaShopErrorType.unknown,
      message: error.toString(),
      originalException: error,
    );
  }

  /// Calcule le délai de retry avec exponential backoff
  static int _calculateRetryDelay(int attempt, PrestaShopException exception) {
    // Utiliser le délai recommandé par l'exception si disponible
    final recommendedDelay = exception.retryDelaySeconds;
    if (recommendedDelay > 0) {
      return recommendedDelay;
    }

    // Sinon utiliser exponential backoff
    return baseRetryDelay * (1 << (attempt - 1)); // 2, 4, 8, 16...
  }
}
