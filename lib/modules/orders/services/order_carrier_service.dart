import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../models/order_carrier_model.dart';

/// Service pour la gestion des transporteurs des commandes
class OrderCarrierService {
  final ApiClient _apiClient = ApiClient();

  /// Récupère tous les transporteurs
  Future<List<OrderCarrier>> getAllCarriers({
    Map<String, String>? filters,
    int? limit,
    int? offset,
    String? language,
    List<String>? sort,
  }) async {
    try {
      final Map<String, dynamic> params = {};

      if (filters != null) params.addAll(filters);
      if (limit != null) params['limit'] = limit.toString();
      if (offset != null) params['offset'] = offset.toString();
      if (language != null) params['language'] = language;
      if (sort != null && sort.isNotEmpty) params['sort'] = sort.join(',');

      final response = await _apiClient.get(
        '/carriers',
        queryParameters: params,
      );

      if (response.data['carriers'] != null) {
        final List<dynamic> carriersData = response.data['carriers'];
        return carriersData.map((json) => OrderCarrier.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        'Erreur lors de la récupération des transporteurs: ${e.message}',
      );
    }
  }

  /// Récupère un transporteur par ID
  Future<OrderCarrier?> getCarrierById(int id, {String? language}) async {
    try {
      final Map<String, dynamic> params = {};
      if (language != null) params['language'] = language;

      final response = await _apiClient.get(
        '/carriers/$id',
        queryParameters: params,
      );

      if (response.data['carrier'] != null) {
        return OrderCarrier.fromJson(response.data['carrier']);
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception(
        'Erreur lors de la récupération du transporteur: ${e.message}',
      );
    }
  }

  /// Récupère les transporteurs actifs
  Future<List<OrderCarrier>> getActiveCarriers({String? language}) async {
    return getAllCarriers(
      filters: {'active': '1'},
      language: language,
      sort: ['position_ASC'],
    );
  }

  /// Récupère les transporteurs par zone
  Future<List<OrderCarrier>> getCarriersByZone(
    int zoneId, {
    String? language,
  }) async {
    return getAllCarriers(
      filters: {'id_zone': zoneId.toString()},
      language: language,
    );
  }

  /// Récupère les transporteurs pour un poids donné
  Future<List<OrderCarrier>> getCarriersByWeight(
    double weight, {
    String? language,
  }) async {
    return getAllCarriers(
      filters: {'max_weight': '>=$weight'},
      language: language,
    );
  }

  /// Récupère les transporteurs gratuits
  Future<List<OrderCarrier>> getFreeCarriers({String? language}) async {
    return getAllCarriers(filters: {'is_free': '1'}, language: language);
  }

  /// Crée un nouveau transporteur
  Future<OrderCarrier?> createCarrier(OrderCarrier carrier) async {
    try {
      final response = await _apiClient.post(
        '/carriers',
        data: {'carrier': carrier.toJson()},
      );

      if (response.data['carrier'] != null) {
        return OrderCarrier.fromJson(response.data['carrier']);
      }

      return null;
    } on DioException catch (e) {
      throw Exception(
        'Erreur lors de la création du transporteur: ${e.message}',
      );
    }
  }

  /// Met à jour un transporteur
  Future<OrderCarrier?> updateCarrier(int id, OrderCarrier carrier) async {
    try {
      final response = await _apiClient.put(
        '/carriers/$id',
        data: {'carrier': carrier.toJson()},
      );

      if (response.data['carrier'] != null) {
        return OrderCarrier.fromJson(response.data['carrier']);
      }

      return null;
    } on DioException catch (e) {
      throw Exception(
        'Erreur lors de la mise à jour du transporteur: ${e.message}',
      );
    }
  }

  /// Supprime un transporteur
  Future<bool> deleteCarrier(int id) async {
    try {
      await _apiClient.delete('/carriers/$id');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return false;
      }
      throw Exception(
        'Erreur lors de la suppression du transporteur: ${e.message}',
      );
    }
  }

  /// Active/désactive un transporteur
  Future<bool> toggleCarrierStatus(int id, bool active) async {
    try {
      final carrier = await getCarrierById(id);
      if (carrier == null) return false;

      final updatedCarrier = carrier.copyWith(active: active);
      final result = await updateCarrier(id, updatedCarrier);

      return result != null;
    } catch (e) {
      throw Exception(
        'Erreur lors du changement de statut du transporteur: $e',
      );
    }
  }

  /// Calcule les frais de livraison pour une zone et un poids
  Future<double?> calculateShippingCost(
    int carrierId,
    int zoneId,
    double weight,
    double price,
  ) async {
    try {
      final response = await _apiClient.get(
        '/carriers/$carrierId/shipping_cost',
        queryParameters: {
          'id_zone': zoneId.toString(),
          'weight': weight.toString(),
          'price': price.toString(),
        },
      );

      if (response.data['shipping_cost'] != null) {
        return double.tryParse(response.data['shipping_cost'].toString());
      }

      return null;
    } on DioException catch (e) {
      throw Exception(
        'Erreur lors du calcul des frais de livraison: ${e.message}',
      );
    }
  }

  /// Récupère les zones desservies par un transporteur
  Future<List<int>> getCarrierZones(int carrierId) async {
    try {
      final response = await _apiClient.get('/carriers/$carrierId/zones');

      if (response.data['zones'] != null) {
        final List<dynamic> zonesData = response.data['zones'];
        return zonesData
            .map((zone) => int.parse(zone['id'].toString()))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        'Erreur lors de la récupération des zones du transporteur: ${e.message}',
      );
    }
  }
}
