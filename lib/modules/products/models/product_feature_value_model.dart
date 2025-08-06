/// Modèle ProductFeatureValue pour PrestaShop API
/// Représente une valeur de caractéristique de produit (ex: "100g" pour Poids)
class ProductFeatureValue {
  final int? id;
  final int idFeature;
  final bool? custom; // Si c'est une valeur personnalisée
  final Map<String, String> value; // Multi-langue

  const ProductFeatureValue({
    this.id,
    required this.idFeature,
    this.custom,
    required this.value,
  });

  /// Crée un ProductFeatureValue à partir de la réponse JSON de PrestaShop
  factory ProductFeatureValue.fromPrestaShopJson(Map<String, dynamic> json) {
    // Parse les valeurs multi-langues
    Map<String, String> parseValue = {};

    if (json['value'] is Map) {
      final valueData = json['value'] as Map<String, dynamic>;
      if (valueData['language'] is List) {
        for (final lang in valueData['language']) {
          if (lang is Map) {
            final langId = lang['@attributes']?['id']?.toString() ?? '1';
            final value = lang['\$']?.toString() ?? '';
            parseValue[langId] = value;
          }
        }
      } else if (valueData['language'] is Map) {
        final lang = valueData['language'] as Map<String, dynamic>;
        final langId = lang['@attributes']?['id']?.toString() ?? '1';
        final value = lang['\$']?.toString() ?? '';
        parseValue[langId] = value;
      }
    }

    return ProductFeatureValue(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idFeature: int.tryParse(json['id_feature']?.toString() ?? '0') ?? 0,
      custom: json['custom']?.toString() == '1',
      value: parseValue.isNotEmpty
          ? parseValue
          : {'1': json['value']?.toString() ?? ''},
    );
  }

  /// Convertit le ProductFeatureValue en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_feature': idFeature.toString(),
      'value': value,
    };

    if (id != null) json['id'] = id.toString();
    if (custom != null) json['custom'] = custom! ? '1' : '0';

    return json;
  }

  /// Convertit le ProductFeatureValue en format XML pour PrestaShop
  String toPrestaShopXml() {
    final buffer = StringBuffer();
    buffer.writeln('<product_feature_value>');

    if (id != null) buffer.writeln('  <id><![CDATA[${id}]]></id>');
    buffer.writeln('  <id_feature><![CDATA[${idFeature}]]></id_feature>');
    if (custom != null)
      buffer.writeln('  <custom><![CDATA[${custom! ? '1' : '0'}]]></custom>');

    // Valeurs multi-langues
    buffer.writeln('  <value>');
    value.forEach((langId, val) {
      buffer.writeln(
        '    <language id="${langId}"><![CDATA[${val}]]></language>',
      );
    });
    buffer.writeln('  </value>');

    buffer.writeln('</product_feature_value>');
    return buffer.toString();
  }

  // Helper pour obtenir la valeur dans une langue spécifique
  String getValueInLanguage(String languageId) {
    return value[languageId] ?? value.values.first;
  }

  @override
  String toString() {
    return 'ProductFeatureValue(id: $id, idFeature: $idFeature, value: ${value.values.first}, custom: $custom)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductFeatureValue && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
