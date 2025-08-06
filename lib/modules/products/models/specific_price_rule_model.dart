/// Modèle SpecificPriceRule pour PrestaShop API
/// Représente une règle de prix spécifique
class SpecificPriceRule {
  final int? id;
  final int idShop;
  final int idCountry;
  final int idCurrency;
  final int idGroup;
  final String name;
  final int fromQuantity;
  final double price;
  final double reduction;
  final bool reductionTax;
  final String reductionType; // 'amount' ou 'percentage'
  final DateTime? from;
  final DateTime? to;

  const SpecificPriceRule({
    this.id,
    required this.idShop,
    required this.idCountry,
    required this.idCurrency,
    required this.idGroup,
    required this.name,
    required this.fromQuantity,
    required this.price,
    required this.reduction,
    required this.reductionTax,
    required this.reductionType,
    this.from,
    this.to,
  });

  /// Crée un SpecificPriceRule à partir de la réponse JSON de PrestaShop
  factory SpecificPriceRule.fromPrestaShopJson(Map<String, dynamic> json) {
    return SpecificPriceRule(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idShop: int.tryParse(json['id_shop']?.toString() ?? '0') ?? 0,
      idCountry: int.tryParse(json['id_country']?.toString() ?? '0') ?? 0,
      idCurrency: int.tryParse(json['id_currency']?.toString() ?? '0') ?? 0,
      idGroup: int.tryParse(json['id_group']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      fromQuantity: int.tryParse(json['from_quantity']?.toString() ?? '1') ?? 1,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      reduction: double.tryParse(json['reduction']?.toString() ?? '0') ?? 0.0,
      reductionTax: json['reduction_tax']?.toString() == '1',
      reductionType: json['reduction_type']?.toString() ?? 'amount',
      from: _parseDate(json['from']),
      to: _parseDate(json['to']),
    );
  }

  /// Parse une date depuis PrestaShop
  static DateTime? _parseDate(dynamic value) {
    if (value == null ||
        value.toString().isEmpty ||
        value.toString() == '0000-00-00 00:00:00') {
      return null;
    }
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  /// Convertit le SpecificPriceRule en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_shop': idShop.toString(),
      'id_country': idCountry.toString(),
      'id_currency': idCurrency.toString(),
      'id_group': idGroup.toString(),
      'name': name,
      'from_quantity': fromQuantity.toString(),
      'price': price.toString(),
      'reduction': reduction.toString(),
      'reduction_tax': reductionTax ? '1' : '0',
      'reduction_type': reductionType,
    };

    if (id != null) json['id'] = id.toString();
    if (from != null) json['from'] = _formatDate(from!);
    if (to != null) json['to'] = _formatDate(to!);

    return json;
  }

  /// Convertit le SpecificPriceRule en format XML pour PrestaShop
  String toPrestaShopXml() {
    final buffer = StringBuffer();
    buffer.writeln('<specific_price_rule>');

    if (id != null) buffer.writeln('  <id><![CDATA[$id]]></id>');
    buffer.writeln('  <id_shop><![CDATA[$idShop]]></id_shop>');
    buffer.writeln('  <id_country><![CDATA[$idCountry]]></id_country>');
    buffer.writeln('  <id_currency><![CDATA[$idCurrency]]></id_currency>');
    buffer.writeln('  <id_group><![CDATA[$idGroup]]></id_group>');
    buffer.writeln('  <name><![CDATA[$name]]></name>');
    buffer.writeln(
      '  <from_quantity><![CDATA[$fromQuantity]]></from_quantity>',
    );
    buffer.writeln('  <price><![CDATA[$price]]></price>');
    buffer.writeln('  <reduction><![CDATA[$reduction]]></reduction>');
    buffer.writeln(
      '  <reduction_tax><![CDATA[${reductionTax ? '1' : '0'}]]></reduction_tax>',
    );
    buffer.writeln(
      '  <reduction_type><![CDATA[$reductionType]]></reduction_type>',
    );

    if (from != null)
      buffer.writeln('  <from><![CDATA[${_formatDate(from!)}]]></from>');
    if (to != null)
      buffer.writeln('  <to><![CDATA[${_formatDate(to!)}]]></to>');

    buffer.writeln('</specific_price_rule>');
    return buffer.toString();
  }

  /// Formate une date pour PrestaShop
  String _formatDate(DateTime date) {
    return date.toIso8601String().substring(0, 19).replaceAll('T', ' ');
  }

  /// Vérifie si la règle de prix est active
  bool get isActive {
    final now = DateTime.now();

    if (from != null && now.isBefore(from!)) return false;
    if (to != null && now.isAfter(to!)) return false;

    return true;
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

  /// Calcule le prix final avec la règle
  double calculateFinalPrice(double originalPrice) {
    if (!isActive) return originalPrice;

    if (price > 0) return price; // Prix fixe défini

    if (reductionType == 'percentage') {
      return originalPrice * (1 - (reduction / 100));
    } else {
      return originalPrice - reduction;
    }
  }

  /// Vérifie si la règle s'applique à une quantité donnée
  bool appliesForQuantity(int quantity) {
    return quantity >= fromQuantity;
  }

  /// Obtient la période d'activité de la règle
  String get activePeriod {
    if (from == null && to == null) return 'Toujours active';
    if (from != null && to == null) return 'À partir du ${_formatDate(from!)}';
    if (from == null && to != null) return 'Jusqu\'au ${_formatDate(to!)}';
    return 'Du ${_formatDate(from!)} au ${_formatDate(to!)}';
  }

  /// Obtient la description de la réduction
  String get reductionDescription {
    if (reduction == 0) return 'Aucune réduction';

    if (reductionType == 'percentage') {
      return '${reduction.toStringAsFixed(1)}% de réduction';
    } else {
      return '${reduction.toStringAsFixed(2)}€ de réduction';
    }
  }

  @override
  String toString() {
    return 'SpecificPriceRule(id: $id, name: $name, reduction: $reductionDescription, active: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpecificPriceRule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
