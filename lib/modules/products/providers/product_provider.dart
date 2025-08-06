import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/product_supplier_model.dart';
import '../models/product_option_model.dart';
import '../models/product_option_value_model.dart';
import '../models/product_feature_model.dart';
import '../models/product_feature_value_model.dart';
import '../models/customization_field_model.dart';
import '../models/price_range_model.dart';
import '../services/product_service.dart';
import '../services/product_sub_resources_service.dart';
import '../../../core/api/api_client.dart';

/// Provider pour la gestion de l'état des produits
class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  late final ProductSubResourcesService _subResourcesService;

  ProductProvider() {
    // Utiliser directement ApiClient au lieu d'essayer d'accéder via ProductService
    _subResourcesService = ProductSubResourcesService(ApiClient());
  }

  // État des produits
  List<Product> _products = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _errorMessage;

  // État des sous-ressources
  List<ProductSupplier> _productSuppliers = [];
  List<ProductOption> _productOptions = [];
  List<ProductOptionValue> _productOptionValues = [];
  List<ProductFeature> _productFeatures = [];
  List<ProductFeatureValue> _productFeatureValues = [];
  List<CustomizationField> _customizationFields = [];
  List<PriceRange> _priceRanges = [];

  // État de chargement des sous-ressources
  bool _isLoadingSubResources = false;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  bool _hasNextPage = true;

  // Filtres
  String? _searchQuery;
  int? _categoryFilter;
  bool _activeOnlyFilter = false;

  // Getters
  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  bool get hasNextPage => _hasNextPage;
  String? get searchQuery => _searchQuery;
  int? get categoryFilter => _categoryFilter;
  bool get activeOnlyFilter => _activeOnlyFilter;

  // Getters pour les sous-ressources
  List<ProductSupplier> get productSuppliers => _productSuppliers;
  List<ProductOption> get productOptions => _productOptions;
  List<ProductOptionValue> get productOptionValues => _productOptionValues;
  List<ProductFeature> get productFeatures => _productFeatures;
  List<ProductFeatureValue> get productFeatureValues => _productFeatureValues;
  List<CustomizationField> get customizationFields => _customizationFields;
  List<PriceRange> get priceRanges => _priceRanges;
  bool get isLoadingSubResources => _isLoadingSubResources;

  /// Charge tous les produits avec pagination
  Future<void> loadProducts({bool reset = false, String? language}) async {
    if (_isLoading) return;

    if (reset) {
      _currentPage = 1;
      _products.clear();
      _hasNextPage = true;
    }

    _setLoading(true);
    _clearError();

    try {
      Map<String, String>? filters;

      // Appliquer les filtres
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        filters = {'name': _searchQuery!};
      }

      if (_categoryFilter != null) {
        filters ??= {};
        filters['id_category_default'] = _categoryFilter.toString();
      }

      if (_activeOnlyFilter) {
        filters ??= {};
        filters['active'] = '1';
      }

      final newProducts = await _productService.getAllProducts(
        filters: filters,
        limit: _itemsPerPage,
        offset: (_currentPage - 1) * _itemsPerPage,
        language: language,
      );

      if (reset) {
        _products = newProducts;
      } else {
        _products.addAll(newProducts);
      }

      _hasNextPage = newProducts.length == _itemsPerPage;
      if (_hasNextPage) _currentPage++;
    } catch (e) {
      _setError('Erreur lors du chargement des produits: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charge plus de produits (pagination)
  Future<void> loadMoreProducts({String? language}) async {
    if (!_hasNextPage || _isLoading) return;
    await loadProducts(reset: false, language: language);
  }

  /// Recherche des produits par nom
  Future<void> searchProducts(String query, {String? language}) async {
    _searchQuery = query;
    await loadProducts(reset: true, language: language);
  }

  /// Filtre les produits par catégorie
  Future<void> filterByCategory(int? categoryId, {String? language}) async {
    _categoryFilter = categoryId;
    await loadProducts(reset: true, language: language);
  }

  /// Active/désactive le filtre "actifs seulement"
  Future<void> toggleActiveFilter({String? language}) async {
    _activeOnlyFilter = !_activeOnlyFilter;
    await loadProducts(reset: true, language: language);
  }

  /// Efface tous les filtres
  Future<void> clearFilters({String? language}) async {
    _searchQuery = null;
    _categoryFilter = null;
    _activeOnlyFilter = false;
    await loadProducts(reset: true, language: language);
  }

  /// Charge un produit par ID
  Future<void> loadProductById(int productId, {String? language}) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedProduct = await _productService.getProductById(
        productId,
        language: language,
      );
    } catch (e) {
      _setError('Erreur lors du chargement du produit: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Crée un nouveau produit
  Future<bool> createProduct(Product product) async {
    _setLoading(true);
    _clearError();

    try {
      final createdProduct = await _productService.createProduct(product);
      if (createdProduct != null) {
        _products.insert(0, createdProduct);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erreur lors de la création du produit: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Met à jour un produit existant
  Future<bool> updateProduct(Product product) async {
    if (product.id == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedProduct = await _productService.updateProduct(product);
      if (updatedProduct != null) {
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _products[index] = updatedProduct;
        }

        if (_selectedProduct?.id == product.id) {
          _selectedProduct = updatedProduct;
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erreur lors de la mise à jour du produit: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Supprime un produit
  Future<bool> deleteProduct(int productId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _productService.deleteProduct(productId);
      if (success) {
        _products.removeWhere((p) => p.id == productId);

        if (_selectedProduct?.id == productId) {
          _selectedProduct = null;
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erreur lors de la suppression du produit: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Met à jour le stock d'un produit
  Future<bool> updateProductStock(int productId, int quantity) async {
    try {
      return await _productService.updateStock(productId, quantity);
    } catch (e) {
      _setError('Erreur lors de la mise à jour du stock: $e');
      return false;
    }
  }

  /// Sélectionne un produit
  void selectProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  /// Rafraîchit les produits
  Future<void> refresh({String? language}) async {
    await loadProducts(reset: true, language: language);
  }

  // Méthodes privées pour la gestion de l'état
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Nettoie les ressources
  @override
  void dispose() {
    _products.clear();
    _selectedProduct = null;
    _productSuppliers.clear();
    _productOptions.clear();
    _productOptionValues.clear();
    _productFeatures.clear();
    _productFeatureValues.clear();
    _customizationFields.clear();
    _priceRanges.clear();
    super.dispose();
  }

  // ===================
  // MÉTHODES SOUS-RESSOURCES
  // ===================

  void _setLoadingSubResources(bool loading) {
    if (_isLoadingSubResources != loading) {
      _isLoadingSubResources = loading;
      notifyListeners();
    }
  }

  /// Charge toutes les sous-ressources d'un produit
  Future<void> loadProductSubResources(int productId) async {
    _setLoadingSubResources(true);
    _clearError();

    try {
      await Future.wait([
        loadProductSuppliers(productId: productId),
        loadCustomizationFields(productId: productId),
        loadProductOptions(),
        loadProductFeatures(),
      ]);
    } catch (e) {
      _setError('Erreur lors du chargement des sous-ressources: $e');
    } finally {
      _setLoadingSubResources(false);
    }
  }

  /// Charge les fournisseurs de produits
  Future<void> loadProductSuppliers({
    int? productId,
    int? limit,
    int? offset,
  }) async {
    try {
      List<ProductSupplier> suppliers;
      if (productId != null) {
        suppliers = await _subResourcesService.getProductSuppliersByProduct(
          productId,
        );
      } else {
        suppliers = await _subResourcesService.getProductSuppliers(
          limit: limit,
          offset: offset,
        );
      }
      _productSuppliers = suppliers;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des fournisseurs: $e');
    }
  }

  /// Charge les options de produits
  Future<void> loadProductOptions({int? limit, int? offset}) async {
    try {
      final options = await _subResourcesService.getProductOptions(
        limit: limit,
        offset: offset,
      );
      _productOptions = options;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des options: $e');
    }
  }

  /// Charge les valeurs d'options de produits
  Future<void> loadProductOptionValues({int? limit, int? offset}) async {
    try {
      final values = await _subResourcesService.getProductOptionValues(
        limit: limit,
        offset: offset,
      );
      _productOptionValues = values;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des valeurs d\'options: $e');
    }
  }

  /// Charge les caractéristiques de produits
  Future<void> loadProductFeatures({int? limit, int? offset}) async {
    try {
      final features = await _subResourcesService.getProductFeatures(
        limit: limit,
        offset: offset,
      );
      _productFeatures = features;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des caractéristiques: $e');
    }
  }

  /// Charge les valeurs de caractéristiques de produits
  Future<void> loadProductFeatureValues({int? limit, int? offset}) async {
    try {
      final values = await _subResourcesService.getProductFeatureValues(
        limit: limit,
        offset: offset,
      );
      _productFeatureValues = values;
      notifyListeners();
    } catch (e) {
      _setError(
        'Erreur lors du chargement des valeurs de caractéristiques: $e',
      );
    }
  }

  /// Charge les champs de personnalisation
  Future<void> loadCustomizationFields({
    int? productId,
    int? limit,
    int? offset,
  }) async {
    try {
      List<CustomizationField> fields;
      if (productId != null) {
        fields = await _subResourcesService.getCustomizationFieldsByProduct(
          productId,
        );
      } else {
        fields = await _subResourcesService.getCustomizationFields(
          limit: limit,
          offset: offset,
        );
      }
      _customizationFields = fields;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des champs de personnalisation: $e');
    }
  }

  /// Charge les plages de prix
  Future<void> loadPriceRanges({int? limit, int? offset}) async {
    try {
      final ranges = await _subResourcesService.getPriceRanges(
        limit: limit,
        offset: offset,
      );
      _priceRanges = ranges;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des plages de prix: $e');
    }
  }

  /// Crée un nouveau fournisseur de produit
  Future<bool> createProductSupplier(ProductSupplier supplier) async {
    try {
      await _subResourcesService.createProductSupplier(supplier);
      await loadProductSuppliers(productId: supplier.idProduct);
      return true;
    } catch (e) {
      _setError('Erreur lors de la création du fournisseur: $e');
      return false;
    }
  }

  /// Met à jour un fournisseur de produit
  Future<bool> updateProductSupplier(int id, ProductSupplier supplier) async {
    try {
      await _subResourcesService.updateProductSupplier(id, supplier);
      await loadProductSuppliers(productId: supplier.idProduct);
      return true;
    } catch (e) {
      _setError('Erreur lors de la mise à jour du fournisseur: $e');
      return false;
    }
  }

  /// Supprime un fournisseur de produit
  Future<bool> deleteProductSupplier(int id, int productId) async {
    try {
      await _subResourcesService.deleteProductSupplier(id);
      await loadProductSuppliers(productId: productId);
      return true;
    } catch (e) {
      _setError('Erreur lors de la suppression du fournisseur: $e');
      return false;
    }
  }
}
