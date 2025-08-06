import 'package:koutonou/core/api/base_prestashop_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import '../models/combination_model.dart';

/// Service pour gérer les combinaisons de produits PrestaShop
class CombinationService extends BasePrestaShopService {
  static final CombinationService _instance = CombinationService._internal();
  factory CombinationService() => _instance;
  CombinationService._internal();

  static final AppLogger _logger = AppLogger();

  /// Récupère toutes les combinaisons
  Future<List<Combination>> getAllCombinations({
    String? display = 'full',
    Map<String, String>? filters,
    List<String>? sort,
    int? limit,
    int? offset,
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching all combinations from PrestaShop API');

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
        'combinations',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['combinations'] is List) {
          final combinationsList = data['combinations'] as List;
          return combinationsList
              .map(
                (json) => Combination.fromPrestaShopJson(
                  json as Map<String, dynamic>,
                ),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error fetching all combinations: $e');
      rethrow;
    }
  }

  /// Récupère une combinaison par ID
  Future<Combination?> getCombinationById(
    int combinationId, {
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching combination by ID: $combinationId');

    try {
      final queryParams = <String, dynamic>{'display': 'full'};

      if (language != null) queryParams['language'] = language;
      if (idShop != null) queryParams['id_shop'] = idShop.toString();

      final response = await get<Map<String, dynamic>>(
        'combinations/$combinationId',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['combination'] is Map<String, dynamic>) {
          return Combination.fromPrestaShopJson(
            data['combination'] as Map<String, dynamic>,
          );
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error fetching combination by ID $combinationId: $e');
      rethrow;
    }
  }

  /// Récupère toutes les combinaisons pour un produit
  Future<List<Combination>> getCombinationsByProduct(
    int productId, {
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching combinations for product: $productId');

    return await getAllCombinations(
      filters: {'id_product': productId.toString()},
      language: language,
      idShop: idShop,
    );
  }

  /// Recherche les combinaisons par référence
  Future<List<Combination>> searchCombinationsByReference(
    String reference, {
    int? limit,
    String? language,
  }) async {
    _logger.info('Searching combinations with reference: $reference');

    try {
      final queryParams = <String, dynamic>{
        'filter[reference]': '%$reference%',
        'display': 'full',
      };

      if (limit != null) queryParams['limit'] = limit.toString();
      if (language != null) queryParams['language'] = language;

      final response = await get<Map<String, dynamic>>(
        'combinations',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['combinations'] is List) {
          final combinationsList = data['combinations'] as List;
          return combinationsList
              .map(
                (json) => Combination.fromPrestaShopJson(
                  json as Map<String, dynamic>,
                ),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error searching combinations: $e');
      rethrow;
    }
  }

  /// Recherche les combinaisons par EAN13
  Future<List<Combination>> searchCombinationsByEan13(
    String ean13, {
    int? limit,
    String? language,
  }) async {
    _logger.info('Searching combinations with EAN13: $ean13');

    return await getAllCombinations(
      filters: {'ean13': ean13},
      limit: limit,
      language: language,
    );
  }

  /// Crée une nouvelle combinaison
  Future<Combination?> createCombination(Combination combination) async {
    _logger.info('Creating combination for product: ${combination.idProduct}');

    try {
      final response = await post<Map<String, dynamic>>(
        'combinations',
        data: {'combination': combination.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        _logger.info('Create combination response: $data');

        if (data['combination'] is Map<String, dynamic>) {
          final combinationData = data['combination'] as Map<String, dynamic>;
          final combinationId = int.tryParse(
            combinationData['id']?.toString() ?? '0',
          );

          if (combinationId != null && combinationId > 0) {
            _logger.info(
              'Combination created with ID: $combinationId, fetching full details...',
            );
            return await getCombinationById(combinationId);
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error creating combination: $e');
      rethrow;
    }
  }

  /// Met à jour une combinaison existante
  Future<Combination?> updateCombination(Combination combination) async {
    if (combination.id == null) {
      throw ArgumentError('Combination ID is required for update');
    }

    _logger.info('Updating combination: ${combination.id}');

    try {
      final response = await put<Map<String, dynamic>>(
        'combinations/${combination.id}',
        data: {'combination': combination.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        _logger.info('Update combination response: $data');

        if (data['combination'] is Map<String, dynamic>) {
          final combinationData = data['combination'] as Map<String, dynamic>;
          final combinationId = int.tryParse(
            combinationData['id']?.toString() ?? '0',
          );

          if (combinationId != null && combinationId > 0) {
            _logger.info(
              'Combination updated with ID: $combinationId, fetching full details...',
            );
            return await getCombinationById(combinationId);
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error updating combination ${combination.id}: $e');
      rethrow;
    }
  }

  /// Supprime une combinaison
  Future<bool> deleteCombination(int combinationId) async {
    _logger.info('Deleting combination: $combinationId');

    try {
      final response = await delete('combinations/$combinationId');
      return response.success;
    } catch (e) {
      _logger.error('Error deleting combination $combinationId: $e');
      rethrow;
    }
  }

  /// Met à jour le stock d'une combinaison
  Future<bool> updateCombinationStock(int combinationId, int quantity) async {
    _logger.info(
      'Updating stock for combination: $combinationId, quantity: $quantity',
    );

    try {
      final response = await put<Map<String, dynamic>>(
        'combinations/$combinationId',
        data: {
          'combination': {'quantity': quantity.toString()},
        },
      );

      return response.success;
    } catch (e) {
      _logger.error('Error updating stock for combination $combinationId: $e');
      rethrow;
    }
  }

  /// Récupère les combinaisons disponibles (en stock)
  Future<List<Combination>> getAvailableCombinations({
    int? productId,
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching available combinations');

    final filters = <String, String>{};
    if (productId != null) filters['id_product'] = productId.toString();

    final allCombinations = await getAllCombinations(
      filters: filters.isNotEmpty ? filters : null,
      language: language,
      idShop: idShop,
    );

    // Filtrer les combinaisons en stock
    return allCombinations.where((combination) => combination.inStock).toList();
  }

  /// Récupère les combinaisons en rupture de stock
  Future<List<Combination>> getOutOfStockCombinations({
    int? productId,
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching out of stock combinations');

    final filters = <String, String>{};
    if (productId != null) filters['id_product'] = productId.toString();

    final allCombinations = await getAllCombinations(
      filters: filters.isNotEmpty ? filters : null,
      language: language,
      idShop: idShop,
    );

    // Filtrer les combinaisons en rupture de stock
    return allCombinations
        .where((combination) => !combination.inStock)
        .toList();
  }

  /// Récupère la combinaison par défaut d'un produit
  Future<Combination?> getDefaultCombination(
    int productId, {
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching default combination for product: $productId');

    final combinations = await getCombinationsByProduct(
      productId,
      language: language,
      idShop: idShop,
    );

    // Chercher la combinaison par défaut
    try {
      return combinations.firstWhere(
        (combination) => combination.defaultOn == 1,
      );
    } catch (e) {
      // Si aucune combinaison par défaut, retourner la première disponible
      if (combinations.isNotEmpty) {
        return combinations.first;
      }
      return null;
    }
  }

  /// Calcule le prix final d'une combinaison
  Future<double> calculateCombinationPrice(
    int combinationId,
    double basePrice, {
    String? language,
    int? idShop,
  }) async {
    _logger.info('Calculating price for combination: $combinationId');

    final combination = await getCombinationById(
      combinationId,
      language: language,
      idShop: idShop,
    );

    if (combination != null) {
      return combination.calculateFinalPrice(basePrice);
    }

    return basePrice;
  }

  /// Récupère les combinaisons avec des images associées
  Future<List<Combination>> getCombinationsWithImages({
    int? productId,
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching combinations with images');

    final filters = <String, String>{};
    if (productId != null) filters['id_product'] = productId.toString();

    final allCombinations = await getAllCombinations(
      filters: filters.isNotEmpty ? filters : null,
      language: language,
      idShop: idShop,
    );

    // Filtrer les combinaisons avec des images
    return allCombinations
        .where(
          (combination) =>
              combination.imageIds != null && combination.imageIds!.isNotEmpty,
        )
        .toList();
  }
}
