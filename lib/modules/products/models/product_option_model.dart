/// Modèle ProductOption pour PrestaShop API
/// Représente un groupe d'options de produit (ex: Couleur, Taille)
class ProductOption {
  final int? id;
  final bool? isColorGroup;
  final String groupType;
  final int? position;
  final Map<String, String> name; // Multi-langue
  final Map<String, String> publicName; // Multi-langue
  final List<int>? productOptionValueIds; // IDs des valeurs associées

  const ProductOption({
    this.id,
    this.isColorGroup,
    required this.groupType,
    this.position,
    required this.name,
    required this.publicName,
    this.productOptionValueIds,
  });

  /// Crée un ProductOption à partir de la réponse JSON de PrestaShop
  factory ProductOption.fromPrestaShopJson(Map<String, dynamic> json) {
    // Parse les noms multi-langues
    Map<String, String> parseName = {};
    Map<String, String> parsePublicName = {};

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

    if (json['public_name'] is Map) {
      final publicNameData = json['public_name'] as Map<String, dynamic>;
      if (publicNameData['language'] is List) {
        for (final lang in publicNameData['language']) {
          if (lang is Map) {
            final langId = lang['@attributes']?['id']?.toString() ?? '1';
            final value = lang['\$']?.toString() ?? '';
            parsePublicName[langId] = value;
          }
        }
      } else if (publicNameData['language'] is Map) {
        final lang = publicNameData['language'] as Map<String, dynamic>;
        final langId = lang['@attributes']?['id']?.toString() ?? '1';
        final value = lang['\$']?.toString() ?? '';
        parsePublicName[langId] = value;
      }
    }

    // Parse les associations (product_option_values)
    List<int>? optionValueIds;
    if (json['associations']?['product_option_values'] is Map) {
      final values = json['associations']['product_option_values'];
      if (values['product_option_value'] is List) {
        optionValueIds = (values['product_option_value'] as List)
            .map((v) => int.tryParse(v['id']?.toString() ?? '0') ?? 0)
            .where((id) => id > 0)
            .toList();
      } else if (values['product_option_value'] is Map) {
        final id =
            int.tryParse(
              values['product_option_value']['id']?.toString() ?? '0',
            ) ??
            0;
        if (id > 0) optionValueIds = [id];
      }
    }

    return ProductOption(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      isColorGroup: json['is_color_group']?.toString() == '1',
      groupType: json['group_type']?.toString() ?? '',
      position: int.tryParse(json['position']?.toString() ?? '0'),
      name: parseName.isNotEmpty
          ? parseName
          : {'1': json['name']?.toString() ?? ''},
      publicName: parsePublicName.isNotEmpty
          ? parsePublicName
          : {'1': json['public_name']?.toString() ?? ''},
      productOptionValueIds: optionValueIds,
    );
  }

  /// Convertit le ProductOption en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'group_type': groupType,
      'name': name,
      'public_name': publicName,
    };

    if (id != null) json['id'] = id.toString();
    if (isColorGroup != null)
      json['is_color_group'] = isColorGroup! ? '1' : '0';
    if (position != null) json['position'] = position.toString();

    // Ajouter les associations si disponibles
    if (productOptionValueIds != null && productOptionValueIds!.isNotEmpty) {
      json['associations'] = {
        'product_option_values': {
          'product_option_value': productOptionValueIds!
              .map((id) => {'id': id.toString()})
              .toList(),
        },
      };
    }

    return json;
  }

  /// Convertit le ProductOption en format XML pour PrestaShop
  String toPrestaShopXml() {
    final buffer = StringBuffer();
    buffer.writeln('<product_option>');

    if (id != null) buffer.writeln('  <id><![CDATA[${id}]]></id>');
    if (isColorGroup != null)
      buffer.writeln(
        '  <is_color_group><![CDATA[${isColorGroup! ? '1' : '0'}]]></is_color_group>',
      );
    buffer.writeln('  <group_type><![CDATA[${groupType}]]></group_type>');
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

    buffer.writeln('  <public_name>');
    publicName.forEach((langId, value) {
      buffer.writeln(
        '    <language id="${langId}"><![CDATA[${value}]]></language>',
      );
    });
    buffer.writeln('  </public_name>');

    // Associations
    if (productOptionValueIds != null && productOptionValueIds!.isNotEmpty) {
      buffer.writeln('  <associations>');
      buffer.writeln('    <product_option_values>');
      for (final valueId in productOptionValueIds!) {
        buffer.writeln('      <product_option_value>');
        buffer.writeln('        <id><![CDATA[${valueId}]]></id>');
        buffer.writeln('      </product_option_value>');
      }
      buffer.writeln('    </product_option_values>');
      buffer.writeln('  </associations>');
    }

    buffer.writeln('</product_option>');
    return buffer.toString();
  }

  // Helper pour obtenir le nom dans une langue spécifique
  String getNameInLanguage(String languageId) {
    return name[languageId] ?? name.values.first;
  }

  // Helper pour obtenir le nom public dans une langue spécifique
  String getPublicNameInLanguage(String languageId) {
    return publicName[languageId] ?? publicName.values.first;
  }

  @override
  String toString() {
    return 'ProductOption(id: $id, groupType: $groupType, name: ${name.values.first}, isColorGroup: $isColorGroup)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
