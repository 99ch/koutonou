import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/base_response.dart';
import '../models/delivery_model.dart';

class DeliveryService {
  final ApiClient _apiClient;

  DeliveryService(this._apiClient);

  /// Get all deliveries
  Future<BaseResponse<List<Delivery>>> getDeliveries({
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
        '/deliveries',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<Delivery> deliveries = [];

        if (response.data['deliveries'] != null) {
          final deliveriesData = response.data['deliveries'];
          if (deliveriesData is List) {
            for (final deliveryData in deliveriesData) {
              if (deliveryData is Map<String, dynamic>) {
                deliveries.add(Delivery.fromJson(deliveryData));
              }
            }
          } else if (deliveriesData is Map<String, dynamic>) {
            if (deliveriesData['delivery'] != null) {
              final deliveryList = deliveriesData['delivery'];
              if (deliveryList is List) {
                for (final deliveryData in deliveryList) {
                  deliveries.add(Delivery.fromJson(deliveryData));
                }
              } else {
                deliveries.add(Delivery.fromJson(deliveryList));
              }
            }
          }
        }

        return BaseResponse.success(data: deliveries);
      } else {
        return BaseResponse.error(
          message: 'Failed to load deliveries: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error loading deliveries: $e');
    }
  }

  /// Get delivery by ID
  Future<BaseResponse<Delivery>> getDelivery(int id) async {
    try {
      final response = await _apiClient.get('/deliveries/$id');

      if (response.statusCode == 200 && response.data != null) {
        final deliveryData = response.data['delivery'] ?? response.data;
        final delivery = Delivery.fromJson(deliveryData);
        return BaseResponse.success(data: delivery);
      } else {
        return BaseResponse.error(message: 'Delivery not found');
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error loading delivery: $e');
    }
  }

  /// Create a new delivery
  Future<BaseResponse<Delivery>> createDelivery(Delivery delivery) async {
    try {
      final response = await _apiClient.post(
        '/deliveries',
        data: delivery.toXml(),
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      if (response.statusCode == 201 && response.data != null) {
        final deliveryData = response.data['delivery'] ?? response.data;
        final createdDelivery = Delivery.fromJson(deliveryData);
        return BaseResponse.success(data: createdDelivery);
      } else {
        return BaseResponse.error(
          message: 'Failed to create delivery: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error creating delivery: $e');
    }
  }

  /// Update an existing delivery
  Future<BaseResponse<Delivery>> updateDelivery(Delivery delivery) async {
    try {
      if (delivery.id == null) {
        return BaseResponse.error(
          message: 'Delivery ID is required for update',
        );
      }

      final response = await _apiClient.put(
        '/deliveries/${delivery.id}',
        data: delivery.toXml(),
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final deliveryData = response.data['delivery'] ?? response.data;
        final updatedDelivery = Delivery.fromJson(deliveryData);
        return BaseResponse.success(data: updatedDelivery);
      } else {
        return BaseResponse.error(
          message: 'Failed to update delivery: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error updating delivery: $e');
    }
  }

  /// Delete a delivery
  Future<BaseResponse<void>> deleteDelivery(int id) async {
    try {
      final response = await _apiClient.delete('/deliveries/$id');

      if (response.statusCode == 200) {
        return BaseResponse.success(data: null);
      } else {
        return BaseResponse.error(
          message: 'Failed to delete delivery: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error deleting delivery: $e');
    }
  }

  /// Get deliveries by carrier
  Future<BaseResponse<List<Delivery>>> getDeliveriesByCarrier(
    int carrierId,
  ) async {
    return getDeliveries(filters: {'id_carrier': carrierId.toString()});
  }

  /// Get deliveries by zone
  Future<BaseResponse<List<Delivery>>> getDeliveriesByZone(int zoneId) async {
    return getDeliveries(filters: {'id_zone': zoneId.toString()});
  }

  /// Get free deliveries
  Future<BaseResponse<List<Delivery>>> getFreeDeliveries() async {
    return getDeliveries(filters: {'price': '0'});
  }
}
