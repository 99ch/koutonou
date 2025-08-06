import 'package:flutter/foundation.dart';
import 'package:koutonou/core/utils/logger.dart';
import '../models/customer_model.dart';
import '../models/address_model.dart';
import '../models/group_model.dart';
import '../services/customer_service.dart';
import '../services/address_service.dart';
import '../services/group_service.dart';

/// Provider pour gérer l'état des clients
class CustomerProvider with ChangeNotifier {
  static final AppLogger _logger = AppLogger();

  final CustomerService _customerService = CustomerService();
  final AddressService _addressService = AddressService();
  final GroupService _groupService = GroupService();

  // État des clients
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  bool _isLoadingCustomers = false;
  String? _customersError;

  // État des adresses
  List<Address> _addresses = [];
  List<Address> _customerAddresses = [];
  bool _isLoadingAddresses = false;
  String? _addressesError;

  // État des groupes
  List<Group> _groups = [];
  bool _isLoadingGroups = false;
  String? _groupsError;

  // Getters
  List<Customer> get customers => _customers;
  Customer? get selectedCustomer => _selectedCustomer;
  bool get isLoadingCustomers => _isLoadingCustomers;
  String? get customersError => _customersError;

  List<Address> get addresses => _addresses;
  List<Address> get customerAddresses => _customerAddresses;
  bool get isLoadingAddresses => _isLoadingAddresses;
  String? get addressesError => _addressesError;

  List<Group> get groups => _groups;
  bool get isLoadingGroups => _isLoadingGroups;
  String? get groupsError => _groupsError;

  // Getters calculés
  List<Customer> get activeCustomers =>
      _customers.where((c) => c.active).toList();
  List<Customer> get inactiveCustomers =>
      _customers.where((c) => !c.active).toList();
  List<Customer> get newsletterSubscribers =>
      _customers.where((c) => c.newsletter).toList();
  List<Customer> get businessCustomers =>
      _customers.where((c) => c.hasCompany).toList();
  List<Customer> get guestAccounts =>
      _customers.where((c) => c.isGuest).toList();

  // Méthodes pour les clients
  Future<void> loadCustomers({
    Map<String, String>? filters,
    int? limit,
    String? language,
  }) async {
    _isLoadingCustomers = true;
    _customersError = null;
    notifyListeners();

    try {
      _customers = await _customerService.getAllCustomers(
        filters: filters,
        limit: limit,
        language: language,
      );
      _logger.info('Loaded ${_customers.length} customers');
    } catch (e) {
      _customersError = e.toString();
      _logger.error('Error loading customers: $e');
    } finally {
      _isLoadingCustomers = false;
      notifyListeners();
    }
  }

  Future<void> loadCustomerById(int customerId, {String? language}) async {
    try {
      _selectedCustomer = await _customerService.getCustomerById(
        customerId,
        language: language,
      );
      notifyListeners();
    } catch (e) {
      _logger.error('Error loading customer $customerId: $e');
      rethrow;
    }
  }

  Future<void> searchCustomers(String query, {String? language}) async {
    _isLoadingCustomers = true;
    _customersError = null;
    notifyListeners();

    try {
      // Recherche par email et nom
      final emailResults = await _customerService.searchCustomersByEmail(
        query,
        language: language,
      );
      final nameResults = await _customerService.searchCustomersByName(
        query,
        language: language,
      );

      // Fusion des résultats sans doublons
      final allResults = <Customer>[];
      final seenIds = <int>{};

      for (final customer in [...emailResults, ...nameResults]) {
        if (customer.id != null && !seenIds.contains(customer.id)) {
          allResults.add(customer);
          seenIds.add(customer.id!);
        }
      }

      _customers = allResults;
      _logger.info('Found ${_customers.length} customers matching "$query"');
    } catch (e) {
      _customersError = e.toString();
      _logger.error('Error searching customers: $e');
    } finally {
      _isLoadingCustomers = false;
      notifyListeners();
    }
  }

  Future<bool> createCustomer(Customer customer) async {
    try {
      final newCustomer = await _customerService.createCustomer(customer);
      if (newCustomer != null) {
        _customers.insert(0, newCustomer);
        notifyListeners();
        _logger.info('Customer created successfully: ${newCustomer.id}');
        return true;
      }
      return false;
    } catch (e) {
      _logger.error('Error creating customer: $e');
      rethrow;
    }
  }

  Future<bool> updateCustomer(Customer customer) async {
    try {
      final updatedCustomer = await _customerService.updateCustomer(customer);
      if (updatedCustomer != null) {
        final index = _customers.indexWhere((c) => c.id == customer.id);
        if (index != -1) {
          _customers[index] = updatedCustomer;
        }
        if (_selectedCustomer?.id == customer.id) {
          _selectedCustomer = updatedCustomer;
        }
        notifyListeners();
        _logger.info('Customer updated successfully: ${updatedCustomer.id}');
        return true;
      }
      return false;
    } catch (e) {
      _logger.error('Error updating customer: $e');
      rethrow;
    }
  }

  Future<bool> deleteCustomer(int customerId) async {
    try {
      final success = await _customerService.deleteCustomer(customerId);
      if (success) {
        _customers.removeWhere((c) => c.id == customerId);
        if (_selectedCustomer?.id == customerId) {
          _selectedCustomer = null;
        }
        notifyListeners();
        _logger.info('Customer deleted successfully: $customerId');
      }
      return success;
    } catch (e) {
      _logger.error('Error deleting customer: $e');
      rethrow;
    }
  }

  Future<bool> activateCustomer(int customerId) async {
    try {
      final success = await _customerService.activateCustomer(customerId);
      if (success) {
        await loadCustomerById(customerId);
        final index = _customers.indexWhere((c) => c.id == customerId);
        if (index != -1) {
          _customers[index] = _selectedCustomer!;
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _logger.error('Error activating customer: $e');
      rethrow;
    }
  }

  Future<bool> deactivateCustomer(int customerId) async {
    try {
      final success = await _customerService.deactivateCustomer(customerId);
      if (success) {
        await loadCustomerById(customerId);
        final index = _customers.indexWhere((c) => c.id == customerId);
        if (index != -1) {
          _customers[index] = _selectedCustomer!;
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _logger.error('Error deactivating customer: $e');
      rethrow;
    }
  }

  // Méthodes pour les adresses
  Future<void> loadAddresses() async {
    _isLoadingAddresses = true;
    _addressesError = null;
    notifyListeners();

    try {
      _addresses = await _addressService.getAllAddresses();
      _logger.info('Loaded ${_addresses.length} addresses');
    } catch (e) {
      _addressesError = e.toString();
      _logger.error('Error loading addresses: $e');
    } finally {
      _isLoadingAddresses = false;
      notifyListeners();
    }
  }

  Future<void> loadCustomerAddresses(int customerId) async {
    _isLoadingAddresses = true;
    _addressesError = null;
    notifyListeners();

    try {
      _customerAddresses = await _addressService.getAddressesByCustomer(
        customerId,
      );
      _logger.info(
        'Loaded ${_customerAddresses.length} addresses for customer $customerId',
      );
    } catch (e) {
      _addressesError = e.toString();
      _logger.error('Error loading customer addresses: $e');
    } finally {
      _isLoadingAddresses = false;
      notifyListeners();
    }
  }

  Future<bool> createAddress(Address address) async {
    try {
      final newAddress = await _addressService.createAddress(address);
      if (newAddress != null) {
        _addresses.insert(0, newAddress);
        if (address.idCustomer != null) {
          _customerAddresses.insert(0, newAddress);
        }
        notifyListeners();
        _logger.info('Address created successfully: ${newAddress.id}');
        return true;
      }
      return false;
    } catch (e) {
      _logger.error('Error creating address: $e');
      rethrow;
    }
  }

  Future<bool> updateAddress(Address address) async {
    try {
      final updatedAddress = await _addressService.updateAddress(address);
      if (updatedAddress != null) {
        final index = _addresses.indexWhere((a) => a.id == address.id);
        if (index != -1) {
          _addresses[index] = updatedAddress;
        }
        final customerIndex = _customerAddresses.indexWhere(
          (a) => a.id == address.id,
        );
        if (customerIndex != -1) {
          _customerAddresses[customerIndex] = updatedAddress;
        }
        notifyListeners();
        _logger.info('Address updated successfully: ${updatedAddress.id}');
        return true;
      }
      return false;
    } catch (e) {
      _logger.error('Error updating address: $e');
      rethrow;
    }
  }

  Future<bool> deleteAddress(int addressId) async {
    try {
      final success = await _addressService.deleteAddress(addressId);
      if (success) {
        _addresses.removeWhere((a) => a.id == addressId);
        _customerAddresses.removeWhere((a) => a.id == addressId);
        notifyListeners();
        _logger.info('Address deleted successfully: $addressId');
      }
      return success;
    } catch (e) {
      _logger.error('Error deleting address: $e');
      rethrow;
    }
  }

  // Méthodes pour les groupes
  Future<void> loadGroups({String? language}) async {
    _isLoadingGroups = true;
    _groupsError = null;
    notifyListeners();

    try {
      _groups = await _groupService.getAllGroups(language: language);
      _logger.info('Loaded ${_groups.length} groups');
    } catch (e) {
      _groupsError = e.toString();
      _logger.error('Error loading groups: $e');
    } finally {
      _isLoadingGroups = false;
      notifyListeners();
    }
  }

  Future<bool> createGroup(Group group) async {
    try {
      final newGroup = await _groupService.createGroup(group);
      if (newGroup != null) {
        _groups.insert(0, newGroup);
        notifyListeners();
        _logger.info('Group created successfully: ${newGroup.id}');
        return true;
      }
      return false;
    } catch (e) {
      _logger.error('Error creating group: $e');
      rethrow;
    }
  }

  Future<bool> updateGroup(Group group) async {
    try {
      final updatedGroup = await _groupService.updateGroup(group);
      if (updatedGroup != null) {
        final index = _groups.indexWhere((g) => g.id == group.id);
        if (index != -1) {
          _groups[index] = updatedGroup;
        }
        notifyListeners();
        _logger.info('Group updated successfully: ${updatedGroup.id}');
        return true;
      }
      return false;
    } catch (e) {
      _logger.error('Error updating group: $e');
      rethrow;
    }
  }

  Future<bool> deleteGroup(int groupId) async {
    try {
      final success = await _groupService.deleteGroup(groupId);
      if (success) {
        _groups.removeWhere((g) => g.id == groupId);
        notifyListeners();
        _logger.info('Group deleted successfully: $groupId');
      }
      return success;
    } catch (e) {
      _logger.error('Error deleting group: $e');
      rethrow;
    }
  }

  // Méthodes utilitaires
  void clearError() {
    _customersError = null;
    _addressesError = null;
    _groupsError = null;
    notifyListeners();
  }

  void selectCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCustomer = null;
    notifyListeners();
  }
}
