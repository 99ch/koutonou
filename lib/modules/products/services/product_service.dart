import 'package:koutonou/core/api/base_prestashop_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import '../models/product_model.dart';

class ProductService extends BasePrestaShopService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();
  static final AppLogger _logger = AppLogger();
  Future<List<Product>> getAllProducts({
    String? display = 'full', // Par défaut, récupérer tous les détails
    Map<String, String>? filters,
    List<String>? sort,
    int? limit,
    int? offset,
    String? language,
    bool? date,
    int? idShop,
    int? idGroupShop,
  }) async {
    _logger.info('Fetching all products from PrestaShop API');
    try {
      final queryParams = <String, dynamic>{};
      // Toujours inclure display=full pour avoir tous les détails
      queryParams['display'] = display ?? 'full';
      if (filters != null) queryParams.addAll(filters);
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
        'products',
        queryParameters: queryParams,
      );
      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['products'] is List) {
          final productsList = data['products'] as List;
          return productsList
              .map(
                (json) =>
                    Product.fromPrestaShopJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }
      return [];
    } catch (e) {
      _logger.error('Error fetching all products: $e');
      rethrow;
    }
  }

  Future<Product?> getProductById(
    int productId, {
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching product by ID: $productId');
    try {
      final queryParams = <String, dynamic>{};
      // Toujours inclure display=full pour avoir tous les détails
      queryParams['display'] = 'full';
      if (language != null) queryParams['language'] = language;
      if (idShop != null) queryParams['id_shop'] = idShop.toString();
      final response = await get<Map<String, dynamic>>(
        'products/$productId',
        queryParameters: queryParams,
      );
      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['product'] is Map<String, dynamic>) {
          return Product.fromPrestaShopJson(
            data['product'] as Map<String, dynamic>,
          );
        }
      }
      return null;
    } catch (e) {
      _logger.error('Error fetching product by ID $productId: $e');
      rethrow;
    }
  }

  Future<List<Product>> searchProducts(
    String query, {
    int? limit,
    String? language,
  }) async {
    _logger.info('Searching products with query: $query');

    try {
      final queryParams = <String, dynamic>{
        'filter[name]': '%$query%',
        'display': 'full', // Inclure tous les détails
      };

      if (limit != null) queryParams['limit'] = limit.toString();
      if (language != null) queryParams['language'] = language;

      final response = await get<Map<String, dynamic>>(
        'products',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['products'] is List) {
          final productsList = data['products'] as List;
          return productsList
              .map(
                (json) =>
                    Product.fromPrestaShopJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error searching products: $e');
      rethrow;
    }
  }

  Future<Product?> createProduct(Product product) async {
    _logger.info('Creating product: ${product.name}');

    try {
      final response = await post<Map<String, dynamic>>(
        'products',
        data: {'product': product.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        _logger.info('Create product response: $data');

        // PrestaShop ne retourne pas tous les champs après création
        // Il faut faire une requête GET pour récupérer le produit complet
        if (data['product'] is Map<String, dynamic>) {
          final productData = data['product'] as Map<String, dynamic>;
          final productId = int.tryParse(productData['id']?.toString() ?? '0');

          if (productId != null && productId > 0) {
            _logger.info(
              'Product created with ID: $productId, fetching full details...',
            );

            // Récupérer le produit complet
            final fullProduct = await getProductById(productId);
            if (fullProduct != null) {
              _logger.info('Created product name: ${fullProduct.name}');
              return fullProduct;
            }
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error creating product: $e');
      rethrow;
    }
  }

  Future<Product?> updateProduct(Product product) async {
    if (product.id == null) {
      throw ArgumentError('Product ID is required for update');
    }

    _logger.info('Updating product: ${product.id}');

    try {
      final response = await put<Map<String, dynamic>>(
        'products/${product.id}',
        data: {'product': product.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        _logger.info('Update product response: $data');

        // PrestaShop ne retourne pas tous les champs après mise à jour
        // Il faut faire une requête GET pour récupérer le produit complet
        if (data['product'] is Map<String, dynamic>) {
          final productData = data['product'] as Map<String, dynamic>;
          final productId = int.tryParse(productData['id']?.toString() ?? '0');

          if (productId != null && productId > 0) {
            _logger.info(
              'Product updated with ID: $productId, fetching full details...',
            );

            // Récupérer le produit complet
            final fullProduct = await getProductById(productId);
            if (fullProduct != null) {
              _logger.info('Updated product name: ${fullProduct.name}');
              return fullProduct;
            }
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error updating product ${product.id}: $e');
      rethrow;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    _logger.info('Deleting product: $productId');

    try {
      final response = await delete('products/$productId');
      return response.success;
    } catch (e) {
      _logger.error('Error deleting product $productId: $e');
      rethrow;
    }
  }

  /// Met à jour le stock d'un produit
  Future<bool> updateStock(int productId, int quantity) async {
    _logger.info('Updating stock for product: $productId, quantity: $quantity');

    try {
      final response = await put<Map<String, dynamic>>(
        'products/$productId',
        data: {
          'product': {'quantity': quantity.toString()},
        },
      );

      return response.success;
    } catch (e) {
      _logger.error('Error updating stock for product $productId: $e');
      rethrow;
    }
  }
}
