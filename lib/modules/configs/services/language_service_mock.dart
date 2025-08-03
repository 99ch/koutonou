// Service mock pour les tests MVP - Languages
// Simule des données PrestaShop sans appel API

import 'package:koutonou/core/utils/logger.dart';
import 'package:koutonou/modules/configs/models/languagemodel.dart';

/// Service mock pour la gestion des languages (tests MVP)
class LanguageServiceMock {
  static final LanguageServiceMock _instance = LanguageServiceMock._internal();
  factory LanguageServiceMock() => _instance;
  LanguageServiceMock._internal();

  static final AppLogger _logger = AppLogger();

  /// Récupère tous les languages (données simulées)
  Future<List<LanguageModel>> getAll({
    Map<String, dynamic>? filters,
    bool useCache = true,
  }) async {
    try {
      _logger.debug('Récupération des languages (données simulées)');

      // Simuler un délai d'API
      await Future.delayed(const Duration(milliseconds: 500));

      // Données simulées de languages PrestaShop
      final mockData = [
        {
          'id': '1',
          'name': 'Français (French)',
          'iso_code': 'fr',
          'language_code': 'fr-fr',
          'active': '1',
          'date_format_lite': 'd/m/Y',
          'date_format_full': 'd/m/Y H:i:s',
          'locale': 'fr-FR',
        },
        {
          'id': '2',
          'name': 'English (English)',
          'iso_code': 'en',
          'language_code': 'en-us',
          'active': '1',
          'date_format_lite': 'm/d/Y',
          'date_format_full': 'm/d/Y H:i:s',
          'locale': 'en-US',
        },
        {
          'id': '3',
          'name': 'Español (Spanish)',
          'iso_code': 'es',
          'language_code': 'es-es',
          'active': '1',
          'date_format_lite': 'd/m/Y',
          'date_format_full': 'd/m/Y H:i:s',
          'locale': 'es-ES',
        },
      ];

      final languages = mockData
          .map((item) => LanguageModel.fromJson(item))
          .toList();

      _logger.info('Languages simulés récupérés: ${languages.length}');
      return languages;
    } catch (e, stackTrace) {
      _logger.error('Erreur récupération languages simulés', e, stackTrace);
      rethrow;
    }
  }

  /// Récupère un LanguageModel par son ID (simulé)
  Future<LanguageModel?> getById(String id) async {
    try {
      _logger.debug('Récupération language ID: $id (simulé)');

      final all = await getAll();
      final found = all.where((lang) => lang.id == id).firstOrNull;

      if (found != null) {
        _logger.info('Language $id trouvé (simulé)');
      } else {
        _logger.debug('Language $id non trouvé (simulé)');
      }

      return found;
    } catch (e, stackTrace) {
      _logger.error('Erreur récupération Language $id (simulé)', e, stackTrace);
      rethrow;
    }
  }
}
