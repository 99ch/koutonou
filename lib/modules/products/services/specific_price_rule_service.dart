import 'package:koutonou/core/api/base_prestashop_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import '../models/specific_price_rule_model.dart';

/// Service pour gérer les règles de prix spécifiques PrestaShop
class SpecificPriceRuleService extends BasePrestaShopService {
  static final SpecificPriceRuleService _instance = SpecificPriceRuleService._internal();
  factory SpecificPriceRuleService() => _instance;
  SpecificPriceRuleService._internal();
  
  static final AppLogger _logger = AppLogger();

  /// Récupère toutes les règles de prix spécifiques
  Future<List<SpecificPriceRule>> getAllSpecificPriceRules({
    String? display = 'full',
    Map<String, String>? filters,
    List<String>? sort,
    int? limit,
    int? offset,
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching all specific price rules from PrestaShop API');
    
    try {
      final queryParams = <String, dynamic>{};
      queryParams['display'] = display ?? 'full';
      
      if (filters != null) queryParams.addAll(filters);
      if (sort != null) queryParams['sort'] = sort.join(',');
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (language != null) queryParams['language'] = language;
      if (idShop != null) queryParams['id_shop'] = idShop.toString();

      final response = await get<Map<String, dynamic>>(
        'specific_price_rules',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['specific_price_rules'] is List) {
          final rulesList = data['specific_price_rules'] as List;
          return rulesList
              .map((json) => SpecificPriceRule.fromPrestaShopJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      _logger.error('Error fetching all specific price rules: $e');
      rethrow;
    }
  }

  /// Récupère une règle de prix spécifique par ID
  Future<SpecificPriceRule?> getSpecificPriceRuleById(
    int ruleId, {
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching specific price rule by ID: $ruleId');
    
    try {
      final queryParams = <String, dynamic>{
        'display': 'full',
      };
      
      if (language != null) queryParams['language'] = language;
      if (idShop != null) queryParams['id_shop'] = idShop.toString();

      final response = await get<Map<String, dynamic>>(
        'specific_price_rules/$ruleId',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['specific_price_rule'] is Map<String, dynamic>) {
          return SpecificPriceRule.fromPrestaShopJson(
            data['specific_price_rule'] as Map<String, dynamic>,
          );
        }
      }
      
      return null;
    } catch (e) {
      _logger.error('Error fetching specific price rule by ID $ruleId: $e');
      rethrow;
    }
  }

  /// Recherche les règles de prix par nom
  Future<List<SpecificPriceRule>> searchSpecificPriceRules(
    String query, {
    int? limit,
    String? language,
  }) async {
    _logger.info('Searching specific price rules with query: $query');

    try {
      final queryParams = <String, dynamic>{
        'filter[name]': '%$query%',
        'display': 'full',
      };

      if (limit != null) queryParams['limit'] = limit.toString();
      if (language != null) queryParams['language'] = language;

      final response = await get<Map<String, dynamic>>(
        'specific_price_rules',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['specific_price_rules'] is List) {
          final rulesList = data['specific_price_rules'] as List;
          return rulesList
              .map((json) => SpecificPriceRule.fromPrestaShopJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error searching specific price rules: $e');
      rethrow;
    }
  }

  /// Crée une nouvelle règle de prix spécifique
  Future<SpecificPriceRule?> createSpecificPriceRule(SpecificPriceRule rule) async {
    _logger.info('Creating specific price rule: ${rule.name}');
    
    try {
      final response = await post<Map<String, dynamic>>(
        'specific_price_rules',
        data: {'specific_price_rule': rule.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        _logger.info('Create specific price rule response: $data');

        if (data['specific_price_rule'] is Map<String, dynamic>) {
          final ruleData = data['specific_price_rule'] as Map<String, dynamic>;
          final ruleId = int.tryParse(ruleData['id']?.toString() ?? '0');

          if (ruleId != null && ruleId > 0) {
            _logger.info('Specific price rule created with ID: $ruleId, fetching full details...');
            return await getSpecificPriceRuleById(ruleId);
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error creating specific price rule: $e');
      rethrow;
    }
  }

  /// Met à jour une règle de prix spécifique existante
  Future<SpecificPriceRule?> updateSpecificPriceRule(SpecificPriceRule rule) async {
    if (rule.id == null) {
      throw ArgumentError('SpecificPriceRule ID is required for update');
    }

    _logger.info('Updating specific price rule: ${rule.id}');

    try {
      final response = await put<Map<String, dynamic>>(
        'specific_price_rules/${rule.id}',
        data: {'specific_price_rule': rule.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        _logger.info('Update specific price rule response: $data');

        if (data['specific_price_rule'] is Map<String, dynamic>) {
          final ruleData = data['specific_price_rule'] as Map<String, dynamic>;
          final ruleId = int.tryParse(ruleData['id']?.toString() ?? '0');

          if (ruleId != null && ruleId > 0) {
            _logger.info('Specific price rule updated with ID: $ruleId, fetching full details...');
            return await getSpecificPriceRuleById(ruleId);
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error updating specific price rule ${rule.id}: $e');
      rethrow;
    }
  }

  /// Supprime une règle de prix spécifique
  Future<bool> deleteSpecificPriceRule(int ruleId) async {
    _logger.info('Deleting specific price rule: $ruleId');

    try {
      final response = await delete('specific_price_rules/$ruleId');
      return response.success;
    } catch (e) {
      _logger.error('Error deleting specific price rule $ruleId: $e');
      rethrow;
    }
  }

  /// Récupère les règles de prix actives à une date donnée
  Future<List<SpecificPriceRule>> getActiveRules({
    DateTime? date,
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching active specific price rules');
    
    final allRules = await getAllSpecificPriceRules(
      language: language,
      idShop: idShop,
    );
    
    // Filtrer les règles actives (basé sur les dates from/to si disponibles)
    return allRules.where((rule) {
      final now = date ?? DateTime.now();
      
      // Vérifier les dates de début et fin si définies
      if (rule.from != null && now.isBefore(rule.from!)) {
        return false;
      }
      
      if (rule.to != null && now.isAfter(rule.to!)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  /// Récupère les règles de prix applicables pour un groupe de clients
  Future<List<SpecificPriceRule>> getRulesForGroup(
    int groupId, {
    DateTime? date,
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching specific price rules for group: $groupId');
    
    return await getAllSpecificPriceRules(
      filters: {'id_group': groupId.toString()},
      language: language,
      idShop: idShop,
    );
  }

  /// Récupère les règles de prix applicables pour un pays
  Future<List<SpecificPriceRule>> getRulesForCountry(
    int countryId, {
    DateTime? date,
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching specific price rules for country: $countryId');
    
    return await getAllSpecificPriceRules(
      filters: {'id_country': countryId.toString()},
      language: language,
      idShop: idShop,
    );
  }

  /// Récupère les règles de prix applicables pour une devise
  Future<List<SpecificPriceRule>> getRulesForCurrency(
    int currencyId, {
    DateTime? date,
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching specific price rules for currency: $currencyId');
    
    return await getAllSpecificPriceRules(
      filters: {'id_currency': currencyId.toString()},
      language: language,
      idShop: idShop,
    );
  }

  /// Calcule le meilleur prix en appliquant toutes les règles applicables
  Future<double> calculateBestPrice(
    double basePrice, {
    int quantity = 1,
    int? groupId,
    int? countryId,
    int? currencyId,
    DateTime? date,
    String? language,
    int? idShop,
  }) async {
    _logger.info('Calculating best price with rules');
    
    final targetDate = date ?? DateTime.now();
    double bestPrice = basePrice;
    
    // Récupérer toutes les règles potentiellement applicables
    final allRules = await getActiveRules(
      date: targetDate,
      language: language,
      idShop: idShop,
    );
    
    for (final rule in allRules) {
      // Vérifier si la règle s'applique aux critères donnés
      if (groupId != null && rule.idGroup != 0 && rule.idGroup != groupId) {
        continue;
      }
      
      if (countryId != null && rule.idCountry != 0 && rule.idCountry != countryId) {
        continue;
      }
      
      if (currencyId != null && rule.idCurrency != 0 && rule.idCurrency != currencyId) {
        continue;
      }
      
      if (quantity < rule.fromQuantity) {
        continue;
      }
      
      // Appliquer la règle
      final calculatedPrice = rule.calculateFinalPrice(basePrice);
      if (calculatedPrice < bestPrice) {
        bestPrice = calculatedPrice;
      }
    }
    
    return bestPrice;
  }
}
