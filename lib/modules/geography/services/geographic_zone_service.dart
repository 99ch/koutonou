import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/base_response.dart';
import '../models/geographic_zone_model.dart';

/// Service for managing geographic zones in PrestaShop
class GeographicZoneService extends ApiService {
  GeographicZoneService({required super.dio});

  /// Get all zones
  Future<BaseResponse<List<GeographicZone>>> getZones({
    int? limit,
    String? sort,
    String? filter,
    String? display,
  }) async {
    try {
      final Map<String, dynamic> params = {'output_format': 'JSON'};

      if (limit != null) params['limit'] = limit.toString();
      if (sort != null) params['sort'] = sort;
      if (filter != null) params['filter'] = filter;
      if (display != null) params['display'] = display;

      final response = await dio.get('/zones', queryParameters: params);

      if (response.statusCode == 200) {
        final List<GeographicZone> zones = [];

        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('zones')) {
          final zonesData = data['zones'];
          if (zonesData is List) {
            for (final zoneData in zonesData) {
              if (zoneData is Map<String, dynamic>) {
                zones.add(GeographicZone.fromJson(zoneData));
              }
            }
          } else if (zonesData is Map<String, dynamic>) {
            // Single zone
            zones.add(GeographicZone.fromJson(zonesData));
          }
        }

        return BaseResponse.success(
          data: zones,
          message: 'Zones géographiques récupérées avec succès',
        );
      }

      return BaseResponse.error(
        message:
            'Erreur lors de la récupération des zones: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Get zone by ID
  Future<BaseResponse<GeographicZone>> getZone(int zoneId) async {
    try {
      final response = await dio.get(
        '/zones/$zoneId',
        queryParameters: {'output_format': 'JSON'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('zone')) {
          final zone = GeographicZone.fromJson(data['zone']);
          return BaseResponse.success(
            data: zone,
            message: 'Zone géographique récupérée avec succès',
          );
        }
      }

      return BaseResponse.error(message: 'Zone géographique non trouvée');
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Create a new zone
  Future<BaseResponse<GeographicZone>> createZone(GeographicZone zone) async {
    try {
      final xmlData = zone.toXml();

      final response = await dio.post(
        '/zones',
        data: xmlData,
        options: Options(
          contentType: 'application/xml',
          headers: {'Content-Type': 'application/xml'},
        ),
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('zone')) {
          final createdZone = GeographicZone.fromJson(data['zone']);
          return BaseResponse.success(
            data: createdZone,
            message: 'Zone géographique créée avec succès',
          );
        }
      }

      return BaseResponse.error(
        message:
            'Erreur lors de la création de la zone: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Update a zone
  Future<BaseResponse<GeographicZone>> updateZone(GeographicZone zone) async {
    try {
      if (zone.id == null) {
        return BaseResponse.error(
          message: 'ID de la zone requis pour la mise à jour',
        );
      }

      final xmlData = zone.toXml();

      final response = await dio.put(
        '/zones/${zone.id}',
        data: xmlData,
        options: Options(
          contentType: 'application/xml',
          headers: {'Content-Type': 'application/xml'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('zone')) {
          final updatedZone = GeographicZone.fromJson(data['zone']);
          return BaseResponse.success(
            data: updatedZone,
            message: 'Zone géographique mise à jour avec succès',
          );
        }
      }

      return BaseResponse.error(
        message:
            'Erreur lors de la mise à jour de la zone: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Delete a zone
  Future<BaseResponse<bool>> deleteZone(int zoneId) async {
    try {
      final response = await dio.delete('/zones/$zoneId');

      if (response.statusCode == 200) {
        return BaseResponse.success(
          data: true,
          message: 'Zone géographique supprimée avec succès',
        );
      }

      return BaseResponse.error(
        message:
            'Erreur lors de la suppression de la zone: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Search zones by name
  Future<BaseResponse<List<GeographicZone>>> searchZones(String query) async {
    try {
      final response = await dio.get(
        '/zones',
        queryParameters: {'output_format': 'JSON', 'filter[name]': '%$query%'},
      );

      if (response.statusCode == 200) {
        final List<GeographicZone> zones = [];

        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('zones')) {
          final zonesData = data['zones'];
          if (zonesData is List) {
            for (final zoneData in zonesData) {
              if (zoneData is Map<String, dynamic>) {
                zones.add(GeographicZone.fromJson(zoneData));
              }
            }
          } else if (zonesData is Map<String, dynamic>) {
            zones.add(GeographicZone.fromJson(zonesData));
          }
        }

        return BaseResponse.success(
          data: zones,
          message: 'Recherche effectuée avec succès',
        );
      }

      return BaseResponse.error(
        message: 'Erreur lors de la recherche: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }
}
