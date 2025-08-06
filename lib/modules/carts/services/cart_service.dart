import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/base_response.dart';
import '../models/cart_model.dart';

class CartService {
  final ApiClient _apiClient;

  CartService(this._apiClient);

  // Get all carts with optional filters
  Future<BaseResponse<List<Cart>>> getCarts({
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
        '/carts',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<Cart> carts = [];
        final data = response.data;

        if (data['carts'] != null) {
          if (data['carts']['cart'] is List) {
            for (var cartData in data['carts']['cart']) {
              carts.add(Cart.fromJson(cartData));
            }
          } else {
            carts.add(Cart.fromJson(data['carts']['cart']));
          }
        }

        return BaseResponse.success(data: carts);
      }

      return BaseResponse.error(
        message: 'Failed to fetch carts: ${response.statusCode}',
      );
    } catch (e) {
      return BaseResponse.error(message: 'Error fetching carts: $e');
    }
  }

  // Get cart by ID
  Future<BaseResponse<Cart>> getCart(int id, {String? display}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (display != null) queryParams['display'] = display;

      final response = await _apiClient.get(
        '/carts/$id',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final cartData = response.data['cart'];
        return BaseResponse.success(data: Cart.fromJson(cartData));
      }

      return BaseResponse.error(message: 'Cart not found');
    } catch (e) {
      return BaseResponse.error(message: 'Error fetching cart: $e');
    }
  }

  // Create new cart
  Future<BaseResponse<Cart>> createCart(Cart cart) async {
    try {
      final response = await _apiClient.post(
        '/carts',
        data: cart.toXml(),
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      if (response.statusCode == 201) {
        final cartData = response.data['cart'];
        return BaseResponse.success(data: Cart.fromJson(cartData));
      }

      return BaseResponse.error(
        message: 'Failed to create cart: ${response.statusCode}',
      );
    } catch (e) {
      return BaseResponse.error(message: 'Error creating cart: $e');
    }
  }

  // Update cart
  Future<BaseResponse<Cart>> updateCart(Cart cart) async {
    if (cart.id == null) {
      return BaseResponse.error(message: 'Cart ID is required for update');
    }

    try {
      final response = await _apiClient.put(
        '/carts/${cart.id}',
        data: cart.toXml(),
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      if (response.statusCode == 200) {
        final cartData = response.data['cart'];
        return BaseResponse.success(data: Cart.fromJson(cartData));
      }

      return BaseResponse.error(
        message: 'Failed to update cart: ${response.statusCode}',
      );
    } catch (e) {
      return BaseResponse.error(message: 'Error updating cart: $e');
    }
  }

  // Delete cart
  Future<BaseResponse<void>> deleteCart(int id) async {
    try {
      final response = await _apiClient.delete('/carts/$id');

      if (response.statusCode == 200) {
        return BaseResponse.success();
      }

      return BaseResponse.error(
        message: 'Failed to delete cart: ${response.statusCode}',
      );
    } catch (e) {
      return BaseResponse.error(message: 'Error deleting cart: $e');
    }
  }

  // Get carts for a specific customer
  Future<BaseResponse<List<Cart>>> getCustomerCarts(int customerId) async {
    return getCarts(filter: 'id_customer:$customerId');
  }

  // Get cart items (cart rows) for a specific cart
  Future<BaseResponse<List<CartRow>>> getCartItems(int cartId) async {
    final cartResponse = await getCart(cartId, display: 'full');

    if (cartResponse.success && cartResponse.data != null) {
      return BaseResponse.success(data: cartResponse.data!.cartRows ?? []);
    }

    return BaseResponse.error(message: 'Failed to fetch cart items');
  }

  // Add product to cart
  Future<BaseResponse<Cart>> addProductToCart(
    int cartId,
    int productId,
    int quantity, {
    int? productAttributeId,
    int? customizationId,
    int? addressDeliveryId,
  }) async {
    final cartResponse = await getCart(cartId, display: 'full');

    if (!cartResponse.success || cartResponse.data == null) {
      return BaseResponse.error(message: 'Cart not found');
    }

    final cart = cartResponse.data!;
    final cartRows = List<CartRow>.from(cart.cartRows ?? []);

    // Check if product already exists in cart
    final existingRowIndex = cartRows.indexWhere(
      (row) =>
          row.idProduct == productId &&
          row.idProductAttribute == productAttributeId,
    );

    if (existingRowIndex != -1) {
      // Update quantity of existing product
      cartRows[existingRowIndex] = CartRow(
        idProduct: productId,
        idProductAttribute: productAttributeId,
        idAddressDelivery:
            addressDeliveryId ?? cartRows[existingRowIndex].idAddressDelivery,
        idCustomization:
            customizationId ?? cartRows[existingRowIndex].idCustomization,
        quantity: cartRows[existingRowIndex].quantity + quantity,
      );
    } else {
      // Add new product to cart
      cartRows.add(
        CartRow(
          idProduct: productId,
          idProductAttribute: productAttributeId,
          idAddressDelivery: addressDeliveryId,
          idCustomization: customizationId,
          quantity: quantity,
        ),
      );
    }

    final updatedCart = cart.copyWith(cartRows: cartRows);
    return updateCart(updatedCart);
  }

  // Remove product from cart
  Future<BaseResponse<Cart>> removeProductFromCart(
    int cartId,
    int productId, {
    int? productAttributeId,
  }) async {
    final cartResponse = await getCart(cartId, display: 'full');

    if (!cartResponse.success || cartResponse.data == null) {
      return BaseResponse.error(message: 'Cart not found');
    }

    final cart = cartResponse.data!;
    final cartRows = List<CartRow>.from(cart.cartRows ?? []);

    cartRows.removeWhere(
      (row) =>
          row.idProduct == productId &&
          row.idProductAttribute == productAttributeId,
    );

    final updatedCart = cart.copyWith(cartRows: cartRows);
    return updateCart(updatedCart);
  }

  // Update product quantity in cart
  Future<BaseResponse<Cart>> updateProductQuantity(
    int cartId,
    int productId,
    int newQuantity, {
    int? productAttributeId,
  }) async {
    if (newQuantity <= 0) {
      return removeProductFromCart(
        cartId,
        productId,
        productAttributeId: productAttributeId,
      );
    }

    final cartResponse = await getCart(cartId, display: 'full');

    if (!cartResponse.success || cartResponse.data == null) {
      return BaseResponse.error(message: 'Cart not found');
    }

    final cart = cartResponse.data!;
    final cartRows = List<CartRow>.from(cart.cartRows ?? []);

    final rowIndex = cartRows.indexWhere(
      (row) =>
          row.idProduct == productId &&
          row.idProductAttribute == productAttributeId,
    );

    if (rowIndex != -1) {
      cartRows[rowIndex] = CartRow(
        idProduct: productId,
        idProductAttribute: productAttributeId,
        idAddressDelivery: cartRows[rowIndex].idAddressDelivery,
        idCustomization: cartRows[rowIndex].idCustomization,
        quantity: newQuantity,
      );
    }

    final updatedCart = cart.copyWith(cartRows: cartRows);
    return updateCart(updatedCart);
  }

  // Clear cart (remove all products)
  Future<BaseResponse<Cart>> clearCart(int cartId) async {
    final cartResponse = await getCart(cartId);

    if (!cartResponse.success || cartResponse.data == null) {
      return BaseResponse.error(message: 'Cart not found');
    }

    final cart = cartResponse.data!;
    final updatedCart = cart.copyWith(cartRows: []);
    return updateCart(updatedCart);
  }

  // Search carts
  Future<BaseResponse<List<Cart>>> searchCarts(String query) async {
    return getCarts(filter: 'secure_key:$query');
  }
}
