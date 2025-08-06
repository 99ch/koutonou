/// Modèle CustomizationField pour PrestaShop API
/// Représente un champ de personnalisation de produit
class CustomizationField {
  final int? id;
  final int idProduct;
  final int type; // Type du champ (0 = texte, 1 = fichier, etc.)
  final bool required;
  final bool? isModule;
  final bool? isDeleted;
  final Map<String, String> name; // Multi-langue

  const CustomizationField({
    this.id,
    required this.idProduct,
    required this.type,
    required this.required,
    this.isModule,
    this.isDeleted,
    required this.name,
  });

  /// Crée un CustomizationField à partir de la réponse JSON de PrestaShop
  factory CustomizationField.fromPrestaShopJson(Map<String, dynamic> json) {
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

    return CustomizationField(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idProduct: int.tryParse(json['id_product']?.toString() ?? '0') ?? 0,
      type: int.tryParse(json['type']?.toString() ?? '0') ?? 0,
      required: json['required']?.toString() == '1',
      isModule: json['is_module']?.toString() == '1',
      isDeleted: json['is_deleted']?.toString() == '1',
      name: parseName.isNotEmpty
          ? parseName
          : {'1': json['name']?.toString() ?? ''},
    );
  }

  /// Convertit le CustomizationField en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_product': idProduct.toString(),
      'type': type.toString(),
      'required': required ? '1' : '0',
      'name': name,
    };

    if (id != null) json['id'] = id.toString();
    if (isModule != null) json['is_module'] = isModule! ? '1' : '0';
    if (isDeleted != null) json['is_deleted'] = isDeleted! ? '1' : '0';

    return json;
  }

  /// Convertit le CustomizationField en format XML pour PrestaShop
  String toPrestaShopXml() {
    final buffer = StringBuffer();
    buffer.writeln('<customization_field>');

    if (id != null) buffer.writeln('  <id><![CDATA[${id}]]></id>');
    buffer.writeln('  <id_product><![CDATA[${idProduct}]]></id_product>');
    buffer.writeln('  <type><![CDATA[${type}]]></type>');
    buffer.writeln(
      '  <required><![CDATA[${required ? '1' : '0'}]]></required>',
    );

    if (isModule != null)
      buffer.writeln(
        '  <is_module><![CDATA[${isModule! ? '1' : '0'}]]></is_module>',
      );
    if (isDeleted != null)
      buffer.writeln(
        '  <is_deleted><![CDATA[${isDeleted! ? '1' : '0'}]]></is_deleted>',
      );

    // Noms multi-langues
    buffer.writeln('  <name>');
    name.forEach((langId, value) {
      buffer.writeln(
        '    <language id="${langId}"><![CDATA[${value}]]></language>',
      );
    });
    buffer.writeln('  </name>');

    buffer.writeln('</customization_field>');
    return buffer.toString();
  }

  // Helper pour obtenir le nom dans une langue spécifique
  String getNameInLanguage(String languageId) {
    return name[languageId] ?? name.values.first;
  }

  // Helper pour obtenir le type de champ lisible
  String get typeDescription {
    switch (type) {
      case 0:
        return 'Texte';
      case 1:
        return 'Fichier';
      default:
        return 'Type $type';
    }
  }

  @override
  String toString() {
    return 'CustomizationField(id: $id, idProduct: $idProduct, name: ${name.values.first}, type: $typeDescription, required: $required)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomizationField && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
