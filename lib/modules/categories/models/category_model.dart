/// Modèle Category pour PrestaShop API
/// Représente une catégorie avec tous ses attributs essentiels et la hiérarchie
class Category {
  final int? id;
  final int? idParent;
  final int? levelDepth;
  final int? nbProductsRecursive;
  final bool active;
  final int? idShopDefault;
  final bool isRootCategory;
  final int? position;
  final DateTime? dateAdd;
  final DateTime? dateUpd;
  final String name;
  final String linkRewrite;
  final String? description;
  final String? metaTitle;
  final String? metaDescription;
  final String? metaKeywords;
  final List<int> childCategoryIds;
  final List<int> productIds;

  const Category({
    this.id,
    this.idParent,
    this.levelDepth,
    this.nbProductsRecursive,
    this.active = true,
    this.idShopDefault,
    this.isRootCategory = false,
    this.position,
    this.dateAdd,
    this.dateUpd,
    required this.name,
    required this.linkRewrite,
    this.description,
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
    this.childCategoryIds = const [],
    this.productIds = const [],
  });

  /// Crée une Category à partir de la réponse JSON de PrestaShop
  factory Category.fromPrestaShopJson(Map<String, dynamic> json) {
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

    // Extraction du link_rewrite
    String linkRewrite = '';
    if (json['link_rewrite'] is String) {
      linkRewrite = json['link_rewrite'] as String;
    } else if (json['link_rewrite'] is Map) {
      final linkData = json['link_rewrite'] as Map<String, dynamic>;
      if (linkData['language'] is List) {
        final languages = linkData['language'] as List;
        if (languages.isNotEmpty) {
          linkRewrite = languages.first['value']?.toString() ?? '';
        }
      }
    }

    // Extraction de la description
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

    // Extraction du meta_title
    String? metaTitle;
    if (json['meta_title'] is String) {
      metaTitle = json['meta_title'] as String;
    } else if (json['meta_title'] is Map) {
      final titleData = json['meta_title'] as Map<String, dynamic>;
      if (titleData['language'] is List) {
        final languages = titleData['language'] as List;
        if (languages.isNotEmpty) {
          metaTitle = languages.first['value']?.toString();
        }
      }
    }

    // Extraction du meta_description
    String? metaDescription;
    if (json['meta_description'] is String) {
      metaDescription = json['meta_description'] as String;
    } else if (json['meta_description'] is Map) {
      final metaDescData = json['meta_description'] as Map<String, dynamic>;
      if (metaDescData['language'] is List) {
        final languages = metaDescData['language'] as List;
        if (languages.isNotEmpty) {
          metaDescription = languages.first['value']?.toString();
        }
      }
    }

    // Extraction du meta_keywords
    String? metaKeywords;
    if (json['meta_keywords'] is String) {
      metaKeywords = json['meta_keywords'] as String;
    } else if (json['meta_keywords'] is Map) {
      final keywordsData = json['meta_keywords'] as Map<String, dynamic>;
      if (keywordsData['language'] is List) {
        final languages = keywordsData['language'] as List;
        if (languages.isNotEmpty) {
          metaKeywords = languages.first['value']?.toString();
        }
      }
    }

    // Extraction des catégories enfants
    List<int> childCategoryIds = [];
    if (json['associations'] != null) {
      final associations = json['associations'] as Map<String, dynamic>;

      if (associations['categories'] is List) {
        final categories = associations['categories'] as List;
        childCategoryIds = categories
            .map((cat) {
              if (cat is Map<String, dynamic>) {
                return int.tryParse(cat['id']?.toString() ?? '0') ?? 0;
              }
              return 0;
            })
            .where((id) => id > 0)
            .toList();
      } else if (associations['categories']?['category'] is List) {
        final categories = associations['categories']['category'] as List;
        childCategoryIds = categories
            .map((cat) => int.tryParse(cat['id']?.toString() ?? '0') ?? 0)
            .where((id) => id > 0)
            .toList();
      }
    }

    // Extraction des produits associés
    List<int> productIds = [];
    if (json['associations'] != null) {
      final associations = json['associations'] as Map<String, dynamic>;

      if (associations['products'] is List) {
        final products = associations['products'] as List;
        productIds = products
            .map((prod) {
              if (prod is Map<String, dynamic>) {
                return int.tryParse(prod['id']?.toString() ?? '0') ?? 0;
              }
              return 0;
            })
            .where((id) => id > 0)
            .toList();
      } else if (associations['products']?['product'] is List) {
        final products = associations['products']['product'] as List;
        productIds = products
            .map((prod) => int.tryParse(prod['id']?.toString() ?? '0') ?? 0)
            .where((id) => id > 0)
            .toList();
      }
    }

    return Category(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idParent: int.tryParse(json['id_parent']?.toString() ?? '0'),
      levelDepth: int.tryParse(json['level_depth']?.toString() ?? '0'),
      nbProductsRecursive: int.tryParse(
        json['nb_products_recursive']?.toString() ?? '0',
      ),
      active: json['active']?.toString() == '1',
      idShopDefault: int.tryParse(json['id_shop_default']?.toString() ?? '0'),
      isRootCategory: json['is_root_category']?.toString() == '1',
      position: int.tryParse(json['position']?.toString() ?? '0'),
      dateAdd: DateTime.tryParse(json['date_add']?.toString() ?? ''),
      dateUpd: DateTime.tryParse(json['date_upd']?.toString() ?? ''),
      name: name,
      linkRewrite: linkRewrite,
      description: description?.isNotEmpty == true ? description : null,
      metaTitle: metaTitle?.isNotEmpty == true ? metaTitle : null,
      metaDescription: metaDescription?.isNotEmpty == true
          ? metaDescription
          : null,
      metaKeywords: metaKeywords?.isNotEmpty == true ? metaKeywords : null,
      childCategoryIds: childCategoryIds,
      productIds: productIds,
    );
  }

  /// Convertit la Category en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson({int languageId = 1}) {
    final json = <String, dynamic>{
      'name': {
        'language': [
          {'id': languageId.toString(), 'value': name},
        ],
      },
      'link_rewrite': {
        'language': [
          {'id': languageId.toString(), 'value': linkRewrite},
        ],
      },
      'active': active ? '1' : '0',
      'is_root_category': isRootCategory ? '1' : '0',
    };

    // Ajouter les champs optionnels
    if (idParent != null) json['id_parent'] = idParent.toString();
    if (position != null) json['position'] = position.toString();
    if (idShopDefault != null) {
      json['id_shop_default'] = idShopDefault.toString();
    }

    if (description != null) {
      json['description'] = {
        'language': [
          {'id': languageId.toString(), 'value': description},
        ],
      };
    }

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

    // Associations
    final associations = <String, dynamic>{};

    if (childCategoryIds.isNotEmpty) {
      associations['categories'] = {
        'category': childCategoryIds
            .map((id) => {'id': id.toString()})
            .toList(),
      };
    }

    if (productIds.isNotEmpty) {
      associations['products'] = {
        'product': productIds.map((id) => {'id': id.toString()}).toList(),
      };
    }

    if (associations.isNotEmpty) {
      json['associations'] = associations;
    }

    return json;
  }

  /// Copie cette Category avec des modifications
  Category copyWith({
    int? id,
    int? idParent,
    int? levelDepth,
    int? nbProductsRecursive,
    bool? active,
    int? idShopDefault,
    bool? isRootCategory,
    int? position,
    DateTime? dateAdd,
    DateTime? dateUpd,
    String? name,
    String? linkRewrite,
    String? description,
    String? metaTitle,
    String? metaDescription,
    String? metaKeywords,
    List<int>? childCategoryIds,
    List<int>? productIds,
  }) {
    return Category(
      id: id ?? this.id,
      idParent: idParent ?? this.idParent,
      levelDepth: levelDepth ?? this.levelDepth,
      nbProductsRecursive: nbProductsRecursive ?? this.nbProductsRecursive,
      active: active ?? this.active,
      idShopDefault: idShopDefault ?? this.idShopDefault,
      isRootCategory: isRootCategory ?? this.isRootCategory,
      position: position ?? this.position,
      dateAdd: dateAdd ?? this.dateAdd,
      dateUpd: dateUpd ?? this.dateUpd,
      name: name ?? this.name,
      linkRewrite: linkRewrite ?? this.linkRewrite,
      description: description ?? this.description,
      metaTitle: metaTitle ?? this.metaTitle,
      metaDescription: metaDescription ?? this.metaDescription,
      metaKeywords: metaKeywords ?? this.metaKeywords,
      childCategoryIds: childCategoryIds ?? this.childCategoryIds,
      productIds: productIds ?? this.productIds,
    );
  }

  /// Vérifie si c'est une catégorie racine
  bool get isRoot => idParent == null || idParent == 0 || isRootCategory;

  /// Vérifie si la catégorie a des enfants
  bool get hasChildren => childCategoryIds.isNotEmpty;

  /// Vérifie si la catégorie a des produits
  bool get hasProducts => productIds.isNotEmpty;

  /// Génère automatiquement un link_rewrite à partir du nom
  static String generateLinkRewrite(String name) {
    return name
        .toLowerCase()
        .replaceAll(
          RegExp(r'[^a-z0-9\s-]'),
          '',
        ) // Supprimer caractères spéciaux
        .replaceAll(RegExp(r'\s+'), '-') // Remplacer espaces par tirets
        .replaceAll(RegExp(r'-+'), '-') // Supprimer tirets multiples
        .replaceAll(RegExp(r'^-|-$'), ''); // Supprimer tirets en début/fin
  }

  @override
  String toString() => 'Category(id: $id, name: $name, parent: $idParent)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Modèle CategoryTree pour représenter la hiérarchie des catégories
class CategoryTree {
  final Category category;
  final List<CategoryTree> children;
  CategoryTree? parent;

  CategoryTree({
    required this.category,
    List<CategoryTree>? children,
    this.parent,
  }) : children = children ?? <CategoryTree>[];

  /// Constructeur avec liste mutable pour les children
  CategoryTree.withMutableChildren({required this.category, this.parent})
    : children = <CategoryTree>[];

  /// Ajoute un enfant à cette node
  void addChild(CategoryTree child) {
    children.add(child);
    child.parent = this;
  }

  /// Retire un enfant de cette node
  void removeChild(CategoryTree child) {
    children.remove(child);
    child.parent = null;
  }

  /// Retourne tous les descendants de cette node
  List<CategoryTree> getAllDescendants() {
    final descendants = <CategoryTree>[];
    for (final child in children) {
      descendants.add(child);
      descendants.addAll(child.getAllDescendants());
    }
    return descendants;
  }

  /// Retourne le chemin depuis la racine jusqu'à cette node
  List<CategoryTree> getPath() {
    final path = <CategoryTree>[];
    CategoryTree? current = this;
    while (current != null) {
      path.insert(0, current);
      current = current.parent;
    }
    return path;
  }

  /// Retourne la profondeur de cette node dans l'arbre
  int get depth {
    int depth = 0;
    CategoryTree? current = parent;
    while (current != null) {
      depth++;
      current = current.parent;
    }
    return depth;
  }

  /// Vérifie si cette node est une feuille (pas d'enfants)
  bool get isLeaf => children.isEmpty;

  /// Vérifie si cette node est la racine (pas de parent)
  bool get isRoot => parent == null;

  @override
  String toString() =>
      'CategoryTree(category: ${category.name}, children: ${children.length})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryTree && other.category.id == category.id;
  }

  @override
  int get hashCode => category.id.hashCode;
}
