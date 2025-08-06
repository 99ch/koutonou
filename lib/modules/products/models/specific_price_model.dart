/// Modèle SpecificPrice pour PrestaShop API
/// Représente un prix spécifique appliqué à un produit
class SpecificPrice {
  final int? id;
  final int? idShopGroup;
  final int idShop;
  final int idCart;
  final int idProduct;
  final int? idProductAttribute;
  final int idCurrency;
  final int idCountry;
  final int idGroup;
  final int idCustomer;
  final int? idSpecificPriceRule;
  final double price;
  final int fromQuantity;
  final double reduction;
  final bool reductionTax;
  final String reductionType; // 'amount' ou 'percentage'
  final DateTime from;
  final DateTime to;

  const SpecificPrice({
    this.id,
    this.idShopGroup,
    required this.idShop,
    required this.idCart,
    required this.idProduct,
    this.idProductAttribute,
    required this.idCurrency,
    required this.idCountry,
    required this.idGroup,
    required this.idCustomer,
    this.idSpecificPriceRule,
    required this.price,
    required this.fromQuantity,
    required this.reduction,
    required this.reductionTax,
    required this.reductionType,
    required this.from,
    required this.to,
  });

  /// Crée un SpecificPrice à partir de la réponse JSON de PrestaShop
  factory SpecificPrice.fromPrestaShopJson(Map<String, dynamic> json) {
    return SpecificPrice(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idShopGroup: int.tryParse(json['id_shop_group']?.toString() ?? '0'),
      idShop: int.tryParse(json['id_shop']?.toString() ?? '0') ?? 0,
      idCart: int.tryParse(json['id_cart']?.toString() ?? '0') ?? 0,
      idProduct: int.tryParse(json['id_product']?.toString() ?? '0') ?? 0,
      idProductAttribute: int.tryParse(json['id_product_attribute']?.toString() ?? '0'),
      idCurrency: int.tryParse(json['id_currency']?.toString() ?? '0') ?? 0,
      idCountry: int.tryParse(json['id_country']?.toString() ?? '0') ?? 0,
      idGroup: int.tryParse(json['id_group']?.toString() ?? '0') ?? 0,
      idCustomer: int.tryParse(json['id_customer']?.toString() ?? '0') ?? 0,
      idSpecificPriceRule: int.tryParse(json['id_specific_price_rule']?.toString() ?? '0'),
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      fromQuantity: int.tryParse(json['from_quantity']?.toString() ?? '1') ?? 1,
      reduction: double.tryParse(json['reduction']?.toString() ?? '0') ?? 0.0,
      reductionTax: json['reduction_tax']?.toString() == '1',
      reductionType: json['reduction_type']?.toString() ?? 'amount',
      from: _parseDate(json['from']) ?? DateTime.now(),
      to: _parseDate(json['to']) ?? DateTime.now().add(const Duration(days: 365)),
    );
  }

  /// Parse une date depuis PrestaShop
  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty || value.toString() == '0000-00-00 00:00:00') {
      return null;
    }
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  /// Convertit le SpecificPrice en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_shop': idShop.toString(),
      'id_cart': idCart.toString(),
      'id_product': idProduct.toString(),
      'id_currency': idCurrency.toString(),
      'id_country': idCountry.toString(),
      'id_group': idGroup.toString(),
      'id_customer': idCustomer.toString(),
      'price': price.toString(),
      'from_quantity': fromQuantity.toString(),
      'reduction': reduction.toString(),
      'reduction_tax': reductionTax ? '1' : '0',
      'reduction_type': reductionType,
      'from': _formatDate(from),
      'to': _formatDate(to),
    };

    if (id != null) json['id'] = id.toString();
    if (idShopGroup != null) json['id_shop_group'] = idShopGroup.toString();
    if (idProductAttribute != null) json['id_product_attribute'] = idProductAttribute.toString();
    if (idSpecificPriceRule != null) json['id_specific_price_rule'] = idSpecificPriceRule.toString();

    return json;
  }

  /// Convertit le SpecificPrice en format XML pour PrestaShop
  String toPrestaShopXml() {
    final buffer = StringBuffer();
    buffer.writeln('<specific_price>');

    if (id != null) buffer.writeln('  <id><![CDATA[$id]]></id>');
    if (idShopGroup != null) buffer.writeln('  <id_shop_group><![CDATA[$idShopGroup]]></id_shop_group>');
    buffer.writeln('  <id_shop><![CDATA[$idShop]]></id_shop>');
    buffer.writeln('  <id_cart><![CDATA[$idCart]]></id_cart>');
    buffer.writeln('  <id_product><![CDATA[$idProduct]]></id_product>');
    if (idProductAttribute != null) buffer.writeln('  <id_product_attribute><![CDATA[$idProductAttribute]]></id_product_attribute>');
    buffer.writeln('  <id_currency><![CDATA[$idCurrency]]></id_currency>');
    buffer.writeln('  <id_country><![CDATA[$idCountry]]></id_country>');
    buffer.writeln('  <id_group><![CDATA[$idGroup]]></id_group>');
    buffer.writeln('  <id_customer><![CDATA[$idCustomer]]></id_customer>');
    if (idSpecificPriceRule != null) buffer.writeln('  <id_specific_price_rule><![CDATA[$idSpecificPriceRule]]></id_specific_price_rule>');
    buffer.writeln('  <price><![CDATA[$price]]></price>');
    buffer.writeln('  <from_quantity><![CDATA[$fromQuantity]]></from_quantity>');
    buffer.writeln('  <reduction><![CDATA[$reduction]]></reduction>');
    buffer.writeln('  <reduction_tax><![CDATA[${reductionTax ? '1' : '0'}]]></reduction_tax>');
    buffer.writeln('  <reduction_type><![CDATA[$reductionType]]></reduction_type>');
    buffer.writeln('  <from><![CDATA[${_formatDate(from)}]]></from>');
    buffer.writeln('  <to><![CDATA[${_formatDate(to)}]]></to>');

    buffer.writeln('</specific_price>');
    return buffer.toString();
  }

  /// Formate une date pour PrestaShop
  String _formatDate(DateTime date) {
    return date.toIso8601String().substring(0, 19).replaceAll('T', ' ');
  }

  /// Vérifie si le prix spécifique est actuel
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(from) && now.isBefore(to);
  }

  /// Obtient le type de réduction en français
  String get reductionTypeDescription {
    switch (reductionType) {
      case 'amount':
        return 'Montant';
      case 'percentage':
        return 'Pourcentage';
      default:
        return reductionType;
    }
  }

  /// Calcule le prix final avec la réduction
  double calculateFinalPrice(double originalPrice) {
    if (!isActive) return originalPrice;
    
    if (price > 0) return price; // Prix fixe défini
    
    if (reductionType == 'percentage') {
      return originalPrice * (1 - (reduction / 100));
    } else {
      return originalPrice - reduction;
    }
  }

  /// Vérifie si le prix s'applique à une quantité donnée
  bool appliesForQuantity(int quantity) {
    return quantity >= fromQuantity;
  }

  @override
  String toString() {
    return 'SpecificPrice(id: $id, product: $idProduct, reduction: $reduction$reductionTypeDescription, from: $from, to: $to)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpecificPrice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
