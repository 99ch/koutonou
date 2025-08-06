import 'package:koutonou/core/api/base_prestashop_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import '../models/address_model.dart';

/// Service pour gérer les adresses PrestaShop
class AddressService extends BasePrestaShopService {
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;
  AddressService._internal();

  static final AppLogger _logger = AppLogger();

  /// Récupère toutes les adresses
  Future<List<Address>> getAllAddresses({
    String? display = 'full',
    Map<String, String>? filters,
    int? limit,
    int? offset,
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching all addresses from PrestaShop API');

    try {
      final queryParams = <String, dynamic>{};
      queryParams['display'] = display ?? 'full';

      if (filters != null) queryParams.addAll(filters);
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (language != null) queryParams['language'] = language;
      if (idShop != null) queryParams['id_shop'] = idShop.toString();

      final response = await get<Map<String, dynamic>>(
        'addresses',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['addresses'] is List) {
          final addressesList = data['addresses'] as List;
          return addressesList
              .map(
                (json) =>
                    Address.fromPrestaShopJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error fetching all addresses: $e');
      rethrow;
    }
  }

  /// Récupère une adresse par ID
  Future<Address?> getAddressById(int addressId) async {
    _logger.info('Fetching address by ID: $addressId');

    try {
      final response = await get<Map<String, dynamic>>(
        'addresses/$addressId',
        queryParameters: {'display': 'full'},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['address'] is Map<String, dynamic>) {
          return Address.fromPrestaShopJson(
            data['address'] as Map<String, dynamic>,
          );
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error fetching address by ID $addressId: $e');
      rethrow;
    }
  }

  /// Récupère les adresses d'un client
  Future<List<Address>> getAddressesByCustomer(int customerId) async {
    _logger.info('Fetching addresses for customer: $customerId');

    return await getAllAddresses(
      filters: {'id_customer': customerId.toString()},
    );
  }

  /// Crée une nouvelle adresse
  Future<Address?> createAddress(Address address) async {
    _logger.info('Creating address for: ${address.fullName}');

    try {
      final response = await post<Map<String, dynamic>>(
        'addresses',
        data: {'address': address.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['address'] is Map<String, dynamic>) {
          final addressData = data['address'] as Map<String, dynamic>;
          final addressId = int.tryParse(addressData['id']?.toString() ?? '0');

          if (addressId != null && addressId > 0) {
            return await getAddressById(addressId);
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error creating address: $e');
      rethrow;
    }
  }

  /// Met à jour une adresse
  Future<Address?> updateAddress(Address address) async {
    if (address.id == null) {
      throw ArgumentError('Address ID is required for update');
    }

    _logger.info('Updating address: ${address.id}');

    try {
      final response = await put<Map<String, dynamic>>(
        'addresses/${address.id}',
        data: {'address': address.toPrestaShopJson()},
      );

      if (response.success) {
        return await getAddressById(address.id!);
      }

      return null;
    } catch (e) {
      _logger.error('Error updating address ${address.id}: $e');
      rethrow;
    }
  }

  /// Supprime une adresse
  Future<bool> deleteAddress(int addressId) async {
    _logger.info('Deleting address: $addressId');

    try {
      final response = await delete('addresses/$addressId');
      return response.success;
    } catch (e) {
      _logger.error('Error deleting address $addressId: $e');
      rethrow;
    }
  }
}
