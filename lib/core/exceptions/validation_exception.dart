
// Defines validation-specific exceptions for the Koutonou application.
// These exceptions handle form validation errors, data validation failures,
// and business rule violations with detailed field-level error information.

// Base exception class for all validation-related errors
class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>> fieldErrors;
  final ValidationErrorType type;
  final DateTime timestamp;

  ValidationException(
    this.message, {
    this.fieldErrors = const {},
    this.type = ValidationErrorType.general,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Constructor for single field error
  ValidationException.field(
    String field,
    String error, {
    ValidationErrorType? type,
  }) : this(
         'Validation error in field: $field',
         fieldErrors: {
           field: [error],
         },
         type: type ?? ValidationErrorType.field,
       );

  /// Constructor for multiple field errors
  ValidationException.fields(
    Map<String, List<String>> errors, {
    String? message,
    ValidationErrorType? type,
  }) : this(
         message ?? 'Multiple validation errors',
         fieldErrors: errors,
         type: type ?? ValidationErrorType.multiple,
       );

  @override
  String toString() {
    final buffer = StringBuffer('ValidationException (${type.name}): $message');
    if (fieldErrors.isNotEmpty) {
      buffer.write('\nField errors: ${fieldErrors.toString()}');
    }
    return buffer.toString();
  }

  /// Get the first error message (useful for general display)
  String get firstError {
    if (fieldErrors.isNotEmpty) {
      final firstField = fieldErrors.keys.first;
      final firstFieldErrors = fieldErrors[firstField]!;
      return firstFieldErrors.isNotEmpty ? firstFieldErrors.first : message;
    }
    return message;
  }

  /// Get all error messages as a single string
  String get allErrors {
    if (fieldErrors.isEmpty) return message;

    final buffer = StringBuffer();
    fieldErrors.forEach((field, errors) {
      for (final error in errors) {
        if (buffer.isNotEmpty) buffer.write('\n');
        buffer.write('$field: $error');
      }
    });
    return buffer.toString();
  }

  /// Get errors for a specific field
  List<String> getFieldErrors(String field) {
    return fieldErrors[field] ?? [];
  }

  /// Check if a specific field has errors
  bool hasFieldError(String field) {
    return fieldErrors.containsKey(field) && fieldErrors[field]!.isNotEmpty;
  }

  /// Get count of total errors
  int get errorCount {
    return fieldErrors.values.fold(0, (sum, errors) => sum + errors.length);
  }

  /// Convert to user-friendly message in French
  String get userMessage {
    switch (type) {
      case ValidationErrorType.required:
        return 'Veuillez remplir tous les champs obligatoires.';
      case ValidationErrorType.format:
        return 'Format de données invalide.';
      case ValidationErrorType.length:
        return 'Longueur de données incorrecte.';
      case ValidationErrorType.range:
        return 'Valeur hors limites autorisées.';
      case ValidationErrorType.email:
        return 'Adresse email invalide.';
      case ValidationErrorType.password:
        return 'Mot de passe ne respecte pas les critères de sécurité.';
      case ValidationErrorType.phone:
        return 'Numéro de téléphone invalide.';
      case ValidationErrorType.url:
        return 'URL invalide.';
      case ValidationErrorType.date:
        return 'Date invalide.';
      case ValidationErrorType.duplicate:
        return 'Cette valeur existe déjà.';
      case ValidationErrorType.business:
        return 'Règle métier non respectée.';
      case ValidationErrorType.field:
      case ValidationErrorType.multiple:
      case ValidationErrorType.general:
        return firstError;
    }
  }
}

// Types of validation errors
enum ValidationErrorType {
  general('General validation error'),
  field('Field validation error'),
  multiple('Multiple field errors'),
  required('Required field missing'),
  format('Invalid format'),
  length('Invalid length'),
  range('Value out of range'),
  email('Invalid email'),
  password('Invalid password'),
  phone('Invalid phone number'),
  url('Invalid URL'),
  date('Invalid date'),
  duplicate('Duplicate value'),
  business('Business rule violation');

  const ValidationErrorType(this.description);
  final String description;
}

// Specific exception for required field validation
class RequiredFieldException extends ValidationException {
  RequiredFieldException(String field)
    : super.field(
        field,
        'Ce champ est obligatoire.',
        type: ValidationErrorType.required,
      );
}

// Specific exception for email validation
class EmailValidationException extends ValidationException {
  EmailValidationException([String field = 'email'])
    : super.field(
        field,
        'Veuillez saisir une adresse email valide.',
        type: ValidationErrorType.email,
      );
}

// Specific exception for password validation
class PasswordValidationException extends ValidationException {
  final List<String> requirements;

  PasswordValidationException({
    this.requirements = const [],
    String field = 'password',
  }) : super.field(
         field,
         _buildPasswordMessage(requirements),
         type: ValidationErrorType.password,
       );

  static String _buildPasswordMessage(List<String> requirements) {
    if (requirements.isEmpty) {
      return 'Mot de passe invalide.';
    }
    return 'Le mot de passe doit respecter: ${requirements.join(', ')}.';
  }
}

// Specific exception for phone validation
class PhoneValidationException extends ValidationException {
  PhoneValidationException([String field = 'phone'])
    : super.field(
        field,
        'Veuillez saisir un numéro de téléphone valide.',
        type: ValidationErrorType.phone,
      );
}

// Specific exception for length validation
class LengthValidationException extends ValidationException {
  final int? minLength;
  final int? maxLength;
  final int actualLength;

  LengthValidationException({
    required String field,
    required this.actualLength,
    this.minLength,
    this.maxLength,
  }) : super.field(
         field,
         _buildLengthMessage(actualLength, minLength, maxLength),
         type: ValidationErrorType.length,
       );

  static String _buildLengthMessage(int actual, int? min, int? max) {
    if (min != null && max != null) {
      return 'Doit contenir entre $min et $max caractères (actuel: $actual).';
    } else if (min != null) {
      return 'Doit contenir au moins $min caractères (actuel: $actual).';
    } else if (max != null) {
      return 'Doit contenir au maximum $max caractères (actuel: $actual).';
    }
    return 'Longueur invalide: $actual caractères.';
  }
}

// Specific exception for range validation
class RangeValidationException extends ValidationException {
  final num? minValue;
  final num? maxValue;
  final num actualValue;

  RangeValidationException({
    required String field,
    required this.actualValue,
    this.minValue,
    this.maxValue,
  }) : super.field(
         field,
         _buildRangeMessage(actualValue, minValue, maxValue),
         type: ValidationErrorType.range,
       );

  static String _buildRangeMessage(num actual, num? min, num? max) {
    if (min != null && max != null) {
      return 'Doit être entre $min et $max (actuel: $actual).';
    } else if (min != null) {
      return 'Doit être supérieur ou égal à $min (actuel: $actual).';
    } else if (max != null) {
      return 'Doit être inférieur ou égal à $max (actuel: $actual).';
    }
    return 'Valeur invalide: $actual.';
  }
}

// Specific exception for date validation
class DateValidationException extends ValidationException {
  DateValidationException({required String field, String? customMessage})
    : super.field(
        field,
        customMessage ?? 'Date invalide ou format incorrect.',
        type: ValidationErrorType.date,
      );
}

// Specific exception for duplicate validation
class DuplicateValidationException extends ValidationException {
  DuplicateValidationException({required String field, String? value})
    : super.field(
        field,
        value != null
            ? 'La valeur "$value" existe déjà.'
            : 'Cette valeur existe déjà.',
        type: ValidationErrorType.duplicate,
      );
}

// Specific exception for business rule violations
class BusinessRuleException extends ValidationException {
  final String ruleName;

  BusinessRuleException({
    required this.ruleName,
    required String message,
    Map<String, List<String>>? fieldErrors,
  }) : super(
         'Business rule violation: $ruleName - $message',
         fieldErrors: fieldErrors ?? {},
         type: ValidationErrorType.business,
       );

  @override
  String get userMessage =>
      message.replaceFirst('Business rule violation: $ruleName - ', '');
}

// Factory class for creating validation exceptions
class ValidationExceptionFactory {
  /// Creates a required field exception
  static RequiredFieldException required(String field) {
    return RequiredFieldException(field);
  }

  /// Creates an email validation exception
  static EmailValidationException email([String field = 'email']) {
    return EmailValidationException(field);
  }

  /// Creates a password validation exception
  static PasswordValidationException password({
    List<String> requirements = const [],
    String field = 'password',
  }) {
    return PasswordValidationException(
      requirements: requirements,
      field: field,
    );
  }

  /// Creates a phone validation exception
  static PhoneValidationException phone([String field = 'phone']) {
    return PhoneValidationException(field);
  }

  /// Creates a length validation exception
  static LengthValidationException length({
    required String field,
    required int actualLength,
    int? minLength,
    int? maxLength,
  }) {
    return LengthValidationException(
      field: field,
      actualLength: actualLength,
      minLength: minLength,
      maxLength: maxLength,
    );
  }

  /// Creates a range validation exception
  static RangeValidationException range({
    required String field,
    required num actualValue,
    num? minValue,
    num? maxValue,
  }) {
    return RangeValidationException(
      field: field,
      actualValue: actualValue,
      minValue: minValue,
      maxValue: maxValue,
    );
  }

  /// Creates a duplicate validation exception
  static DuplicateValidationException duplicate({
    required String field,
    String? value,
  }) {
    return DuplicateValidationException(field: field, value: value);
  }

  /// Creates multiple field errors from a map
  static ValidationException multiple(Map<String, List<String>> errors) {
    return ValidationException.fields(errors);
  }
}
