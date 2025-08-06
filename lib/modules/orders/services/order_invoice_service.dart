import 'package:koutonou/core/api/base_prestashop_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import '../models/order_invoice_model.dart';

/// Service pour la gestion des factures de commande
class OrderInvoiceService extends BasePrestaShopService {
  static final OrderInvoiceService _instance = OrderInvoiceService._internal();
  factory OrderInvoiceService() => _instance;
  OrderInvoiceService._internal();

  static final AppLogger _logger = AppLogger();

  /// Récupère toutes les factures de commande
  Future<List<OrderInvoice>> getAllOrderInvoices({
    String? display = 'full',
    Map<String, String>? filters,
    List<String>? sort,
    int? limit,
    int? offset,
  }) async {
    _logger.info('Fetching all order invoices from PrestaShop API');

    try {
      final queryParams = <String, dynamic>{};
      queryParams['display'] = display ?? 'full';
      if (filters != null) queryParams.addAll(filters);
      if (sort != null) queryParams['sort'] = sort.join(',');
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final response = await get<Map<String, dynamic>>(
        'order_invoices',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_invoices'] is List) {
          final invoicesList = data['order_invoices'] as List;
          return invoicesList
              .map(
                (json) => OrderInvoice.fromPrestaShopJson(
                  json as Map<String, dynamic>,
                ),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error fetching all order invoices: $e');
      rethrow;
    }
  }

  /// Récupère une facture par ID
  Future<OrderInvoice?> getOrderInvoiceById(int invoiceId) async {
    _logger.info('Fetching order invoice by ID: $invoiceId');

    try {
      final response = await get<Map<String, dynamic>>(
        'order_invoices/$invoiceId',
        queryParameters: {'display': 'full'},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_invoice'] is Map<String, dynamic>) {
          return OrderInvoice.fromPrestaShopJson(
            data['order_invoice'] as Map<String, dynamic>,
          );
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error fetching order invoice by ID $invoiceId: $e');
      rethrow;
    }
  }

  /// Récupère les factures d'une commande spécifique
  Future<List<OrderInvoice>> getInvoicesByOrderId(int orderId) async {
    _logger.info('Fetching invoices for order ID: $orderId');

    return await getAllOrderInvoices(filters: {'id_order': orderId.toString()});
  }

  /// Crée une nouvelle facture
  Future<OrderInvoice?> createOrderInvoice(OrderInvoice invoice) async {
    _logger.info('Creating order invoice for order: ${invoice.idOrder}');

    try {
      final response = await post<Map<String, dynamic>>(
        'order_invoices',
        data: {'order_invoice': invoice.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['order_invoice'] is Map<String, dynamic>) {
          final invoiceData = data['order_invoice'] as Map<String, dynamic>;
          final invoiceId = int.tryParse(invoiceData['id']?.toString() ?? '0');

          if (invoiceId != null && invoiceId > 0) {
            return await getOrderInvoiceById(invoiceId);
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error creating order invoice: $e');
      rethrow;
    }
  }

  /// Met à jour une facture existante
  Future<OrderInvoice?> updateOrderInvoice(OrderInvoice invoice) async {
    if (invoice.id == null) {
      throw ArgumentError('OrderInvoice ID is required for update');
    }

    _logger.info('Updating order invoice: ${invoice.id}');

    try {
      final response = await put<Map<String, dynamic>>(
        'order_invoices/${invoice.id}',
        data: {'order_invoice': invoice.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        return await getOrderInvoiceById(invoice.id!);
      }

      return null;
    } catch (e) {
      _logger.error('Error updating order invoice ${invoice.id}: $e');
      rethrow;
    }
  }

  /// Supprime une facture
  Future<bool> deleteOrderInvoice(int invoiceId) async {
    _logger.info('Deleting order invoice: $invoiceId');

    try {
      final response = await delete('order_invoices/$invoiceId');
      return response.success;
    } catch (e) {
      _logger.error('Error deleting order invoice $invoiceId: $e');
      rethrow;
    }
  }
}
