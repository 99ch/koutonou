// Extensions utiles pour les chaînes de caractères
// Fournit des méthodes pratiques pour la validation, formatage et manipulation des strings

extension StringExtensions on String {
  /// Vérifie si la chaîne est un email valide
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }

  /// Vérifie si la chaîne est un numéro de téléphone valide (format international)
  bool get isValidPhoneNumber {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  /// Vérifie si la chaîne est un mot de passe fort
  bool get isStrongPassword {
    if (length < 8) return false;
    final hasUppercase = contains(RegExp(r'[A-Z]'));
    final hasLowercase = contains(RegExp(r'[a-z]'));
    final hasDigit = contains(RegExp(r'\d'));
    final hasSpecialChar = contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasUppercase && hasLowercase && hasDigit && hasSpecialChar;
  }

  /// Vérifie si la chaîne est un URL valide
  bool get isValidUrl {
    try {
      final uri = Uri.parse(this);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Capitalise la première lettre
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalise chaque mot
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Supprime les espaces en début et fin et les espaces multiples
  String get cleanWhitespace {
    return trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Supprime tous les caractères non numériques
  String get numbersOnly {
    return replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Supprime tous les caractères non alphabétiques
  String get lettersOnly {
    return replaceAll(RegExp(r'[^a-zA-ZÀ-ÿ]'), '');
  }

  /// Convertit en slug (URL-friendly)
  String get toSlug {
    return toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ÿý]'), 'y')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  /// Masque partiellement une chaîne (utile pour les emails, téléphones)
  String maskPartial({int start = 2, int end = 2, String maskChar = '*'}) {
    if (length <= start + end) return this;
    final startPart = substring(0, start);
    final endPart = substring(length - end);
    final maskLength = length - start - end;
    return '$startPart${maskChar * maskLength}$endPart';
  }

  /// Génère des initiales (max 2 caractères)
  String get initials {
    final words = trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Compte les mots
  int get wordCount {
    if (trim().isEmpty) return 0;
    return trim().split(RegExp(r'\s+')).length;
  }

  /// Tronque le texte avec des points de suspension
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Extrait les mentions (@username)
  List<String> get mentions {
    final mentionRegex = RegExp(r'@(\w+)');
    return mentionRegex
        .allMatches(this)
        .map((match) => match.group(1)!)
        .toList();
  }

  /// Extrait les hashtags (#tag)
  List<String> get hashtags {
    final hashtagRegex = RegExp(r'#(\w+)');
    return hashtagRegex
        .allMatches(this)
        .map((match) => match.group(1)!)
        .toList();
  }

  /// Vérifie si la chaîne contient uniquement des caractères numériques
  bool get isNumeric {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  /// Vérifie si la chaîne contient uniquement des caractères alphabétiques
  bool get isAlphabetic {
    return RegExp(r'^[a-zA-ZÀ-ÿ]+$').hasMatch(this);
  }

  /// Vérifie si la chaîne est alphanumérique
  bool get isAlphanumeric {
    return RegExp(r'^[a-zA-Z0-9À-ÿ]+$').hasMatch(this);
  }

  /// Reverse la chaîne
  String get reversed {
    return split('').reversed.join('');
  }

  /// Convertit en CamelCase
  String get toCamelCase {
    final words = toLowerCase().split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return '';
    final first = words.first;
    final rest = words.skip(1).map((word) => word.capitalize);
    return '$first${rest.join('')}';
  }

  /// Convertit en PascalCase
  String get toPascalCase {
    return toLowerCase()
        .split(RegExp(r'[\s_-]+'))
        .map((word) => word.capitalize)
        .join('');
  }

  /// Convertit en snake_case
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceAll(RegExp(r'^_'), '').toLowerCase();
  }
}
