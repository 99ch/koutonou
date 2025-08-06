import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/order_state_model.dart';
import '../models/order_payment_model.dart';
import '../models/order_invoice_model.dart';
import '../models/order_history_model.dart';
import '../models/order_detail_model.dart';
import '../services/order_service.dart';
import '../services/order_state_service.dart';
import '../services/order_payment_service.dart';
import '../services/order_invoice_service.dart';
import '../services/order_history_service.dart';
import '../services/order_detail_service.dart';

/// Provider principal pour la gestion de l'état des commandes
class OrderProviderNew with ChangeNotifier {
  final OrderService _orderService = OrderService();
  final OrderStateService _orderStateService = OrderStateService();
  final OrderPaymentService _orderPaymentService = OrderPaymentService();
  final OrderInvoiceService _orderInvoiceService = OrderInvoiceService();
  final OrderHistoryService _orderHistoryService = OrderHistoryService();
  final OrderDetailService _orderDetailService = OrderDetailService();

  // État des commandes
  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _errorMessage;

  // États de commande
  List<OrderState> _orderStates = [];
  bool _statesLoaded = false;

  // Données associées à la commande sélectionnée
  List<OrderPayment> _selectedOrderPayments = [];
  List<OrderInvoice> _selectedOrderInvoices = [];
  List<OrderHistory> _selectedOrderHistory = [];
  List<OrderDetail> _selectedOrderDetails = [];

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  bool _hasNextPage = true;

  // Filtres
  String? _searchQuery;
  int? _customerFilter;
  int? _stateFilter;
  String? _referenceFilter;

  // Getters
  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<OrderState> get orderStates => _orderStates;
  bool get statesLoaded => _statesLoaded;

  List<OrderPayment> get selectedOrderPayments => _selectedOrderPayments;
  List<OrderInvoice> get selectedOrderInvoices => _selectedOrderInvoices;
  List<OrderHistory> get selectedOrderHistory => _selectedOrderHistory;
  List<OrderDetail> get selectedOrderDetails => _selectedOrderDetails;

  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  bool get hasNextPage => _hasNextPage;
  String? get searchQuery => _searchQuery;
  int? get customerFilter => _customerFilter;
  int? get stateFilter => _stateFilter;
  String? get referenceFilter => _referenceFilter;

  /// Charge toutes les commandes avec pagination
  Future<void> loadOrders({bool reset = false, String? language}) async {
    if (_isLoading) return;

    if (reset) {
      _currentPage = 1;
      _orders.clear();
      _hasNextPage = true;
    }

    _setLoading(true);
    _clearError();

    try {
      Map<String, String>? filters;

      // Appliquer les filtres
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        filters = {'reference': _searchQuery!};
      }

      if (_customerFilter != null) {
        filters ??= {};
        filters['id_customer'] = _customerFilter.toString();
      }

      if (_stateFilter != null) {
        filters ??= {};
        filters['current_state'] = _stateFilter.toString();
      }

      if (_referenceFilter != null && _referenceFilter!.isNotEmpty) {
        filters ??= {};
        filters['reference'] = _referenceFilter!;
      }

      final newOrders = await _orderService.getAllOrders(
        filters: filters,
        limit: _itemsPerPage,
        offset: (_currentPage - 1) * _itemsPerPage,
        language: language,
        sort: ['id_DESC'], // Plus récentes en premier
      );

      if (reset) {
        _orders = newOrders;
      } else {
        _orders.addAll(newOrders);
      }

      _hasNextPage = newOrders.length == _itemsPerPage;
      if (_hasNextPage) _currentPage++;
    } catch (e) {
      _setError('Erreur lors du chargement des commandes: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charge plus de commandes (pagination)
  Future<void> loadMoreOrders({String? language}) async {
    if (!_hasNextPage || _isLoading) return;
    await loadOrders(reset: false, language: language);
  }

  /// Charge les états de commande
  Future<void> loadOrderStates({String? language}) async {
    if (_statesLoaded && _orderStates.isNotEmpty) return;

    try {
      _orderStates = await _orderStateService.getAllOrderStates(
        language: language,
        sort: ['name_ASC'],
      );
      _statesLoaded = true;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des états: $e');
    }
  }

  /// Charge une commande par ID avec toutes ses données associées
  Future<void> loadOrderById(int orderId, {String? language}) async {
    _setLoading(true);
    _clearError();

    try {
      // Charger la commande principale
      _selectedOrder = await _orderService.getOrderById(
        orderId,
        language: language,
      );

      if (_selectedOrder != null) {
        // Charger les données associées en parallèle
        await Future.wait([
          _loadOrderPayments(orderId),
          _loadOrderInvoices(orderId),
          _loadOrderHistory(orderId),
          _loadOrderDetails(orderId),
        ]);
      }
    } catch (e) {
      _setError('Erreur lors du chargement de la commande: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charge les paiements d'une commande
  Future<void> _loadOrderPayments(int orderId) async {
    if (_selectedOrder != null) {
      _selectedOrderPayments = await _orderPaymentService
          .getPaymentsByOrderReference(_selectedOrder!.reference ?? '');
    }
  }

  /// Charge les factures d'une commande
  Future<void> _loadOrderInvoices(int orderId) async {
    _selectedOrderInvoices = await _orderInvoiceService.getInvoicesByOrderId(
      orderId,
    );
  }

  /// Charge l'historique d'une commande
  Future<void> _loadOrderHistory(int orderId) async {
    _selectedOrderHistory = await _orderHistoryService.getHistoryByOrderId(
      orderId,
    );
  }

  /// Charge les détails d'une commande
  Future<void> _loadOrderDetails(int orderId) async {
    _selectedOrderDetails = await _orderDetailService.getDetailsByOrderId(
      orderId,
    );
  }

  /// Change l'état d'une commande
  Future<bool> changeOrderState(
    int orderId,
    int newStateId, {
    int? employeeId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final history = await _orderHistoryService.changeOrderState(
        orderId,
        newStateId,
        employeeId: employeeId,
      );

      if (history != null) {
        // Recharger la commande et son historique
        await loadOrderById(orderId);
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erreur lors du changement d\'état: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Recherche des commandes par référence
  Future<void> searchOrders(String query, {String? language}) async {
    _searchQuery = query;
    await loadOrders(reset: true, language: language);
  }

  /// Filtre les commandes par client
  Future<void> filterByCustomer(int? customerId, {String? language}) async {
    _customerFilter = customerId;
    await loadOrders(reset: true, language: language);
  }

  /// Filtre les commandes par état
  Future<void> filterByState(int? stateId, {String? language}) async {
    _stateFilter = stateId;
    await loadOrders(reset: true, language: language);
  }

  /// Filtre les commandes par référence
  Future<void> filterByReference(String? reference, {String? language}) async {
    _referenceFilter = reference;
    await loadOrders(reset: true, language: language);
  }

  /// Efface tous les filtres
  Future<void> clearFilters({String? language}) async {
    _searchQuery = null;
    _customerFilter = null;
    _stateFilter = null;
    _referenceFilter = null;
    await loadOrders(reset: true, language: language);
  }

  /// Sélectionne une commande
  void selectOrder(Order? order) {
    _selectedOrder = order;
    // Nettoyer les données associées
    _selectedOrderPayments.clear();
    _selectedOrderInvoices.clear();
    _selectedOrderHistory.clear();
    _selectedOrderDetails.clear();
    notifyListeners();
  }

  /// Rafraîchit les commandes
  Future<void> refresh({String? language}) async {
    await loadOrders(reset: true, language: language);
  }

  /// Obtient l'état d'une commande par ID
  OrderState? getOrderStateById(int stateId) {
    try {
      return _orderStates.firstWhere((state) => state.id == stateId);
    } catch (e) {
      return null;
    }
  }

  /// Obtient le nom d'un état par ID
  String getOrderStateName(int stateId) {
    final state = getOrderStateById(stateId);
    return state?.name ?? 'État inconnu';
  }

  /// Obtient la couleur d'un état par ID
  String? getOrderStateColor(int stateId) {
    final state = getOrderStateById(stateId);
    return state?.color;
  }

  // Méthodes privées pour la gestion de l'état
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Nettoie les ressources
  @override
  void dispose() {
    _orders.clear();
    _orderStates.clear();
    _selectedOrder = null;
    _selectedOrderPayments.clear();
    _selectedOrderInvoices.clear();
    _selectedOrderHistory.clear();
    _selectedOrderDetails.clear();
    super.dispose();
  }
}
