import 'package:flutter/foundation.dart';
import '../core/api/prestashop_api.dart';
import '../core/config/environment_service.dart';

/// Service spécialisé pour la gestion des produits PrestaShop
/// 
/// Cette classe fournit des méthodes haut niveau pour interagir
/// avec les produits de la boutique PrestaShop.
class ProductService extends ChangeNotifier {
  final PrestashopApiService _apiService;
  
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  ProductService({PrestashopApiService? apiService})
      : _apiService = apiService ?? PrestashopApiService();

  // ==================== GETTERS ====================
  
  List<ProductModel> get products => List.unmodifiable(_products);
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // ==================== INITIALISATION ====================

  /// Initialiser le service
  Future<void> initialize() async {
    if (!_apiService.isInitialized) {
      await _apiService.initialize(EnvironmentService.prestashopConfig);
    }
  }

  // ==================== PRODUITS ====================

  /// Charger les produits avec pagination
  Future<void> loadProducts({
    int page = 1,
    int? itemsPerPage,
    String? searchQuery,
    int? categoryId,
    bool refresh = false,
  }) async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      await initialize();

      final pageSize = itemsPerPage ?? EnvironmentService.defaultPageSize;
      final offset = (page - 1) * pageSize;

      Map<String, dynamic>? filters;
      if (categoryId != null) {
        filters = {'id_category_default': categoryId};
      }

      final response = await _apiService.getList(
        PrestashopApiEndpoints.products,
        filters: filters,
        searchTerm: searchQuery,
        limit: pageSize,
        offset: offset,
        useCache: !refresh,
      );

      final newProducts = response.data
          .map((data) => ProductModel.fromPrestashopData(data))
          .toList();

      if (page == 1 || refresh) {
        _products = newProducts;
      } else {
        _products.addAll(newProducts);
      }

      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des produits: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Rechercher des produits
  Future<List<ProductModel>> searchProducts(
    String query, {
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
  }) async {
    try {
      await initialize();

      final filters = <String, dynamic>{};
      if (categoryId != null) filters['id_category_default'] = categoryId;
      if (minPrice != null) filters['price'] = '[$minPrice,${maxPrice ?? 999999}]';
      if (inStock == true) filters['quantity'] = '[1,*]';

      final response = await _apiService.advancedSearch(
        resource: PrestashopApiEndpoints.products,
        query: query,
        filters: filters,
        itemsPerPage: 50,
      );

      return response.data
          .map((data) => ProductModel.fromPrestashopData(data))
          .toList();
    } catch (e) {
      _setError('Erreur lors de la recherche: $e');
      return [];
    }
  }

  /// Obtenir un produit par ID
  Future<ProductModel?> getProductById(int productId) async {
    try {
      await initialize();

      final response = await _apiService.getById(
        PrestashopApiEndpoints.products,
        productId,
      );

      return ProductModel.fromPrestashopData(response.data);
    } catch (e) {
      _setError('Erreur lors du chargement du produit: $e');
      return null;
    }
  }

  /// Obtenir les produits d'une catégorie
  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    try {
      await initialize();

      final response = await _apiService.getList(
        PrestashopApiEndpoints.products,
        filters: {'id_category_default': categoryId},
      );

      return response.data
          .map((data) => ProductModel.fromPrestashopData(data))
          .toList();
    } catch (e) {
      _setError('Erreur lors du chargement des produits de la catégorie: $e');
      return [];
    }
  }

  /// Obtenir les produits similaires
  Future<List<ProductModel>> getSimilarProducts(int productId) async {
    try {
      await initialize();

      // Récupérer le produit pour obtenir sa catégorie
      final product = await getProductById(productId);
      if (product == null) return [];

      // Récupérer d'autres produits de la même catégorie
      final categoryProducts = await getProductsByCategory(product.categoryId);
      
      // Exclure le produit actuel et limiter les résultats
      return categoryProducts
          .where((p) => p.id != productId)
          .take(5)
          .toList();
    } catch (e) {
      _setError('Erreur lors du chargement des produits similaires: $e');
      return [];
    }
  }

  // ==================== CATÉGORIES ====================

  /// Charger les catégories
  Future<void> loadCategories({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _setLoading(true);
    _clearError();

    try {
      await initialize();

      final response = await _apiService.getList(
        PrestashopApiEndpoints.categories,
        useCache: !refresh,
      );

      _categories = response.data
          .map((data) => CategoryModel.fromPrestashopData(data))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des catégories: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtenir une catégorie par ID
  Future<CategoryModel?> getCategoryById(int categoryId) async {
    try {
      await initialize();

      final response = await _apiService.getById(
        PrestashopApiEndpoints.categories,
        categoryId,
      );

      return CategoryModel.fromPrestashopData(response.data);
    } catch (e) {
      _setError('Erreur lors du chargement de la catégorie: $e');
      return null;
    }
  }

  // ==================== IMAGES ====================

  /// Obtenir l'image d'un produit
  Future<List<int>?> getProductImage(int productId, int imageId) async {
    try {
      await initialize();
      return await _apiService.getProductImage(productId, imageId);
    } catch (e) {
      _setError('Erreur lors du chargement de l\'image: $e');
      return null;
    }
  }

  /// Construire l'URL d'une image de produit
  String getProductImageUrl(int productId, int imageId, {String size = 'large'}) {
    final baseUrl = EnvironmentService.prestashopConfig.imageBaseUrl;
    return '$baseUrl/p/$productId/$imageId-$size_default.jpg';
  }

  /// Construire l'URL d'une image de catégorie
  String getCategoryImageUrl(int categoryId, {String size = 'large'}) {
    final baseUrl = EnvironmentService.prestashopConfig.imageBaseUrl;
    return '$baseUrl/c/$categoryId-$size_default.jpg';
  }

  // ==================== CACHE ====================

  /// Vider le cache des produits
  void clearProductsCache() {
    _apiService.clearCacheFor(PrestashopApiEndpoints.products);
    _products.clear();
    notifyListeners();
  }

  /// Vider le cache des catégories
  void clearCategoriesCache() {
    _apiService.clearCacheFor(PrestashopApiEndpoints.categories);
    _categories.clear();
    notifyListeners();
  }

  /// Rafraîchir toutes les données
  Future<void> refreshAll() async {
    await Future.wait([
      loadProducts(refresh: true),
      loadCategories(refresh: true),
    ]);
  }

  // ==================== MÉTHODES PRIVÉES ====================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    if (EnvironmentService.isDevelopment) {
      print('❌ [ProductService] $error');
    }
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}

/// Modèle simplifié pour les produits
class ProductModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? reference;
  final int categoryId;
  final int quantity;
  final bool active;
  final String? imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.reference,
    required this.categoryId,
    this.quantity = 0,
    this.active = true,
    this.imageUrl,
  });

  factory ProductModel.fromPrestashopData(Map<String, dynamic> data) {
    return ProductModel(
      id: int.tryParse(data['id']?.toString() ?? '0') ?? 0,
      name: data['name']?.toString() ?? 'Produit sans nom',
      description: data['description']?.toString(),
      price: double.tryParse(data['price']?.toString() ?? '0') ?? 0.0,
      reference: data['reference']?.toString(),
      categoryId: int.tryParse(data['id_category_default']?.toString() ?? '0') ?? 0,
      quantity: int.tryParse(data['quantity']?.toString() ?? '0') ?? 0,
      active: data['active']?.toString() == '1',
      imageUrl: data['image_url']?.toString(),
    );
  }

  bool get isInStock => quantity > 0;
  bool get isAvailable => active && isInStock;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'reference': reference,
      'categoryId': categoryId,
      'quantity': quantity,
      'active': active,
      'imageUrl': imageUrl,
    };
  }
}

/// Modèle simplifié pour les catégories
class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final int? parentId;
  final bool active;
  final String? imageUrl;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.active = true,
    this.imageUrl,
  });

  factory CategoryModel.fromPrestashopData(Map<String, dynamic> data) {
    return CategoryModel(
      id: int.tryParse(data['id']?.toString() ?? '0') ?? 0,
      name: data['name']?.toString() ?? 'Catégorie sans nom',
      description: data['description']?.toString(),
      parentId: int.tryParse(data['id_parent']?.toString() ?? '0'),
      active: data['active']?.toString() == '1',
      imageUrl: data['image_url']?.toString(),
    );
  }

  bool get isRootCategory => parentId == null || parentId == 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parentId': parentId,
      'active': active,
      'imageUrl': imageUrl,
    };
  }
}
