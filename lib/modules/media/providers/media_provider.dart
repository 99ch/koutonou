import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/image_type_model.dart';
import '../models/image_model.dart';
import '../services/image_type_service.dart';
import '../services/image_service.dart';

/// Provider pour la gestion des médias (images et types d'images)
class MediaProvider with ChangeNotifier {
  final ImageTypeService _imageTypeService;
  final ImageService _imageService;

  MediaProvider({
    required ImageTypeService imageTypeService,
    required ImageService imageService,
  }) : _imageTypeService = imageTypeService,
       _imageService = imageService;

  // ===================
  // ÉTAT DES TYPES D'IMAGES
  // ===================

  List<ImageType> _imageTypes = [];
  bool _isLoadingImageTypes = false;
  String? _imageTypesError;

  List<ImageType> get imageTypes => _imageTypes;
  bool get isLoadingImageTypes => _isLoadingImageTypes;
  String? get imageTypesError => _imageTypesError;

  // ===================
  // ÉTAT DES IMAGES
  // ===================

  final Map<ImageCategory, List<PrestaShopImage>> _imagesByCategory = {};
  final Map<ImageCategory, ImageMetadata> _imageMetadata = {};
  bool _isLoadingImages = false;
  String? _imagesError;

  Map<ImageCategory, List<PrestaShopImage>> get imagesByCategory =>
      _imagesByCategory;
  Map<ImageCategory, ImageMetadata> get imageMetadata => _imageMetadata;
  bool get isLoadingImages => _isLoadingImages;
  String? get imagesError => _imagesError;

  // ===================
  // ÉTAT D'UPLOAD
  // ===================

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadError;

  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get uploadError => _uploadError;

  // ===================
  // MÉTHODES TYPES D'IMAGES
  // ===================

  /// Charge tous les types d'images
  Future<void> loadImageTypes() async {
    _isLoadingImageTypes = true;
    _imageTypesError = null;
    notifyListeners();

    try {
      _imageTypes = await _imageTypeService.getImageTypes();
      _imageTypesError = null;
    } catch (e) {
      _imageTypesError = e.toString();
      _imageTypes = [];
    } finally {
      _isLoadingImageTypes = false;
      notifyListeners();
    }
  }

  /// Crée un nouveau type d'image
  Future<bool> createImageType(ImageType imageType) async {
    try {
      final newImageType = await _imageTypeService.createImageType(imageType);
      _imageTypes.add(newImageType);
      notifyListeners();
      return true;
    } catch (e) {
      _imageTypesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Met à jour un type d'image
  Future<bool> updateImageType(int id, ImageType imageType) async {
    try {
      final updatedImageType = await _imageTypeService.updateImageType(
        id,
        imageType,
      );
      final index = _imageTypes.indexWhere((type) => type.id == id);
      if (index != -1) {
        _imageTypes[index] = updatedImageType;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _imageTypesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Supprime un type d'image
  Future<bool> deleteImageType(int id) async {
    try {
      await _imageTypeService.deleteImageType(id);
      _imageTypes.removeWhere((type) => type.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _imageTypesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Obtient les types d'images pour une catégorie
  List<ImageType> getImageTypesForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'products':
        return _imageTypes.where((type) => type.products).toList();
      case 'categories':
        return _imageTypes.where((type) => type.categories).toList();
      case 'manufacturers':
        return _imageTypes.where((type) => type.manufacturers).toList();
      case 'suppliers':
        return _imageTypes.where((type) => type.suppliers).toList();
      case 'stores':
        return _imageTypes.where((type) => type.stores).toList();
      default:
        return _imageTypes;
    }
  }

  // ===================
  // MÉTHODES IMAGES
  // ===================

  /// Charge les métadonnées d'images pour toutes les catégories
  Future<void> loadImageMetadata() async {
    for (final category in ImageCategory.values) {
      try {
        final metadata = await _imageService.getImageMetadata(category);
        _imageMetadata[category] = metadata;
      } catch (e) {
        debugPrint('Erreur metadata ${category.name}: $e');
      }
    }
    notifyListeners();
  }

  /// Charge les images d'une catégorie spécifique
  Future<void> loadImages(
    ImageCategory category, {
    int? entityId,
    int? limit,
    int? offset,
  }) async {
    _isLoadingImages = true;
    _imagesError = null;
    notifyListeners();

    try {
      final images = await _imageService.getImages(
        category,
        entityId: entityId,
        limit: limit,
        offset: offset,
      );
      _imagesByCategory[category] = images;
      _imagesError = null;
    } catch (e) {
      _imagesError = e.toString();
      _imagesByCategory[category] = [];
    } finally {
      _isLoadingImages = false;
      notifyListeners();
    }
  }

  /// Charge les images pour toutes les catégories
  Future<void> loadAllImages({int? limit}) async {
    for (final category in ImageCategory.values) {
      await loadImages(category, limit: limit);
    }
  }

  /// Upload une image
  Future<PrestaShopImage?> uploadImage(
    ImageCategory category,
    int entityId,
    File imageFile, {
    String? filename,
    void Function(double)? onProgress,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _uploadError = null;
    notifyListeners();

    try {
      // Validation du fichier
      final isValid = await _imageService.validateImageFile(
        imageFile,
        category,
      );
      if (!isValid) {
        throw Exception('Fichier image invalide');
      }

      // Simulation du progrès d'upload
      _uploadProgress = 0.1;
      onProgress?.call(_uploadProgress);
      notifyListeners();

      final image = await _imageService.uploadImageFromFile(
        category,
        entityId,
        imageFile,
        filename: filename,
      );

      if (image != null) {
        // Ajouter à la liste locale
        _imagesByCategory[category] ??= [];
        _imagesByCategory[category]!.add(image);

        _uploadProgress = 1.0;
        onProgress?.call(_uploadProgress);
        notifyListeners();

        return image;
      }

      return null;
    } catch (e) {
      _uploadError = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// Upload multiple images
  Future<List<PrestaShopImage>> uploadMultipleImages(
    ImageCategory category,
    int entityId,
    List<File> imageFiles, {
    void Function(double)? onProgress,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _uploadError = null;
    notifyListeners();

    final uploadedImages = <PrestaShopImage>[];

    try {
      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final progress = (i + 1) / imageFiles.length;

        _uploadProgress = progress;
        onProgress?.call(progress);
        notifyListeners();

        try {
          final image = await _imageService.uploadImageFromFile(
            category,
            entityId,
            file,
          );

          if (image != null) {
            uploadedImages.add(image);

            // Ajouter à la liste locale
            _imagesByCategory[category] ??= [];
            _imagesByCategory[category]!.add(image);
          }
        } catch (e) {
          debugPrint('Erreur upload ${file.path}: $e');
        }
      }

      return uploadedImages;
    } catch (e) {
      _uploadError = e.toString();
      return uploadedImages;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// Télécharge une image
  Future<Uint8List?> downloadImage(
    ImageCategory category,
    int entityId,
    int imageId, {
    String? imageType,
  }) async {
    try {
      return await _imageService.downloadImage(
        category,
        entityId,
        imageId,
        imageType: imageType,
      );
    } catch (e) {
      _imagesError = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Supprime une image
  Future<bool> deleteImage(
    ImageCategory category,
    int entityId,
    int imageId,
  ) async {
    try {
      final success = await _imageService.deleteImage(
        category,
        entityId,
        imageId,
      );

      if (success) {
        // Retirer de la liste locale
        _imagesByCategory[category]?.removeWhere((img) => img.id == imageId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _imagesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Supprime toutes les images d'une entité
  Future<bool> deleteAllImages(ImageCategory category, int entityId) async {
    try {
      final success = await _imageService.deleteAllImages(category, entityId);

      if (success) {
        // Retirer de la liste locale
        _imagesByCategory[category]?.removeWhere(
          (img) => img.entityId == entityId,
        );
        notifyListeners();
      }

      return success;
    } catch (e) {
      _imagesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ===================
  // MÉTHODES UTILITAIRES
  // ===================

  /// Obtient les images pour une entité spécifique
  List<PrestaShopImage> getImagesForEntity(
    ImageCategory category,
    int entityId,
  ) {
    final images = _imagesByCategory[category] ?? [];
    return images.where((img) => img.entityId == entityId).toList();
  }

  /// Obtient les statistiques des images
  Future<Map<String, dynamic>> getImageStats(ImageCategory category) async {
    try {
      return await _imageService.getImageStats(category);
    } catch (e) {
      return {};
    }
  }

  /// Obtient l'URL d'une image
  String getImageUrl(
    ImageCategory category,
    int entityId,
    int imageId, {
    String? imageType,
  }) {
    return _imageService.getImageUrl(
      category,
      entityId,
      imageId,
      imageType: imageType,
    );
  }

  /// Réinitialise les erreurs
  void clearErrors() {
    _imageTypesError = null;
    _imagesError = null;
    _uploadError = null;
    notifyListeners();
  }

  /// Réinitialise le progrès d'upload
  void resetUploadProgress() {
    _uploadProgress = 0.0;
    _uploadError = null;
    notifyListeners();
  }
}
