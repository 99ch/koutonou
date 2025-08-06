/// Modèle ProductOptionValue pour PrestaShop API
/// Représente une valeur d'option de produit (ex: Rouge, Bleu pour Couleur)
class ProductOptionValue {
  final int? id;
  final int idAttributeGroup;
  final String? color; // Couleur hex si applicable
  final int? position;
  final Map<String, String> name; // Multi-langue

  const ProductOptionValue({
    this.id,
    required this.idAttributeGroup,
    this.color,
    this.position,
    required this.name,
  });

  /// Crée un ProductOptionValue à partir de la réponse JSON de PrestaShop
  factory ProductOptionValue.fromPrestaShopJson(Map<String, dynamic> json) {
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

    return ProductOptionValue(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idAttributeGroup:
          int.tryParse(json['id_attribute_group']?.toString() ?? '0') ?? 0,
      color: json['color']?.toString().isNotEmpty == true
          ? json['color'].toString()
          : null,
      position: int.tryParse(json['position']?.toString() ?? '0'),
      name: parseName.isNotEmpty
          ? parseName
          : {'1': json['name']?.toString() ?? ''},
    );
  }

  /// Convertit le ProductOptionValue en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_attribute_group': idAttributeGroup.toString(),
      'name': name,
    };

    if (id != null) json['id'] = id.toString();
    if (color != null) json['color'] = color;
    if (position != null) json['position'] = position.toString();

    return json;
  }

  /// Convertit le ProductOptionValue en format XML pour PrestaShop
  String toPrestaShopXml() {
    final buffer = StringBuffer();
    buffer.writeln('<product_option_value>');

    if (id != null) buffer.writeln('  <id><![CDATA[${id}]]></id>');
    buffer.writeln(
      '  <id_attribute_group><![CDATA[${idAttributeGroup}]]></id_attribute_group>',
    );
    if (color != null) buffer.writeln('  <color><![CDATA[${color}]]></color>');
    if (position != null)
      buffer.writeln('  <position><![CDATA[${position}]]></position>');

    // Noms multi-langues
    buffer.writeln('  <name>');
    name.forEach((langId, value) {
      buffer.writeln(
        '    <language id="${langId}"><![CDATA[${value}]]></language>',
      );
    });
    buffer.writeln('  </name>');

    buffer.writeln('</product_option_value>');
    return buffer.toString();
  }

  // Helper pour obtenir le nom dans une langue spécifique
  String getNameInLanguage(String languageId) {
    return name[languageId] ?? name.values.first;
  }

  // Helper pour vérifier si c'est une couleur
  bool get isColor => color != null && color!.isNotEmpty;

  @override
  String toString() {
    return 'ProductOptionValue(id: $id, name: ${name.values.first}, color: $color, idAttributeGroup: $idAttributeGroup)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductOptionValue && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
