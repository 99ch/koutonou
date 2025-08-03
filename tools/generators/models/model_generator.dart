// Générateur de modèles Dart basé sur les données découvertes
// Phase 1 MVP : Génération automatique pour 3 ressources simples
// Crée des modèles avec json_annotation et validation

import 'dart:convert';
import 'dart:io';

/// Générateur de modèles Dart
class ModelGenerator {
  static const String _inputDir = 'tools/generators/data';
  static const String _outputBaseDir = 'lib/modules';

  /// Mapping des ressources vers leurs modules
  static const Map<String, String> _resourceToModule = {
    'languages': 'configs',
    'currencies': 'configs',
    'countries': 'configs',
  };

  /// Mapping des types PrestaShop vers Dart
  static const Map<String, String> _typeMapping = {
    'int': 'int',
    'double': 'double',
    'bool': 'bool',
    'String': 'String',
    'DateTime': 'DateTime',
    'List<dynamic>': 'List<dynamic>',
    'Map<String, dynamic>': 'Map<String, dynamic>',
    'dynamic': 'dynamic',
  };

  /// Génère tous les modèles MVP
  static Future<void> generateMvpModels() async {
    print('🏗️  Début de la génération des modèles MVP');

    // Lire les résultats de la découverte
    final discoveryData = await _loadDiscoveryData();
    if (discoveryData == null) {
      print('❌ Impossible de charger les données de découverte');
      return;
    }

    final resources = discoveryData['resources'] as Map<String, dynamic>;

    for (final entry in resources.entries) {
      final resourceName = entry.key;
      final resourceData = entry.value as Map<String, dynamic>;

      if (resourceData['error'] != null) {
        print('⚠️  Ignorer $resourceName (erreur lors de la découverte)');
        continue;
      }

      try {
        print('📝 Génération du modèle pour: $resourceName');
        await _generateModelForResource(resourceName, resourceData);
        print('✅ Modèle généré pour $resourceName');
      } catch (e, stackTrace) {
        print('❌ Erreur génération $resourceName: $e');
        print('Stack: $stackTrace');
      }
    }

    print('✅ Génération des modèles MVP terminée');
  }

  /// Charge les données de découverte
  static Future<Map<String, dynamic>?> _loadDiscoveryData() async {
    try {
      final file = File('$_inputDir/mvp_discovery_results.json');
      if (!await file.exists()) {
        print('❌ Fichier de découverte non trouvé: ${file.path}');
        return null;
      }

      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      print('❌ Erreur lecture données découverte: $e');
      return null;
    }
  }

  /// Génère un modèle pour une ressource
  static Future<void> _generateModelForResource(
    String resourceName,
    Map<String, dynamic> resourceData,
  ) async {
    // Analyser les données pour extraire les champs
    final fields = _extractFields(resourceData);
    if (fields.isEmpty) {
      print('⚠️  Aucun champ détecté pour $resourceName');
      return;
    }

    // Générer le code Dart
    final dartCode = _generateDartCode(resourceName, fields);

    // Écrire le fichier
    await _writeModelFile(resourceName, dartCode);
  }

  /// Extrait les champs d'une ressource
  static List<ModelField> _extractFields(Map<String, dynamic> resourceData) {
    final fields = <ModelField>[];

    // Utiliser les métadonnées détectées
    final metadata = resourceData['metadata'] as Map<String, dynamic>?;
    if (metadata == null) return fields;

    final detectedFields = metadata['detected_fields'] as List<dynamic>? ?? [];
    final detectedTypes =
        metadata['detected_types'] as Map<String, dynamic>? ?? {};

    for (final fieldName in detectedFields) {
      final fieldNameStr = fieldName.toString();
      final detectedType = detectedTypes[fieldNameStr]?.toString() ?? 'String';
      final dartType = _typeMapping[detectedType] ?? 'String';

      fields.add(
        ModelField(
          name: fieldNameStr,
          dartType: dartType,
          isRequired: fieldNameStr == 'id', // ID toujours requis
          isNullable: dartType.endsWith('?') || fieldNameStr != 'id',
        ),
      );
    }

    return fields;
  }

  /// Génère le code Dart complet
  static String _generateDartCode(
    String resourceName,
    List<ModelField> fields,
  ) {
    final className = _generateClassName(resourceName);
    final imports = _generateImports(className);
    final classContent = _generateClassContent(className, fields);

    return '''$imports

$classContent''';
  }

  /// Génère le nom de classe
  static String _generateClassName(String resourceName) {
    final singular = _getSingularName(resourceName);
    return '${_capitalize(singular)}Model';
  }

  /// Convertit au singulier
  static String _getSingularName(String resource) {
    switch (resource) {
      case 'languages':
        return 'language';
      case 'currencies':
        return 'currency';
      case 'countries':
        return 'country';
      default:
        return resource.endsWith('s')
            ? resource.substring(0, resource.length - 1)
            : resource;
    }
  }

  /// Capitalise la première lettre
  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Génère les imports
  static String _generateImports(String className) {
    final lowerClassName = className.toLowerCase();
    return '''// Modèle généré automatiquement pour PrestaShop
// Phase 1 MVP - Ne pas modifier manuellement
// Utiliser les générateurs pour les modifications

import 'package:json_annotation/json_annotation.dart';

part '$lowerClassName.g.dart';''';
  }

  /// Génère le contenu de la classe
  static String _generateClassContent(
    String className,
    List<ModelField> fields,
  ) {
    final properties = fields.map(_generateProperty).join('\n\n');
    final constructor = _generateConstructor(className, fields);
    final fromJson = _generateFromJson(className);
    final toJson = _generateToJson(className);
    final toString = _generateToString(className, fields);
    final equality = _generateEquality(fields);

    return '''@JsonSerializable()
class $className {
$properties

$constructor

$fromJson

$toJson

$toString

$equality
}''';
  }

  /// Génère une propriété
  static String _generateProperty(ModelField field) {
    final annotation = _generateJsonAnnotation(field);
    final documentation = _generatePropertyDocumentation(field);
    final nullableType = field.isNullable && !field.dartType.endsWith('?')
        ? '${field.dartType}?'
        : field.dartType;

    return '''$documentation$annotation
  final $nullableType ${field.name};''';
  }

  /// Génère l'annotation JSON
  static String _generateJsonAnnotation(ModelField field) {
    return "  @JsonKey(name: '${field.name}')";
  }

  /// Génère la documentation
  static String _generatePropertyDocumentation(ModelField field) {
    var doc = '  /// ${field.name}';
    if (field.isRequired) {
      doc += ' (requis)';
    }
    if (field.isNullable) {
      doc += ' (optionnel)';
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
        .map((f) => '    required this.${f.name}')
        .join(',\n');

    final optionalParams = fields
        .where((f) => !f.isRequired)
        .map((f) => '    this.${f.name}')
        .join(',\n');

    var constructor = '  const $className({\n';
    if (requiredParams.isNotEmpty) {
      constructor += '$requiredParams,\n';
    }
    if (optionalParams.isNotEmpty) {
      constructor += '$optionalParams,\n';
    }
    constructor += '  });';

    return constructor;
  }

  /// Génère fromJson
  static String _generateFromJson(String className) {
    return '''  factory $className.fromJson(Map<String, dynamic> json) => 
      _\$${className}FromJson(json);''';
  }

  /// Génère toJson
  static String _generateToJson(String className) {
    return '''  Map<String, dynamic> toJson() => _\$${className}ToJson(this);''';
  }

  /// Génère toString
  static String _generateToString(String className, List<ModelField> fields) {
    final fieldStrings = fields
        .take(3) // Limiter pour éviter toString trop long
        .map((f) => '${f.name}: \$${f.name}')
        .join(', ');

    return '''  @override
  String toString() => '$className($fieldStrings)';''';
  }

  /// Génère equals et hashCode
  static String _generateEquality(List<ModelField> fields) {
    final equalityFields = fields
        .map((f) => f.name)
        .join(' &&\n        other.');
    final hashFields = fields
        .map((f) => '${f.name}.hashCode')
        .join(' ^\n        ');

    return '''  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ${_generateClassName('')} &&
          runtimeType == other.runtimeType &&
          ${equalityFields.isNotEmpty ? 'other.$equalityFields' : 'true'};

  @override
  int get hashCode => ${hashFields.isNotEmpty ? hashFields : '0'};''';
  }

  /// Écrit le fichier modèle
  static Future<void> _writeModelFile(
    String resourceName,
    String dartCode,
  ) async {
    final moduleName = _resourceToModule[resourceName];
    if (moduleName == null) {
      throw Exception('Module non trouvé pour $resourceName');
    }

    final className = _generateClassName(resourceName);
    final fileName = '${className.toLowerCase()}.dart';
    final dirPath = '$_outputBaseDir/$moduleName/models';
    final filePath = '$dirPath/$fileName';

    // Créer le dossier si nécessaire
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Écrire le fichier
    final file = File(filePath);
    await file.writeAsString(dartCode);

    print('📄 Modèle créé: $filePath');
  }
}

/// Représente un champ de modèle
class ModelField {
  final String name;
  final String dartType;
  final bool isRequired;
  final bool isNullable;

  ModelField({
    required this.name,
    required this.dartType,
    this.isRequired = false,
    this.isNullable = true,
  });
}
