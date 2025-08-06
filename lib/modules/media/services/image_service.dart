import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../core/api/api_client.dart';
import '../models/image_model.dart';

/// Service pour la gestion des images PrestaShop
class ImageService {
  final ApiClient _apiClient;

  ImageService(this._apiClient);

  /// Récupère les métadonnées des images par catégorie
  Future<ImageMetadata> getImageMetadata(ImageCategory category) async {
    try {
      final response = await _apiClient.get(
        '/images',
        queryParameters: {'output_format': 'JSON'},
      );

      // Parse la réponse pour extraire les métadonnées
      final data = response.data;
      if (data != null && data['image_types'] != null) {
        final categoryData = data['image_types'][category.name];
        if (categoryData != null) {
          return ImageMetadata.fromXmlAttributes(category, categoryData);
        }
      }

      // Métadonnées par défaut si non trouvées
      return ImageMetadata(
        category: category,
        href: '/api/images/${category.name}',
        canGet: true,
        canPost: true,
        canDelete: true,
        allowedMimeTypes: category.allowedMimeTypes,
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des métadonnées: $e');
    }
  }

  /// Récupère toutes les images d'une catégorie
  Future<List<PrestaShopImage>> getImages(
    ImageCategory category, {
    int? entityId,
    int? limit,
    int? offset,
  }) async {
    try {
      String endpoint = '/images/${category.name}';
      if (entityId != null) {
        endpoint += '/$entityId';
      }

      final response = await _apiClient.get(
        endpoint,
        queryParameters: {
          'output_format': 'JSON',
          if (limit != null) 'limit': '$offset,$limit',
        },
      );

      final images = <PrestaShopImage>[];
      if (response.data != null) {
        final data = response.data;

        // La structure varie selon l'endpoint
        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              images.add(PrestaShopImage.fromPrestaShopJson(item, category));
            }
          }
        } else if (data is Map<String, dynamic>) {
          images.add(PrestaShopImage.fromPrestaShopJson(data, category));
        }
      }

      return images;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des images: $e');
    }
  }

  /// Récupère une image spécifique
  Future<PrestaShopImage?> getImageById(
    ImageCategory category,
    int entityId,
    int imageId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/images/${category.name}/$entityId/$imageId',
        queryParameters: {'output_format': 'JSON'},
      );

      if (response.data != null) {
        return PrestaShopImage.fromPrestaShopJson(
          response.data as Map<String, dynamic>,
          category,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'image: $e');
    }
  }

  /// Upload une image depuis un fichier
  Future<PrestaShopImage?> uploadImageFromFile(
    ImageCategory category,
    int entityId,
    File imageFile, {
    String? filename,
  }) async {
    try {
      // Validation du type MIME
      final mimeType = _getMimeTypeFromFile(imageFile);
      final allowedTypes = category.allowedMimeTypes;

      if (!allowedTypes.contains(mimeType)) {
        throw Exception('Type de fichier non supporté: $mimeType');
      }

      // Préparation du fichier
      final bytes = await imageFile.readAsBytes();
      final fileName = filename ?? imageFile.path.split('/').last;

      return await uploadImageFromBytes(
        category,
        entityId,
        bytes,
        fileName,
        mimeType,
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'upload depuis fichier: $e');
    }
  }

  /// Upload une image depuis des bytes
  Future<PrestaShopImage?> uploadImageFromBytes(
    ImageCategory category,
    int entityId,
    Uint8List imageBytes,
    String filename,
    String mimeType,
  ) async {
    try {
      // Validation du type MIME
      final allowedTypes = category.allowedMimeTypes;
      if (!allowedTypes.contains(mimeType)) {
        throw Exception('Type MIME non supporté: $mimeType');
      }

      // Création du FormData
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: filename,
          contentType: MediaType.parse(mimeType),
        ),
      });

      // Upload
      final response = await _apiClient.post(
        '/images/${category.name}/$entityId',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      // Parse la réponse
      if (response.data != null) {
        return PrestaShopImage.fromPrestaShopJson(
          response.data as Map<String, dynamic>,
          category,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }

  /// Upload multiple images
  Future<List<PrestaShopImage>> uploadMultipleImages(
    ImageCategory category,
    int entityId,
    List<File> imageFiles,
  ) async {
    final uploadedImages = <PrestaShopImage>[];

    for (final file in imageFiles) {
      try {
        final image = await uploadImageFromFile(category, entityId, file);
        if (image != null) {
          uploadedImages.add(image);
        }
      } catch (e) {
        // Log l'erreur mais continue avec les autres fichiers
        print('Erreur upload ${file.path}: $e');
      }
    }

    return uploadedImages;
  }

  /// Télécharge une image
  Future<Uint8List?> downloadImage(
    ImageCategory category,
    int entityId,
    int imageId, {
    String? imageType, // Par exemple: 'large', 'medium', 'small'
  }) async {
    try {
      String endpoint = '/images/${category.name}/$entityId/$imageId';
      if (imageType != null) {
        endpoint += '/$imageType';
      }

      final response = await _apiClient.get(
        endpoint,
        options: Options(responseType: ResponseType.bytes),
      );

      return response.data as Uint8List?;
    } catch (e) {
      throw Exception('Erreur lors du téléchargement: $e');
    }
  }

  /// Supprime une image
  Future<bool> deleteImage(
    ImageCategory category,
    int entityId,
    int imageId,
  ) async {
    try {
      await _apiClient.delete('/images/${category.name}/$entityId/$imageId');
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  /// Supprime toutes les images d'une entité
  Future<bool> deleteAllImages(ImageCategory category, int entityId) async {
    try {
      await _apiClient.delete('/images/${category.name}/$entityId');
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la suppression des images: $e');
    }
  }

  /// Redimensionne automatiquement une image selon les types configurés
  Future<Map<String, PrestaShopImage>> resizeAndUploadImage(
    ImageCategory category,
    int entityId,
    File imageFile,
    List<String> imageTypes, // ['large', 'medium', 'small']
  ) async {
    final results = <String, PrestaShopImage>{};

    for (final type in imageTypes) {
      try {
        // Upload l'image avec le type spécifié
        final image = await uploadImageFromFile(
          category,
          entityId,
          imageFile,
          filename: '${type}_${imageFile.path.split('/').last}',
        );

        if (image != null) {
          results[type] = image;
        }
      } catch (e) {
        print('Erreur redimensionnement $type: $e');
      }
    }

    return results;
  }

  /// Obtient l'URL complète d'une image
  String getImageUrl(
    ImageCategory category,
    int entityId,
    int imageId, {
    String? imageType,
  }) {
    String url =
        '${_apiClient.baseUrl}/images/${category.name}/$entityId/$imageId';
    if (imageType != null) {
      url += '/$imageType';
    }
    return url;
  }

  /// Valide un fichier image
  Future<bool> validateImageFile(File imageFile, ImageCategory category) async {
    try {
      // Vérification de l'existence
      if (!await imageFile.exists()) return false;

      // Vérification de la taille
      final size = await imageFile.length();
      if (size == 0 || size > 10 * 1024 * 1024) return false; // Max 10MB

      // Vérification du type MIME
      final mimeType = _getMimeTypeFromFile(imageFile);
      return category.allowedMimeTypes.contains(mimeType);
    } catch (e) {
      return false;
    }
  }

  /// Détermine le type MIME depuis un fichier
  String _getMimeTypeFromFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  /// Obtient les statistiques des images
  Future<Map<String, dynamic>> getImageStats(ImageCategory category) async {
    try {
      final images = await getImages(category);

      return {
        'total': images.length,
        'totalSize': images.fold<int>(
          0,
          (sum, img) => sum + (img.fileSize ?? 0),
        ),
        'avgSize': images.isNotEmpty
            ? images.fold<int>(0, (sum, img) => sum + (img.fileSize ?? 0)) /
                  images.length
            : 0,
        'mimeTypes': images.map((img) => img.mimeType).toSet().toList(),
        'recent': images.where((img) => img.isRecent).length,
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }
}
