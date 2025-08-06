import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../models/product_supplier_model.dart';
import '../models/product_option_model.dart';
import '../models/product_option_value_model.dart';
import '../models/product_feature_model.dart';
import '../models/product_feature_value_model.dart';
import '../models/customization_field_model.dart';
import '../models/price_range_model.dart';

/// Service pour les sous-ressources des produits PrestaShop
class ProductSubResourcesService {
  final ApiClient _apiClient;

  ProductSubResourcesService(this._apiClient);

  // ===================
  // PRODUCT SUPPLIERS
  // ===================

  /// Récupère tous les fournisseurs de produits
  Future<List<ProductSupplier>> getProductSuppliers({
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _apiClient.get(
        '/product_suppliers',
        queryParameters: {
          'output_format': 'JSON',
          'display': 'full',
          if (limit != null) 'limit': '$offset,$limit',
        },
      );

      if (response.data['product_suppliers'] == null) return [];

      final suppliers = response.data['product_suppliers'];
      if (suppliers is List) {
        return suppliers
            .map(
              (json) => ProductSupplier.fromPrestaShopJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();
      } else if (suppliers is Map) {
        return [
          ProductSupplier.fromPrestaShopJson(
            Map<String, dynamic>.from(suppliers),
          ),
        ];
      }

      return [];
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des fournisseurs de produits: $e',
      );
    }
  }

  /// Récupère un fournisseur de produit par ID
  Future<ProductSupplier?> getProductSupplier(int id) async {
    try {
      final response = await _apiClient.get(
        '/product_suppliers/$id',
        queryParameters: {'output_format': 'JSON'},
      );

      if (response.data['product_suppliers'] != null) {
        return ProductSupplier.fromPrestaShopJson(
          response.data['product_suppliers'],
        );
      }
      return null;
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération du fournisseur de produit: $e',
      );
    }
  }

  /// Crée un nouveau fournisseur de produit
  Future<ProductSupplier> createProductSupplier(
    ProductSupplier supplier,
  ) async {
    try {
      final xmlData = supplier.toPrestaShopXml();
      final response = await _apiClient.post(
        '/product_suppliers',
        data: xmlData,
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      final id = int.tryParse(response.data?.toString() ?? '0') ?? 0;
      return await getProductSupplier(id) ?? supplier;
    } catch (e) {
      throw Exception(
        'Erreur lors de la création du fournisseur de produit: $e',
      );
    }
  }

  /// Met à jour un fournisseur de produit
  Future<ProductSupplier> updateProductSupplier(
    int id,
    ProductSupplier supplier,
  ) async {
    try {
      final xmlData = supplier.toPrestaShopXml();
      await _apiClient.put(
        '/product_suppliers/$id',
        data: xmlData,
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      return await getProductSupplier(id) ?? supplier;
    } catch (e) {
      throw Exception(
        'Erreur lors de la mise à jour du fournisseur de produit: $e',
      );
    }
  }

  /// Supprime un fournisseur de produit
  Future<bool> deleteProductSupplier(int id) async {
    try {
      await _apiClient.delete('/product_suppliers/$id');
      return true;
    } catch (e) {
      throw Exception(
        'Erreur lors de la suppression du fournisseur de produit: $e',
      );
    }
  }

  // ===================
  // PRODUCT OPTIONS
  // ===================

  /// Récupère toutes les options de produits
  Future<List<ProductOption>> getProductOptions({
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _apiClient.get(
        '/product_options',
        queryParameters: {
          'output_format': 'JSON',
          'display': 'full',
          if (limit != null) 'limit': '$offset,$limit',
        },
      );

      if (response.data['product_options'] == null) return [];

      final options = response.data['product_options'];
      if (options is List) {
        return options
            .map(
              (json) => ProductOption.fromPrestaShopJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();
      } else if (options is Map) {
        return [
          ProductOption.fromPrestaShopJson(Map<String, dynamic>.from(options)),
        ];
      }

      return [];
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des options de produits: $e',
      );
    }
  }

  /// Récupère une option de produit par ID
  Future<ProductOption?> getProductOption(int id) async {
    try {
      final response = await _apiClient.get(
        '/product_options/$id',
        queryParameters: {'output_format': 'JSON'},
      );

      if (response.data['product_options'] != null) {
        return ProductOption.fromPrestaShopJson(
          response.data['product_options'],
        );
      }
      return null;
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération de l\'option de produit: $e',
      );
    }
  }

  // ===================
  // PRODUCT OPTION VALUES
  // ===================

  /// Récupère toutes les valeurs d'options de produits
  Future<List<ProductOptionValue>> getProductOptionValues({
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _apiClient.get(
        '/product_option_values',
        queryParameters: {
          'output_format': 'JSON',
          'display': 'full',
          if (limit != null) 'limit': '$offset,$limit',
        },
      );

      if (response.data['product_option_values'] == null) return [];

      final values = response.data['product_option_values'];
      if (values is List) {
        return values
            .map(
              (json) => ProductOptionValue.fromPrestaShopJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();
      } else if (values is Map) {
        return [
          ProductOptionValue.fromPrestaShopJson(
            Map<String, dynamic>.from(values),
          ),
        ];
      }

      return [];
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des valeurs d\'options de produits: $e',
      );
    }
  }

  /// Récupère une valeur d'option de produit par ID
  Future<ProductOptionValue?> getProductOptionValue(int id) async {
    try {
      final response = await _apiClient.get(
        '/product_option_values/$id',
        queryParameters: {'output_format': 'JSON'},
      );

      if (response.data['product_option_values'] != null) {
        return ProductOptionValue.fromPrestaShopJson(
          response.data['product_option_values'],
        );
      }
      return null;
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération de la valeur d\'option de produit: $e',
      );
    }
  }

  // ===================
  // PRODUCT FEATURES
  // ===================

  /// Récupère toutes les caractéristiques de produits
  Future<List<ProductFeature>> getProductFeatures({
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _apiClient.get(
        '/product_features',
        queryParameters: {
          'output_format': 'JSON',
          'display': 'full',
          if (limit != null) 'limit': '$offset,$limit',
        },
      );

      if (response.data['product_features'] == null) return [];

      final features = response.data['product_features'];
      if (features is List) {
        return features
            .map(
              (json) => ProductFeature.fromPrestaShopJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();
      } else if (features is Map) {
        return [
          ProductFeature.fromPrestaShopJson(
            Map<String, dynamic>.from(features),
          ),
        ];
      }

      return [];
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des caractéristiques de produits: $e',
      );
    }
  }

  /// Récupère une caractéristique de produit par ID
  Future<ProductFeature?> getProductFeature(int id) async {
    try {
      final response = await _apiClient.get(
        '/product_features/$id',
        queryParameters: {'output_format': 'JSON'},
      );

      if (response.data['product_features'] != null) {
        return ProductFeature.fromPrestaShopJson(
          response.data['product_features'],
        );
      }
      return null;
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération de la caractéristique de produit: $e',
      );
    }
  }

  // ===================
  // PRODUCT FEATURE VALUES
  // ===================

  /// Récupère toutes les valeurs de caractéristiques de produits
  Future<List<ProductFeatureValue>> getProductFeatureValues({
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _apiClient.get(
        '/product_feature_values',
        queryParameters: {
          'output_format': 'JSON',
          'display': 'full',
          if (limit != null) 'limit': '$offset,$limit',
        },
      );

      if (response.data['product_feature_values'] == null) return [];

      final values = response.data['product_feature_values'];
      if (values is List) {
        return values
            .map(
              (json) => ProductFeatureValue.fromPrestaShopJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();
      } else if (values is Map) {
        return [
          ProductFeatureValue.fromPrestaShopJson(
            Map<String, dynamic>.from(values),
          ),
        ];
      }

      return [];
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des valeurs de caractéristiques de produits: $e',
      );
    }
  }

  /// Récupère une valeur de caractéristique de produit par ID
  Future<ProductFeatureValue?> getProductFeatureValue(int id) async {
    try {
      final response = await _apiClient.get(
        '/product_feature_values/$id',
        queryParameters: {'output_format': 'JSON'},
      );

      if (response.data['product_feature_values'] != null) {
        return ProductFeatureValue.fromPrestaShopJson(
          response.data['product_feature_values'],
        );
      }
      return null;
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération de la valeur de caractéristique de produit: $e',
      );
    }
  }

  // ===================
  // CUSTOMIZATION FIELDS
  // ===================

  /// Récupère tous les champs de personnalisation
  Future<List<CustomizationField>> getCustomizationFields({
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _apiClient.get(
        '/product_customization_fields',
        queryParameters: {
          'output_format': 'JSON',
          'display': 'full',
          if (limit != null) 'limit': '$offset,$limit',
        },
      );

      if (response.data['product_customization_fields'] == null) return [];

      final fields = response.data['product_customization_fields'];
      if (fields is List) {
        return fields
            .map(
              (json) => CustomizationField.fromPrestaShopJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();
      } else if (fields is Map) {
        return [
          CustomizationField.fromPrestaShopJson(
            Map<String, dynamic>.from(fields),
          ),
        ];
      }

      return [];
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des champs de personnalisation: $e',
      );
    }
  }

  /// Récupère un champ de personnalisation par ID
  Future<CustomizationField?> getCustomizationField(int id) async {
    try {
      final response = await _apiClient.get(
        '/product_customization_fields/$id',
        queryParameters: {'output_format': 'JSON'},
      );

      if (response.data['product_customization_field'] != null) {
        return CustomizationField.fromPrestaShopJson(
          Map<String, dynamic>.from(
            response.data['product_customization_field'],
          ),
        );
      }
      return null;
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération du champ de personnalisation: $e',
      );
    }
  }

  // ===================
  // PRICE RANGES
  // ===================

  /// Récupère toutes les plages de prix
  Future<List<PriceRange>> getPriceRanges({int? limit, int? offset}) async {
    try {
      final response = await _apiClient.get(
        '/price_ranges',
        queryParameters: {
          'output_format': 'JSON',
          'display': 'full',
          if (limit != null) 'limit': '$offset,$limit',
        },
      );

      if (response.data['price_ranges'] == null) return [];

      final ranges = response.data['price_ranges'];
      if (ranges is List) {
        return ranges
            .map(
              (json) => PriceRange.fromPrestaShopJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();
      } else if (ranges is Map) {
        return [
          PriceRange.fromPrestaShopJson(Map<String, dynamic>.from(ranges)),
        ];
      }

      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des plages de prix: $e');
    }
  }

  /// Récupère une plage de prix par ID
  Future<PriceRange?> getPriceRange(int id) async {
    try {
      final response = await _apiClient.get(
        '/price_ranges/$id',
        queryParameters: {'output_format': 'JSON'},
      );

      if (response.data['price_ranges'] != null) {
        return PriceRange.fromPrestaShopJson(
          Map<String, dynamic>.from(response.data['price_ranges']),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la plage de prix: $e');
    }
  }

  // ===================
  // MÉTHODES UTILITAIRES
  // ===================

  /// Récupère les fournisseurs pour un produit spécifique
  Future<List<ProductSupplier>> getProductSuppliersByProduct(
    int productId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/product_suppliers',
        queryParameters: {
          'output_format': 'JSON',
          'display': 'full',
          'filter[id_product]': productId.toString(),
        },
      );

      if (response.data['product_suppliers'] == null) return [];

      final suppliers = response.data['product_suppliers'];
      if (suppliers is List) {
        return suppliers
            .map((json) => ProductSupplier.fromPrestaShopJson(json))
            .toList();
      } else if (suppliers is Map) {
        return [
          ProductSupplier.fromPrestaShopJson(
            Map<String, dynamic>.from(suppliers),
          ),
        ];
      }

      return [];
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des fournisseurs du produit: $e',
      );
    }
  }

  /// Récupère les champs de personnalisation pour un produit spécifique
  Future<List<CustomizationField>> getCustomizationFieldsByProduct(
    int productId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/product_customization_fields',
        queryParameters: {
          'output_format': 'JSON',
          'display': 'full',
          'filter[id_product]': productId.toString(),
        },
      );

      if (response.data['product_customization_fields'] == null) return [];

      final fields = response.data['product_customization_fields'];
      if (fields is List) {
        return fields
            .map((json) => CustomizationField.fromPrestaShopJson(json))
            .toList();
      } else if (fields is Map) {
        return [
          CustomizationField.fromPrestaShopJson(
            Map<String, dynamic>.from(fields),
          ),
        ];
      }

      return [];
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des champs de personnalisation du produit: $e',
      );
    }
  }
}
