// Service de localisation pour gérer les langues et traductions de l'application Koutonou.
// Fournit un accès centralisé aux traductions avec support pour le français et l'anglais.
// Intègre la détection automatique de la langue système et la persistance des préférences.

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:koutonou/core/services/cache_service.dart';
import 'package:koutonou/core/utils/logger.dart';

/// Service de gestion de la localisation
class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  static const String _cacheKey = 'app_locale';
  static const String _defaultLocale = 'fr';

  final AppLogger _logger = AppLogger();
  final CacheService _cache = CacheService();

  Map<String, String> _localizedStrings = {};
  Locale _currentLocale = const Locale('fr');

  /// Langues supportées
  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'), // Français
    Locale('en', 'US'), // Anglais
  ];

  /// Locale actuelle
  Locale get currentLocale => _currentLocale;

  /// Code de langue actuel (fr, en)
  String get currentLanguageCode => _currentLocale.languageCode;

  /// Initialise le service de localisation
  Future<void> initialize() async {
    try {
      _logger.info('Initialisation du service de localisation...');

      // Récupérer la langue sauvegardée ou détecter la langue système
      final savedLocale = await _getSavedLocale();
      _currentLocale = savedLocale ?? _detectSystemLocale();

      // Charger les traductions
      await _loadTranslations(_currentLocale.languageCode);

      _logger.info(
        'Localisation initialisée avec la langue: ${_currentLocale.languageCode}',
      );
    } catch (e) {
      _logger.error('Erreur lors de l\'initialisation de la localisation: $e');
      // Fallback vers le français en cas d'erreur
      await _loadTranslations(_defaultLocale);
      _currentLocale = const Locale('fr');
    }
  }

  /// Change la langue de l'application
  Future<bool> changeLanguage(String languageCode) async {
    try {
      if (!_isLanguageSupported(languageCode)) {
        _logger.warning('Langue non supportée: $languageCode');
        return false;
      }

      _logger.info('Changement de langue vers: $languageCode');

      // Charger les nouvelles traductions
      await _loadTranslations(languageCode);

      // Mettre à jour la locale
      _currentLocale = Locale(languageCode);

      // Sauvegarder la préférence
      await _saveLocale(_currentLocale);

      _logger.info('Langue changée avec succès vers: $languageCode');
      return true;
    } catch (e) {
      _logger.error('Erreur lors du changement de langue: $e');
      return false;
    }
  }

  /// Obtient une traduction par clé
  String translate(String key, {Map<String, dynamic>? parameters}) {
    try {
      String translation = _localizedStrings[key] ?? key;

      // Substitution des paramètres si fournis
      if (parameters != null) {
        parameters.forEach((paramKey, value) {
          translation = translation.replaceAll('{$paramKey}', value.toString());
        });
      }

      return translation;
    } catch (e) {
      _logger.error('Erreur lors de la traduction de "$key": $e');
      return key; // Retourner la clé en cas d'erreur
    }
  }

  /// Alias court pour translate
  String t(String key, {Map<String, dynamic>? parameters}) {
    return translate(key, parameters: parameters);
  }

  /// Vérifie si une clé de traduction existe
  bool hasTranslation(String key) {
    return _localizedStrings.containsKey(key);
  }

  /// Obtient toutes les traductions chargées
  Map<String, String> getAllTranslations() {
    return Map.unmodifiable(_localizedStrings);
  }

  /// Recharge les traductions pour la langue actuelle
  Future<void> reloadTranslations() async {
    await _loadTranslations(_currentLocale.languageCode);
  }

  /// Obtient les statistiques de localisation
  LocalizationStats getStats() {
    return LocalizationStats(
      currentLanguage: _currentLocale.languageCode,
      supportedLanguages: supportedLocales.map((l) => l.languageCode).toList(),
      totalTranslations: _localizedStrings.length,
      lastUpdate: DateTime.now(),
    );
  }

  // Méthodes privées

  /// Charge les traductions depuis les fichiers JSON
  Future<void> _loadTranslations(String languageCode) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/localization/$languageCode.json',
      );

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      _logger.debug(
        '${_localizedStrings.length} traductions chargées pour $languageCode',
      );
    } catch (e) {
      _logger.error(
        'Impossible de charger les traductions pour $languageCode: $e',
      );

      // Fallback vers les traductions par défaut si pas le français
      if (languageCode != _defaultLocale) {
        await _loadTranslations(_defaultLocale);
      } else {
        // Traductions de base en cas d'échec total
        _localizedStrings = _getFallbackTranslations();
      }
    }
  }

  /// Détecte la langue du système
  Locale _detectSystemLocale() {
    final systemLocale = PlatformDispatcher.instance.locale;

    // Vérifier si la langue système est supportée
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == systemLocale.languageCode) {
        _logger.info(
          'Langue système détectée et supportée: ${systemLocale.languageCode}',
        );
        return supportedLocale;
      }
    }

    // Fallback vers le français
    _logger.info(
      'Langue système non supportée, utilisation du français par défaut',
    );
    return const Locale('fr');
  }

  /// Vérifie si une langue est supportée
  bool _isLanguageSupported(String languageCode) {
    return supportedLocales.any(
      (locale) => locale.languageCode == languageCode,
    );
  }

  /// Sauvegarde la locale dans le cache
  Future<void> _saveLocale(Locale locale) async {
    try {
      await _cache.set(_cacheKey, locale.languageCode);
    } catch (e) {
      _logger.error('Erreur lors de la sauvegarde de la locale: $e');
    }
  }

  /// Récupère la locale sauvegardée
  Future<Locale?> _getSavedLocale() async {
    try {
      final savedLanguageCode = await _cache.get<String>(_cacheKey);
      if (savedLanguageCode != null &&
          _isLanguageSupported(savedLanguageCode)) {
        return Locale(savedLanguageCode);
      }
    } catch (e) {
      _logger.error(
        'Erreur lors de la récupération de la locale sauvegardée: $e',
      );
    }
    return null;
  }

  /// Traductions de fallback en cas d'erreur
  Map<String, String> _getFallbackTranslations() {
    return {
      'app_name': 'Koutonou',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'retry': 'Réessayer',
      'ok': 'OK',
      'cancel': 'Annuler',
      'yes': 'Oui',
      'no': 'Non',
    };
  }
}

/// Extension pour simplifier l'accès aux traductions
extension LocalizationExtension on String {
  /// Traduit la chaîne courante
  String tr({Map<String, dynamic>? parameters}) {
    return LocalizationService().translate(this, parameters: parameters);
  }
}

/// Modèle pour les statistiques de localisation
class LocalizationStats {
  final String currentLanguage;
  final List<String> supportedLanguages;
  final int totalTranslations;
  final DateTime lastUpdate;

  const LocalizationStats({
    required this.currentLanguage,
    required this.supportedLanguages,
    required this.totalTranslations,
    required this.lastUpdate,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentLanguage': currentLanguage,
      'supportedLanguages': supportedLanguages,
      'totalTranslations': totalTranslations,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}
