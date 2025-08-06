/// Modèle Combination pour PrestaShop API
/// Représente une combinaison de produit (attributs, variantes)
class Combination {
  final int? id;
  final int idProduct;
  final String? location;
  final String? ean13;
  final String? isbn;
  final String? upc;
  final String? mpn;
  final int? quantity;
  final String? reference;
  final String? supplierReference;
  final double? wholesalePrice;
  final double? price;
  final double? ecotax;
  final double? weight;
  final double? unitPriceImpact;
  final int minimalQuantity;
  final int? lowStockThreshold;
  final bool? lowStockAlert;
  final bool? defaultOn;
  final DateTime? availableDate;

  // Associations
  final List<int>? productOptionValueIds;
  final List<int>? imageIds;

  const Combination({
    this.id,
    required this.idProduct,
    this.location,
    this.ean13,
    this.isbn,
    this.upc,
    this.mpn,
    this.quantity,
    this.reference,
    this.supplierReference,
    this.wholesalePrice,
    this.price,
    this.ecotax,
    this.weight,
    this.unitPriceImpact,
    required this.minimalQuantity,
    this.lowStockThreshold,
    this.lowStockAlert,
    this.defaultOn,
    this.availableDate,
    this.productOptionValueIds,
    this.imageIds,
  });

  /// Crée une Combination à partir de la réponse JSON de PrestaShop
  factory Combination.fromPrestaShopJson(Map<String, dynamic> json) {
    // Parse les associations
    List<int>? optionValueIds;
    List<int>? imgIds;

    if (json['associations'] is Map) {
      final associations = json['associations'] as Map<String, dynamic>;

      // Product option values
      if (associations['product_option_values'] is Map) {
        final povData =
            associations['product_option_values'] as Map<String, dynamic>;
        if (povData['product_option_value'] is List) {
          optionValueIds = (povData['product_option_value'] as List)
              .map((item) => int.tryParse(item['id']?.toString() ?? '0') ?? 0)
              .where((id) => id > 0)
              .toList();
        } else if (povData['product_option_value'] is Map) {
          final id = int.tryParse(
            povData['product_option_value']['id']?.toString() ?? '0',
          );
          if (id != null && id > 0) optionValueIds = [id];
        }
      }

      // Images
      if (associations['images'] is Map) {
        final imgData = associations['images'] as Map<String, dynamic>;
        if (imgData['image'] is List) {
          imgIds = (imgData['image'] as List)
              .map((item) => int.tryParse(item['id']?.toString() ?? '0') ?? 0)
              .where((id) => id > 0)
              .toList();
        } else if (imgData['image'] is Map) {
          final id = int.tryParse(imgData['image']['id']?.toString() ?? '0');
          if (id != null && id > 0) imgIds = [id];
        }
      }
    }

    return Combination(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idProduct: int.tryParse(json['id_product']?.toString() ?? '0') ?? 0,
      location: json['location']?.toString(),
      ean13: json['ean13']?.toString(),
      isbn: json['isbn']?.toString(),
      upc: json['upc']?.toString(),
      mpn: json['mpn']?.toString(),
      quantity: int.tryParse(json['quantity']?.toString() ?? '0'),
      reference: json['reference']?.toString(),
      supplierReference: json['supplier_reference']?.toString(),
      wholesalePrice: double.tryParse(
        json['wholesale_price']?.toString() ?? '0',
      ),
      price: double.tryParse(json['price']?.toString() ?? '0'),
      ecotax: double.tryParse(json['ecotax']?.toString() ?? '0'),
      weight: double.tryParse(json['weight']?.toString() ?? '0'),
      unitPriceImpact: double.tryParse(
        json['unit_price_impact']?.toString() ?? '0',
      ),
      minimalQuantity:
          int.tryParse(json['minimal_quantity']?.toString() ?? '1') ?? 1,
      lowStockThreshold: int.tryParse(
        json['low_stock_threshold']?.toString() ?? '0',
      ),
      lowStockAlert: json['low_stock_alert']?.toString() == '1',
      defaultOn: json['default_on']?.toString() == '1',
      availableDate: _parseDate(json['available_date']),
      productOptionValueIds: optionValueIds,
      imageIds: imgIds,
    );
  }

  /// Parse une date depuis PrestaShop
  static DateTime? _parseDate(dynamic value) {
    if (value == null ||
        value.toString().isEmpty ||
        value.toString() == '0000-00-00') {
      return null;
    }
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  /// Convertit la Combination en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_product': idProduct.toString(),
      'minimal_quantity': minimalQuantity.toString(),
    };

    if (id != null) json['id'] = id.toString();
    if (location != null) json['location'] = location;
    if (ean13 != null) json['ean13'] = ean13;
    if (isbn != null) json['isbn'] = isbn;
    if (upc != null) json['upc'] = upc;
    if (mpn != null) json['mpn'] = mpn;
    if (quantity != null) json['quantity'] = quantity.toString();
    if (reference != null) json['reference'] = reference;
    if (supplierReference != null)
      json['supplier_reference'] = supplierReference;
    if (wholesalePrice != null)
      json['wholesale_price'] = wholesalePrice.toString();
    if (price != null) json['price'] = price.toString();
    if (ecotax != null) json['ecotax'] = ecotax.toString();
    if (weight != null) json['weight'] = weight.toString();
    if (unitPriceImpact != null)
      json['unit_price_impact'] = unitPriceImpact.toString();
    if (lowStockThreshold != null)
      json['low_stock_threshold'] = lowStockThreshold.toString();
    if (lowStockAlert != null)
      json['low_stock_alert'] = lowStockAlert! ? '1' : '0';
    if (defaultOn != null) json['default_on'] = defaultOn! ? '1' : '0';
    if (availableDate != null)
      json['available_date'] = _formatDate(availableDate!);

    // Associations
    if (productOptionValueIds != null || imageIds != null) {
      final associations = <String, dynamic>{};

      if (productOptionValueIds != null) {
        associations['product_option_values'] = {
          'product_option_value': productOptionValueIds!
              .map((id) => {'id': id.toString()})
              .toList(),
        };
      }

      if (imageIds != null) {
        associations['images'] = {
          'image': imageIds!.map((id) => {'id': id.toString()}).toList(),
        };
      }

      json['associations'] = associations;
    }

    return json;
  }

  /// Convertit la Combination en format XML pour PrestaShop
  String toPrestaShopXml() {
    final buffer = StringBuffer();
    buffer.writeln('<combination>');

    if (id != null) buffer.writeln('  <id><![CDATA[$id]]></id>');
    buffer.writeln('  <id_product><![CDATA[$idProduct]]></id_product>');
    if (location != null)
      buffer.writeln('  <location><![CDATA[$location]]></location>');
    if (ean13 != null) buffer.writeln('  <ean13><![CDATA[$ean13]]></ean13>');
    if (isbn != null) buffer.writeln('  <isbn><![CDATA[$isbn]]></isbn>');
    if (upc != null) buffer.writeln('  <upc><![CDATA[$upc]]></upc>');
    if (mpn != null) buffer.writeln('  <mpn><![CDATA[$mpn]]></mpn>');
    if (quantity != null)
      buffer.writeln('  <quantity><![CDATA[$quantity]]></quantity>');
    if (reference != null)
      buffer.writeln('  <reference><![CDATA[$reference]]></reference>');
    if (supplierReference != null)
      buffer.writeln(
        '  <supplier_reference><![CDATA[$supplierReference]]></supplier_reference>',
      );
    if (wholesalePrice != null)
      buffer.writeln(
        '  <wholesale_price><![CDATA[$wholesalePrice]]></wholesale_price>',
      );
    if (price != null) buffer.writeln('  <price><![CDATA[$price]]></price>');
    if (ecotax != null)
      buffer.writeln('  <ecotax><![CDATA[$ecotax]]></ecotax>');
    if (weight != null)
      buffer.writeln('  <weight><![CDATA[$weight]]></weight>');
    if (unitPriceImpact != null)
      buffer.writeln(
        '  <unit_price_impact><![CDATA[$unitPriceImpact]]></unit_price_impact>',
      );
    buffer.writeln(
      '  <minimal_quantity><![CDATA[$minimalQuantity]]></minimal_quantity>',
    );
    if (lowStockThreshold != null)
      buffer.writeln(
        '  <low_stock_threshold><![CDATA[$lowStockThreshold]]></low_stock_threshold>',
      );
    if (lowStockAlert != null)
      buffer.writeln(
        '  <low_stock_alert><![CDATA[${lowStockAlert! ? '1' : '0'}]]></low_stock_alert>',
      );
    if (defaultOn != null)
      buffer.writeln(
        '  <default_on><![CDATA[${defaultOn! ? '1' : '0'}]]></default_on>',
      );
    if (availableDate != null)
      buffer.writeln(
        '  <available_date><![CDATA[${_formatDate(availableDate!)}]]></available_date>',
      );

    // Associations
    if (productOptionValueIds != null || imageIds != null) {
      buffer.writeln('  <associations>');

      if (productOptionValueIds != null) {
        buffer.writeln('    <product_option_values>');
        for (final id in productOptionValueIds!) {
          buffer.writeln('      <product_option_value>');
          buffer.writeln('        <id><![CDATA[$id]]></id>');
          buffer.writeln('      </product_option_value>');
        }
        buffer.writeln('    </product_option_values>');
      }

      if (imageIds != null) {
        buffer.writeln('    <images>');
        for (final id in imageIds!) {
          buffer.writeln('      <image>');
          buffer.writeln('        <id><![CDATA[$id]]></id>');
          buffer.writeln('      </image>');
        }
        buffer.writeln('    </images>');
      }

      buffer.writeln('  </associations>');
    }

    buffer.writeln('</combination>');
    return buffer.toString();
  }

  /// Formate une date pour PrestaShop
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Vérifie si la combinaison est en stock
  bool get inStock => (quantity ?? 0) > 0;

  /// Vérifie si la combinaison est en rupture de stock
  bool get isLowStock {
    if (lowStockThreshold == null || quantity == null) return false;
    return quantity! <= lowStockThreshold!;
  }

  /// Obtient la référence complète (référence produit ou fournisseur)
  String get fullReference {
    if (reference != null && reference!.isNotEmpty) return reference!;
    if (supplierReference != null && supplierReference!.isNotEmpty)
      return supplierReference!;
    return 'Sans référence';
  }

  /// Obtient le statut de disponibilité
  String get availabilityStatus {
    if (!inStock) return 'Rupture de stock';
    if (isLowStock) return 'Stock faible';
    if (availableDate != null && availableDate!.isAfter(DateTime.now())) {
      return 'Disponible le ${_formatDate(availableDate!)}';
    }
    return 'En stock';
  }

  /// Calcule le prix final avec impact
  double calculateFinalPrice(double basePrice) {
    return basePrice + (unitPriceImpact ?? 0);
  }

  @override
  String toString() {
    return 'Combination(id: $id, product: $idProduct, reference: $fullReference, quantity: $quantity, price: ${price ?? 0})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Combination && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
