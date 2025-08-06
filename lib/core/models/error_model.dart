/// Énumération pour les types d'erreur
enum ErrorType { network, server, authentication, validation, unknown }

/// Énumération pour la sévérité des erreurs
enum ErrorSeverity { low, medium, high, critical }

/// Modèle pour les erreurs de l'application
class ErrorModel {
  final String message;
  final ErrorType type;
  final ErrorSeverity severity;
  final int? statusCode;
  final String? code;
  final Map<String, dynamic>? details;
  final DateTime timestamp;

  ErrorModel({
    required this.message,
    required this.type,
    this.severity = ErrorSeverity.medium,
    this.statusCode,
    this.code,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ErrorModel.network({String? message, int? statusCode, String? code}) {
    return ErrorModel(
      message: message ?? 'Erreur de connexion réseau',
      type: ErrorType.network,
      severity: ErrorSeverity.high,
      statusCode: statusCode,
      code: code,
    );
  }

  factory ErrorModel.server({
    String? message,
    int? statusCode,
    String? code,
    Map<String, dynamic>? details,
  }) {
    return ErrorModel(
      message: message ?? 'Erreur serveur',
      type: ErrorType.server,
      severity: ErrorSeverity.high,
      statusCode: statusCode,
      code: code,
      details: details,
    );
  }

  factory ErrorModel.authentication({String? message, int? statusCode}) {
    return ErrorModel(
      message: message ?? 'Erreur d\'authentification',
      type: ErrorType.authentication,
      severity: ErrorSeverity.critical,
      statusCode: statusCode,
    );
  }

  factory ErrorModel.validation({
    String? message,
    Map<String, dynamic>? details,
  }) {
    return ErrorModel(
      message: message ?? 'Erreur de validation',
      type: ErrorType.validation,
      severity: ErrorSeverity.medium,
      details: details,
    );
  }

  factory ErrorModel.unknown({String? message, int? statusCode}) {
    return ErrorModel(
      message: message ?? 'Erreur inconnue',
      type: ErrorType.unknown,
      severity: ErrorSeverity.low,
      statusCode: statusCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'type': type.name,
      'severity': severity.name,
      if (statusCode != null) 'statusCode': statusCode,
      if (code != null) 'code': code,
      if (details != null) 'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      message: json['message'] ?? '',
      type: ErrorType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ErrorType.unknown,
      ),
      severity: ErrorSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => ErrorSeverity.medium,
      ),
      statusCode: json['statusCode'],
      code: json['code'],
      details: json['details'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ErrorModel(message: $message, type: $type, severity: $severity)';
  }
}
