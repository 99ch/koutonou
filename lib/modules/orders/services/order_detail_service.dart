import 'package:koutonou/core/api/base_prestashop_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import '../models/order_detail_model.dart';

/// Service pour la gestion des détails de commande
class OrderDetailService extends BasePrestaShopService {
  static final OrderDetailService _instance = OrderDetailService._internal();
  factory OrderDetailService() => _instance;
  OrderDetailService._internal();

  static final AppLogger _logger = AppLogger();

  /// Récupère tous les détails de commande
  Future<List<OrderDetail>> getAllOrderDetails({
    String? display = 'full',
    Map<String, String>? filters,
    List<String>? sort,
    int? limit,
    int? offset,
  }) async {
    _logger.info('Fetching all order details from PrestaShop API');

    try {
      final queryParams = <String, dynamic>{};
      queryParams['display'] = display ?? 'full';
      if (filters != null) queryParams.addAll(filters);
      if (sort != null) queryParams['sort'] = sort.join(',');
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

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
      _logger.error('Error fetching all order details: $e');
      rethrow;
    }
  }

  /// Récupère un détail par ID
  Future<OrderDetail?> getOrderDetailById(int detailId) async {
    _logger.info('Fetching order detail by ID: $detailId');

    try {
      final response = await get<Map<String, dynamic>>(
        'order_details/$detailId',
        queryParameters: {'display': 'full'},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_detail'] is Map<String, dynamic>) {
          return OrderDetail.fromPrestaShopJson(
            data['order_detail'] as Map<String, dynamic>,
          );
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error fetching order detail by ID $detailId: $e');
      rethrow;
    }
  }

  /// Récupère les détails d'une commande spécifique
  Future<List<OrderDetail>> getDetailsByOrderId(int orderId) async {
    _logger.info('Fetching details for order ID: $orderId');

    return await getAllOrderDetails(filters: {'id_order': orderId.toString()});
  }

  /// Récupère les détails par produit
  Future<List<OrderDetail>> getDetailsByProductId(int productId) async {
    _logger.info('Fetching details for product ID: $productId');

    return await getAllOrderDetails(
      filters: {'product_id': productId.toString()},
    );
  }

  /// Crée un nouveau détail de commande
  Future<OrderDetail?> createOrderDetail(OrderDetail detail) async {
    _logger.info('Creating order detail for order: ${detail.idOrder}');

    try {
      final response = await post<Map<String, dynamic>>(
        'order_details',
        data: {'order_detail': detail.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_detail'] is Map<String, dynamic>) {
          final detailData = data['order_detail'] as Map<String, dynamic>;
          final detailId = int.tryParse(detailData['id']?.toString() ?? '0');

          if (detailId != null && detailId > 0) {
            return await getOrderDetailById(detailId);
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error creating order detail: $e');
      rethrow;
    }
  }

  /// Met à jour un détail existant
  Future<OrderDetail?> updateOrderDetail(OrderDetail detail) async {
    if (detail.id == null) {
      throw ArgumentError('OrderDetail ID is required for update');
    }

    _logger.info('Updating order detail: ${detail.id}');

    try {
      final response = await put<Map<String, dynamic>>(
        'order_details/${detail.id}',
        data: {'order_detail': detail.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        return await getOrderDetailById(detail.id!);
      }

      return null;
    } catch (e) {
      _logger.error('Error updating order detail ${detail.id}: $e');
      rethrow;
    }
  }

  /// Supprime un détail de commande
  Future<bool> deleteOrderDetail(int detailId) async {
    _logger.info('Deleting order detail: $detailId');

    try {
      final response = await delete('order_details/$detailId');
      return response.success;
    } catch (e) {
      _logger.error('Error deleting order detail $detailId: $e');
      rethrow;
    }
  }

  /// Met à jour la quantité d'un détail
  Future<bool> updateQuantity(int detailId, int newQuantity) async {
    _logger.info('Updating quantity for detail $detailId to $newQuantity');

    try {
      final response = await put<Map<String, dynamic>>(
        'order_details/$detailId',
        data: {
          'order_detail': {'product_quantity': newQuantity.toString()},
        },
      );

      return response.success;
    } catch (e) {
      _logger.error('Error updating quantity for detail $detailId: $e');
      rethrow;
    }
  }
}
