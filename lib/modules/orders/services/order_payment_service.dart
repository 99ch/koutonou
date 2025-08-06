import 'package:koutonou/core/api/base_prestashop_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import '../models/order_payment_model.dart';

/// Service pour la gestion des paiements de commande
class OrderPaymentService extends BasePrestaShopService {
  static final OrderPaymentService _instance = OrderPaymentService._internal();
  factory OrderPaymentService() => _instance;
  OrderPaymentService._internal();

  static final AppLogger _logger = AppLogger();

  /// Récupère tous les paiements de commande
  Future<List<OrderPayment>> getAllOrderPayments({
    String? display = 'full',
    Map<String, String>? filters,
    List<String>? sort,
    int? limit,
    int? offset,
  }) async {
    _logger.info('Fetching all order payments from PrestaShop API');

    try {
      final queryParams = <String, dynamic>{};
      queryParams['display'] = display ?? 'full';
      if (filters != null) queryParams.addAll(filters);
      if (sort != null) queryParams['sort'] = sort.join(',');
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final response = await get<Map<String, dynamic>>(
        'order_payments',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_payments'] is List) {
          final paymentsList = data['order_payments'] as List;
          return paymentsList
              .map(
                (json) => OrderPayment.fromPrestaShopJson(
                  json as Map<String, dynamic>,
                ),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error fetching all order payments: $e');
      rethrow;
    }
  }

  /// Récupère un paiement par ID
  Future<OrderPayment?> getOrderPaymentById(int paymentId) async {
    _logger.info('Fetching order payment by ID: $paymentId');

    try {
      final response = await get<Map<String, dynamic>>(
        'order_payments/$paymentId',
        queryParameters: {'display': 'full'},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_payment'] is Map<String, dynamic>) {
          return OrderPayment.fromPrestaShopJson(
            data['order_payment'] as Map<String, dynamic>,
          );
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error fetching order payment by ID $paymentId: $e');
      rethrow;
    }
  }

  /// Récupère les paiements d'une commande spécifique
  Future<List<OrderPayment>> getPaymentsByOrderReference(
    String orderReference,
  ) async {
    _logger.info('Fetching payments for order reference: $orderReference');

    return await getAllOrderPayments(
      filters: {'order_reference': orderReference},
    );
  }

  /// Crée un nouveau paiement
  Future<OrderPayment?> createOrderPayment(OrderPayment payment) async {
    _logger.info('Creating order payment for amount: ${payment.amount}');

    try {
      final response = await post<Map<String, dynamic>>(
        'order_payments',
        data: {'order_payment': payment.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_payment'] is Map<String, dynamic>) {
          final paymentData = data['order_payment'] as Map<String, dynamic>;
          final paymentId = int.tryParse(paymentData['id']?.toString() ?? '0');

          if (paymentId != null && paymentId > 0) {
            return await getOrderPaymentById(paymentId);
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error creating order payment: $e');
      rethrow;
    }
  }

  /// Met à jour un paiement existant
  Future<OrderPayment?> updateOrderPayment(OrderPayment payment) async {
    if (payment.id == null) {
      throw ArgumentError('OrderPayment ID is required for update');
    }

    _logger.info('Updating order payment: ${payment.id}');

    try {
      final response = await put<Map<String, dynamic>>(
        'order_payments/${payment.id}',
        data: {'order_payment': payment.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        return await getOrderPaymentById(payment.id!);
      }

      return null;
    } catch (e) {
      _logger.error('Error updating order payment ${payment.id}: $e');
      rethrow;
    }
  }

  /// Supprime un paiement
  Future<bool> deleteOrderPayment(int paymentId) async {
    _logger.info('Deleting order payment: $paymentId');

    try {
      final response = await delete('order_payments/$paymentId');
      return response.success;
    } catch (e) {
      _logger.error('Error deleting order payment $paymentId: $e');
      rethrow;
    }
  }
}
