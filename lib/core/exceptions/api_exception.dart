// Defines API-specific exceptions for the Koutonou application.
// These exceptions handle various API error scenarios including HTTP status codes,
// server errors, and malformed responses.

// Base exception class for all API-related errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? endpoint;
  final dynamic responseData;
  final DateTime timestamp;

  ApiException(
    this.message, {
    this.statusCode,
    this.endpoint,
    this.responseData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Factory constructor for creating API exceptions
  factory ApiException.create(
    String message, {
    int? statusCode,
    String? endpoint,
    dynamic responseData,
  }) {
    return ApiException(
      message,
      statusCode: statusCode,
      endpoint: endpoint,
      responseData: responseData,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('ApiException: $message');
    if (statusCode != null) buffer.write(' (Status: $statusCode)');
    if (endpoint != null) buffer.write(' [Endpoint: $endpoint]');
    return buffer.toString();
  }

  /// Convert to a user-friendly message
  String get userMessage {
    switch (statusCode) {
      case 400:
        return 'Requête invalide. Veuillez vérifier vos données.';
      case 401:
        return 'Session expirée. Veuillez vous reconnecter.';
      case 403:
        return 'Accès interdit. Vous n\'avez pas les permissions nécessaires.';
      case 404:
        return 'Ressource non trouvée.';
      case 429:
        return 'Trop de requêtes. Veuillez patienter un moment.';
      case 500:
        return 'Erreur serveur. Veuillez réessayer plus tard.';
      case 503:
        return 'Service temporairement indisponible.';
      default:
        return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }
}

// Exception for authentication-related API errors
class AuthenticationException extends ApiException {
  AuthenticationException(
    super.message, {
    super.statusCode = 401,
    super.endpoint,
    super.responseData,
  });

  @override
  String get userMessage =>
      'Erreur d\'authentification. Veuillez vous reconnecter.';
}

// Exception for authorization-related API errors
class AuthorizationException extends ApiException {
  AuthorizationException(
    super.message, {
    super.statusCode = 403,
    super.endpoint,
    super.responseData,
  });

  @override
  String get userMessage =>
      'Accès refusé. Vous n\'avez pas les permissions nécessaires.';
}

// Exception for server-side errors (5xx status codes)
class ServerException extends ApiException {
  ServerException(
    super.message, {
    super.statusCode = 500,
    super.endpoint,
    super.responseData,
  });

  @override
  String get userMessage => 'Erreur serveur. Veuillez réessayer plus tard.';
}

// Exception for client-side errors (4xx status codes)
class ClientException extends ApiException {
  ClientException(
    super.message, {
    super.statusCode = 400,
    super.endpoint,
    super.responseData,
  });

  @override
  String get userMessage =>
      'Erreur dans la requête. Veuillez vérifier vos données.';
}

// Exception for JSON parsing errors
class ParseException extends ApiException {
  ParseException(super.message, {super.endpoint, super.responseData})
    : super(statusCode: null);

  @override
  String get userMessage =>
      'Erreur de traitement des données. Veuillez réessayer.';
}

// Exception for timeout errors
class TimeoutException extends ApiException {
  final Duration timeout;

  TimeoutException(super.message, {required this.timeout, super.endpoint})
    : super(statusCode: 408);

  @override
  String get userMessage =>
      'Délai d\'attente dépassé. Vérifiez votre connexion internet.';
}

// Factory class to create appropriate API exceptions based on status codes
class ApiExceptionFactory {
  /// Creates an appropriate API exception based on the HTTP status code
  static ApiException fromStatusCode(
    int statusCode,
    String message, {
    String? endpoint,
    dynamic responseData,
  }) {
    switch (statusCode) {
      case 401:
        return AuthenticationException(
          message,
          statusCode: statusCode,
          endpoint: endpoint,
          responseData: responseData,
        );
      case 403:
        return AuthorizationException(
          message,
          statusCode: statusCode,
          endpoint: endpoint,
          responseData: responseData,
        );
      case >= 400 && < 500:
        return ClientException(
          message,
          statusCode: statusCode,
          endpoint: endpoint,
          responseData: responseData,
        );
      case >= 500:
        return ServerException(
          message,
          statusCode: statusCode,
          endpoint: endpoint,
          responseData: responseData,
        );
      default:
        return ApiException.create(
          message,
          statusCode: statusCode,
          endpoint: endpoint,
          responseData: responseData,
        );
    }
  }

  /// Creates an exception from an HTTP response
  static ApiException fromResponse(
    int statusCode,
    String? reasonPhrase,
    String endpoint, {
    dynamic responseData,
  }) {
    final message = reasonPhrase ?? 'HTTP Error $statusCode';
    return fromStatusCode(
      statusCode,
      message,
      endpoint: endpoint,
      responseData: responseData,
    );
  }
}
