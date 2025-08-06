import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/base_response.dart';
import '../models/zone_model.dart';

class ZoneService {
  final ApiClient _apiClient;

  ZoneService(this._apiClient);

  /// Get all zones
  Future<BaseResponse<List<Zone>>> getZones({
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
        '/zones',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<Zone> zones = [];

        if (response.data['zones'] != null) {
          final zonesData = response.data['zones'];
          if (zonesData is List) {
            for (final zoneData in zonesData) {
              if (zoneData is Map<String, dynamic>) {
                zones.add(Zone.fromJson(zoneData));
              }
            }
          } else if (zonesData is Map<String, dynamic>) {
            if (zonesData['zone'] != null) {
              final zoneList = zonesData['zone'];
              if (zoneList is List) {
                for (final zoneData in zoneList) {
                  zones.add(Zone.fromJson(zoneData));
                }
              } else {
                zones.add(Zone.fromJson(zoneList));
              }
            }
          }
        }

        return BaseResponse.success(data: zones);
      } else {
        return BaseResponse.error(
          message: 'Failed to load zones: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error loading zones: $e');
    }
  }

  /// Get zone by ID
  Future<BaseResponse<Zone>> getZone(int id) async {
    try {
      final response = await _apiClient.get('/zones/$id');

      if (response.statusCode == 200 && response.data != null) {
        final zoneData = response.data['zone'] ?? response.data;
        final zone = Zone.fromJson(zoneData);
        return BaseResponse.success(data: zone);
      } else {
        return BaseResponse.error(message: 'Zone not found');
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error loading zone: $e');
    }
  }

  /// Create a new zone
  Future<BaseResponse<Zone>> createZone(Zone zone) async {
    try {
      final response = await _apiClient.post(
        '/zones',
        data: zone.toXml(),
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      if (response.statusCode == 201 && response.data != null) {
        final zoneData = response.data['zone'] ?? response.data;
        final createdZone = Zone.fromJson(zoneData);
        return BaseResponse.success(data: createdZone);
      } else {
        return BaseResponse.error(
          message: 'Failed to create zone: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error creating zone: $e');
    }
  }

  /// Update an existing zone
  Future<BaseResponse<Zone>> updateZone(Zone zone) async {
    try {
      if (zone.id == null) {
        return BaseResponse.error(message: 'Zone ID is required for update');
      }

      final response = await _apiClient.put(
        '/zones/${zone.id}',
        data: zone.toXml(),
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final zoneData = response.data['zone'] ?? response.data;
        final updatedZone = Zone.fromJson(zoneData);
        return BaseResponse.success(data: updatedZone);
      } else {
        return BaseResponse.error(
          message: 'Failed to update zone: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error updating zone: $e');
    }
  }

  /// Delete a zone
  Future<BaseResponse<void>> deleteZone(int id) async {
    try {
      final response = await _apiClient.delete('/zones/$id');

      if (response.statusCode == 200) {
        return BaseResponse.success(data: null);
      } else {
        return BaseResponse.error(
          message: 'Failed to delete zone: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error deleting zone: $e');
    }
  }

  /// Get active zones
  Future<BaseResponse<List<Zone>>> getActiveZones() async {
    return getZones(filters: {'active': '1'});
  }

  /// Search zones by name
  Future<BaseResponse<List<Zone>>> searchZonesByName(String name) async {
    return getZones(filters: {'name': '%$name%'});
  }
}
