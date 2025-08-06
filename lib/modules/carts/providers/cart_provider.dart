import 'package:flutter/foundation.dart';
import '../../../core/models/base_response.dart';
import '../models/cart_model.dart';
import '../models/cart_rule_model.dart';
import '../services/cart_service.dart';
import '../services/cart_rule_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService;
  final CartRuleService _cartRuleService;

  CartProvider(this._cartService, this._cartRuleService);

  // Carts state
  List<Cart> _carts = [];
  Cart? _currentCart;
  bool _isLoadingCarts = false;
  String? _cartsError;

  // Cart rules state
  List<CartRule> _cartRules = [];
  List<CartRule> _activeCartRules = [];
  bool _isLoadingCartRules = false;
  String? _cartRulesError;

  // Applied promotions
  List<CartRule> _appliedPromotions = [];

  // Getters for carts
  List<Cart> get carts => _carts;
  Cart? get currentCart => _currentCart;
  bool get isLoadingCarts => _isLoadingCarts;
  String? get cartsError => _cartsError;

  // Getters for cart rules
  List<CartRule> get cartRules => _cartRules;
  List<CartRule> get activeCartRules => _activeCartRules;
  bool get isLoadingCartRules => _isLoadingCartRules;
  String? get cartRulesError => _cartRulesError;

  // Getters for applied promotions
  List<CartRule> get appliedPromotions => _appliedPromotions;

  // Cart management methods
  Future<void> loadCarts({int? customerId}) async {
    _isLoadingCarts = true;
    _cartsError = null;
    notifyListeners();

    try {
      final BaseResponse<List<Cart>> response;
      if (customerId != null) {
        response = await _cartService.getCustomerCarts(customerId);
      } else {
        response = await _cartService.getCarts();
      }

      if (response.success) {
        _carts = response.data ?? [];
        _cartsError = null;
      } else {
        _cartsError = response.message;
        _carts = [];
      }
    } catch (e) {
      _cartsError = 'Erreur lors du chargement des paniers: $e';
      _carts = [];
    }

    _isLoadingCarts = false;
    notifyListeners();
  }

  Future<bool> loadCart(int cartId) async {
    try {
      final response = await _cartService.getCart(cartId, display: 'full');

      if (response.success && response.data != null) {
        _currentCart = response.data;

        // Update cart in the list if it exists
        final index = _carts.indexWhere((cart) => cart.id == cartId);
        if (index != -1) {
          _carts[index] = response.data!;
        }

        notifyListeners();
        return true;
      } else {
        _cartsError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cartsError = 'Erreur lors du chargement du panier: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createCart(Cart cart) async {
    try {
      final response = await _cartService.createCart(cart);

      if (response.success && response.data != null) {
        _carts.add(response.data!);
        _currentCart = response.data;
        notifyListeners();
        return true;
      } else {
        _cartsError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cartsError = 'Erreur lors de la création du panier: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCart(Cart cart) async {
    try {
      final response = await _cartService.updateCart(cart);

      if (response.success && response.data != null) {
        final index = _carts.indexWhere((c) => c.id == cart.id);
        if (index != -1) {
          _carts[index] = response.data!;
        }

        if (_currentCart?.id == cart.id) {
          _currentCart = response.data;
        }

        notifyListeners();
        return true;
      } else {
        _cartsError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cartsError = 'Erreur lors de la mise à jour du panier: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCart(int cartId) async {
    try {
      final response = await _cartService.deleteCart(cartId);

      if (response.success) {
        _carts.removeWhere((cart) => cart.id == cartId);

        if (_currentCart?.id == cartId) {
          _currentCart = null;
        }

        notifyListeners();
        return true;
      } else {
        _cartsError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cartsError = 'Erreur lors de la suppression du panier: $e';
      notifyListeners();
      return false;
    }
  }

  // Cart item management
  Future<bool> addProductToCart(
    int cartId,
    int productId,
    int quantity, {
    int? productAttributeId,
    int? customizationId,
    int? addressDeliveryId,
  }) async {
    try {
      final response = await _cartService.addProductToCart(
        cartId,
        productId,
        quantity,
        productAttributeId: productAttributeId,
        customizationId: customizationId,
        addressDeliveryId: addressDeliveryId,
      );

      if (response.success && response.data != null) {
        final index = _carts.indexWhere((cart) => cart.id == cartId);
        if (index != -1) {
          _carts[index] = response.data!;
        }

        if (_currentCart?.id == cartId) {
          _currentCart = response.data;
        }

        notifyListeners();
        return true;
      } else {
        _cartsError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cartsError = 'Erreur lors de l\'ajout du produit: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeProductFromCart(
    int cartId,
    int productId, {
    int? productAttributeId,
  }) async {
    try {
      final response = await _cartService.removeProductFromCart(
        cartId,
        productId,
        productAttributeId: productAttributeId,
      );

      if (response.success && response.data != null) {
        final index = _carts.indexWhere((cart) => cart.id == cartId);
        if (index != -1) {
          _carts[index] = response.data!;
        }

        if (_currentCart?.id == cartId) {
          _currentCart = response.data;
        }

        notifyListeners();
        return true;
      } else {
        _cartsError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cartsError = 'Erreur lors de la suppression du produit: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProductQuantity(
    int cartId,
    int productId,
    int newQuantity, {
    int? productAttributeId,
  }) async {
    try {
      final response = await _cartService.updateProductQuantity(
        cartId,
        productId,
        newQuantity,
        productAttributeId: productAttributeId,
      );

      if (response.success && response.data != null) {
        final index = _carts.indexWhere((cart) => cart.id == cartId);
        if (index != -1) {
          _carts[index] = response.data!;
        }

        if (_currentCart?.id == cartId) {
          _currentCart = response.data;
        }

        notifyListeners();
        return true;
      } else {
        _cartsError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cartsError = 'Erreur lors de la mise à jour de la quantité: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearCart(int cartId) async {
    try {
      final response = await _cartService.clearCart(cartId);

      if (response.success && response.data != null) {
        final index = _carts.indexWhere((cart) => cart.id == cartId);
        if (index != -1) {
          _carts[index] = response.data!;
        }

        if (_currentCart?.id == cartId) {
          _currentCart = response.data;
        }

        // Clear applied promotions when clearing cart
        _appliedPromotions.clear();

        notifyListeners();
        return true;
      } else {
        _cartsError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cartsError = 'Erreur lors de la suppression des produits: $e';
      notifyListeners();
      return false;
    }
  }

  // Cart rules management methods
  Future<void> loadCartRules() async {
    _isLoadingCartRules = true;
    _cartRulesError = null;
    notifyListeners();

    try {
      final response = await _cartRuleService.getCartRules();

      if (response.success) {
        _cartRules = response.data ?? [];
        _cartRulesError = null;
      } else {
        _cartRulesError = response.message;
        _cartRules = [];
      }
    } catch (e) {
      _cartRulesError = 'Erreur lors du chargement des promotions: $e';
      _cartRules = [];
    }

    _isLoadingCartRules = false;
    notifyListeners();
  }

  Future<void> loadActiveCartRules() async {
    try {
      final response = await _cartRuleService.getActiveCartRules();

      if (response.success) {
        _activeCartRules = response.data ?? [];
      } else {
        _activeCartRules = [];
      }

      notifyListeners();
    } catch (e) {
      _activeCartRules = [];
      notifyListeners();
    }
  }

  Future<bool> createCartRule(CartRule cartRule) async {
    try {
      final response = await _cartRuleService.createCartRule(cartRule);

      if (response.success && response.data != null) {
        _cartRules.add(response.data!);
        notifyListeners();
        return true;
      } else {
        _cartRulesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cartRulesError = 'Erreur lors de la création de la promotion: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCartRule(CartRule cartRule) async {
    try {
      final response = await _cartRuleService.updateCartRule(cartRule);

      if (response.success && response.data != null) {
        final index = _cartRules.indexWhere((cr) => cr.id == cartRule.id);
        if (index != -1) {
          _cartRules[index] = response.data!;
        }

        notifyListeners();
        return true;
      } else {
        _cartRulesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cartRulesError = 'Erreur lors de la mise à jour de la promotion: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCartRule(int cartRuleId) async {
    try {
      final response = await _cartRuleService.deleteCartRule(cartRuleId);

      if (response.success) {
        _cartRules.removeWhere((cartRule) => cartRule.id == cartRuleId);
        _activeCartRules.removeWhere((cartRule) => cartRule.id == cartRuleId);
        _appliedPromotions.removeWhere((cartRule) => cartRule.id == cartRuleId);
        notifyListeners();
        return true;
      } else {
        _cartRulesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cartRulesError = 'Erreur lors de la suppression de la promotion: $e';
      notifyListeners();
      return false;
    }
  }

  // Promotion application methods
  Future<bool> applyPromotionCode(String code) async {
    try {
      final response = await _cartRuleService.validateCartRuleCode(code);

      if (response.success && response.data != null) {
        final cartRule = response.data!;

        // Check if already applied
        if (!_appliedPromotions.any((cr) => cr.id == cartRule.id)) {
          _appliedPromotions.add(cartRule);
          notifyListeners();
        }

        return true;
      } else {
        _cartRulesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _cartRulesError = 'Erreur lors de l\'application du code: $e';
      notifyListeners();
      return false;
    }
  }

  void removeAppliedPromotion(int cartRuleId) {
    _appliedPromotions.removeWhere((cartRule) => cartRule.id == cartRuleId);
    notifyListeners();
  }

  void clearAppliedPromotions() {
    _appliedPromotions.clear();
    notifyListeners();
  }

  // Helper methods
  void setCurrentCart(Cart? cart) {
    _currentCart = cart;
    notifyListeners();
  }

  void clearErrors() {
    _cartsError = null;
    _cartRulesError = null;
    notifyListeners();
  }

  // Business logic helpers
  double calculateCartTotal(Cart cart) {
    // This would typically integrate with product pricing
    // For now, return basic calculation
    return cart.totalQuantity * 10.0; // Placeholder calculation
  }

  double calculateDiscountAmount(Cart cart, List<CartRule> appliedRules) {
    double totalDiscount = 0.0;

    for (final rule in appliedRules) {
      if (rule.hasPercentageDiscount) {
        totalDiscount +=
            calculateCartTotal(cart) * (rule.reductionPercent! / 100);
      } else if (rule.hasAmountDiscount) {
        totalDiscount += rule.reductionAmount!;
      }
    }

    return totalDiscount;
  }

  bool canApplyPromotion(Cart cart, CartRule cartRule) {
    // Check if cart meets minimum amount requirement
    if (cartRule.hasMinimumAmount) {
      final cartTotal = calculateCartTotal(cart);
      if (cartTotal < cartRule.minimumAmount!) {
        return false;
      }
    }

    // Check if promotion is active
    if (!cartRule.isActive) {
      return false;
    }

    return true;
  }
}
