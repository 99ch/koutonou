import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/base_response.dart';
import '../models/cart_rule_model.dart';

class CartRuleService {
  final ApiClient _apiClient;

  CartRuleService(this._apiClient);

  // Get all cart rules with optional filters
  Future<BaseResponse<List<CartRule>>> getCartRules({
    int? limit,
    int? offset,
    String? sort,
    String? filter,
    String? display,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (sort != null) queryParams['sort'] = sort;
      if (filter != null) queryParams['filter'] = filter;
      if (display != null) queryParams['display'] = display;

      final response = await _apiClient.get(
        '/cart_rules',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<CartRule> cartRules = [];
        final data = response.data;

        if (data['cart_rules'] != null) {
          if (data['cart_rules']['cart_rule'] is List) {
            for (var cartRuleData in data['cart_rules']['cart_rule']) {
              cartRules.add(CartRule.fromJson(cartRuleData));
            }
          } else {
            cartRules.add(CartRule.fromJson(data['cart_rules']['cart_rule']));
          }
        }

        return BaseResponse.success(data: cartRules);
      }

      return BaseResponse.error(
        message: 'Failed to fetch cart rules: ${response.statusCode}',
      );
    } catch (e) {
      return BaseResponse.error(message: 'Error fetching cart rules: $e');
    }
  }

  // Get cart rule by ID
  Future<BaseResponse<CartRule>> getCartRule(int id, {String? display}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (display != null) queryParams['display'] = display;

      final response = await _apiClient.get(
        '/cart_rules/$id',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final cartRuleData = response.data['cart_rule'];
        return BaseResponse.success(data: CartRule.fromJson(cartRuleData));
      }

      return BaseResponse.error(message: 'Cart rule not found');
    } catch (e) {
      return BaseResponse.error(message: 'Error fetching cart rule: $e');
    }
  }

  // Create new cart rule
  Future<BaseResponse<CartRule>> createCartRule(CartRule cartRule) async {
    try {
      final response = await _apiClient.post(
        '/cart_rules',
        data: cartRule.toXml(),
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      if (response.statusCode == 201) {
        final cartRuleData = response.data['cart_rule'];
        return BaseResponse.success(data: CartRule.fromJson(cartRuleData));
      }

      return BaseResponse.error(
        message: 'Failed to create cart rule: ${response.statusCode}',
      );
    } catch (e) {
      return BaseResponse.error(message: 'Error creating cart rule: $e');
    }
  }

  // Update cart rule
  Future<BaseResponse<CartRule>> updateCartRule(CartRule cartRule) async {
    if (cartRule.id == null) {
      return BaseResponse.error(message: 'Cart rule ID is required for update');
    }

    try {
      final response = await _apiClient.put(
        '/cart_rules/${cartRule.id}',
        data: cartRule.toXml(),
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      if (response.statusCode == 200) {
        final cartRuleData = response.data['cart_rule'];
        return BaseResponse.success(data: CartRule.fromJson(cartRuleData));
      }

      return BaseResponse.error(
        message: 'Failed to update cart rule: ${response.statusCode}',
      );
    } catch (e) {
      return BaseResponse.error(message: 'Error updating cart rule: $e');
    }
  }

  // Delete cart rule
  Future<BaseResponse<void>> deleteCartRule(int id) async {
    try {
      final response = await _apiClient.delete('/cart_rules/$id');

      if (response.statusCode == 200) {
        return BaseResponse.success();
      }

      return BaseResponse.error(
        message: 'Failed to delete cart rule: ${response.statusCode}',
      );
    } catch (e) {
      return BaseResponse.error(message: 'Error deleting cart rule: $e');
    }
  }

  // Get active cart rules
  Future<BaseResponse<List<CartRule>>> getActiveCartRules() async {
    final now = DateTime.now().toIso8601String();
    return getCartRules(
      filter: 'active:1,date_from:[* TO $now],date_to:[$now TO *]',
    );
  }

  // Get cart rules by customer
  Future<BaseResponse<List<CartRule>>> getCustomerCartRules(
    int customerId,
  ) async {
    return getCartRules(filter: 'id_customer:$customerId');
  }

  // Get cart rules by code
  Future<BaseResponse<List<CartRule>>> getCartRulesByCode(String code) async {
    return getCartRules(filter: 'code:$code');
  }

  // Validate cart rule code
  Future<BaseResponse<CartRule?>> validateCartRuleCode(String code) async {
    final response = await getCartRulesByCode(code);

    if (response.success &&
        response.data != null &&
        response.data!.isNotEmpty) {
      final cartRule = response.data!.first;

      if (cartRule.isActive) {
        return BaseResponse.success(data: cartRule);
      } else if (cartRule.isExpired) {
        return BaseResponse.error(message: 'Cette promotion a expiré');
      } else if (cartRule.isNotYetValid) {
        return BaseResponse.error(
          message: 'Cette promotion n\'est pas encore valide',
        );
      } else {
        return BaseResponse.error(message: 'Cette promotion est désactivée');
      }
    }

    return BaseResponse.error(message: 'Code de promotion invalide');
  }

  // Get cart rules with percentage discount
  Future<BaseResponse<List<CartRule>>> getPercentageDiscountRules() async {
    return getCartRules(filter: 'reduction_percent:[0 TO *]');
  }

  // Get cart rules with amount discount
  Future<BaseResponse<List<CartRule>>> getAmountDiscountRules() async {
    return getCartRules(filter: 'reduction_amount:[0 TO *]');
  }

  // Get cart rules with free shipping
  Future<BaseResponse<List<CartRule>>> getFreeShippingRules() async {
    return getCartRules(filter: 'free_shipping:1');
  }

  // Get cart rules with gift products
  Future<BaseResponse<List<CartRule>>> getGiftProductRules() async {
    return getCartRules(filter: 'gift_product:[1 TO *]');
  }

  // Get highlighted cart rules
  Future<BaseResponse<List<CartRule>>> getHighlightedCartRules() async {
    return getCartRules(filter: 'highlight:1,active:1');
  }

  // Search cart rules by name
  Future<BaseResponse<List<CartRule>>> searchCartRules(String query) async {
    // Note: This is a basic implementation. PrestaShop might require different approach for multilingual search
    return getCartRules(filter: 'name:*$query*');
  }

  // Get cart rules expiring soon (within next 7 days)
  Future<BaseResponse<List<CartRule>>> getCartRulesExpiringSoon({
    int days = 7,
  }) async {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    return getCartRules(
      filter:
          'active:1,date_to:[${now.toIso8601String()} TO ${futureDate.toIso8601String()}]',
    );
  }

  // Get usage statistics for cart rules
  Future<BaseResponse<Map<String, dynamic>>> getCartRuleUsageStats(
    int cartRuleId,
  ) async {
    // This would typically require additional API endpoints or database queries
    // For now, we'll return basic information from the cart rule itself
    final cartRuleResponse = await getCartRule(cartRuleId, display: 'full');

    if (cartRuleResponse.success && cartRuleResponse.data != null) {
      final cartRule = cartRuleResponse.data!;

      return BaseResponse.success(
        data: {
          'id': cartRule.id,
          'name': cartRule.name,
          'total_quantity': cartRule.quantity ?? 0,
          'quantity_per_user': cartRule.quantityPerUser ?? 0,
          'active': cartRule.active,
          'is_active': cartRule.isActive,
          'is_expired': cartRule.isExpired,
          'remaining_time_days': cartRule.remainingTime.inDays,
          'has_code': cartRule.hasCode,
          'has_minimum_amount': cartRule.hasMinimumAmount,
          'minimum_amount': cartRule.minimumAmount,
          'has_percentage_discount': cartRule.hasPercentageDiscount,
          'percentage_discount': cartRule.reductionPercent,
          'has_amount_discount': cartRule.hasAmountDiscount,
          'amount_discount': cartRule.reductionAmount,
          'has_gift_product': cartRule.hasGiftProduct,
          'gift_product_id': cartRule.giftProduct,
          'free_shipping': cartRule.freeShipping,
        },
      );
    }

    return BaseResponse.error(message: 'Cart rule not found');
  }
}
