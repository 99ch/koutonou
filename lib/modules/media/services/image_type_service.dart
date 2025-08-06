import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../models/image_type_model.dart';

/// Service pour la gestion des types d'images PrestaShop
class ImageTypeService {
  final ApiClient _apiClient;

  ImageTypeService(this._apiClient);

  /// Récupère tous les types d'images
  Future<List<ImageType>> getImageTypes({int? limit, int? offset}) async {
    try {
      final response = await _apiClient.get(
        '/image_types',
        queryParameters: {
          'output_format': 'JSON',
          'display': 'full',
          if (limit != null) 'limit': '$offset,$limit',
        },
      );

      if (response.data['image_types'] == null) return [];

      final types = response.data['image_types'];
      if (types is List) {
        return types
            .map(
              (json) =>
                  ImageType.fromPrestaShopJson(Map<String, dynamic>.from(json)),
            )
            .toList();
      } else if (types is Map) {
        return [ImageType.fromPrestaShopJson(Map<String, dynamic>.from(types))];
      }

      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des types d\'images: $e');
    }
  }

  /// Récupère un type d'image par ID
  Future<ImageType?> getImageTypeById(int id) async {
    try {
      final response = await _apiClient.get(
        '/image_types/$id',
        queryParameters: {'output_format': 'JSON'},
      );

      if (response.data['image_type'] != null) {
        return ImageType.fromPrestaShopJson(
          Map<String, dynamic>.from(response.data['image_type']),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du type d\'image: $e');
    }
  }

  /// Crée un nouveau type d'image
  Future<ImageType> createImageType(ImageType imageType) async {
    try {
      final xmlData = imageType.toPrestaShopXml();
      final response = await _apiClient.post(
        '/image_types',
        data: xmlData,
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      final id = int.tryParse(response.data?.toString() ?? '0') ?? 0;
      return await getImageTypeById(id) ?? imageType;
    } catch (e) {
      throw Exception('Erreur lors de la création du type d\'image: $e');
    }
  }

  /// Met à jour un type d'image
  Future<ImageType> updateImageType(int id, ImageType imageType) async {
    try {
      final xmlData = imageType.toPrestaShopXml();
      await _apiClient.put(
        '/image_types/$id',
        data: xmlData,
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      return await getImageTypeById(id) ?? imageType;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du type d\'image: $e');
    }
  }

  /// Supprime un type d'image
  Future<bool> deleteImageType(int id) async {
    try {
      await _apiClient.delete('/image_types/$id');
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la suppression du type d\'image: $e');
    }
  }

  /// Récupère les types d'images pour une catégorie spécifique
  Future<List<ImageType>> getImageTypesForCategory(String category) async {
    final allTypes = await getImageTypes();

    switch (category.toLowerCase()) {
      case 'products':
        return allTypes.where((type) => type.products).toList();
      case 'categories':
        return allTypes.where((type) => type.categories).toList();
      case 'manufacturers':
        return allTypes.where((type) => type.manufacturers).toList();
      case 'suppliers':
        return allTypes.where((type) => type.suppliers).toList();
      case 'stores':
        return allTypes.where((type) => type.stores).toList();
      default:
        return allTypes;
    }
  }

  /// Récupère les dimensions recommandées pour une catégorie
  Future<List<String>> getRecommendedSizes(String category) async {
    final types = await getImageTypesForCategory(category);
    return types.map((type) => type.dimensions).toSet().toList();
  }

  /// Valide les dimensions d'une image
  Future<bool> validateImageDimensions(
    String category,
    int width,
    int height,
  ) async {
    final types = await getImageTypesForCategory(category);
    return types.any((type) => type.width == width && type.height == height);
  }
}
