import 'package:flutter/foundation.dart';
import '../models/category_model.dart' as cat_model;
import '../services/category_service.dart';

/// Provider pour la gestion de l'état des catégories
class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  // État des catégories
  List<cat_model.Category> _categories = [];
  List<cat_model.CategoryTree> _categoryTree = [];
  cat_model.Category? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  bool _hasNextPage = true;

  // Filtres
  String? _searchQuery;
  int? _parentCategoryFilter;
  bool _activeOnlyFilter = true;

  // Getters
  List<cat_model.Category> get categories => _categories;
  List<cat_model.CategoryTree> get categoryTree => _categoryTree;
  cat_model.Category? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  bool get hasNextPage => _hasNextPage;
  String? get searchQuery => _searchQuery;
  int? get parentCategoryFilter => _parentCategoryFilter;
  bool get activeOnlyFilter => _activeOnlyFilter;

  /// Charge toutes les catégories avec pagination
  Future<void> loadCategories({bool reset = false, String? language}) async {
    if (_isLoading) return;

    if (reset) {
      _currentPage = 1;
      _categories.clear();
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

      if (_parentCategoryFilter != null) {
        filters ??= {};
        filters['id_parent'] = _parentCategoryFilter.toString();
      }

      if (_activeOnlyFilter) {
        filters ??= {};
        filters['active'] = '1';
      }

      // DIAGNOSTIC : Charger toutes les catégories sans pagination
      final newCategories = await _categoryService.getAllCategories(
        filters: filters,
        limit: null,
        offset: null,
        language: language,
      );

      if (reset) {
        _categories = newCategories;
      } else {
        _categories.addAll(newCategories);
      }

      _hasNextPage = newCategories.length == _itemsPerPage;
      if (_hasNextPage) _currentPage++;
    } catch (e) {
      _setError('Erreur lors du chargement des catégories: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charge plus de catégories (pagination)
  Future<void> loadMoreCategories({String? language}) async {
    if (!_hasNextPage || _isLoading) return;
    await loadCategories(reset: false, language: language);
  }

  /// Charge l'arbre hiérarchique des catégories
  Future<void> loadCategoryTree({String? language}) async {
    _setLoading(true);
    _clearError();

    try {
      _categoryTree = await _categoryService.getCategoryTree(
        language: language,
      );
    } catch (e) {
      _setError('Erreur lors du chargement de l\'arbre des catégories: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Recherche des catégories par nom
  Future<void> searchCategories(String query, {String? language}) async {
    _searchQuery = query;
    await loadCategories(reset: true, language: language);
  }

  /// Filtre les catégories par parent
  Future<void> filterByParent(int? parentId, {String? language}) async {
    _parentCategoryFilter = parentId;
    await loadCategories(reset: true, language: language);
  }

  /// Active/désactive le filtre "actives seulement"
  Future<void> toggleActiveFilter({String? language}) async {
    _activeOnlyFilter = !_activeOnlyFilter;
    await loadCategories(reset: true, language: language);
  }

  /// Efface tous les filtres
  Future<void> clearFilters({String? language}) async {
    _searchQuery = null;
    _parentCategoryFilter = null;
    _activeOnlyFilter = true;
    await loadCategories(reset: true, language: language);
  }

  /// Charge une catégorie par ID
  Future<void> loadCategoryById(int categoryId, {String? language}) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedCategory = await _categoryService.getCategoryById(
        categoryId,
        language: language,
      );
    } catch (e) {
      _setError('Erreur lors du chargement de la catégorie: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charge les catégories racines
  Future<void> loadRootCategories({String? language}) async {
    _setLoading(true);
    _clearError();

    try {
      _categories = await _categoryService.getRootCategories(
        language: language,
      );
    } catch (e) {
      _setError('Erreur lors du chargement des catégories racines: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charge les catégories enfants d'une catégorie parent
  Future<void> loadChildCategories(int parentId, {String? language}) async {
    _setLoading(true);
    _clearError();

    try {
      _categories = await _categoryService.getChildCategories(
        parentId,
        language: language,
      );
    } catch (e) {
      _setError('Erreur lors du chargement des catégories enfants: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Crée une nouvelle catégorie
  Future<bool> createCategory(cat_model.Category category) async {
    _setLoading(true);
    _clearError();

    try {
      final createdCategory = await _categoryService.createCategory(category);
      if (createdCategory != null) {
        // Ajouter la nouvelle catégorie à la liste
        _categories.insert(0, createdCategory);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erreur lors de la création de la catégorie: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Met à jour une catégorie existante
  Future<bool> updateCategory(cat_model.Category category) async {
    if (category.id == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedCategory = await _categoryService.updateCategory(category);
      if (updatedCategory != null) {
        // Mettre à jour la catégorie dans la liste
        final index = _categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _categories[index] = updatedCategory;
        }

        // Mettre à jour la catégorie sélectionnée si c'est la même
        if (_selectedCategory?.id == category.id) {
          _selectedCategory = updatedCategory;
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erreur lors de la mise à jour de la catégorie: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Supprime une catégorie
  Future<bool> deleteCategory(int categoryId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _categoryService.deleteCategory(categoryId);
      if (success) {
        // Supprimer la catégorie de la liste
        _categories.removeWhere((c) => c.id == categoryId);

        // Réinitialiser la catégorie sélectionnée si c'est celle supprimée
        if (_selectedCategory?.id == categoryId) {
          _selectedCategory = null;
        }

        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Erreur lors de la suppression de la catégorie: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sélectionne une catégorie
  void selectCategory(cat_model.Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Trouve une catégorie par ID dans la liste actuelle
  cat_model.Category? findCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Trouve une catégorie par nom dans la liste actuelle
  cat_model.Category? findCategoryByName(String name) {
    try {
      return _categories.firstWhere(
        (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Récupère les statistiques des catégories
  CategoryStats getStats() {
    final totalCategories = _categories.length;
    final activeCategories = _categories.where((c) => c.active).length;
    final rootCategories = _categories.where((c) => c.isRootCategory).length;
    final categoriesWithProducts = _categories
        .where((c) => c.productIds.isNotEmpty)
        .length;

    return CategoryStats(
      totalCategories: totalCategories,
      activeCategories: activeCategories,
      rootCategories: rootCategories,
      categoriesWithProducts: categoriesWithProducts,
      averageProductsPerCategory: totalCategories > 0
          ? _categories
                    .map((c) => c.productIds.length)
                    .reduce((a, b) => a + b) /
                totalCategories
          : 0.0,
    );
  }

  // Méthodes privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Nettoie les ressources
  @override
  void dispose() {
    _categories.clear();
    _categoryTree.clear();
    super.dispose();
  }
}

/// Modèle pour les statistiques des catégories
class CategoryStats {
  final int totalCategories;
  final int activeCategories;
  final int rootCategories;
  final int categoriesWithProducts;
  final double averageProductsPerCategory;

  const CategoryStats({
    required this.totalCategories,
    required this.activeCategories,
    required this.rootCategories,
    required this.categoriesWithProducts,
    required this.averageProductsPerCategory,
  });

  int get inactiveCategories => totalCategories - activeCategories;

  double get activePercentage =>
      totalCategories > 0 ? (activeCategories / totalCategories) * 100 : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'totalCategories': totalCategories,
      'activeCategories': activeCategories,
      'inactiveCategories': inactiveCategories,
      'rootCategories': rootCategories,
      'categoriesWithProducts': categoriesWithProducts,
      'averageProductsPerCategory': averageProductsPerCategory,
      'activePercentage': activePercentage,
    };
  }
}
