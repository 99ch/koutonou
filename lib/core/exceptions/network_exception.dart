// Defines network-specific exceptions for the Koutonou application.
// These exceptions handle various network error scenarios including connectivity issues,
// DNS resolution failures, SSL errors, and connection timeouts.

// Base exception class for all network-related errors
class NetworkException implements Exception {
  final String message;
  final NetworkErrorType type;
  final String? endpoint;
  final DateTime timestamp;
  final Duration? timeout;

  NetworkException(
    this.message, {
    required this.type,
    this.endpoint,
    this.timeout,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    final buffer = StringBuffer('NetworkException (${type.name}): $message');
    if (endpoint != null) buffer.write(' [Endpoint: $endpoint]');
    if (timeout != null) buffer.write(' [Timeout: ${timeout!.inSeconds}s]');
    return buffer.toString();
  }

  /// Convert to a user-friendly message in French
  String get userMessage {
    switch (type) {
      case NetworkErrorType.noConnection:
        return 'Aucune connexion internet. Vérifiez votre réseau.';
      case NetworkErrorType.timeout:
        return 'Délai d\'attente dépassé. Vérifiez votre connexion.';
      case NetworkErrorType.hostUnreachable:
        return 'Serveur inaccessible. Réessayez plus tard.';
      case NetworkErrorType.dnsFailure:
        return 'Problème de résolution DNS. Vérifiez votre connexion.';
      case NetworkErrorType.sslError:
        return 'Erreur de sécurité SSL. Contactez le support.';
      case NetworkErrorType.connectionReset:
        return 'Connexion interrompue. Veuillez réessayer.';
      case NetworkErrorType.unknownHost:
        return 'Serveur introuvable. Vérifiez l\'URL.';
      case NetworkErrorType.socketException:
        return 'Erreur de connexion réseau. Réessayez.';
      case NetworkErrorType.badCertificate:
        return 'Certificat de sécurité invalide.';
      case NetworkErrorType.other:
        return 'Problème de réseau. Vérifiez votre connexion.';
    }
  }

  /// Get the severity level of the network error
  NetworkErrorSeverity get severity {
    switch (type) {
      case NetworkErrorType.noConnection:
      case NetworkErrorType.hostUnreachable:
        return NetworkErrorSeverity.critical;
      case NetworkErrorType.timeout:
      case NetworkErrorType.connectionReset:
        return NetworkErrorSeverity.high;
      case NetworkErrorType.dnsFailure:
      case NetworkErrorType.unknownHost:
        return NetworkErrorSeverity.medium;
      case NetworkErrorType.sslError:
      case NetworkErrorType.badCertificate:
        return NetworkErrorSeverity.high;
      case NetworkErrorType.socketException:
      case NetworkErrorType.other:
        return NetworkErrorSeverity.low;
    }
  }

  /// Whether the error is likely to be recoverable by retrying
  bool get isRecoverable {
    switch (type) {
      case NetworkErrorType.timeout:
      case NetworkErrorType.connectionReset:
      case NetworkErrorType.hostUnreachable:
      case NetworkErrorType.socketException:
        return true;
      case NetworkErrorType.noConnection:
      case NetworkErrorType.dnsFailure:
      case NetworkErrorType.unknownHost:
      case NetworkErrorType.sslError:
      case NetworkErrorType.badCertificate:
      case NetworkErrorType.other:
        return false;
    }
  }
}

// Types of network errors
enum NetworkErrorType {
  noConnection('No internet connection'),
  timeout('Request timeout'),
  hostUnreachable('Host unreachable'),
  dnsFailure('DNS resolution failed'),
  sslError('SSL/TLS error'),
  connectionReset('Connection reset'),
  unknownHost('Unknown host'),
  socketException('Socket exception'),
  badCertificate('Bad certificate'),
  other('Unknown network error');

  const NetworkErrorType(this.description);
  final String description;
}

// Severity levels for network errors
enum NetworkErrorSeverity { low, medium, high, critical }

// Specific exception for connection timeout
class ConnectionTimeoutException extends NetworkException {
  ConnectionTimeoutException(
    super.message, {
    required Duration timeout,
    super.endpoint,
  }) : super(type: NetworkErrorType.timeout, timeout: timeout);

  @override
  String get userMessage =>
      'Délai d\'attente dépassé (${timeout!.inSeconds}s). Vérifiez votre connexion.';
}

// Specific exception for no internet connection
class NoConnectionException extends NetworkException {
  NoConnectionException([String? endpoint])
    : super(
        'No internet connection available',
        type: NetworkErrorType.noConnection,
        endpoint: endpoint,
      );

  @override
  String get userMessage => 'Aucune connexion internet détectée.';
}

// Specific exception for DNS resolution failures
class DnsException extends NetworkException {
  final String hostName;

  DnsException(super.message, {required this.hostName, super.endpoint})
    : super(type: NetworkErrorType.dnsFailure);

  @override
  String get userMessage => 'Impossible de résoudre l\'adresse $hostName.';
}

// Specific exception for SSL/TLS errors
class SslException extends NetworkException {
  final String? certificateInfo;

  SslException(super.message, {this.certificateInfo, super.endpoint})
    : super(type: NetworkErrorType.sslError);

  @override
  String get userMessage =>
      'Erreur de certificat SSL. Connexion non sécurisée.';
}

// Specific exception for host unreachable errors
class HostUnreachableException extends NetworkException {
  HostUnreachableException(super.message, {super.endpoint})
    : super(type: NetworkErrorType.hostUnreachable);

  @override
  String get userMessage => 'Serveur inaccessible. Vérifiez votre connexion.';
}

// Factory class to create appropriate network exceptions
class NetworkExceptionFactory {
  /// Creates an appropriate network exception based on the error type
  static NetworkException fromError(dynamic error, {String? endpoint}) {
    final errorString = error.toString().toLowerCase();

    // Check for specific error patterns
    if (errorString.contains('no address associated with hostname') ||
        errorString.contains('failed host lookup')) {
      return DnsException(
        error.toString(),
        hostName: _extractHostName(endpoint),
        endpoint: endpoint,
      );
    }

    if (errorString.contains('connection timed out') ||
        errorString.contains('timeout')) {
      return ConnectionTimeoutException(
        error.toString(),
        timeout: const Duration(seconds: 30), // Default timeout
        endpoint: endpoint,
      );
    }

    if (errorString.contains('no route to host') ||
        errorString.contains('host unreachable')) {
      return HostUnreachableException(error.toString(), endpoint: endpoint);
    }

    if (errorString.contains('certificate') ||
        errorString.contains('ssl') ||
        errorString.contains('tls')) {
      return SslException(error.toString(), endpoint: endpoint);
    }

    if (errorString.contains('network is unreachable') ||
        errorString.contains('no internet')) {
      return NoConnectionException(endpoint);
    }

    // Default to generic network exception
    return NetworkException(
      error.toString(),
      type: NetworkErrorType.other,
      endpoint: endpoint,
    );
  }

  /// Creates a timeout exception with specific duration
  static ConnectionTimeoutException timeout(
    Duration duration, {
    String? endpoint,
    String? customMessage,
  }) {
    return ConnectionTimeoutException(
      customMessage ?? 'Request timed out after ${duration.inSeconds} seconds',
      timeout: duration,
      endpoint: endpoint,
    );
  }

  /// Creates a no connection exception
  static NoConnectionException noConnection({String? endpoint}) {
    return NoConnectionException(endpoint);
  }

  /// Helper method to extract hostname from endpoint
  static String _extractHostName(String? endpoint) {
    if (endpoint == null) return 'unknown';
    try {
      final uri = Uri.parse(endpoint);
      return uri.host;
    } catch (e) {
      return endpoint;
    }
  }
}
