/// Exception spécifique à l'API PrestaShop
/// 
/// Cette exception est levée lors d'erreurs de communication
/// avec l'API PrestaShop (erreurs HTTP, parsing, authentification, etc.)
class PrestashopApiException implements Exception {
  /// Message d'erreur principal
  final String message;
  
  /// Code de statut HTTP (optionnel)
  final int? statusCode;
  
  /// Réponse brute du serveur
  final String? response;
  
  /// Détails de l'erreur structurés
  final Map<String, dynamic>? errorDetails;
  
  /// Exception originale (si applicable)
  final dynamic originalException;
  
  /// Timestamp de l'erreur
  final DateTime timestamp;

  const PrestashopApiException(
    this.message, {
    this.statusCode,
    this.response,
    this.errorDetails,
    this.originalException,
  }) : timestamp = const Duration(milliseconds: 0).inMilliseconds == 0 
           ? const Duration(milliseconds: 0) 
           : DateTime.now();

  /// Type d'erreur basé sur le code de statut
  PrestashopApiErrorType get errorType {
    if (statusCode == null) return PrestashopApiErrorType.unknown;
    
    switch (statusCode!) {
      case 400:
        return PrestashopApiErrorType.badRequest;
      case 401:
        return PrestashopApiErrorType.unauthorized;
      case 403:
        return PrestashopApiErrorType.forbidden;
      case 404:
        return PrestashopApiErrorType.notFound;
      case 405:
        return PrestashopApiErrorType.methodNotAllowed;
      case 500:
        return PrestashopApiErrorType.serverError;
      case 503:
        return PrestashopApiErrorType.serviceUnavailable;
      default:
        if (statusCode! >= 400 && statusCode! < 500) {
          return PrestashopApiErrorType.clientError;
        } else if (statusCode! >= 500) {
          return PrestashopApiErrorType.serverError;
        }
        return PrestashopApiErrorType.unknown;
    }
  }

  /// Message d'erreur convivial pour l'utilisateur
  String get userFriendlyMessage {
    switch (errorType) {
      case PrestashopApiErrorType.unauthorized:
        return 'Erreur d\'authentification. Vérifiez vos identifiants.';
      case PrestashopApiErrorType.forbidden:
        return 'Accès refusé. Permissions insuffisantes.';
      case PrestashopApiErrorType.notFound:
        return 'Ressource non trouvée.';
      case PrestashopApiErrorType.methodNotAllowed:
        return 'Opération non autorisée sur cette ressource.';
      case PrestashopApiErrorType.serverError:
        return 'Erreur serveur. Veuillez réessayer plus tard.';
      case PrestashopApiErrorType.serviceUnavailable:
        return 'Service temporairement indisponible.';
      case PrestashopApiErrorType.badRequest:
        return 'Données invalides. ${_extractValidationMessage()}';
      case PrestashopApiErrorType.clientError:
        return 'Erreur dans la requête. Contactez le support si le problème persiste.';
      default:
        return 'Une erreur inattendue s\'est produite.';
    }
  }

  /// Extraire le message de validation des détails d'erreur
  String _extractValidationMessage() {
    if (errorDetails == null) return '';
    
    final validationErrors = errorDetails!['validation_errors'];
    if (validationErrors is List && validationErrors.isNotEmpty) {
      return validationErrors.join(', ');
    }
    
    return errorDetails!['message']?.toString() ?? '';
  }

  /// Conversion en Map pour logging
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'statusCode': statusCode,
      'errorType': errorType.toString(),
      'timestamp': timestamp.toIso8601String(),
      'response': response,
      'errorDetails': errorDetails,
      'originalException': originalException?.toString(),
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer('PrestashopApiException: $message');
    
    if (statusCode != null) {
      buffer.write(' (HTTP $statusCode)');
    }
    
    if (errorDetails != null) {
      buffer.write('\nDetails: $errorDetails');
    }
    
    if (originalException != null) {
      buffer.write('\nCaused by: $originalException');
    }
    
    return buffer.toString();
  }
}

/// Types d'erreurs API PrestaShop
enum PrestashopApiErrorType {
  /// Requête malformée (400)
  badRequest,
  
  /// Non autorisé - authentification requise (401)
  unauthorized,
  
  /// Interdit - permissions insuffisantes (403)
  forbidden,
  
  /// Ressource non trouvée (404)
  notFound,
  
  /// Méthode HTTP non autorisée (405)
  methodNotAllowed,
  
  /// Erreur client générique (4xx)
  clientError,
  
  /// Erreur serveur interne (500)
  serverError,
  
  /// Service indisponible (503)
  serviceUnavailable,
  
  /// Erreur de réseau/connectivité
  networkError,
  
  /// Timeout de requête
  timeout,
  
  /// Erreur de parsing XML
  parsingError,
  
  /// Erreur inconnue
  unknown,
}

/// Exception pour les erreurs de validation de données
class PrestashopValidationException extends PrestashopApiException {
  /// Champs avec erreurs de validation
  final Map<String, List<String>> fieldErrors;

  const PrestashopValidationException(
    String message,
    this.fieldErrors, {
    int? statusCode,
    String? response,
  }) : super(
          message,
          statusCode: statusCode,
          response: response,
          errorDetails: {'validation_errors': fieldErrors},
        );

  /// Premier message d'erreur pour un champ donné
  String? getFirstErrorFor(String field) {
    final errors = fieldErrors[field];
    return errors != null && errors.isNotEmpty ? errors.first : null;
  }

  /// Tous les messages d'erreur concaténés
  String get allErrorMessages {
    final messages = <String>[];
    
    for (final entry in fieldErrors.entries) {
      for (final error in entry.value) {
        messages.add('${entry.key}: $error');
      }
    }
    
    return messages.join('\n');
  }
}

/// Exception pour les erreurs d'authentification
class PrestashopAuthException extends PrestashopApiException {
  const PrestashopAuthException(
    String message, {
    String? response,
  }) : super(
          message,
          statusCode: 401,
          response: response,
        );
}

/// Exception pour les erreurs de permissions
class PrestashopPermissionException extends PrestashopApiException {
  /// Ressource tentée d'accès
  final String? resource;
  
  /// Action tentée
  final String? action;

  const PrestashopPermissionException(
    String message, {
    this.resource,
    this.action,
    String? response,
  }) : super(
          message,
          statusCode: 403,
          response: response,
          errorDetails: {
            'resource': resource,
            'action': action,
          },
        );
}

/// Exception pour les erreurs de connectivité réseau
class PrestashopNetworkException extends PrestashopApiException {
  const PrestashopNetworkException(
    String message, {
    dynamic originalException,
  }) : super(
          message,
          originalException: originalException,
        );

  @override
  PrestashopApiErrorType get errorType => PrestashopApiErrorType.networkError;
}

/// Exception pour les timeouts de requête
class PrestashopTimeoutException extends PrestashopApiException {
  /// Durée du timeout (en secondes)
  final int timeoutSeconds;

  const PrestashopTimeoutException(
    this.timeoutSeconds, {
    dynamic originalException,
  }) : super(
          'Request timed out after $timeoutSeconds seconds',
          originalException: originalException,
        );

  @override
  PrestashopApiErrorType get errorType => PrestashopApiErrorType.timeout;
}
