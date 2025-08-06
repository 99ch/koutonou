import 'package:koutonou/core/api/base_prestashop_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import '../models/order_slip_model.dart';

/// Service pour la gestion des avoirs de commande
class OrderSlipService extends BasePrestaShopService {
  static final OrderSlipService _instance = OrderSlipService._internal();
  factory OrderSlipService() => _instance;
  OrderSlipService._internal();

  static final AppLogger _logger = AppLogger();

  /// Récupère tous les avoirs de commande
  Future<List<OrderSlip>> getAllOrderSlips({
    String? display = 'full',
    Map<String, String>? filters,
    List<String>? sort,
    int? limit,
    int? offset,
  }) async {
    _logger.info('Fetching all order slips from PrestaShop API');

    try {
      final queryParams = <String, dynamic>{};
      queryParams['display'] = display ?? 'full';
      if (filters != null) queryParams.addAll(filters);
      if (sort != null) queryParams['sort'] = sort.join(',');
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      // Note: L'API utilise le singulier "order_slip" et non "order_slips"
      final response = await get<Map<String, dynamic>>(
        'order_slip',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_slip'] is List) {
          final slipsList = data['order_slip'] as List;
          return slipsList
              .map(
                (json) =>
                    OrderSlip.fromPrestaShopJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error fetching all order slips: $e');
      rethrow;
    }
  }

  /// Récupère un avoir par ID
  Future<OrderSlip?> getOrderSlipById(int slipId) async {
    _logger.info('Fetching order slip by ID: $slipId');

    try {
      final response = await get<Map<String, dynamic>>(
        'order_slip/$slipId',
        queryParameters: {'display': 'full'},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_slip'] is Map<String, dynamic>) {
          return OrderSlip.fromPrestaShopJson(
            data['order_slip'] as Map<String, dynamic>,
          );
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error fetching order slip by ID $slipId: $e');
      rethrow;
    }
  }

  /// Récupère les avoirs d'une commande spécifique
  Future<List<OrderSlip>> getSlipsByOrderId(int orderId) async {
    _logger.info('Fetching slips for order ID: $orderId');

    return await getAllOrderSlips(filters: {'id_order': orderId.toString()});
  }

  /// Récupère les avoirs d'un client spécifique
  Future<List<OrderSlip>> getSlipsByCustomerId(int customerId) async {
    _logger.info('Fetching slips for customer ID: $customerId');

    return await getAllOrderSlips(
      filters: {'id_customer': customerId.toString()},
    );
  }

  /// Crée un nouvel avoir
  Future<OrderSlip?> createOrderSlip(OrderSlip slip) async {
    _logger.info('Creating order slip for order: ${slip.idOrder}');

    try {
      final response = await post<Map<String, dynamic>>(
        'order_slip',
        data: {'order_slip': slip.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_slip'] is Map<String, dynamic>) {
          final slipData = data['order_slip'] as Map<String, dynamic>;
          final slipId = int.tryParse(slipData['id']?.toString() ?? '0');

          if (slipId != null && slipId > 0) {
            return await getOrderSlipById(slipId);
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error creating order slip: $e');
      rethrow;
    }
  }

  /// Met à jour un avoir existant
  Future<OrderSlip?> updateOrderSlip(OrderSlip slip) async {
    if (slip.id == null) {
      throw ArgumentError('OrderSlip ID is required for update');
    }

    _logger.info('Updating order slip: ${slip.id}');

    try {
      final response = await put<Map<String, dynamic>>(
        'order_slip/${slip.id}',
        data: {'order_slip': slip.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        return await getOrderSlipById(slip.id!);
      }

      return null;
    } catch (e) {
      _logger.error('Error updating order slip ${slip.id}: $e');
      rethrow;
    }
  }

  /// Supprime un avoir
  Future<bool> deleteOrderSlip(int slipId) async {
    _logger.info('Deleting order slip: $slipId');

    try {
      final response = await delete('order_slip/$slipId');
      return response.success;
    } catch (e) {
      _logger.error('Error deleting order slip $slipId: $e');
      rethrow;
    }
  }
}
