// Extensions utiles pour les dates et DateTime
// Fournit des méthodes pour le formatage, calculs et manipulation des dates

extension DateTimeExtensions on DateTime {
  /// Formate la date en français
  String get toFrenchDate {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '$day ${months[month - 1]} $year';
  }

  /// Formate la date au format court (DD/MM/YYYY)
  String get toShortDate {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }

  /// Formate l'heure en français (HH:mm)
  String get toFrenchTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Formate la date et l'heure complètes
  String get toFrenchDateTime {
    return '$toFrenchDate à $toFrenchTime';
  }

  /// Retourne le nom du jour en français
  String get frenchDayName {
    const days = [
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi',
      'dimanche',
    ];
    return days[weekday - 1];
  }

  /// Retourne le nom du mois en français
  String get frenchMonthName {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return months[month - 1];
  }

  /// Vérifie si c'est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Vérifie si c'était hier
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Vérifie si c'est demain
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Vérifie si c'est un week-end
  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Vérifie si c'est un jour de semaine
  bool get isWeekday => !isWeekend;

  /// Vérifie si c'est une année bissextile
  bool get isLeapYear {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Début de la journée (00:00:00)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Fin de la journée (23:59:59.999)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Début de la semaine (lundi)
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).startOfDay;
  }

  /// Fin de la semaine (dimanche)
  DateTime get endOfWeek {
    final daysUntilSunday = 7 - weekday;
    return add(Duration(days: daysUntilSunday)).endOfDay;
  }

  /// Début du mois
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// Fin du mois
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }

  /// Début de l'année
  DateTime get startOfYear {
    return DateTime(year, 1, 1);
  }

  /// Fin de l'année
  DateTime get endOfYear {
    return DateTime(year, 12, 31, 23, 59, 59, 999);
  }

  /// Nombre de jours dans le mois
  int get daysInMonth {
    return DateTime(year, month + 1, 0).day;
  }

  /// Jour de l'année (1-366)
  int get dayOfYear {
    return difference(DateTime(year, 1, 1)).inDays + 1;
  }

  /// Semaine de l'année
  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysOffset = firstDayOfYear.weekday - 1;
    final firstWeekStart = firstDayOfYear.subtract(Duration(days: daysOffset));
    return difference(firstWeekStart).inDays ~/ 7 + 1;
  }

  /// Âge en années à partir de cette date
  int ageInYears([DateTime? relativeTo]) {
    final reference = relativeTo ?? DateTime.now();
    int age = reference.year - year;
    if (reference.month < month ||
        (reference.month == month && reference.day < day)) {
      age--;
    }
    return age;
  }

  /// Ajoute des jours ouvrables (exclut weekends)
  DateTime addBusinessDays(int days) {
    DateTime result = this;
    int remainingDays = days;

    while (remainingDays > 0) {
      result = result.add(const Duration(days: 1));
      if (result.isWeekday) {
        remainingDays--;
      }
    }

    return result;
  }

  /// Soustrait des jours ouvrables
  DateTime subtractBusinessDays(int days) {
    DateTime result = this;
    int remainingDays = days;

    while (remainingDays > 0) {
      result = result.subtract(const Duration(days: 1));
      if (result.isWeekday) {
        remainingDays--;
      }
    }

    return result;
  }

  /// Nombre de jours ouvrables entre deux dates
  int businessDaysBetween(DateTime other) {
    DateTime start = isBefore(other) ? this : other;
    DateTime end = isBefore(other) ? other : this;

    int businessDays = 0;
    DateTime current = start;

    while (current.isBefore(end)) {
      if (current.isWeekday) {
        businessDays++;
      }
      current = current.add(const Duration(days: 1));
    }

    return businessDays;
  }

  /// Retourne la différence en format lisible
  String timeAgo([DateTime? relativeTo]) {
    final reference = relativeTo ?? DateTime.now();
    final difference = reference.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'il y a $years an${years > 1 ? 's' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'il y a $months mois';
    } else if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }

  /// Retourne la différence future en format lisible
  String timeUntil([DateTime? relativeTo]) {
    final reference = relativeTo ?? DateTime.now();
    final difference = this.difference(reference);

    if (difference.isNegative) return 'passé';

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'dans $years an${years > 1 ? 's' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'dans $months mois';
    } else if (difference.inDays > 0) {
      return 'dans ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'dans ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'dans ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'maintenant';
    }
  }

  /// Format relatif intelligent
  String get smartFormat {
    if (isToday) return 'Aujourd\'hui à $toFrenchTime';
    if (isYesterday) return 'Hier à $toFrenchTime';
    if (isTomorrow) return 'Demain à $toFrenchTime';

    final now = DateTime.now();
    final difference = now.difference(this).inDays.abs();

    if (difference < 7) {
      return '$frenchDayName à $toFrenchTime';
    } else if (year == now.year) {
      return '$day $frenchMonthName à $toFrenchTime';
    } else {
      return toFrenchDateTime;
    }
  }

  /// Copie avec modification de certains champs
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}

/// Extensions pour Duration
extension DurationExtensions on Duration {
  /// Format lisible de la durée
  String get readableFormat {
    if (inDays > 0) {
      return '$inDays jour${inDays > 1 ? 's' : ''}';
    } else if (inHours > 0) {
      return '$inHours heure${inHours > 1 ? 's' : ''}';
    } else if (inMinutes > 0) {
      return '$inMinutes minute${inMinutes > 1 ? 's' : ''}';
    } else {
      return '$inSeconds seconde${inSeconds > 1 ? 's' : ''}';
    }
  }

  /// Format HH:MM:SS
  String get timeFormat {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = (inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Format compact (ex: 1h 30m)
  String get compactFormat {
    if (inDays > 0) {
      final hours = inHours % 24;
      return hours > 0 ? '${inDays}j ${hours}h' : '${inDays}j';
    } else if (inHours > 0) {
      final minutes = inMinutes % 60;
      return minutes > 0 ? '${inHours}h ${minutes}m' : '${inHours}h';
    } else if (inMinutes > 0) {
      return '${inMinutes}m';
    } else {
      return '${inSeconds}s';
    }
  }
}
