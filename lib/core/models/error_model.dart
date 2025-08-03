
// Defines the error model for API error responses in the Koutonou application.
// This model provides a standardized structure for handling API errors,
// including error codes, messages, field-specific errors, and error metadata.

// Model for representing API errors
class ErrorModel {
  /// Error code (can be string or numeric)
  final String code;

  /// Error message
  final String message;

  /// Field name if this is a field-specific error
  final String? field;

  /// Error type/category
  final ErrorType type;

  /// Additional error details
  final Map<String, dynamic>? details;

  /// Timestamp when the error occurred
  final DateTime timestamp;

  /// Whether this error is user-facing or internal
  final bool isUserFacing;

  ErrorModel({
    required this.code,
    required this.message,
    this.field,
    this.type = ErrorType.general,
    this.details,
    DateTime? timestamp,
    this.isUserFacing = true,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Factory constructor for validation errors
  factory ErrorModel.validation({
    required String field,
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) {
    return ErrorModel(
      code: code ?? 'VALIDATION_ERROR',
      message: message,
      field: field,
      type: ErrorType.validation,
      details: details,
      isUserFacing: true,
    );
  }

  /// Factory constructor for authentication errors
  factory ErrorModel.authentication({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) {
    return ErrorModel(
      code: code ?? 'AUTH_ERROR',
      message: message,
      type: ErrorType.authentication,
      details: details,
      isUserFacing: true,
    );
  }

  /// Factory constructor for authorization errors
  factory ErrorModel.authorization({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) {
    return ErrorModel(
      code: code ?? 'AUTHORIZATION_ERROR',
      message: message,
      type: ErrorType.authorization,
      details: details,
      isUserFacing: true,
    );
  }

  /// Factory constructor for business logic errors
  factory ErrorModel.business({
    required String message,
    String? code,
    String? field,
    Map<String, dynamic>? details,
  }) {
    return ErrorModel(
      code: code ?? 'BUSINESS_ERROR',
      message: message,
      field: field,
      type: ErrorType.business,
      details: details,
      isUserFacing: true,
    );
  }

  /// Factory constructor for system/internal errors
  factory ErrorModel.system({
    required String message,
    String? code,
    Map<String, dynamic>? details,
    bool isUserFacing = false,
  }) {
    return ErrorModel(
      code: code ?? 'SYSTEM_ERROR',
      message: message,
      type: ErrorType.system,
      details: details,
      isUserFacing: isUserFacing,
    );
  }

  /// Factory constructor for network errors
  factory ErrorModel.network({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) {
    return ErrorModel(
      code: code ?? 'NETWORK_ERROR',
      message: message,
      type: ErrorType.network,
      details: details,
      isUserFacing: true,
    );
  }

  /// Factory constructor from JSON
  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      code:
          json['code']?.toString() ??
          json['error_code']?.toString() ??
          'UNKNOWN_ERROR',
      message:
          json['message'] as String? ??
          json['error'] as String? ??
          json['msg'] as String? ??
          'Unknown error',
      field: json['field'] as String? ?? json['property'] as String?,
      type: _parseErrorType(json['type'] as String?),
      details:
          json['details'] as Map<String, dynamic>? ??
          json['meta'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isUserFacing:
          json['user_facing'] as bool? ??
          json['is_user_facing'] as bool? ??
          true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'field': field,
      'type': type.name,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'user_facing': isUserFacing,
    };
  }

  /// Get user-friendly message in French
  String get userMessage {
    if (!isUserFacing) {
      return 'Une erreur technique est survenue. Veuillez réessayer.';
    }

    // Return translated message based on error type and code
    switch (type) {
      case ErrorType.validation:
        return _getValidationMessage();
      case ErrorType.authentication:
        return _getAuthenticationMessage();
      case ErrorType.authorization:
        return 'Vous n\'avez pas les permissions nécessaires pour effectuer cette action.';
      case ErrorType.business:
        return message; // Business messages are usually already user-friendly
      case ErrorType.network:
        return 'Problème de connexion. Veuillez vérifier votre réseau.';
      case ErrorType.system:
        return 'Erreur système. Veuillez réessayer plus tard.';
      case ErrorType.general:
        return message.isNotEmpty ? message : 'Une erreur est survenue.';
    }
  }

  /// Get severity level of the error
  ErrorSeverity get severity {
    switch (type) {
      case ErrorType.system:
        return ErrorSeverity.critical;
      case ErrorType.network:
        return ErrorSeverity.high;
      case ErrorType.authentication:
      case ErrorType.authorization:
        return ErrorSeverity.medium;
      case ErrorType.validation:
      case ErrorType.business:
        return ErrorSeverity.low;
      case ErrorType.general:
        return ErrorSeverity.medium;
    }
  }

  /// Check if error is retryable
  bool get isRetryable {
    switch (type) {
      case ErrorType.network:
      case ErrorType.system:
        return true;
      case ErrorType.authentication:
      case ErrorType.authorization:
      case ErrorType.validation:
      case ErrorType.business:
      case ErrorType.general:
        return false;
    }
  }

  /// Get detailed error information
  String get detailedInfo {
    final buffer = StringBuffer();
    buffer.write('Error: $code - $message');
    if (field != null) buffer.write(' (Field: $field)');
    buffer.write(' [Type: ${type.name}]');
    if (details != null && details!.isNotEmpty) {
      buffer.write(' Details: ${details.toString()}');
    }
    return buffer.toString();
  }

  /// Create a copy with different values
  ErrorModel copyWith({
    String? code,
    String? message,
    String? field,
    ErrorType? type,
    Map<String, dynamic>? details,
    DateTime? timestamp,
    bool? isUserFacing,
  }) {
    return ErrorModel(
      code: code ?? this.code,
      message: message ?? this.message,
      field: field ?? this.field,
      type: type ?? this.type,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
      isUserFacing: isUserFacing ?? this.isUserFacing,
    );
  }

  @override
  String toString() {
    return 'ErrorModel(code: $code, message: $message, field: $field, type: ${type.name})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorModel &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          field == other.field &&
          type == other.type;

  @override
  int get hashCode =>
      code.hashCode ^ message.hashCode ^ field.hashCode ^ type.hashCode;

  // Private helper methods

  String _getValidationMessage() {
    switch (code.toUpperCase()) {
      case 'REQUIRED':
      case 'REQUIRED_FIELD':
        return field != null
            ? 'Le champ "$field" est obligatoire.'
            : 'Ce champ est obligatoire.';
      case 'INVALID_EMAIL':
        return 'Veuillez saisir une adresse email valide.';
      case 'INVALID_PHONE':
        return 'Veuillez saisir un numéro de téléphone valide.';
      case 'PASSWORD_TOO_SHORT':
        return 'Le mot de passe doit contenir au moins 8 caractères.';
      case 'PASSWORD_TOO_WEAK':
        return 'Le mot de passe doit contenir majuscules, minuscules et chiffres.';
      case 'INVALID_FORMAT':
        return field != null
            ? 'Le format du champ "$field" est invalide.'
            : 'Format de données invalide.';
      default:
        return message.isNotEmpty ? message : 'Données invalides.';
    }
  }

  String _getAuthenticationMessage() {
    switch (code.toUpperCase()) {
      case 'INVALID_CREDENTIALS':
        return 'Email ou mot de passe incorrect.';
      case 'TOKEN_EXPIRED':
        return 'Votre session a expiré. Veuillez vous reconnecter.';
      case 'TOKEN_INVALID':
        return 'Session invalide. Veuillez vous reconnecter.';
      case 'ACCOUNT_LOCKED':
        return 'Votre compte est temporairement verrouillé.';
      case 'ACCOUNT_DISABLED':
        return 'Votre compte a été désactivé.';
      default:
        return 'Erreur d\'authentification. Veuillez vous reconnecter.';
    }
  }

  /// Parse error type from string
  static ErrorType _parseErrorType(String? typeString) {
    if (typeString == null) return ErrorType.general;

    switch (typeString.toLowerCase()) {
      case 'validation':
        return ErrorType.validation;
      case 'authentication':
      case 'auth':
        return ErrorType.authentication;
      case 'authorization':
      case 'authz':
        return ErrorType.authorization;
      case 'business':
        return ErrorType.business;
      case 'network':
        return ErrorType.network;
      case 'system':
      case 'internal':
        return ErrorType.system;
      default:
        return ErrorType.general;
    }
  }
}

// Types of errors
enum ErrorType {
  general('General error'),
  validation('Validation error'),
  authentication('Authentication error'),
  authorization('Authorization error'),
  business('Business logic error'),
  network('Network error'),
  system('System error');

  const ErrorType(this.description);
  final String description;
}

// Error severity levels
enum ErrorSeverity { low, medium, high, critical }

// Factory class for creating common error models
class ErrorModelFactory {
  /// Create a validation error
  static ErrorModel validation(String field, String message, {String? code}) {
    return ErrorModel.validation(field: field, message: message, code: code);
  }

  /// Create an authentication error
  static ErrorModel authentication(String message, {String? code}) {
    return ErrorModel.authentication(message: message, code: code);
  }

  /// Create a network error
  static ErrorModel network(String message, {String? code}) {
    return ErrorModel.network(message: message, code: code);
  }

  /// Create a system error
  static ErrorModel system(
    String message, {
    String? code,
    bool isUserFacing = false,
  }) {
    return ErrorModel.system(
      message: message,
      code: code,
      isUserFacing: isUserFacing,
    );
  }

  /// Create from exception
  static ErrorModel fromException(
    Exception exception, {
    bool isUserFacing = false,
  }) {
    return ErrorModel.system(
      message: exception.toString(),
      code: 'EXCEPTION_ERROR',
      isUserFacing: isUserFacing,
    );
  }
}
