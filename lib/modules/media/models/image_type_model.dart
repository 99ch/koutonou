/// Modèle pour les types d'images PrestaShop
class ImageType {
  final int? id;
  final String name;
  final int width;
  final int height;
  final bool categories;
  final bool products;
  final bool manufacturers;
  final bool suppliers;
  final bool stores;

  const ImageType({
    this.id,
    required this.name,
    required this.width,
    required this.height,
    this.categories = false,
    this.products = false,
    this.manufacturers = false,
    this.suppliers = false,
    this.stores = false,
  });

  /// Crée une instance depuis les données JSON de PrestaShop
  factory ImageType.fromPrestaShopJson(Map<String, dynamic> json) {
    return ImageType(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      name: json['name']?.toString() ?? '',
      width: int.tryParse(json['width']?.toString() ?? '0') ?? 0,
      height: int.tryParse(json['height']?.toString() ?? '0') ?? 0,
      categories: _parseBool(json['categories']),
      products: _parseBool(json['products']),
      manufacturers: _parseBool(json['manufacturers']),
      suppliers: _parseBool(json['suppliers']),
      stores: _parseBool(json['stores']),
    );
  }

  /// Convertit vers le format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    return {
      if (id != null) 'id': id.toString(),
      'name': name,
      'width': width.toString(),
      'height': height.toString(),
      'categories': categories ? '1' : '0',
      'products': products ? '1' : '0',
      'manufacturers': manufacturers ? '1' : '0',
      'suppliers': suppliers ? '1' : '0',
      'stores': stores ? '1' : '0',
    };
  }

  /// Convertit vers le format XML pour PrestaShop
  String toPrestaShopXml() {
    return '''
<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
  <image_type>
    ${id != null ? '<id><![CDATA[$id]]></id>' : ''}
    <name><![CDATA[$name]]></name>
    <width><![CDATA[$width]]></width>
    <height><![CDATA[$height]]></height>
    <categories><![CDATA[${categories ? '1' : '0'}]]></categories>
    <products><![CDATA[${products ? '1' : '0'}]]></products>
    <manufacturers><![CDATA[${manufacturers ? '1' : '0'}]]></manufacturers>
    <suppliers><![CDATA[${suppliers ? '1' : '0'}]]></suppliers>
    <stores><![CDATA[${stores ? '1' : '0'}]]></stores>
  </image_type>
</prestashop>''';
  }

  /// Parse une valeur booléenne depuis PrestaShop (0/1)
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    final str = value.toString().toLowerCase();
    return str == '1' || str == 'true';
  }

  /// Description du type d'image
  String get description {
    final List<String> usages = [];
    if (categories) usages.add('Catégories');
    if (products) usages.add('Produits');
    if (manufacturers) usages.add('Fabricants');
    if (suppliers) usages.add('Fournisseurs');
    if (stores) usages.add('Magasins');

    if (usages.isEmpty) return 'Aucune utilisation définie';
    return 'Utilisé pour: ${usages.join(', ')}';
  }

  /// Dimensions formatées
  String get dimensions => '${width}x$height px';

  /// Copie avec modifications
  ImageType copyWith({
    int? id,
    String? name,
    int? width,
    int? height,
    bool? categories,
    bool? products,
    bool? manufacturers,
    bool? suppliers,
    bool? stores,
  }) {
    return ImageType(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      manufacturers: manufacturers ?? this.manufacturers,
      suppliers: suppliers ?? this.suppliers,
      stores: stores ?? this.stores,
    );
  }

  @override
  String toString() {
    return 'ImageType(id: $id, name: $name, dimensions: $dimensions)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageType && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
