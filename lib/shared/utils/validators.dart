// Validateurs pour les formulaires et données
// Fournit des fonctions de validation réutilisables avec messages d'erreur en français

class Validators {
  // Messages d'erreur par défaut
  static const String requiredMessage = 'Ce champ est obligatoire';
  static const String emailMessage = 'Veuillez saisir un email valide';
  static const String passwordMessage =
      'Le mot de passe doit contenir au moins 8 caractères';
  static const String phoneMessage =
      'Veuillez saisir un numéro de téléphone valide';
  static const String urlMessage = 'Veuillez saisir une URL valide';

  /// Valide qu'un champ n'est pas vide
  static String? required(String? value, [String? customMessage]) {
    if (value == null || value.trim().isEmpty) {
      return customMessage ?? requiredMessage;
    }
    return null;
  }

  /// Valide un email
  static String? email(String? value, [String? customMessage]) {
    if (value == null || value.isEmpty) return null;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return customMessage ?? emailMessage;
    }
    return null;
  }

  /// Valide un mot de passe
  static String? password(
    String? value, {
    int minLength = 8,
    bool requireUppercase = false,
    bool requireLowercase = false,
    bool requireNumbers = false,
    bool requireSpecialChars = false,
    String? customMessage,
  }) {
    if (value == null || value.isEmpty) return null;

    if (value.length < minLength) {
      return customMessage ??
          'Le mot de passe doit contenir au moins $minLength caractères';
    }

    if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      return customMessage ??
          'Le mot de passe doit contenir au moins une majuscule';
    }

    if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
      return customMessage ??
          'Le mot de passe doit contenir au moins une minuscule';
    }

    if (requireNumbers && !value.contains(RegExp(r'\d'))) {
      return customMessage ??
          'Le mot de passe doit contenir au moins un chiffre';
    }

    if (requireSpecialChars &&
        !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return customMessage ??
          'Le mot de passe doit contenir au moins un caractère spécial';
    }

    return null;
  }

  /// Valide un numéro de téléphone
  static String? phoneNumber(String? value, [String? customMessage]) {
    if (value == null || value.isEmpty) return null;

    // Nettoie le numéro (supprime espaces, tirets, parenthèses)
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Vérifie le format international ou français
    final phoneRegex = RegExp(r'^(?:\+33|0)[1-9](?:[0-9]{8})$');
    if (!phoneRegex.hasMatch(cleanNumber)) {
      return customMessage ?? phoneMessage;
    }
    return null;
  }

  /// Valide une URL
  static String? url(String? value, [String? customMessage]) {
    if (value == null || value.isEmpty) return null;

    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return customMessage ?? urlMessage;
      }
    } catch (e) {
      return customMessage ?? urlMessage;
    }
    return null;
  }

  /// Valide une longueur minimale
  static String? minLength(String? value, int min, [String? customMessage]) {
    if (value == null || value.isEmpty) return null;

    if (value.length < min) {
      return customMessage ?? 'Ce champ doit contenir au moins $min caractères';
    }
    return null;
  }

  /// Valide une longueur maximale
  static String? maxLength(String? value, int max, [String? customMessage]) {
    if (value == null || value.isEmpty) return null;

    if (value.length > max) {
      return customMessage ?? 'Ce champ ne peut pas dépasser $max caractères';
    }
    return null;
  }

  /// Valide une plage de longueur
  static String? lengthRange(
    String? value,
    int min,
    int max, [
    String? customMessage,
  ]) {
    if (value == null || value.isEmpty) return null;

    if (value.length < min || value.length > max) {
      return customMessage ??
          'Ce champ doit contenir entre $min et $max caractères';
    }
    return null;
  }

  /// Valide qu'une valeur est numérique
  static String? numeric(String? value, [String? customMessage]) {
    if (value == null || value.isEmpty) return null;

    if (double.tryParse(value) == null) {
      return customMessage ?? 'Veuillez saisir un nombre valide';
    }
    return null;
  }

  /// Valide qu'une valeur est un entier
  static String? integer(String? value, [String? customMessage]) {
    if (value == null || value.isEmpty) return null;

    if (int.tryParse(value) == null) {
      return customMessage ?? 'Veuillez saisir un nombre entier valide';
    }
    return null;
  }

  /// Valide une plage de valeurs numériques
  static String? numberRange(
    String? value,
    num min,
    num max, [
    String? customMessage,
  ]) {
    if (value == null || value.isEmpty) return null;

    final number = double.tryParse(value);
    if (number == null) {
      return 'Veuillez saisir un nombre valide';
    }

    if (number < min || number > max) {
      return customMessage ?? 'La valeur doit être comprise entre $min et $max';
    }
    return null;
  }

  /// Valide qu'une valeur correspond à un pattern regex
  static String? pattern(
    String? value,
    RegExp pattern, [
    String? customMessage,
  ]) {
    if (value == null || value.isEmpty) return null;

    if (!pattern.hasMatch(value)) {
      return customMessage ?? 'Le format saisi n\'est pas valide';
    }
    return null;
  }

  /// Valide qu'une valeur est dans une liste
  static String? isIn(
    String? value,
    List<String> allowedValues, [
    String? customMessage,
  ]) {
    if (value == null || value.isEmpty) return null;

    if (!allowedValues.contains(value)) {
      return customMessage ?? 'Valeur non autorisée';
    }
    return null;
  }

  /// Valide une date
  static String? date(String? value, [String? customMessage]) {
    if (value == null || value.isEmpty) return null;

    try {
      DateTime.parse(value);
    } catch (e) {
      return customMessage ?? 'Veuillez saisir une date valide';
    }
    return null;
  }

  /// Valide une date dans le futur
  static String? futureDate(String? value, [String? customMessage]) {
    if (value == null || value.isEmpty) return null;

    try {
      final date = DateTime.parse(value);
      if (date.isBefore(DateTime.now())) {
        return customMessage ?? 'La date doit être dans le futur';
      }
    } catch (e) {
      return customMessage ?? 'Veuillez saisir une date valide';
    }
    return null;
  }

  /// Valide une date dans le passé
  static String? pastDate(String? value, [String? customMessage]) {
    if (value == null || value.isEmpty) return null;

    try {
      final date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) {
        return customMessage ?? 'La date doit être dans le passé';
      }
    } catch (e) {
      return customMessage ?? 'Veuillez saisir une date valide';
    }
    return null;
  }

  /// Valide un code postal français
  static String? frenchPostalCode(String? value, [String? customMessage]) {
    if (value == null || value.isEmpty) return null;

    final postalCodeRegex = RegExp(r'^[0-9]{5}$');
    if (!postalCodeRegex.hasMatch(value)) {
      return customMessage ??
          'Veuillez saisir un code postal valide (5 chiffres)';
    }
    return null;
  }

  /// Valide un numéro SIRET français
  static String? siret(String? value, [String? customMessage]) {
    if (value == null || value.isEmpty) return null;

    final cleanSiret = value.replaceAll(RegExp(r'[\s]'), '');
    if (cleanSiret.length != 14 ||
        !RegExp(r'^[0-9]{14}$').hasMatch(cleanSiret)) {
      return customMessage ?? 'Le numéro SIRET doit contenir 14 chiffres';
    }
    return null;
  }

  /// Combine plusieurs validateurs
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  /// Validateur conditionnel
  static String? Function(String?) conditional(
    bool Function() condition,
    String? Function(String?) validator,
  ) {
    return (String? value) {
      if (condition()) {
        return validator(value);
      }
      return null;
    };
  }
}
