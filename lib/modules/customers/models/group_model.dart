/// Modèle Group pour PrestaShop API
/// Représente un groupe de clients
class Group {
  final int? id;
  final double? reduction;
  final int priceDisplayMethod;
  final bool showPrices;
  final DateTime? dateAdd;
  final DateTime? dateUpd;
  final Map<String, String> name; // Multi-langue

  const Group({
    this.id,
    this.reduction,
    required this.priceDisplayMethod,
    this.showPrices = true,
    this.dateAdd,
    this.dateUpd,
    required this.name,
  });

  /// Crée un Group à partir de la réponse JSON de PrestaShop
  factory Group.fromPrestaShopJson(Map<String, dynamic> json) {
    // Parse les noms multi-langues
    Map<String, String> parseName = {};

    if (json['name'] is Map) {
      final nameData = json['name'] as Map<String, dynamic>;
      if (nameData['language'] is List) {
        for (final lang in nameData['language']) {
          if (lang is Map) {
            final langId = lang['@attributes']?['id']?.toString() ?? '1';
            final value = lang['\$']?.toString() ?? '';
            parseName[langId] = value;
          }
        }
      } else if (nameData['language'] is Map) {
        final lang = nameData['language'] as Map<String, dynamic>;
        final langId = lang['@attributes']?['id']?.toString() ?? '1';
        final value = lang['\$']?.toString() ?? '';
        parseName[langId] = value;
      }
    }

    return Group(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      reduction: double.tryParse(json['reduction']?.toString() ?? '0'),
      priceDisplayMethod:
          int.tryParse(json['price_display_method']?.toString() ?? '0') ?? 0,
      showPrices: json['show_prices']?.toString() == '1',
      dateAdd:
          json['date_add'] != null && json['date_add'].toString().isNotEmpty
          ? DateTime.tryParse(json['date_add'].toString())
          : null,
      dateUpd:
          json['date_upd'] != null && json['date_upd'].toString().isNotEmpty
          ? DateTime.tryParse(json['date_upd'].toString())
          : null,
      name: parseName.isNotEmpty
          ? parseName
          : {'1': json['name']?.toString() ?? ''},
    );
  }

  /// Convertit le Group en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'price_display_method': priceDisplayMethod.toString(),
      'show_prices': showPrices ? '1' : '0',
      'name': name,
    };

    if (id != null) json['id'] = id.toString();
    if (reduction != null) json['reduction'] = reduction.toString();

    return json;
  }

  /// Convertit le Group en format XML pour PrestaShop
  String toPrestaShopXml() {
    final buffer = StringBuffer();
    buffer.writeln('<group>');

    if (id != null) buffer.writeln('  <id><![CDATA[${id}]]></id>');
    if (reduction != null)
      buffer.writeln('  <reduction><![CDATA[${reduction}]]></reduction>');
    buffer.writeln(
      '  <price_display_method><![CDATA[${priceDisplayMethod}]]></price_display_method>',
    );
    buffer.writeln(
      '  <show_prices><![CDATA[${showPrices ? '1' : '0'}]]></show_prices>',
    );

    // Noms multi-langues
    buffer.writeln('  <name>');
    name.forEach((langId, value) {
      buffer.writeln(
        '    <language id="${langId}"><![CDATA[${value}]]></language>',
      );
    });
    buffer.writeln('  </name>');

    buffer.writeln('</group>');
    return buffer.toString();
  }

  /// Obtient le nom dans une langue spécifique
  String getNameInLanguage(String languageId) {
    return name[languageId] ?? name.values.first;
  }

  /// Nom par défaut (première langue)
  String get defaultName => name.values.first;

  /// Méthode d'affichage des prix (description)
  String get priceDisplayMethodDescription {
    switch (priceDisplayMethod) {
      case 0:
        return 'Prix TTC';
      case 1:
        return 'Prix HT';
      default:
        return 'Méthode $priceDisplayMethod';
    }
  }

  /// Statut d'affichage des prix
  String get priceVisibilityStatus => showPrices ? 'Visible' : 'Masqué';

  /// Pourcentage de réduction formaté
  String get formattedReduction {
    if (reduction == null || reduction == 0) return 'Aucune réduction';
    return '${reduction!.toStringAsFixed(2)}%';
  }

  /// Vérifie si le groupe a une réduction
  bool get hasReduction => reduction != null && reduction! > 0;

  /// Vérifie si le groupe affiche les prix TTC
  bool get showsPricesWithTax => priceDisplayMethod == 0;

  /// Vérifie si le groupe affiche les prix HT
  bool get showsPricesWithoutTax => priceDisplayMethod == 1;

  /// Date formatée d'ajout
  String get formattedDateAdd {
    if (dateAdd == null) return 'Date inconnue';
    return '${dateAdd!.day.toString().padLeft(2, '0')}/${dateAdd!.month.toString().padLeft(2, '0')}/${dateAdd!.year}';
  }

  @override
  String toString() {
    return 'Group(id: $id, name: $defaultName, reduction: $formattedReduction, showPrices: $showPrices)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Group && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
