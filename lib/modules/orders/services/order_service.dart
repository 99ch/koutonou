import 'package:koutonou/core/api/base_prestashop_service.dart';
import 'package:koutonou/core/utils/logger.dart';
// Import du nouveau modèle Order basé sur l'API PrestaShop complète
import '../models/order_model.dart';
import '../models/order_detail_model.dart';
import '../models/order_state_model.dart';

class OrderService extends BasePrestaShopService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  static final AppLogger _logger = AppLogger();

  /// Récupère toutes les commandes
  Future<List<Order>> getAllOrders({
    String? display = 'full',
    Map<String, String>? filters,
    List<String>? sort,
    int? limit,
    int? offset,
    String? language,
    bool? date,
    int? idShop,
    int? idGroupShop,
  }) async {
    _logger.info('Fetching all orders from PrestaShop API');

    try {
      final queryParams = <String, dynamic>{
        'display': 'full',
        'sort':
            'id_DESC', // Trier par ID décroissant (plus récentes en premier)
      };

      // Ajouter les filtres optionnels
      if (filters != null) {
        for (final entry in filters.entries) {
          queryParams['filter[${entry.key}]'] = entry.value;
        }
      }

      if (sort != null) queryParams['sort'] = sort.join(',');
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (language != null) queryParams['language'] = language;
      if (date != null) queryParams['date'] = date.toString();
      if (idShop != null) queryParams['id_shop'] = idShop.toString();
      if (idGroupShop != null) {
        queryParams['id_group_shop'] = idGroupShop.toString();
      }

      final response = await get<Map<String, dynamic>>(
        'orders',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['orders'] is List) {
          final ordersList = data['orders'] as List;
          return ordersList
              .map(
                (json) =>
                    Order.fromPrestaShopJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error fetching all orders: $e');
      rethrow;
    }
  }

  /// Récupère une commande par ID
  Future<Order?> getOrderById(
    int orderId, {
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching order by ID: $orderId');

    try {
      final queryParams = <String, dynamic>{'display': 'full'};
      if (language != null) queryParams['language'] = language;
      if (idShop != null) queryParams['id_shop'] = idShop.toString();

      final response = await get<Map<String, dynamic>>(
        'orders/$orderId',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order'] is Map<String, dynamic>) {
          return Order.fromPrestaShopJson(
            data['order'] as Map<String, dynamic>,
          );
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error fetching order by ID $orderId: $e');
      rethrow;
    }
  }

  /// Récupère les commandes d'un client spécifique
  Future<List<Order>> getOrdersByCustomer(
    int customerId, {
    String? language,
    int? limit,
    int? offset,
  }) async {
    _logger.info('Fetching orders for customer: $customerId');

    return await getAllOrders(
      filters: {'id_customer': customerId.toString()},
      language: language,
      limit: limit,
      offset: offset,
    );
  }

  /// Récupère les commandes par état
  Future<List<Order>> getOrdersByState(
    int stateId, {
    String? language,
    int? limit,
    int? offset,
  }) async {
    _logger.info('Fetching orders with state: $stateId');

    return await getAllOrders(
      filters: {'current_state': stateId.toString()},
      language: language,
      limit: limit,
      offset: offset,
    );
  }

  /// Recherche des commandes par référence
  Future<List<Order>> searchOrdersByReference(
    String reference, {
    int? limit,
    String? language,
  }) async {
    _logger.info('Searching orders with reference: $reference');

    try {
      final queryParams = <String, dynamic>{
        'filter[reference]': '%$reference%',
        'display': 'full',
      };

      if (limit != null) queryParams['limit'] = limit.toString();
      if (language != null) queryParams['language'] = language;

      final response = await get<Map<String, dynamic>>(
        'orders',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['orders'] is List) {
          final ordersList = data['orders'] as List;
          return ordersList
              .map(
                (json) =>
                    Order.fromPrestaShopJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error searching orders: $e');
      rethrow;
    }
  }

  /// Récupère les commandes par période
  Future<List<Order>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? language,
    int? limit,
    int? offset,
  }) async {
    _logger.info(
      'Fetching orders from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
    );

    try {
      final queryParams = <String, dynamic>{
        'date': '1', // Activer le filtrage par date
        'filter[date_add]':
            '[${startDate.toIso8601String()},${endDate.toIso8601String()}]',
        'display': 'full',
        'sort': 'date_add_DESC',
      };

      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (language != null) queryParams['language'] = language;

      final response = await get<Map<String, dynamic>>(
        'orders',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['orders'] is List) {
          final ordersList = data['orders'] as List;
          return ordersList
              .map(
                (json) =>
                    Order.fromPrestaShopJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error fetching orders by date range: $e');
      rethrow;
    }
  }

  /// Crée une nouvelle commande
  Future<Order?> createOrder(Order order) async {
    _logger.info('Creating order with reference: ${order.reference}');

    try {
      final response = await post<Map<String, dynamic>>(
        'orders',
        data: {'order': order.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        _logger.info('Create order response: $data');

        // Récupérer la commande complète après création
        if (data['order'] is Map<String, dynamic>) {
          final orderData = data['order'] as Map<String, dynamic>;
          final orderId = int.tryParse(orderData['id']?.toString() ?? '0');

          if (orderId != null && orderId > 0) {
            _logger.info(
              'Order created with ID: $orderId, fetching full details...',
            );

            final fullOrder = await getOrderById(orderId);
            if (fullOrder != null) {
              _logger.info('Created order reference: ${fullOrder.reference}');
              return fullOrder;
            }
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error creating order: $e');
      rethrow;
    }
  }

  /// Met à jour une commande existante
  Future<Order?> updateOrder(Order order) async {
    if (order.id == null) {
      throw ArgumentError('Order ID is required for update');
    }

    _logger.info('Updating order: ${order.id}');

    try {
      final response = await put<Map<String, dynamic>>(
        'orders/${order.id}',
        data: {'order': order.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        _logger.info('Update order response: $data');

        // Récupérer la commande complète après mise à jour
        if (data['order'] is Map<String, dynamic>) {
          final orderData = data['order'] as Map<String, dynamic>;
          final orderId = int.tryParse(orderData['id']?.toString() ?? '0');

          if (orderId != null && orderId > 0) {
            _logger.info(
              'Order updated with ID: $orderId, fetching full details...',
            );

            final fullOrder = await getOrderById(orderId);
            if (fullOrder != null) {
              _logger.info('Updated order reference: ${fullOrder.reference}');
              return fullOrder;
            }
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error updating order ${order.id}: $e');
      rethrow;
    }
  }

  /// Met à jour l'état d'une commande
  Future<bool> updateOrderState(
    int orderId,
    int newStateId, {
    bool sendEmail = false,
  }) async {
    _logger.info('Updating order $orderId state to: $newStateId');

    try {
      // Pour changer l'état d'une commande, on utilise l'endpoint order_histories
      final response = await post<Map<String, dynamic>>(
        'order_histories',
        data: {
          'order_history': {
            'id_order': orderId.toString(),
            'id_order_state': newStateId.toString(),
          },
        },
        queryParameters: sendEmail ? {'sendemail': '1'} : null,
      );

      return response.success;
    } catch (e) {
      _logger.error('Error updating order state $orderId: $e');
      rethrow;
    }
  }

  /// Supprime une commande (généralement non recommandé)
  Future<bool> deleteOrder(int orderId) async {
    _logger.info('Deleting order: $orderId');

    try {
      final response = await delete('orders/$orderId');
      return response.success;
    } catch (e) {
      _logger.error('Error deleting order $orderId: $e');
      rethrow;
    }
  }

  /// Récupère les détails d'une commande (order_details)
  Future<List<OrderDetail>> getOrderDetails(int orderId) async {
    _logger.info('Fetching order details for order: $orderId');

    try {
      final queryParams = <String, dynamic>{
        'filter[id_order]': orderId.toString(),
        'display': 'full',
      };

      final response = await get<Map<String, dynamic>>(
        'order_details',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_details'] is List) {
          final detailsList = data['order_details'] as List;
          return detailsList
              .map(
                (json) => OrderDetail.fromPrestaShopJson(
                  json as Map<String, dynamic>,
                ),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error fetching order details for $orderId: $e');
      rethrow;
    }
  }

  /// Récupère l'historique des états d'une commande
  Future<List<Map<String, dynamic>>> getOrderHistory(int orderId) async {
    _logger.info('Fetching order history for order: $orderId');

    try {
      final queryParams = <String, dynamic>{
        'filter[id_order]': orderId.toString(),
        'display': 'full',
        'sort': 'date_add_DESC',
      };

      final response = await get<Map<String, dynamic>>(
        'order_histories',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_histories'] is List) {
          return (data['order_histories'] as List).cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error fetching order history for $orderId: $e');
      rethrow;
    }
  }

  /// Récupère tous les états de commande disponibles
  Future<List<OrderState>> getOrderStates({String? language}) async {
    _logger.info('Fetching all order states');

    try {
      final queryParams = <String, dynamic>{'display': 'full'};
      if (language != null) queryParams['language'] = language;

      final response = await get<Map<String, dynamic>>(
        'order_states',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_states'] is List) {
          final statesList = data['order_states'] as List;
          return statesList
              .map(
                (json) =>
                    OrderState.fromPrestaShopJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error fetching order states: $e');
      rethrow;
    }
  }
}
