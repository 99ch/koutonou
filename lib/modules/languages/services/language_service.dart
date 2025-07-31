// Service Language mis à jour - Phase 3
// Utilise la nouvelle infrastructure API avec gestion d'erreurs et retry

import 'package:koutonou/core/services/prestashop_base_service.dart';
import 'package:koutonou/modules/languages/models/language_model.dart';

/// Service pour la gestion des languages PrestaShop
class LanguageService extends PrestaShopBaseService<LanguageModel> {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  @override
  String get resourceName => 'languages';

  @override
  LanguageModel fromJson(Map<String, dynamic> json) {
    return LanguageModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(LanguageModel item) {
    return item.toJson();
  }

  /// Récupère les langues actives seulement
  Future<List<LanguageModel>> getActiveLanguages() async {
    return await search(
      filters: {'active': '1'},
    );
  }

  /// Récupère la langue par défaut
  Future<LanguageModel?> getDefaultLanguage() async {
    final languages = await search(
      filters: {'active': '1'},
      limit: 1,
    );
    
    return languages.isNotEmpty ? languages.first : null;
  }

  /// Récupère une langue par son code ISO
  Future<LanguageModel?> getByIsoCode(String isoCode) async {
    final languages = await search(
      filters: {'iso_code': isoCode},
      limit: 1,
    );
    
    return languages.isNotEmpty ? languages.first : null;
  }

  /// Active/désactive une langue
  Future<LanguageModel> toggleActive(int id, bool active) async {
    final language = await getById(id);
    if (language == null) {
      throw Exception('Langue non trouvée avec l\'ID: $id');
    }
    
    // Créer un nouveau modèle avec le statut modifié
    final updatedLanguage = LanguageModel(
      id: language.id,
      name: language.name,
      iso_code: language.iso_code,
      language_code: language.language_code,
      active: active ? 1 : 0,
      is_rtl: language.is_rtl,
      date_format_lite: language.date_format_lite,
      date_format_full: language.date_format_full,
    );
    
    return await update(id, updatedLanguage);
  }
}
