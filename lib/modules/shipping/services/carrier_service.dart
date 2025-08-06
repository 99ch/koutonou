import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/base_response.dart';
import '../models/carrier_model.dart';

class CarrierService {
  final ApiClient _apiClient;

  CarrierService(this._apiClient);

  /// Get all carriers
  Future<BaseResponse<List<Carrier>>> getCarriers({
    String? display,
    int? limit,
    Map<String, String>? filters,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (display != null) queryParams['display'] = display;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (filters != null) {
        filters.forEach((key, value) {
          queryParams['filter[$key]'] = value;
        });
      }

      final response = await _apiClient.get(
        '/carriers',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<Carrier> carriers = [];

        if (response.data['carriers'] != null) {
          final carriersData = response.data['carriers'];
          if (carriersData is List) {
            for (final carrierData in carriersData) {
              if (carrierData is Map<String, dynamic>) {
                carriers.add(Carrier.fromJson(carrierData));
              }
            }
          } else if (carriersData is Map<String, dynamic>) {
            if (carriersData['carrier'] != null) {
              final carrierList = carriersData['carrier'];
              if (carrierList is List) {
                for (final carrierData in carrierList) {
                  carriers.add(Carrier.fromJson(carrierData));
                }
              } else {
                carriers.add(Carrier.fromJson(carrierList));
              }
            }
          }
        }

        return BaseResponse.success(data: carriers);
      } else {
        return BaseResponse.error(
          message: 'Failed to load carriers: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error loading carriers: $e');
    }
  }

  /// Get carrier by ID
  Future<BaseResponse<Carrier>> getCarrier(int id, {String? display}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (display != null) queryParams['display'] = display;

      final response = await _apiClient.get(
        '/carriers/$id',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final carrierData = response.data['carrier'] ?? response.data;
        final carrier = Carrier.fromJson(carrierData);
        return BaseResponse.success(data: carrier);
      } else {
        return BaseResponse.error(message: 'Carrier not found');
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error loading carrier: $e');
    }
  }

  /// Create a new carrier
  Future<BaseResponse<Carrier>> createCarrier(Carrier carrier) async {
    try {
      final response = await _apiClient.post(
        '/carriers',
        data: carrier.toXml(),
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      if (response.statusCode == 201 && response.data != null) {
        final carrierData = response.data['carrier'] ?? response.data;
        final createdCarrier = Carrier.fromJson(carrierData);
        return BaseResponse.success(data: createdCarrier);
      } else {
        return BaseResponse.error(
          message: 'Failed to create carrier: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error creating carrier: $e');
    }
  }

  /// Update an existing carrier
  Future<BaseResponse<Carrier>> updateCarrier(Carrier carrier) async {
    try {
      if (carrier.id == null) {
        return BaseResponse.error(message: 'Carrier ID is required for update');
      }

      final response = await _apiClient.put(
        '/carriers/${carrier.id}',
        data: carrier.toXml(),
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final carrierData = response.data['carrier'] ?? response.data;
        final updatedCarrier = Carrier.fromJson(carrierData);
        return BaseResponse.success(data: updatedCarrier);
      } else {
        return BaseResponse.error(
          message: 'Failed to update carrier: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error updating carrier: $e');
    }
  }

  /// Delete a carrier
  Future<BaseResponse<void>> deleteCarrier(int id) async {
    try {
      final response = await _apiClient.delete('/carriers/$id');

      if (response.statusCode == 200) {
        return BaseResponse.success(data: null);
      } else {
        return BaseResponse.error(
          message: 'Failed to delete carrier: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error deleting carrier: $e');
    }
  }

  /// Get active carriers
  Future<BaseResponse<List<Carrier>>> getActiveCarriers() async {
    return getCarriers(filters: {'active': '1'});
  }

  /// Get free carriers
  Future<BaseResponse<List<Carrier>>> getFreeCarriers() async {
    return getCarriers(filters: {'is_free': '1'});
  }

  /// Get carriers by shipping method
  Future<BaseResponse<List<Carrier>>> getCarriersByShippingMethod(
    int method,
  ) async {
    return getCarriers(filters: {'shipping_method': method.toString()});
  }

  /// Search carriers by name
  Future<BaseResponse<List<Carrier>>> searchCarriersByName(String name) async {
    return getCarriers(filters: {'name': '%$name%'});
  }
}
