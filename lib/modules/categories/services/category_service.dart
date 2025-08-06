import 'package:koutonou/core/api/base_prestashop_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import '../models/category_model.dart';

class CategoryService extends BasePrestaShopService {
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  static final AppLogger _logger = AppLogger();

  /// Récupère toutes les catégories
  Future<List<Category>> getAllCategories({
    String? display = 'full',
    Map<String, String>? filters,
    List<String>? sort,
    int? limit,
    int? offset,
    String? language,
    bool? date,
    int? idShop,
    int? idGroupShop,
  }) async {
    _logger.info('Fetching all categories from PrestaShop API');

    try {
      // Always use these base parameters for consistent results
      final queryParams = <String, dynamic>{
        'display': 'full', // Always get full data
        'filter[active]': '1', // Only get active categories
        'sort': 'position_ASC', // Sort by position
      };

      // Add optional filters
      if (filters != null) {
        for (final entry in filters.entries) {
          queryParams['filter[${entry.key}]'] = entry.value;
        }
      }

      // Add other optional parameters
      if (sort != null) queryParams['sort'] = sort.join(',');
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (language != null) queryParams['language'] = language;
      if (date != null) queryParams['date'] = date.toString();
      if (idShop != null) queryParams['id_shop'] = idShop.toString();
      if (idGroupShop != null) {
        queryParams['id_group_shop'] = idGroupShop.toString();
      }

      final response = await get<Map<String, dynamic>>(
        'categories',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['categories'] is List) {
          final categoriesList = data['categories'] as List;
          return categoriesList
              .map(
                (json) =>
                    Category.fromPrestaShopJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error fetching all categories: $e');
      rethrow;
    }
  }

  /// Récupère une catégorie par ID
  Future<Category?> getCategoryById(
    int categoryId, {
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching category by ID: $categoryId');

    try {
      final queryParams = <String, dynamic>{};
      queryParams['display'] = 'full';
      if (language != null) queryParams['language'] = language;
      if (idShop != null) queryParams['id_shop'] = idShop.toString();

      final response = await get<Map<String, dynamic>>(
        'categories/$categoryId',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['category'] is Map<String, dynamic>) {
          return Category.fromPrestaShopJson(
            data['category'] as Map<String, dynamic>,
          );
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error fetching category by ID $categoryId: $e');
      rethrow;
    }
  }

  /// Récupère les catégories racines
  Future<List<Category>> getRootCategories({
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching root categories');

    return await getAllCategories(
      filters: {'is_root_category': '1'},
      language: language,
    );
  }

  /// Récupère les catégories enfants d'une catégorie parent
  Future<List<Category>> getChildCategories(
    int parentId, {
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching child categories for parent: $parentId');

    return await getAllCategories(
      filters: {'id_parent': parentId.toString()},
      language: language,
    );
  }

  /// Recherche des catégories par nom
  Future<List<Category>> searchCategories(
    String query, {
    int? limit,
    String? language,
  }) async {
    _logger.info('Searching categories with query: $query');

    try {
      final queryParams = <String, dynamic>{
        'filter[name]': '%$query%',
        'display': 'full',
      };

      if (limit != null) queryParams['limit'] = limit.toString();
      if (language != null) queryParams['language'] = language;

      final response = await get<Map<String, dynamic>>(
        'categories',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['categories'] is List) {
          final categoriesList = data['categories'] as List;
          return categoriesList
              .map(
                (json) =>
                    Category.fromPrestaShopJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error searching categories: $e');
      rethrow;
    }
  }

  /// Crée une nouvelle catégorie
  Future<Category?> createCategory(Category category) async {
    _logger.info('Creating category: ${category.name}');

    try {
      final response = await post<Map<String, dynamic>>(
        'categories',
        data: {'category': category.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        _logger.info('Create category response: $data');

        // Récupérer la catégorie complète après création
        if (data['category'] is Map<String, dynamic>) {
          final categoryData = data['category'] as Map<String, dynamic>;
          final categoryId = int.tryParse(
            categoryData['id']?.toString() ?? '0',
          );

          if (categoryId != null && categoryId > 0) {
            _logger.info(
              'Category created with ID: $categoryId, fetching full details...',
            );

            final fullCategory = await getCategoryById(categoryId);
            if (fullCategory != null) {
              _logger.info('Created category name: ${fullCategory.name}');
              return fullCategory;
            }
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error creating category: $e');
      rethrow;
    }
  }

  /// Met à jour une catégorie existante
  Future<Category?> updateCategory(Category category) async {
    if (category.id == null) {
      throw ArgumentError('Category ID is required for update');
    }

    _logger.info('Updating category: ${category.id}');

    try {
      final response = await put<Map<String, dynamic>>(
        'categories/${category.id}',
        data: {'category': category.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        _logger.info('Update category response: $data');

        // Récupérer la catégorie complète après mise à jour
        if (data['category'] is Map<String, dynamic>) {
          final categoryData = data['category'] as Map<String, dynamic>;
          final categoryId = int.tryParse(
            categoryData['id']?.toString() ?? '0',
          );

          if (categoryId != null && categoryId > 0) {
            _logger.info(
              'Category updated with ID: $categoryId, fetching full details...',
            );

            final fullCategory = await getCategoryById(categoryId);
            if (fullCategory != null) {
              _logger.info('Updated category name: ${fullCategory.name}');
              return fullCategory;
            }
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error updating category ${category.id}: $e');
      rethrow;
    }
  }

  /// Supprime une catégorie
  Future<bool> deleteCategory(int categoryId) async {
    _logger.info('Deleting category: $categoryId');

    try {
      final response = await delete('categories/$categoryId');
      return response.success;
    } catch (e) {
      _logger.error('Error deleting category $categoryId: $e');
      rethrow;
    }
  }

  /// Récupère la hiérarchie complète des catégories sous forme d'arbre
  Future<List<CategoryTree>> getCategoryTree({
    String? language,
    int? idShop,
  }) async {
    _logger.info('Building category tree');

    try {
      // Récupérer toutes les catégories
      final allCategories = await getAllCategories(language: language);

      // Construire l'arbre hiérarchique
      return _buildCategoryTree(allCategories);
    } catch (e) {
      _logger.error('Error building category tree: $e');
      rethrow;
    }
  }

  /// Construit l'arbre hiérarchique des catégories
  List<CategoryTree> _buildCategoryTree(List<Category> categories) {
    final List<CategoryTree> roots = [];
    final Map<int, CategoryTree> treeMap = {};

    // Créer les nœuds de l'arbre
    for (final category in categories) {
      if (category.id != null) {
        treeMap[category.id!] = CategoryTree.withMutableChildren(
          category: category,
        );
      }
    }

    // Construire la hiérarchie
    for (final category in categories) {
      if (category.id != null) {
        final currentNode = treeMap[category.id!]!;

        if (category.idParent != null && category.idParent! > 0) {
          // Catégorie enfant
          final parentNode = treeMap[category.idParent!];
          if (parentNode != null) {
            parentNode.addChild(currentNode);
            currentNode.parent = parentNode;
          } else {
            // Parent non trouvé, traiter comme racine
            roots.add(currentNode);
          }
        } else {
          // Catégorie racine
          roots.add(currentNode);
        }
      }
    }

    // Trier les racines et leurs enfants
    roots.sort(
      (a, b) => (a.category.position ?? 0).compareTo(b.category.position ?? 0),
    );
    for (final root in roots) {
      _sortCategoryTreeChildren(root);
    }

    return roots;
  }

  /// Trie récursivement les enfants d'un nœud de l'arbre
  void _sortCategoryTreeChildren(CategoryTree node) {
    node.children.sort(
      (a, b) => (a.category.position ?? 0).compareTo(b.category.position ?? 0),
    );
    for (final child in node.children) {
      _sortCategoryTreeChildren(child);
    }
  }
}
