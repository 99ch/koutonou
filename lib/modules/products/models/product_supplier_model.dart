/// Modèle ProductSupplier pour PrestaShop API
/// Représente la relation entre un produit et un fournisseur
class ProductSupplier {
  final int? id;
  final int idProduct;
  final int idProductAttribute;
  final int idSupplier;
  final int? idCurrency;
  final String? productSupplierReference;
  final double? productSupplierPriceTe;

  const ProductSupplier({
    this.id,
    required this.idProduct,
    required this.idProductAttribute,
    required this.idSupplier,
    this.idCurrency,
    this.productSupplierReference,
    this.productSupplierPriceTe,
  });

  /// Crée un ProductSupplier à partir de la réponse JSON de PrestaShop
  factory ProductSupplier.fromPrestaShopJson(Map<String, dynamic> json) {
    return ProductSupplier(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idProduct: int.tryParse(json['id_product']?.toString() ?? '0') ?? 0,
      idProductAttribute:
          int.tryParse(json['id_product_attribute']?.toString() ?? '0') ?? 0,
      idSupplier: int.tryParse(json['id_supplier']?.toString() ?? '0') ?? 0,
      idCurrency: int.tryParse(json['id_currency']?.toString() ?? '0'),
      productSupplierReference: json['product_supplier_reference']?.toString(),
      productSupplierPriceTe: double.tryParse(
        json['product_supplier_price_te']?.toString() ?? '0',
      ),
    );
  }

  /// Convertit le ProductSupplier en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_product': idProduct.toString(),
      'id_product_attribute': idProductAttribute.toString(),
      'id_supplier': idSupplier.toString(),
    };

    if (id != null) json['id'] = id.toString();
    if (idCurrency != null) json['id_currency'] = idCurrency.toString();
    if (productSupplierReference != null)
      json['product_supplier_reference'] = productSupplierReference;
    if (productSupplierPriceTe != null)
      json['product_supplier_price_te'] = productSupplierPriceTe.toString();

    return json;
  }

  /// Convertit le ProductSupplier en format XML pour PrestaShop
  String toPrestaShopXml() {
    final buffer = StringBuffer();
    buffer.writeln('<product_suppliers>');

    if (id != null) buffer.writeln('  <id><![CDATA[${id}]]></id>');
    buffer.writeln('  <id_product><![CDATA[${idProduct}]]></id_product>');
    buffer.writeln(
      '  <id_product_attribute><![CDATA[${idProductAttribute}]]></id_product_attribute>',
    );
    buffer.writeln('  <id_supplier><![CDATA[${idSupplier}]]></id_supplier>');

    if (idCurrency != null)
      buffer.writeln('  <id_currency><![CDATA[${idCurrency}]]></id_currency>');
    if (productSupplierReference != null)
      buffer.writeln(
        '  <product_supplier_reference><![CDATA[${productSupplierReference}]]></product_supplier_reference>',
      );
    if (productSupplierPriceTe != null)
      buffer.writeln(
        '  <product_supplier_price_te><![CDATA[${productSupplierPriceTe}]]></product_supplier_price_te>',
      );

    buffer.writeln('</product_suppliers>');
    return buffer.toString();
  }

  @override
  String toString() {
    return 'ProductSupplier(id: $id, idProduct: $idProduct, idProductAttribute: $idProductAttribute, idSupplier: $idSupplier, reference: $productSupplierReference, price: $productSupplierPriceTe)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductSupplier && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
