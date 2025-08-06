import 'package:koutonou/core/api/base_prestashop_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import '../models/order_state_model.dart';

/// Service pour la gestion des états de commande
class OrderStateService extends BasePrestaShopService {
  static final OrderStateService _instance = OrderStateService._internal();
  factory OrderStateService() => _instance;
  OrderStateService._internal();

  static final AppLogger _logger = AppLogger();

  /// Récupère tous les états de commande
  Future<List<OrderState>> getAllOrderStates({
    String? display = 'full',
    Map<String, String>? filters,
    List<String>? sort,
    int? limit,
    int? offset,
    String? language,
  }) async {
    _logger.info('Fetching all order states from PrestaShop API');

    try {
      final queryParams = <String, dynamic>{};
      queryParams['display'] = display ?? 'full';
      if (filters != null) queryParams.addAll(filters);
      if (sort != null) queryParams['sort'] = sort.join(',');
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (language != null) queryParams['language'] = language;

      final response = await get<Map<String, dynamic>>(
        'order_states',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_states'] is List) {
          final orderStatesList = data['order_states'] as List;
          return orderStatesList
              .map(
                (json) =>
                    OrderState.fromPrestaShopJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error fetching all order states: $e');
      rethrow;
    }
  }

  /// Récupère un état de commande par ID
  Future<OrderState?> getOrderStateById(
    int orderStateId, {
    String? language,
  }) async {
    _logger.info('Fetching order state by ID: $orderStateId');

    try {
      final queryParams = <String, dynamic>{};
      queryParams['display'] = 'full';
      if (language != null) queryParams['language'] = language;

      final response = await get<Map<String, dynamic>>(
        'order_states/$orderStateId',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_state'] is Map<String, dynamic>) {
          return OrderState.fromPrestaShopJson(
            data['order_state'] as Map<String, dynamic>,
          );
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error fetching order state by ID $orderStateId: $e');
      rethrow;
    }
  }

  /// Crée un nouvel état de commande
  Future<OrderState?> createOrderState(OrderState orderState) async {
    _logger.info('Creating order state: ${orderState.name}');

    try {
      final response = await post<Map<String, dynamic>>(
        'order_states',
        data: {'order_state': orderState.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_state'] is Map<String, dynamic>) {
          final orderStateData = data['order_state'] as Map<String, dynamic>;
          final orderStateId = int.tryParse(
            orderStateData['id']?.toString() ?? '0',
          );

          if (orderStateId != null && orderStateId > 0) {
            return await getOrderStateById(orderStateId);
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error creating order state: $e');
      rethrow;
    }
  }

  /// Met à jour un état de commande existant
  Future<OrderState?> updateOrderState(OrderState orderState) async {
    if (orderState.id == null) {
      throw ArgumentError('OrderState ID is required for update');
    }

    _logger.info('Updating order state: ${orderState.id}');

    try {
      final response = await put<Map<String, dynamic>>(
        'order_states/${orderState.id}',
        data: {'order_state': orderState.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        return await getOrderStateById(orderState.id!);
      }

      return null;
    } catch (e) {
      _logger.error('Error updating order state ${orderState.id}: $e');
      rethrow;
    }
  }

  /// Supprime un état de commande
  Future<bool> deleteOrderState(int orderStateId) async {
    _logger.info('Deleting order state: $orderStateId');

    try {
      final response = await delete('order_states/$orderStateId');
      return response.success;
    } catch (e) {
      _logger.error('Error deleting order state $orderStateId: $e');
      rethrow;
    }
  }
}
