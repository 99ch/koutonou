/// Énumération des types d'images supportés
enum ImageCategory {
  general,
  products,
  categories,
  manufacturers,
  suppliers,
  stores,
  customizations,
}

/// Extension pour les catégories d'images
extension ImageCategoryExtension on ImageCategory {
  String get name {
    switch (this) {
      case ImageCategory.general:
        return 'general';
      case ImageCategory.products:
        return 'products';
      case ImageCategory.categories:
        return 'categories';
      case ImageCategory.manufacturers:
        return 'manufacturers';
      case ImageCategory.suppliers:
        return 'suppliers';
      case ImageCategory.stores:
        return 'stores';
      case ImageCategory.customizations:
        return 'customizations';
    }
  }

  String get displayName {
    switch (this) {
      case ImageCategory.general:
        return 'Générales';
      case ImageCategory.products:
        return 'Produits';
      case ImageCategory.categories:
        return 'Catégories';
      case ImageCategory.manufacturers:
        return 'Fabricants';
      case ImageCategory.suppliers:
        return 'Fournisseurs';
      case ImageCategory.stores:
        return 'Magasins';
      case ImageCategory.customizations:
        return 'Personnalisations';
    }
  }

  /// MIME types supportés pour cette catégorie
  List<String> get allowedMimeTypes {
    return [
      'image/gif',
      'image/jpg',
      'image/jpeg',
      'image/pjpeg',
      'image/png',
      'image/x-png',
    ];
  }
}

/// Modèle pour les métadonnées d'images PrestaShop
class ImageMetadata {
  final ImageCategory category;
  final String href;
  final bool canGet;
  final bool canPut;
  final bool canPost;
  final bool canPatch;
  final bool canDelete;
  final bool canHead;
  final List<String> allowedMimeTypes;

  const ImageMetadata({
    required this.category,
    required this.href,
    this.canGet = false,
    this.canPut = false,
    this.canPost = false,
    this.canPatch = false,
    this.canDelete = false,
    this.canHead = false,
    this.allowedMimeTypes = const [],
  });

  /// Crée une instance depuis les attributs XML de PrestaShop
  factory ImageMetadata.fromXmlAttributes(
    ImageCategory category,
    Map<String, dynamic> attributes,
  ) {
    return ImageMetadata(
      category: category,
      href: attributes['href']?.toString() ?? '',
      canGet: _parseBool(attributes['get']),
      canPut: _parseBool(attributes['put']),
      canPost: _parseBool(attributes['post']),
      canPatch: _parseBool(attributes['patch']),
      canDelete: _parseBool(attributes['delete']),
      canHead: _parseBool(attributes['head']),
      allowedMimeTypes: _parseMimeTypes(attributes['upload_allowed_mimetypes']),
    );
  }

  /// Parse une valeur booléenne
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }

  /// Parse les types MIME autorisés
  static List<String> _parseMimeTypes(dynamic value) {
    if (value == null) return [];
    return value.toString().split(',').map((s) => s.trim()).toList();
  }

  /// Vérifie si un type MIME est autorisé
  bool isMimeTypeAllowed(String mimeType) {
    return allowedMimeTypes.contains(mimeType);
  }

  /// Liste des opérations autorisées
  List<String> get allowedOperations {
    final operations = <String>[];
    if (canGet) operations.add('GET');
    if (canPost) operations.add('POST');
    if (canPut) operations.add('PUT');
    if (canPatch) operations.add('PATCH');
    if (canDelete) operations.add('DELETE');
    if (canHead) operations.add('HEAD');
    return operations;
  }

  @override
  String toString() {
    return 'ImageMetadata(category: ${category.name}, operations: ${allowedOperations.join(', ')})';
  }
}

/// Modèle pour une image PrestaShop
class PrestaShopImage {
  final int? id;
  final int? entityId; // ID de l'entité (produit, catégorie, etc.)
  final ImageCategory category;
  final String? url;
  final String? filename;
  final String? legend; // Légende/titre de l'image
  final String? mimeType;
  final int? fileSize;
  final DateTime? dateAdd;
  final DateTime? dateUpd;

  const PrestaShopImage({
    this.id,
    this.entityId,
    required this.category,
    this.url,
    this.filename,
    this.legend,
    this.mimeType,
    this.fileSize,
    this.dateAdd,
    this.dateUpd,
  });

  /// Crée une instance depuis les données JSON de PrestaShop
  factory PrestaShopImage.fromPrestaShopJson(
    Map<String, dynamic> json,
    ImageCategory category,
  ) {
    return PrestaShopImage(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      entityId: int.tryParse(
        json['id_${category.name.substring(0, category.name.length - 1)}']
                ?.toString() ??
            '0',
      ),
      category: category,
      url: json['url']?.toString(),
      filename: json['filename']?.toString(),
      legend: json['legend']?.toString(),
      mimeType: json['mime_type']?.toString(),
      fileSize: int.tryParse(json['file_size']?.toString() ?? '0'),
      dateAdd: _parseDate(json['date_add']),
      dateUpd: _parseDate(json['date_upd']),
    );
  }

  /// Parse une date depuis PrestaShop
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  /// Taille du fichier formatée
  String get formattedFileSize {
    if (fileSize == null) return 'Inconnue';

    final size = fileSize!;
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Extension du fichier
  String? get fileExtension {
    if (filename == null) return null;
    final parts = filename!.split('.');
    return parts.length > 1 ? parts.last : null;
  }

  /// Vérifie si l'image est récente (moins de 24h)
  bool get isRecent {
    if (dateAdd == null) return false;
    return DateTime.now().difference(dateAdd!).inHours < 24;
  }

  @override
  String toString() {
    return 'PrestaShopImage(id: $id, category: ${category.name}, filename: $filename)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrestaShopImage &&
        other.id == id &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(id, category);
}
