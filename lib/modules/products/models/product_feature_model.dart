/// Modèle ProductFeature pour PrestaShop API
/// Représente une caractéristique de produit (ex: Poids, Matériau)
class ProductFeature {
  final int? id;
  final int? position;
  final Map<String, String> name; // Multi-langue

  const ProductFeature({this.id, this.position, required this.name});

  /// Crée un ProductFeature à partir de la réponse JSON de PrestaShop
  factory ProductFeature.fromPrestaShopJson(Map<String, dynamic> json) {
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

    return ProductFeature(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      position: int.tryParse(json['position']?.toString() ?? '0'),
      name: parseName.isNotEmpty
          ? parseName
          : {'1': json['name']?.toString() ?? ''},
    );
  }

  /// Convertit le ProductFeature en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{'name': name};

    if (id != null) json['id'] = id.toString();
    if (position != null) json['position'] = position.toString();

    return json;
  }

  /// Convertit le ProductFeature en format XML pour PrestaShop
  String toPrestaShopXml() {
    final buffer = StringBuffer();
    buffer.writeln('<product_feature>');

    if (id != null) buffer.writeln('  <id><![CDATA[${id}]]></id>');
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

    buffer.writeln('</product_feature>');
    return buffer.toString();
  }

  // Helper pour obtenir le nom dans une langue spécifique
  String getNameInLanguage(String languageId) {
    return name[languageId] ?? name.values.first;
  }

  @override
  String toString() {
    return 'ProductFeature(id: $id, name: ${name.values.first}, position: $position)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductFeature && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
