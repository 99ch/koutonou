/// Modèle Product manuel pour PrestaShop API
/// Représente un produit avec tous ses attributs essentiels
class Product {
  final int? id;
  final String name;
  final double price;
  final String? reference;
  final bool active;
  final int categoryId;
  final String? description;
  final String? shortDescription;
  final String? ean13;
  final String? upc;
  final int? quantity;
  final bool outOfStock;
  final double? weight;
  final String? condition;
  final bool showPrice;
  final bool indexed;
  final bool onSale;
  final DateTime? dateAdd;
  final DateTime? dateUpd;
  final List<int> categoryIds;
  final List<ProductImage> images;
  final ProductSeo seo;

  const Product({
    this.id,
    required this.name,
    required this.price,
    this.reference,
    this.active = true,
    required this.categoryId,
    this.description,
    this.shortDescription,
    this.ean13,
    this.upc,
    this.quantity,
    this.outOfStock = false,
    this.weight,
    this.condition = 'new',
    this.showPrice = true,
    this.indexed = true,
    this.onSale = false,
    this.dateAdd,
    this.dateUpd,
    this.categoryIds = const [],
    this.images = const [],
    this.seo = const ProductSeo(),
  });

  /// Crée un Product à partir de la réponse JSON de PrestaShop
  factory Product.fromPrestaShopJson(Map<String, dynamic> json) {
    // Extraction du nom (gérer les deux formats : string directe ou structure multilingue)
    String name = '';
    if (json['name'] is String) {
      name = json['name'] as String;
    } else if (json['name'] is Map) {
      final nameData = json['name'] as Map<String, dynamic>;
      if (nameData['language'] is List) {
        final languages = nameData['language'] as List;
        if (languages.isNotEmpty) {
          name = languages.first['value']?.toString() ?? '';
        }
      }
    }

    // Extraction de la description (gérer les deux formats)
    String? description;
    if (json['description'] is String) {
      description = json['description'] as String;
    } else if (json['description'] is Map) {
      final descData = json['description'] as Map<String, dynamic>;
      if (descData['language'] is List) {
        final languages = descData['language'] as List;
        if (languages.isNotEmpty) {
          description = languages.first['value']?.toString();
        }
      }
    }

    // Extraction de la description courte (gérer les deux formats)
    String? shortDescription;
    if (json['description_short'] is String) {
      shortDescription = json['description_short'] as String;
    } else if (json['description_short'] is Map) {
      final shortDescData = json['description_short'] as Map<String, dynamic>;
      if (shortDescData['language'] is List) {
        final languages = shortDescData['language'] as List;
        if (languages.isNotEmpty) {
          shortDescription = languages.first['value']?.toString();
        }
      }
    }

    // Extraction des catégories (gérer différents formats)
    List<int> categoryIds = [];
    if (json['associations'] != null) {
      final associations = json['associations'] as Map<String, dynamic>;

      // Format: categories: [{"id": "2"}]
      if (associations['categories'] is List) {
        final categories = associations['categories'] as List;
        categoryIds = categories
            .map((cat) {
              if (cat is Map<String, dynamic>) {
                return int.tryParse(cat['id']?.toString() ?? '0') ?? 0;
              }
              return 0;
            })
            .where((id) => id > 0)
            .toList();
      }
      // Format alternatif: categories: {"category": [{"id": "2"}]}
      else if (associations['categories']?['category'] is List) {
        final categories = associations['categories']['category'] as List;
        categoryIds = categories
            .map((cat) => int.tryParse(cat['id']?.toString() ?? '0') ?? 0)
            .where((id) => id > 0)
            .toList();
      }
    }

    // Extraction des images (gérer différents formats)
    List<ProductImage> images = [];
    if (json['associations'] != null) {
      final associations = json['associations'] as Map<String, dynamic>;

      // Format: images: [{"id": "1"}]
      if (associations['images'] is List) {
        final imageList = associations['images'] as List;
        images = imageList
            .map((img) {
              if (img is Map<String, dynamic>) {
                return ProductImage.fromPrestaShopJson(img);
              }
              return null;
            })
            .where((img) => img != null)
            .cast<ProductImage>()
            .toList();
      }
      // Format alternatif: images: {"image": [{"id": "1"}]}
      else if (associations['images']?['image'] is List) {
        final imageList = associations['images']['image'] as List;
        images = imageList
            .map((img) => ProductImage.fromPrestaShopJson(img))
            .toList();
      }
    }

    return Product(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      name: name,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      reference: json['reference']?.toString(),
      active: json['active']?.toString() == '1',
      categoryId:
          int.tryParse(json['id_category_default']?.toString() ?? '0') ?? 0,
      description: description,
      shortDescription: shortDescription,
      ean13: json['ean13']?.toString(),
      upc: json['upc']?.toString(),
      quantity: int.tryParse(json['quantity']?.toString() ?? '0'),
      outOfStock: json['out_of_stock']?.toString() == '1',
      weight: double.tryParse(json['weight']?.toString() ?? '0'),
      condition: json['condition']?.toString() ?? 'new',
      showPrice: json['show_price']?.toString() != '0',
      indexed: json['indexed']?.toString() != '0',
      onSale: json['on_sale']?.toString() == '1',
      dateAdd: DateTime.tryParse(json['date_add']?.toString() ?? ''),
      dateUpd: DateTime.tryParse(json['date_upd']?.toString() ?? ''),
      categoryIds: categoryIds,
      images: images,
      seo: ProductSeo.fromPrestaShopJson(json),
    );
  }

  /// Convertit le Product en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson({int languageId = 1}) {
    final json = <String, dynamic>{
      'name': {
        'language': [
          {'id': languageId.toString(), 'value': name},
        ],
      },
      'price': price.toString(),
      'active': active ? '1' : '0',
      'id_category_default': categoryId.toString(),
      'show_price': showPrice ? '1' : '0',
      'indexed': indexed ? '1' : '0',
      'condition': condition,
    };

    // Ajouter les champs optionnels
    if (reference != null) json['reference'] = reference;
    if (ean13 != null) json['ean13'] = ean13;
    if (upc != null) json['upc'] = upc;
    if (weight != null) json['weight'] = weight.toString();

    if (description != null) {
      json['description'] = {
        'language': [
          {'id': languageId.toString(), 'value': description},
        ],
      };
    }

    if (shortDescription != null) {
      json['description_short'] = {
        'language': [
          {'id': languageId.toString(), 'value': shortDescription},
        ],
      };
    }

    // Associations des catégories
    if (categoryIds.isNotEmpty) {
      json['associations'] = {
        'categories': {
          'category': categoryIds.map((id) => {'id': id.toString()}).toList(),
        },
      };
    }

    return json;
  }

  /// Copie ce Product avec des modifications
  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? reference,
    bool? active,
    int? categoryId,
    String? description,
    String? shortDescription,
    String? ean13,
    String? upc,
    int? quantity,
    bool? outOfStock,
    double? weight,
    String? condition,
    bool? showPrice,
    bool? indexed,
    bool? onSale,
    DateTime? dateAdd,
    DateTime? dateUpd,
    List<int>? categoryIds,
    List<ProductImage>? images,
    ProductSeo? seo,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      reference: reference ?? this.reference,
      active: active ?? this.active,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      ean13: ean13 ?? this.ean13,
      upc: upc ?? this.upc,
      quantity: quantity ?? this.quantity,
      outOfStock: outOfStock ?? this.outOfStock,
      weight: weight ?? this.weight,
      condition: condition ?? this.condition,
      showPrice: showPrice ?? this.showPrice,
      indexed: indexed ?? this.indexed,
      onSale: onSale ?? this.onSale,
      dateAdd: dateAdd ?? this.dateAdd,
      dateUpd: dateUpd ?? this.dateUpd,
      categoryIds: categoryIds ?? this.categoryIds,
      images: images ?? this.images,
      seo: seo ?? this.seo,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Modèle pour les images de produit
class ProductImage {
  final int id;
  final String? url;
  final bool cover;
  final int position;

  const ProductImage({
    required this.id,
    this.url,
    this.cover = false,
    this.position = 0,
  });

  factory ProductImage.fromPrestaShopJson(Map<String, dynamic> json) {
    return ProductImage(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      url: json['url']?.toString(),
      cover: json['cover']?.toString() == '1',
      position: int.tryParse(json['position']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toPrestaShopJson() {
    return {
      'id': id.toString(),
      if (url != null) 'url': url,
      'cover': cover ? '1' : '0',
      'position': position.toString(),
    };
  }
}

/// Modèle pour le SEO du produit
class ProductSeo {
  final String? metaTitle;
  final String? metaDescription;
  final String? metaKeywords;
  final String? linkRewrite;

  const ProductSeo({
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
    this.linkRewrite,
  });

  factory ProductSeo.fromPrestaShopJson(Map<String, dynamic> json) {
    // Extraction des données SEO multilingues
    String? metaTitle;
    if (json['meta_title'] is Map) {
      final titleData = json['meta_title'] as Map<String, dynamic>;
      if (titleData['language'] is List) {
        final languages = titleData['language'] as List;
        if (languages.isNotEmpty) {
          metaTitle = languages.first['value']?.toString();
        }
      }
    }

    String? metaDescription;
    if (json['meta_description'] is Map) {
      final descData = json['meta_description'] as Map<String, dynamic>;
      if (descData['language'] is List) {
        final languages = descData['language'] as List;
        if (languages.isNotEmpty) {
          metaDescription = languages.first['value']?.toString();
        }
      }
    }

    String? metaKeywords;
    if (json['meta_keywords'] is Map) {
      final keywordsData = json['meta_keywords'] as Map<String, dynamic>;
      if (keywordsData['language'] is List) {
        final languages = keywordsData['language'] as List;
        if (languages.isNotEmpty) {
          metaKeywords = languages.first['value']?.toString();
        }
      }
    }

    String? linkRewrite;
    if (json['link_rewrite'] is Map) {
      final linkData = json['link_rewrite'] as Map<String, dynamic>;
      if (linkData['language'] is List) {
        final languages = linkData['language'] as List;
        if (languages.isNotEmpty) {
          linkRewrite = languages.first['value']?.toString();
        }
      }
    }

    return ProductSeo(
      metaTitle: metaTitle,
      metaDescription: metaDescription,
      metaKeywords: metaKeywords,
      linkRewrite: linkRewrite,
    );
  }

  Map<String, dynamic> toPrestaShopJson({int languageId = 1}) {
    final json = <String, dynamic>{};

    if (metaTitle != null) {
      json['meta_title'] = {
        'language': [
          {'id': languageId.toString(), 'value': metaTitle},
        ],
      };
    }

    if (metaDescription != null) {
      json['meta_description'] = {
        'language': [
          {'id': languageId.toString(), 'value': metaDescription},
        ],
      };
    }

    if (metaKeywords != null) {
      json['meta_keywords'] = {
        'language': [
          {'id': languageId.toString(), 'value': metaKeywords},
        ],
      };
    }

    if (linkRewrite != null) {
      json['link_rewrite'] = {
        'language': [
          {'id': languageId.toString(), 'value': linkRewrite},
        ],
      };
    }

    return json;
  }
}
