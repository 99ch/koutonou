import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../models/order_cart_rule_model.dart';

/// Service pour la gestion des règles de panier des commandes
class OrderCartRuleService {
  final ApiClient _apiClient = ApiClient();

  /// Récupère toutes les règles de panier
  Future<List<OrderCartRule>> getAllCartRules({
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
        '/cart_rules',
        queryParameters: params,
      );

      if (response.data['cart_rules'] != null) {
        final List<dynamic> cartRulesData = response.data['cart_rules'];
        return cartRulesData
            .map((json) => OrderCartRule.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        'Erreur lors de la récupération des règles de panier: ${e.message}',
      );
    }
  }

  /// Récupère une règle de panier par ID
  Future<OrderCartRule?> getCartRuleById(int id, {String? language}) async {
    try {
      final Map<String, dynamic> params = {};
      if (language != null) params['language'] = language;

      final response = await _apiClient.get(
        '/cart_rules/$id',
        queryParameters: params,
      );

      if (response.data['cart_rule'] != null) {
        return OrderCartRule.fromJson(response.data['cart_rule']);
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception(
        'Erreur lors de la récupération de la règle de panier: ${e.message}',
      );
    }
  }

  /// Récupère les règles de panier par code
  Future<List<OrderCartRule>> getCartRulesByCode(
    String code, {
    String? language,
  }) async {
    return getAllCartRules(filters: {'code': code}, language: language);
  }

  /// Récupère les règles de panier actives
  Future<List<OrderCartRule>> getActiveCartRules({String? language}) async {
    return getAllCartRules(filters: {'active': '1'}, language: language);
  }

  /// Récupère les règles de panier par date
  Future<List<OrderCartRule>> getCartRulesByDateRange(
    DateTime from,
    DateTime to, {
    String? language,
  }) async {
    final String fromDate = from.toIso8601String().split('T')[0];
    final String toDate = to.toIso8601String().split('T')[0];

    return getAllCartRules(
      filters: {'date_from': '[$fromDate,$toDate]'},
      language: language,
    );
  }

  /// Crée une nouvelle règle de panier
  Future<OrderCartRule?> createCartRule(OrderCartRule cartRule) async {
    try {
      final response = await _apiClient.post(
        '/cart_rules',
        data: {'cart_rule': cartRule.toJson()},
      );

      if (response.data['cart_rule'] != null) {
        return OrderCartRule.fromJson(response.data['cart_rule']);
      }

      return null;
    } on DioException catch (e) {
      throw Exception(
        'Erreur lors de la création de la règle de panier: ${e.message}',
      );
    }
  }

  /// Met à jour une règle de panier
  Future<OrderCartRule?> updateCartRule(int id, OrderCartRule cartRule) async {
    try {
      final response = await _apiClient.put(
        '/cart_rules/$id',
        data: {'cart_rule': cartRule.toJson()},
      );

      if (response.data['cart_rule'] != null) {
        return OrderCartRule.fromJson(response.data['cart_rule']);
      }

      return null;
    } on DioException catch (e) {
      throw Exception(
        'Erreur lors de la mise à jour de la règle de panier: ${e.message}',
      );
    }
  }

  /// Supprime une règle de panier
  Future<bool> deleteCartRule(int id) async {
    try {
      await _apiClient.delete('/cart_rules/$id');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return false;
      }
      throw Exception(
        'Erreur lors de la suppression de la règle de panier: ${e.message}',
      );
    }
  }

  /// Active/désactive une règle de panier
  Future<bool> toggleCartRuleStatus(int id, bool active) async {
    try {
      final cartRule = await getCartRuleById(id);
      if (cartRule == null) return false;

      // Note: OrderCartRule n'a pas de propriété 'active', utiliser 'deleted' inversé
      final updatedCartRule = cartRule.copyWith(deleted: !active);
      final result = await updateCartRule(id, updatedCartRule);

      return result != null;
    } catch (e) {
      throw Exception(
        'Erreur lors du changement de statut de la règle de panier: $e',
      );
    }
  }
}
