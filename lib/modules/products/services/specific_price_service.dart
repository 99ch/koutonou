import 'package:koutonou/core/api/base_prestashop_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import '../models/specific_price_model.dart';

/// Service pour gérer les prix spécifiques PrestaShop
class SpecificPriceService extends BasePrestaShopService {
  static final SpecificPriceService _instance = SpecificPriceService._internal();
  factory SpecificPriceService() => _instance;
  SpecificPriceService._internal();
  
  static final AppLogger _logger = AppLogger();

  /// Récupère tous les prix spécifiques
  Future<List<SpecificPrice>> getAllSpecificPrices({
    String? display = 'full',
    Map<String, String>? filters,
    List<String>? sort,
    int? limit,
    int? offset,
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching all specific prices from PrestaShop API');
    
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
        'specific_prices',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['specific_prices'] is List) {
          final specificPricesList = data['specific_prices'] as List;
          return specificPricesList
              .map((json) => SpecificPrice.fromPrestaShopJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      _logger.error('Error fetching all specific prices: $e');
      rethrow;
    }
  }

  /// Récupère un prix spécifique par ID
  Future<SpecificPrice?> getSpecificPriceById(
    int specificPriceId, {
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching specific price by ID: $specificPriceId');
    
    try {
      final queryParams = <String, dynamic>{
        'display': 'full',
      };
      
      if (language != null) queryParams['language'] = language;
      if (idShop != null) queryParams['id_shop'] = idShop.toString();

      final response = await get<Map<String, dynamic>>(
        'specific_prices/$specificPriceId',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['specific_price'] is Map<String, dynamic>) {
          return SpecificPrice.fromPrestaShopJson(
            data['specific_price'] as Map<String, dynamic>,
          );
        }
      }
      
      return null;
    } catch (e) {
      _logger.error('Error fetching specific price by ID $specificPriceId: $e');
      rethrow;
    }
  }

  /// Récupère tous les prix spécifiques pour un produit
  Future<List<SpecificPrice>> getSpecificPricesByProduct(
    int productId, {
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching specific prices for product: $productId');
    
    return await getAllSpecificPrices(
      filters: {'id_product': productId.toString()},
      language: language,
      idShop: idShop,
    );
  }

  /// Récupère tous les prix spécifiques pour un client
  Future<List<SpecificPrice>> getSpecificPricesByCustomer(
    int customerId, {
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching specific prices for customer: $customerId');
    
    return await getAllSpecificPrices(
      filters: {'id_customer': customerId.toString()},
      language: language,
      idShop: idShop,
    );
  }

  /// Crée un nouveau prix spécifique
  Future<SpecificPrice?> createSpecificPrice(SpecificPrice specificPrice) async {
    _logger.info('Creating specific price for product: ${specificPrice.idProduct}');
    
    try {
      final response = await post<Map<String, dynamic>>(
        'specific_prices',
        data: {'specific_price': specificPrice.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        _logger.info('Create specific price response: $data');

        if (data['specific_price'] is Map<String, dynamic>) {
          final specificPriceData = data['specific_price'] as Map<String, dynamic>;
          final specificPriceId = int.tryParse(specificPriceData['id']?.toString() ?? '0');

          if (specificPriceId != null && specificPriceId > 0) {
            _logger.info('Specific price created with ID: $specificPriceId, fetching full details...');
            return await getSpecificPriceById(specificPriceId);
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error creating specific price: $e');
      rethrow;
    }
  }

  /// Met à jour un prix spécifique existant
  Future<SpecificPrice?> updateSpecificPrice(SpecificPrice specificPrice) async {
    if (specificPrice.id == null) {
      throw ArgumentError('SpecificPrice ID is required for update');
    }

    _logger.info('Updating specific price: ${specificPrice.id}');

    try {
      final response = await put<Map<String, dynamic>>(
        'specific_prices/${specificPrice.id}',
        data: {'specific_price': specificPrice.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        _logger.info('Update specific price response: $data');

        if (data['specific_price'] is Map<String, dynamic>) {
          final specificPriceData = data['specific_price'] as Map<String, dynamic>;
          final specificPriceId = int.tryParse(specificPriceData['id']?.toString() ?? '0');

          if (specificPriceId != null && specificPriceId > 0) {
            _logger.info('Specific price updated with ID: $specificPriceId, fetching full details...');
            return await getSpecificPriceById(specificPriceId);
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error updating specific price ${specificPrice.id}: $e');
      rethrow;
    }
  }

  /// Supprime un prix spécifique
  Future<bool> deleteSpecificPrice(int specificPriceId) async {
    _logger.info('Deleting specific price: $specificPriceId');

    try {
      final response = await delete('specific_prices/$specificPriceId');
      return response.success;
    } catch (e) {
      _logger.error('Error deleting specific price $specificPriceId: $e');
      rethrow;
    }
  }

  /// Recherche les prix spécifiques actifs pour un produit à une date donnée
  Future<List<SpecificPrice>> getActiveSpecificPrices(
    int productId, {
    DateTime? date,
    int? customerId,
    int? groupId,
    int? countryId,
    int? currencyId,
  }) async {
    _logger.info('Fetching active specific prices for product: $productId');
    
    final filters = <String, String>{
      'id_product': productId.toString(),
    };
    
    if (customerId != null) filters['id_customer'] = customerId.toString();
    if (groupId != null) filters['id_group'] = groupId.toString();
    if (countryId != null) filters['id_country'] = countryId.toString();
    if (currencyId != null) filters['id_currency'] = currencyId.toString();
    
    final allPrices = await getAllSpecificPrices(filters: filters);
    
    // Filtrer les prix actifs à la date donnée
    return allPrices.where((price) => price.isActive).toList();
  }

  /// Calcule le meilleur prix pour un produit donné
  Future<double?> getBestPriceForProduct(
    int productId,
    double basePrice, {
    int quantity = 1,
    int? customerId,
    int? groupId,
    int? countryId,
    int? currencyId,
    DateTime? date,
  }) async {
    _logger.info('Calculating best price for product: $productId');
    
    final activeSpecificPrices = await getActiveSpecificPrices(
      productId,
      date: date,
      customerId: customerId,
      groupId: groupId,
      countryId: countryId,
      currencyId: currencyId,
    );
    
    double bestPrice = basePrice;
    
    for (final specificPrice in activeSpecificPrices) {
      if (quantity < specificPrice.fromQuantity) {
        continue; // Cette réduction ne s'applique pas pour cette quantité
      }
      
      final calculatedPrice = specificPrice.calculateFinalPrice(basePrice);
      if (calculatedPrice < bestPrice) {
        bestPrice = calculatedPrice;
      }
    }
    
    return bestPrice;
  }
}
