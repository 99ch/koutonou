import 'package:koutonou/core/api/base_prestashop_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import '../models/order_history_model.dart';

/// Service pour la gestion de l'historique des commandes
class OrderHistoryService extends BasePrestaShopService {
  static final OrderHistoryService _instance = OrderHistoryService._internal();
  factory OrderHistoryService() => _instance;
  OrderHistoryService._internal();

  static final AppLogger _logger = AppLogger();

  /// Récupère tout l'historique des commandes
  Future<List<OrderHistory>> getAllOrderHistories({
    String? display = 'full',
    Map<String, String>? filters,
    List<String>? sort,
    int? limit,
    int? offset,
  }) async {
    _logger.info('Fetching all order histories from PrestaShop API');

    try {
      final queryParams = <String, dynamic>{};
      queryParams['display'] = display ?? 'full';
      if (filters != null) queryParams.addAll(filters);
      if (sort != null) queryParams['sort'] = sort.join(',');
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final response = await get<Map<String, dynamic>>(
        'order_histories',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_histories'] is List) {
          final historiesList = data['order_histories'] as List;
          return historiesList
              .map(
                (json) => OrderHistory.fromPrestaShopJson(
                  json as Map<String, dynamic>,
                ),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error fetching all order histories: $e');
      rethrow;
    }
  }

  /// Récupère un historique par ID
  Future<OrderHistory?> getOrderHistoryById(int historyId) async {
    _logger.info('Fetching order history by ID: $historyId');

    try {
      final response = await get<Map<String, dynamic>>(
        'order_histories/$historyId',
        queryParameters: {'display': 'full'},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_history'] is Map<String, dynamic>) {
          return OrderHistory.fromPrestaShopJson(
            data['order_history'] as Map<String, dynamic>,
          );
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error fetching order history by ID $historyId: $e');
      rethrow;
    }
  }

  /// Récupère l'historique d'une commande spécifique
  Future<List<OrderHistory>> getHistoryByOrderId(int orderId) async {
    _logger.info('Fetching history for order ID: $orderId');

    return await getAllOrderHistories(
      filters: {'id_order': orderId.toString()},
      sort: ['date_add_DESC'], // Plus récent en premier
    );
  }

  /// Crée un nouvel entrée d'historique (changement d'état)
  Future<OrderHistory?> createOrderHistory(OrderHistory history) async {
    _logger.info('Creating order history for order: ${history.idOrder}');

    try {
      final response = await post<Map<String, dynamic>>(
        'order_histories',
        data: {'order_history': history.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_history'] is Map<String, dynamic>) {
          final historyData = data['order_history'] as Map<String, dynamic>;
          final historyId = int.tryParse(historyData['id']?.toString() ?? '0');

          if (historyId != null && historyId > 0) {
            return await getOrderHistoryById(historyId);
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error creating order history: $e');
      rethrow;
    }
  }

  /// Change l'état d'une commande (crée automatiquement un historique)
  Future<OrderHistory?> changeOrderState(
    int orderId,
    int newStateId, {
    int? employeeId,
  }) async {
    _logger.info('Changing state for order $orderId to state $newStateId');

    final history = OrderHistory(
      idOrder: orderId,
      idOrderState: newStateId,
      idEmployee: employeeId,
    );

    return await createOrderHistory(history);
  }

  /// Supprime un historique
  Future<bool> deleteOrderHistory(int historyId) async {
    _logger.info('Deleting order history: $historyId');

    try {
      final response = await delete('order_histories/$historyId');
      return response.success;
    } catch (e) {
      _logger.error('Error deleting order history $historyId: $e');
      rethrow;
    }
  }
}
