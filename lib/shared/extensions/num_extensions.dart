// Extensions utiles pour les nombres (int et double)
// Fournit des méthodes pour le formatage, validation et manipulation des nombres

import 'dart:math';

extension NumExtensions on num {
  /// Formate le nombre en prix avec devise
  String toCurrency({
    String symbol = '€',
    int decimals = 2,
    bool symbolAfter = true,
  }) {
    final formatted = toStringAsFixed(decimals);
    return symbolAfter ? '$formatted $symbol' : '$symbol$formatted';
  }

  /// Formate le nombre en pourcentage
  String toPercentage({int decimals = 1}) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }

  /// Formate le nombre avec des séparateurs de milliers
  String toFormattedString({String separator = ' '}) {
    final parts = toString().split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}$separator',
    );

    return '$formattedInteger$decimalPart';
  }

  /// Arrondit à un nombre de décimales spécifique
  double roundToDecimals(int decimals) {
    final factor = pow(10, decimals);
    return (this * factor).round() / factor;
  }

  /// Vérifie si le nombre est dans une plage
  bool isBetween(num min, num max) {
    return this >= min && this <= max;
  }

  /// Vérifie si le nombre est pair
  bool get isEven => this % 2 == 0;

  /// Vérifie si le nombre est impair
  bool get isOdd => this % 2 != 0;

  /// Vérifie si le nombre est positif
  bool get isPositive => this > 0;

  /// Vérifie si le nombre est négatif
  bool get isNegative => this < 0;

  /// Vérifie si le nombre est zéro
  bool get isZero => this == 0;

  /// Convertit en taille de fichier lisible
  String toFileSize() {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Convertit les secondes en durée lisible
  String toReadableDuration() {
    final totalSeconds = toInt();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Clamp le nombre entre min et max
  num clampTo(num min, num max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Génère une liste de nombres de 0 à cette valeur
  List<int> get range {
    return List.generate(toInt(), (index) => index);
  }

  /// Calcule le pourcentage par rapport à un total
  double percentageOf(num total) {
    if (total == 0) return 0;
    return (this / total) * 100;
  }

  /// Convertit en notation scientifique
  String toScientificNotation({int decimals = 2}) {
    return toStringAsExponential(decimals);
  }
}

extension IntExtensions on int {
  /// Vérifie si le nombre est premier
  bool get isPrime {
    if (this < 2) return false;
    for (int i = 2; i <= sqrt(this); i++) {
      if (this % i == 0) return false;
    }
    return true;
  }

  /// Génère les facteurs du nombre
  List<int> get factors {
    final factors = <int>[];
    for (int i = 1; i <= this; i++) {
      if (this % i == 0) factors.add(i);
    }
    return factors;
  }

  /// Calcule la factorielle
  int get factorial {
    if (this < 0) {
      throw ArgumentError('Factorial is not defined for negative numbers');
    }
    if (this <= 1) return 1;
    int result = 1;
    for (int i = 2; i <= this; i++) {
      result *= i;
    }
    return result;
  }

  /// Convertit en nombre romain
  String get toRoman {
    if (this <= 0 || this > 3999) {
      throw ArgumentError('Roman numerals are only supported for 1-3999');
    }

    const values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    const numerals = [
      'M',
      'CM',
      'D',
      'CD',
      'C',
      'XC',
      'L',
      'XL',
      'X',
      'IX',
      'V',
      'IV',
      'I',
    ];

    String result = '';
    int number = this;

    for (int i = 0; i < values.length; i++) {
      while (number >= values[i]) {
        result += numerals[i];
        number -= values[i];
      }
    }

    return result;
  }

  /// Convertit en ordinale (1er, 2ème, etc.)
  String get toOrdinal {
    if (this % 100 >= 11 && this % 100 <= 13) {
      return '$this'
          'ème';
    }
    switch (this % 10) {
      case 1:
        return '$this'
            'er';
      default:
        return '$this'
            'ème';
    }
  }

  /// Génère une séquence Fibonacci jusqu'à cette valeur
  List<int> get fibonacciSequence {
    if (this <= 0) return [];
    if (this == 1) return [0];
    if (this == 2) return [0, 1];

    final sequence = [0, 1];
    while (sequence.length < this) {
      sequence.add(
        sequence[sequence.length - 1] + sequence[sequence.length - 2],
      );
    }
    return sequence;
  }
}

extension DoubleExtensions on double {
  /// Arrondit vers le haut au multiple le plus proche
  double ceilToMultiple(double multiple) {
    return (this / multiple).ceil() * multiple;
  }

  /// Arrondit vers le bas au multiple le plus proche
  double floorToMultiple(double multiple) {
    return (this / multiple).floor() * multiple;
  }

  /// Arrondit au multiple le plus proche
  double roundToMultiple(double multiple) {
    return (this / multiple).round() * multiple;
  }

  /// Vérifie si le nombre est approximativement égal à un autre
  bool isApproximatelyEqualTo(double other, {double epsilon = 0.001}) {
    return (this - other).abs() < epsilon;
  }

  /// Interpole entre cette valeur et une autre
  double lerp(double target, double t) {
    return this + (target - this) * t;
  }
}
