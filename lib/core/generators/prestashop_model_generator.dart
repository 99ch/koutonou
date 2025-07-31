// Générateur automatique de modèles Dart basés sur l'API PrestaShop
// Analyse les schémas XML de PrestaShop et génère les classes Dart correspondantes
// avec sérialisation JSON, validation et types Dart appropriés.

import 'dart:io';
import 'package:koutonou/core/api/api_client.dart';
import 'package:koutonou/core/utils/logger.dart';

class PrestaShopModelGenerator {
  static final _logger = AppLogger();
  static final _apiClient = ApiClient();

  /// Mapping des types PrestaShop vers les types Dart
  static const Map<String, String> _typeMapping = {
    // Types génériques
    'isBool': 'bool',
    'isFloat': 'double',
    'isInt': 'int',
    'isString': 'String',
    'isUnsignedId': 'int',
    'isUnsignedFloat': 'double',
    'isNullOrUnsignedId': 'int?',

    // Types spécifiques
    'isEmail': 'String',
    'isDate': 'DateTime',
    'isBirthDate': 'DateTime',
    'isUrl': 'String',
    'isAbsoluteUrl': 'String',
    'isColor': 'String',
    'isMd5': 'String',
    'isSha1': 'String',
    'isPasswd': 'String',
    'isPercentage': 'double',

    // Noms et textes
    'isName': 'String',
    'isGenericName': 'String',
    'isCatalogName': 'String',
    'isCustomerName': 'String',
    'isCarrierName': 'String',

    // Localisations
    'isAddress': 'String',
    'isCityName': 'String',
    'isPostCode': 'String',
    'isPhoneNumber': 'String',
    'isCoordinate': 'double',
    'isStateIsoCode': 'String',
    'isLanguageCode': 'String',
    'isLanguageIsoCode': 'String',

    // Produits
    'isPrice': 'double',
    'isNegativePrice': 'double',
    'isEan13': 'String',
    'isUpc': 'String',
    'isIsbn': 'String',
    'isMpn': 'String',
    'isLinkRewrite': 'String',
    'isReference': 'String',
    'isProductVisibility': 'String',

    // Types spéciaux
    'isJson': 'Map<String, dynamic>',
    'isSerializedArray': 'List<dynamic>',
    'isAnything': 'dynamic',
  };

  /// Configuration des ressources PrestaShop et leurs modules correspondants
  static const Map<String, String> _resourceModuleMapping = {
    // Products module
    'products': 'products',
    'categories': 'products',
    'manufacturers': 'products',
    'suppliers': 'products',
    'attachments': 'products',
    'images': 'products',
    'product_features': 'products',
    'product_feature_values': 'products',
    'product_options': 'products',
    'product_option_values': 'products',
    'combinations': 'products',
    'tags': 'products',

    // Customers module
    'customers': 'customers',
    'addresses': 'customers',
    'groups': 'customers',
    'guests': 'customers',

    // Orders module
    'orders': 'orders',
    'order_details': 'orders',
    'order_histories': 'orders',
    'order_invoices': 'orders',
    'order_payments': 'orders',
    'order_carriers': 'orders',
    'order_states': 'orders',
    'order_slip': 'orders',

    // Carts module
    'carts': 'carts',
    'cart_rules': 'carts',

    // Stocks module
    'stocks': 'stocks',
    'stock_availables': 'stocks',
    'stock_movements': 'stocks',
    'stock_movement_reasons': 'stocks',

    // Shipping module
    'carriers': 'shipping',
    'deliveries': 'shipping',
    'price_ranges': 'shipping',
    'weight_ranges': 'shipping',

    // Support module
    'customer_messages': 'support',
    'customer_threads': 'support',
    'messages': 'support',

    // Stores module
    'stores': 'stores',
    'warehouses': 'stores',
    'warehouse_product_locations': 'stores',

    // Employees module
    'employees': 'employees',

    // Taxes module
    'taxes': 'taxes',
    'tax_rules': 'taxes',
    'tax_rule_groups': 'taxes',

    // Configs module
    'configurations': 'configs',
    'translated_configurations': 'configs',
    'currencies': 'configs',
    'countries': 'configs',
    'states': 'configs',
    'languages': 'configs',
    'zones': 'configs',

    // CMS module
    'content_management_system': 'cms',

    // Customizations module
    'customizations': 'customizations',
    'product_customization_fields': 'customizations',

    // Autres
    'specific_prices': 'products',
    'specific_price_rules': 'products',
    'contacts': 'support',
  };

  /// Génère tous les modèles pour toutes les ressources
  static Future<void> generateAllModels() async {
    _logger.info('🚀 Début de la génération des modèles PrestaShop');

    for (final resource in _resourceModuleMapping.keys) {
      try {
        await generateModelForResource(resource);
        await Future.delayed(
          const Duration(milliseconds: 500),
        ); // Éviter surcharge API
      } catch (e) {
        _logger.error('❌ Erreur génération modèle $resource: $e');
      }
    }

    _logger.info('✅ Génération des modèles terminée');
  }

  /// Génère un modèle pour une ressource spécifique
  static Future<void> generateModelForResource(String resource) async {
    _logger.info('📝 Génération du modèle pour: $resource');

    try {
      // 1. Récupérer le schéma synopsis de PrestaShop
      final schema = await _fetchResourceSchema(resource);

      // 2. Parser le schéma XML
      final fields = _parseXmlSchema(schema);

      // 3. Générer le code Dart
      final dartCode = _generateDartModel(resource, fields);

      // 4. Écrire le fichier
      await _writeModelFile(resource, dartCode);

      _logger.info('✅ Modèle généré pour $resource');
    } catch (e, stackTrace) {
      _logger.error('❌ Erreur génération $resource', e, stackTrace);
      rethrow;
    }
  }

  /// Récupère le schéma XML d'une ressource PrestaShop
  static Future<String> _fetchResourceSchema(String resource) async {
    final response = await _apiClient.get(
      resource,
      queryParameters: {'schema': 'synopsis'},
    );

    if (!response.success) {
      throw Exception('Impossible de récupérer le schéma pour $resource');
    }

    return response.data.toString();
  }

  /// Parse le schéma XML et extrait les champs
  static List<ModelField> _parseXmlSchema(String xmlSchema) {
    final fields = <ModelField>[];

    // Parser XML basique (à améliorer avec xml package)
    final fieldRegex = RegExp(r'<(\w+)([^>]*)>([^<]*)</\1>');
    final matches = fieldRegex.allMatches(xmlSchema);

    for (final match in matches) {
      final fieldName = match.group(1)!;
      final attributes = match.group(2) ?? '';

      // Extraire les attributs
      final formatMatch = RegExp(r'format="([^"]*)"').firstMatch(attributes);
      final requiredMatch = RegExp(r'required="true"').hasMatch(attributes);
      final maxSizeMatch = RegExp(r'maxSize="([^"]*)"').firstMatch(attributes);
      final readOnlyMatch = RegExp(r'readOnly="true"').hasMatch(attributes);

      final format = formatMatch?.group(1);
      final dartType = _mapPrestaShopTypeToDart(format);

      fields.add(
        ModelField(
          name: fieldName,
          dartType: dartType,
          prestaShopFormat: format,
          isRequired: requiredMatch,
          maxSize: maxSizeMatch?.group(1),
          isReadOnly: readOnlyMatch,
        ),
      );
    }

    return fields;
  }

  /// Mappe un type PrestaShop vers un type Dart
  static String _mapPrestaShopTypeToDart(String? prestaShopFormat) {
    if (prestaShopFormat == null) return 'String';

    return _typeMapping[prestaShopFormat] ?? 'String';
  }

  /// Génère le code Dart du modèle
  static String _generateDartModel(String resource, List<ModelField> fields) {
    final className = _generateClassName(resource);
    final imports = _generateImports();
    final classContent = _generateClassContent(className, fields);

    return '''$imports

$classContent''';
  }

  /// Génère le nom de classe en PascalCase
  static String _generateClassName(String resource) {
    return resource
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join('') +
        'Model';
  }

  /// Génère les imports nécessaires
  static String _generateImports() {
    return '''// Modèle généré automatiquement depuis l'API PrestaShop
// Ne pas modifier manuellement - utiliser le générateur

import 'package:json_annotation/json_annotation.dart';

part '${_generateClassName('').toLowerCase()}.g.dart';''';
  }

  /// Génère le contenu de la classe
  static String _generateClassContent(
    String className,
    List<ModelField> fields,
  ) {
    final properties = fields.map(_generateProperty).join('\n\n');
    final constructor = _generateConstructor(className, fields);
    final fromJson = _generateFromJson(className);
    final toJson = _generateToJson();

    return '''@JsonSerializable()
class $className {
$properties

$constructor

$fromJson

$toJson
}''';
  }

  /// Génère une propriété de classe
  static String _generateProperty(ModelField field) {
    final annotation = _generateJsonAnnotation(field);
    final documentation = _generatePropertyDocumentation(field);

    return '''$documentation$annotation
  final ${field.dartType} ${field.name};''';
  }

  /// Génère l'annotation JSON pour une propriété
  static String _generateJsonAnnotation(ModelField field) {
    if (field.name == 'id') {
      return "  @JsonKey(name: 'id')";
    }
    return "  @JsonKey(name: '${field.name}')";
  }

  /// Génère la documentation d'une propriété
  static String _generatePropertyDocumentation(ModelField field) {
    var doc = '  /// ${field.name}';
    if (field.prestaShopFormat != null) {
      doc += ' (${field.prestaShopFormat})';
    }
    if (field.isRequired) {
      doc += ' - Requis';
    }
    if (field.isReadOnly) {
      doc += ' - Lecture seule';
    }
    return '$doc\n';
  }

  /// Génère le constructeur
  static String _generateConstructor(
    String className,
    List<ModelField> fields,
  ) {
    final requiredParams = fields
        .where((f) => f.isRequired)
        .map((f) => 'required this.${f.name}')
        .join(',\n    ');
    final optionalParams = fields
        .where((f) => !f.isRequired)
        .map((f) => 'this.${f.name}')
        .join(',\n    ');

    var constructor = '  $className({\n';
    if (requiredParams.isNotEmpty) {
      constructor += '    $requiredParams,\n';
    }
    if (optionalParams.isNotEmpty) {
      constructor += '    $optionalParams,\n';
    }
    constructor += '  });';

    return constructor;
  }

  /// Génère la méthode fromJson
  static String _generateFromJson(String className) {
    return '''  factory $className.fromJson(Map<String, dynamic> json) => 
      _\$${className}FromJson(json);''';
  }

  /// Génère la méthode toJson
  static String _generateToJson() {
    return '''  Map<String, dynamic> toJson() => _\$${_generateClassName('')}ToJson(this);''';
  }

  /// Écrit le fichier modèle
  static Future<void> _writeModelFile(String resource, String dartCode) async {
    final moduleName = _resourceModuleMapping[resource];
    if (moduleName == null) {
      throw Exception('Module non trouvé pour la ressource: $resource');
    }

    final fileName = '${resource}_model.dart';
    final filePath = 'lib/modules/$moduleName/models/$fileName';

    final file = File(filePath);
    await file.writeAsString(dartCode);

    _logger.info('📄 Fichier créé: $filePath');
  }
}

/// Représente un champ de modèle
class ModelField {
  final String name;
  final String dartType;
  final String? prestaShopFormat;
  final bool isRequired;
  final String? maxSize;
  final bool isReadOnly;

  ModelField({
    required this.name,
    required this.dartType,
    this.prestaShopFormat,
    this.isRequired = false,
    this.maxSize,
    this.isReadOnly = false,
  });
}
