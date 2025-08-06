import 'package:koutonou/core/api/base_prestashop_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import '../models/customer_model.dart';

/// Service pour gérer les clients PrestaShop
class CustomerService extends BasePrestaShopService {
  static final CustomerService _instance = CustomerService._internal();
  factory CustomerService() => _instance;
  CustomerService._internal();

  static final AppLogger _logger = AppLogger();

  /// Récupère tous les clients
  Future<List<Customer>> getAllCustomers({
    String? display = 'full',
    Map<String, String>? filters,
    List<String>? sort,
    int? limit,
    int? offset,
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching all customers from PrestaShop API');

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
        'customers',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['customers'] is List) {
          final customersList = data['customers'] as List;
          return customersList
              .map(
                (json) =>
                    Customer.fromPrestaShopJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error fetching all customers: $e');
      rethrow;
    }
  }

  /// Récupère un client par ID
  Future<Customer?> getCustomerById(
    int customerId, {
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching customer by ID: $customerId');

    try {
      final queryParams = <String, dynamic>{'display': 'full'};

      if (language != null) queryParams['language'] = language;
      if (idShop != null) queryParams['id_shop'] = idShop.toString();

      final response = await get<Map<String, dynamic>>(
        'customers/$customerId',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['customer'] is Map<String, dynamic>) {
          return Customer.fromPrestaShopJson(
            data['customer'] as Map<String, dynamic>,
          );
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error fetching customer by ID $customerId: $e');
      rethrow;
    }
  }

  /// Recherche les clients par email
  Future<List<Customer>> searchCustomersByEmail(
    String email, {
    int? limit,
    String? language,
  }) async {
    _logger.info('Searching customers by email: $email');

    return await getAllCustomers(
      filters: {'email': '%$email%'},
      limit: limit,
      language: language,
    );
  }

  /// Recherche les clients par nom
  Future<List<Customer>> searchCustomersByName(
    String name, {
    int? limit,
    String? language,
  }) async {
    _logger.info('Searching customers by name: $name');

    try {
      final queryParams = <String, dynamic>{
        'filter[firstname]': '%$name%',
        'filter[lastname]': '%$name%',
        'display': 'full',
      };

      if (limit != null) queryParams['limit'] = limit.toString();
      if (language != null) queryParams['language'] = language;

      final response = await get<Map<String, dynamic>>(
        'customers',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['customers'] is List) {
          final customersList = data['customers'] as List;
          return customersList
              .map(
                (json) =>
                    Customer.fromPrestaShopJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error searching customers by name: $e');
      rethrow;
    }
  }

  /// Récupère les clients par groupe
  Future<List<Customer>> getCustomersByGroup(
    int groupId, {
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching customers for group: $groupId');

    return await getAllCustomers(
      filters: {'id_default_group': groupId.toString()},
      language: language,
      idShop: idShop,
    );
  }

  /// Crée un nouveau client
  Future<Customer?> createCustomer(Customer customer) async {
    _logger.info('Creating customer: ${customer.email}');

    try {
      final response = await post<Map<String, dynamic>>(
        'customers',
        data: {'customer': customer.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        _logger.info('Create customer response: $data');

        if (data['customer'] is Map<String, dynamic>) {
          final customerData = data['customer'] as Map<String, dynamic>;
          final customerId = int.tryParse(
            customerData['id']?.toString() ?? '0',
          );

          if (customerId != null && customerId > 0) {
            _logger.info(
              'Customer created with ID: $customerId, fetching full details...',
            );
            return await getCustomerById(customerId);
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error creating customer: $e');
      rethrow;
    }
  }

  /// Met à jour un client existant
  Future<Customer?> updateCustomer(Customer customer) async {
    if (customer.id == null) {
      throw ArgumentError('Customer ID is required for update');
    }

    _logger.info('Updating customer: ${customer.id}');

    try {
      final response = await put<Map<String, dynamic>>(
        'customers/${customer.id}',
        data: {'customer': customer.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        _logger.info('Update customer response: $data');

        if (data['customer'] is Map<String, dynamic>) {
          final customerData = data['customer'] as Map<String, dynamic>;
          final customerId = int.tryParse(
            customerData['id']?.toString() ?? '0',
          );

          if (customerId != null && customerId > 0) {
            _logger.info(
              'Customer updated with ID: $customerId, fetching full details...',
            );
            return await getCustomerById(customerId);
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error updating customer ${customer.id}: $e');
      rethrow;
    }
  }

  /// Supprime un client
  Future<bool> deleteCustomer(int customerId) async {
    _logger.info('Deleting customer: $customerId');

    try {
      final response = await delete('customers/$customerId');
      return response.success;
    } catch (e) {
      _logger.error('Error deleting customer $customerId: $e');
      rethrow;
    }
  }

  /// Récupère les clients actifs
  Future<List<Customer>> getActiveCustomers({
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching active customers');

    return await getAllCustomers(
      filters: {'active': '1'},
      language: language,
      idShop: idShop,
    );
  }

  /// Récupère les clients inactifs
  Future<List<Customer>> getInactiveCustomers({
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching inactive customers');

    return await getAllCustomers(
      filters: {'active': '0'},
      language: language,
      idShop: idShop,
    );
  }

  /// Récupère les clients abonnés à la newsletter
  Future<List<Customer>> getNewsletterSubscribers({
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching newsletter subscribers');

    return await getAllCustomers(
      filters: {'newsletter': '1'},
      language: language,
      idShop: idShop,
    );
  }

  /// Récupère les comptes invités
  Future<List<Customer>> getGuestAccounts({
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching guest accounts');

    return await getAllCustomers(
      filters: {'is_guest': '1'},
      language: language,
      idShop: idShop,
    );
  }

  /// Récupère les clients avec entreprise
  Future<List<Customer>> getBusinessCustomers({
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching business customers');

    final allCustomers = await getAllCustomers(
      language: language,
      idShop: idShop,
    );

    return allCustomers.where((customer) => customer.hasCompany).toList();
  }

  /// Active un client
  Future<bool> activateCustomer(int customerId) async {
    _logger.info('Activating customer: $customerId');

    try {
      final customer = await getCustomerById(customerId);
      if (customer == null) return false;

      final updatedCustomer = Customer(
        id: customer.id,
        idDefaultGroup: customer.idDefaultGroup,
        idLang: customer.idLang,
        passwd: customer.passwd,
        lastname: customer.lastname,
        firstname: customer.firstname,
        email: customer.email,
        active: true,
        deleted: customer.deleted,
        newsletter: customer.newsletter,
        optin: customer.optin,
        isGuest: customer.isGuest,
        idGender: customer.idGender,
        birthday: customer.birthday,
        website: customer.website,
        company: customer.company,
        siret: customer.siret,
        ape: customer.ape,
        outstandingAllowAmount: customer.outstandingAllowAmount,
        showPublicPrices: customer.showPublicPrices,
        idRisk: customer.idRisk,
        maxPaymentDays: customer.maxPaymentDays,
        note: customer.note,
        idShop: customer.idShop,
        idShopGroup: customer.idShopGroup,
        groupIds: customer.groupIds,
      );

      final result = await updateCustomer(updatedCustomer);
      return result != null;
    } catch (e) {
      _logger.error('Error activating customer $customerId: $e');
      rethrow;
    }
  }

  /// Désactive un client
  Future<bool> deactivateCustomer(int customerId) async {
    _logger.info('Deactivating customer: $customerId');

    try {
      final customer = await getCustomerById(customerId);
      if (customer == null) return false;

      final updatedCustomer = Customer(
        id: customer.id,
        idDefaultGroup: customer.idDefaultGroup,
        idLang: customer.idLang,
        passwd: customer.passwd,
        lastname: customer.lastname,
        firstname: customer.firstname,
        email: customer.email,
        active: false,
        deleted: customer.deleted,
        newsletter: customer.newsletter,
        optin: customer.optin,
        isGuest: customer.isGuest,
        idGender: customer.idGender,
        birthday: customer.birthday,
        website: customer.website,
        company: customer.company,
        siret: customer.siret,
        ape: customer.ape,
        outstandingAllowAmount: customer.outstandingAllowAmount,
        showPublicPrices: customer.showPublicPrices,
        idRisk: customer.idRisk,
        maxPaymentDays: customer.maxPaymentDays,
        note: customer.note,
        idShop: customer.idShop,
        idShopGroup: customer.idShopGroup,
        groupIds: customer.groupIds,
      );

      final result = await updateCustomer(updatedCustomer);
      return result != null;
    } catch (e) {
      _logger.error('Error deactivating customer $customerId: $e');
      rethrow;
    }
  }
}
