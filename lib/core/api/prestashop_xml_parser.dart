import 'dart:convert';
import 'package:xml/xml.dart';
import '../exceptions/prestashop_api_exception.dart';

/// Parser XML spécialisé pour les réponses de l'API PrestaShop
/// 
/// Cette classe gère le parsing des réponses XML de PrestaShop
/// et la conversion en objets Dart utilisables.
class PrestashopXmlParser {
  
  /// Parser une réponse de liste d'objets
  static List<Map<String, dynamic>> parseList(XmlDocument document, String resourceName) {
    try {
      final results = <Map<String, dynamic>>[];
      
      // Chercher l'élément racine de la réponse
      final rootElement = document.rootElement;
      
      // Vérifier s'il y a des erreurs
      _checkForErrors(rootElement);
      
      // Trouver l'élément contenant les objets
      final objectsElement = rootElement.findElements(resourceName).firstOrNull;
      if (objectsElement == null) {
        return results;
      }
      
      // Parser chaque objet individuel
      for (final element in objectsElement.children.whereType<XmlElement>()) {
        if (element.localName == resourceName.replaceAll('s', '')) {
          final parsedObject = _parseObjectElement(element);
          if (parsedObject.isNotEmpty) {
            results.add(parsedObject);
          }
        }
      }
      
      return results;
    } catch (e) {
      throw PrestashopApiException(
        'Failed to parse XML list response: $e',
        originalException: e,
      );
    }
  }
  
  /// Parser une réponse d'objet unique
  static Map<String, dynamic> parseObject(XmlDocument document, String resourceName) {
    try {
      final rootElement = document.rootElement;
      
      // Vérifier s'il y a des erreurs
      _checkForErrors(rootElement);
      
      // Trouver l'élément de l'objet
      final objectElement = rootElement.findElements(resourceName).firstOrNull;
      if (objectElement == null) {
        throw PrestashopApiException('Object element not found in response');
      }
      
      return _parseObjectElement(objectElement);
    } catch (e) {
      throw PrestashopApiException(
        'Failed to parse XML object response: $e',
        originalException: e,
      );
    }
  }
  
  /// Parser les métadonnées de pagination
  static Map<String, dynamic> parsePaginationMeta(XmlDocument document) {
    final meta = <String, dynamic>{};
    
    try {
      final rootElement = document.rootElement;
      
      // Extraire les informations de pagination depuis les attributs
      final limitAttr = rootElement.getAttribute('limit');
      final offsetAttr = rootElement.getAttribute('offset');
      final totalAttr = rootElement.getAttribute('total');
      
      if (limitAttr != null) meta['limit'] = int.tryParse(limitAttr);
      if (offsetAttr != null) meta['offset'] = int.tryParse(offsetAttr);
      if (totalAttr != null) meta['total'] = int.tryParse(totalAttr);
      
      // Calculer les pages
      if (meta['limit'] != null && meta['total'] != null) {
        final limit = meta['limit'] as int;
        final total = meta['total'] as int;
        meta['totalPages'] = (total / limit).ceil();
        meta['currentPage'] = meta['offset'] != null 
            ? ((meta['offset'] as int) / limit).floor() + 1
            : 1;
      }
      
      return meta;
    } catch (e) {
      return meta;
    }
  }
  
  /// Créer un document XML pour l'envoi de données
  static XmlDocument createRequestDocument(String resourceName, Map<String, dynamic> data) {
    final builder = XmlBuilder();
    
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('prestashop', nest: () {
      builder.element(resourceName, nest: () {
        _buildElementFromMap(builder, data);
      });
    });
    
    return builder.buildDocument();
  }
  
  /// Parser un élément d'erreur PrestaShop
  static Map<String, dynamic>? parseError(XmlDocument document) {
    try {
      final errorElement = document.findAllElements('error').firstOrNull;
      if (errorElement == null) return null;
      
      return {
        'code': errorElement.findElements('code').firstOrNull?.text,
        'message': errorElement.findElements('message').firstOrNull?.text,
      };
    } catch (e) {
      return null;
    }
  }
  
  // ==================== MÉTHODES PRIVÉES ====================
  
  /// Parser un élément XML en Map
  static Map<String, dynamic> _parseObjectElement(XmlElement element) {
    final result = <String, dynamic>{};
    
    // Ajouter les attributs
    for (final attr in element.attributes) {
      result[attr.localName] = _convertValue(attr.value);
    }
    
    // Parser les éléments enfants
    for (final child in element.children.whereType<XmlElement>()) {
      final key = child.localName;
      
      if (child.children.whereType<XmlElement>().isNotEmpty) {
        // Élément complexe avec des sous-éléments
        if (result.containsKey(key)) {
          // Convertir en liste si plusieurs éléments avec le même nom
          if (result[key] is! List) {
            result[key] = [result[key]];
          }
          (result[key] as List).add(_parseObjectElement(child));
        } else {
          result[key] = _parseObjectElement(child);
        }
      } else {
        // Élément simple avec texte
        final value = _convertValue(child.text);
        
        if (result.containsKey(key)) {
          // Convertir en liste si plusieurs éléments avec le même nom
          if (result[key] is! List) {
            result[key] = [result[key]];
          }
          (result[key] as List).add(value);
        } else {
          result[key] = value;
        }
      }
      
      // Ajouter les attributs de l'élément enfant
      for (final attr in child.attributes) {
        final attrKey = '${key}_${attr.localName}';
        result[attrKey] = _convertValue(attr.value);
      }
    }
    
    return result;
  }
  
  /// Construire des éléments XML depuis une Map
  static void _buildElementFromMap(XmlBuilder builder, Map<String, dynamic> data) {
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value == null) continue;
      
      if (value is Map<String, dynamic>) {
        builder.element(key, nest: () {
          _buildElementFromMap(builder, value);
        });
      } else if (value is List) {
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            builder.element(key, nest: () {
              _buildElementFromMap(builder, item);
            });
          } else {
            builder.element(key, nest: item.toString());
          }
        }
      } else {
        builder.element(key, nest: value.toString());
      }
    }
  }
  
  /// Convertir une valeur texte en type approprié
  static dynamic _convertValue(String value) {
    if (value.isEmpty) return null;
    
    // Booléens
    if (value.toLowerCase() == 'true' || value == '1') return true;
    if (value.toLowerCase() == 'false' || value == '0') return false;
    
    // Nombres
    final intValue = int.tryParse(value);
    if (intValue != null) return intValue;
    
    final doubleValue = double.tryParse(value);
    if (doubleValue != null) return doubleValue;
    
    // Dates ISO 8601
    try {
      if (value.contains('T') || value.contains('-')) {
        final dateTime = DateTime.tryParse(value);
        if (dateTime != null) return dateTime;
      }
    } catch (_) {}
    
    // Texte par défaut
    return value;
  }
  
  /// Vérifier la présence d'erreurs dans la réponse
  static void _checkForErrors(XmlElement rootElement) {
    final errorElement = rootElement.findAllElements('error').firstOrNull;
    if (errorElement != null) {
      final code = errorElement.findElements('code').firstOrNull?.text;
      final message = errorElement.findElements('message').firstOrNull?.text ?? 'Unknown error';
      
      throw PrestashopApiException(
        message,
        statusCode: int.tryParse(code ?? ''),
        errorDetails: {
          'code': code,
          'message': message,
        },
      );
    }
  }
}

/// Wrapper pour les réponses de l'API PrestaShop
class PrestashopApiResponse<T> {
  /// Données de la réponse
  final T data;
  
  /// Métadonnées (pagination, etc.)
  final Map<String, dynamic> meta;
  
  /// Document XML original
  final XmlDocument? originalDocument;
  
  /// Timestamp de la réponse
  final DateTime timestamp;

  const PrestashopApiResponse({
    required this.data,
    this.meta = const {},
    this.originalDocument,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Vérifier si la réponse contient des données
  bool get hasData {
    if (data is List) return (data as List).isNotEmpty;
    if (data is Map) return (data as Map).isNotEmpty;
    return data != null;
  }
  
  /// Nombre d'éléments (pour les listes)
  int get count {
    if (data is List) return (data as List).length;
    return hasData ? 1 : 0;
  }
  
  /// Total d'éléments disponibles (depuis meta)
  int? get total => meta['total'] as int?;
  
  /// Page actuelle
  int? get currentPage => meta['currentPage'] as int?;
  
  /// Nombre total de pages
  int? get totalPages => meta['totalPages'] as int?;
  
  /// Conversion en Map pour debugging
  Map<String, dynamic> toDebugMap() {
    return {
      'hasData': hasData,
      'count': count,
      'meta': meta,
      'timestamp': timestamp.toIso8601String(),
      'dataType': data.runtimeType.toString(),
    };
  }
}
