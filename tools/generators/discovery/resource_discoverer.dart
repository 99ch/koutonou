// Découvreur de ressources PrestaShop pour génération automatique
// Phase 1 MVP : Focus sur 3 ressources simples pour validation
// Teste la récupération de schémas et données d'exemple

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

/// Découvreur de ressources PrestaShop
class ResourceDiscoverer {
  static const String _outputDir = 'tools/generators/data';

  final Dio _dio;
  final String _baseUrl;
  final String _apiKey;

  ResourceDiscoverer({required String baseUrl, required String apiKey})
    : _baseUrl = baseUrl,
      _apiKey = apiKey,
      _dio = Dio() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers['Authorization'] =
        'Basic ${base64Encode(utf8.encode('$_apiKey:'))}';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Ressources simples pour le MVP Phase 1
  static const List<String> mvpResources = [
    'languages', // Simple, peu de champs
    'currencies', // Structure basique
    'countries', // Relations simples
  ];

  /// Découvre toutes les ressources MVP
  Future<void> discoverMvpResources() async {
    print('🚀 Début de la découverte des ressources MVP');

    // Créer le dossier de sortie
    await _ensureOutputDirectory();

    final results = <String, Map<String, dynamic>>{};

    for (final resource in mvpResources) {
      try {
        print('📝 Traitement de la ressource: $resource');

        final resourceData = await _discoverResource(resource);
        results[resource] = resourceData;

        print('✅ $resource → traité avec succès');
      } catch (e, stackTrace) {
        print('❌ Erreur pour $resource: $e');
        print('Stack: $stackTrace');

        // Continuer avec les autres ressources
        results[resource] = {
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        };
      }

      // Pause pour éviter de surcharger l'API
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Sauvegarder les résultats
    await _saveResults(results);

    print('✅ Découverte terminée. Résultats sauvegardés dans $_outputDir/');
  }

  /// Découvre une ressource spécifique
  Future<Map<String, dynamic>> _discoverResource(String resource) async {
    final result = <String, dynamic>{
      'resource': resource,
      'timestamp': DateTime.now().toIso8601String(),
      'schema': null,
      'examples': [],
      'metadata': {},
    };

    try {
      // 1. Récupérer le schéma synopsis
      print('  📋 Récupération du schéma pour $resource');
      final schema = await _fetchSchema(resource);
      result['schema'] = schema;

      // 2. Récupérer des exemples réels
      print('  📦 Récupération d\'exemples pour $resource');
      final examples = await _fetchExamples(resource);
      result['examples'] = examples;

      // 3. Analyser les métadonnées
      result['metadata'] = _analyzeResource(resource, schema, examples);
    } catch (e) {
      print('  ⚠️  Erreur lors du traitement de $resource: $e');
      rethrow;
    }

    return result;
  }

  /// Récupère le schéma synopsis d'une ressource
  Future<String?> _fetchSchema(String resource) async {
    try {
      final response = await _dio.get(
        '/$resource',
        queryParameters: {
          'schema': 'synopsis',
          'output_format': 'JSON', // Essayer JSON d'abord
        },
      );

      if (response.statusCode == 200) {
        // Si c'est du JSON, le convertir en string
        if (response.data is Map || response.data is List) {
          return jsonEncode(response.data);
        }
        return response.data.toString();
      }
    } catch (e) {
      print('    ⚠️  Schéma JSON échoué, tentative XML...');
    }

    // Fallback: essayer sans output_format (XML par défaut)
    try {
      final response = await _dio.get(
        '/$resource',
        queryParameters: {'schema': 'synopsis'},
      );

      if (response.statusCode == 200) {
        return response.data.toString();
      }
    } catch (e) {
      print('    ❌ Impossible de récupérer le schéma: $e');
    }

    return null;
  }

  /// Récupère des exemples réels d'une ressource
  Future<List<Map<String, dynamic>>> _fetchExamples(String resource) async {
    final examples = <Map<String, dynamic>>[];

    try {
      // Récupérer une liste avec quelques éléments
      final listResponse = await _dio.get(
        '/$resource',
        queryParameters: {
          'output_format': 'JSON',
          'limit': '3', // Limiter à 3 exemples
        },
      );

      if (listResponse.statusCode == 200 && listResponse.data != null) {
        final data = listResponse.data;

        // PrestaShop retourne généralement {resource: [...]}
        if (data is Map<String, dynamic>) {
          final items = data[resource] ?? data['${resource}s'] ?? [];

          if (items is List) {
            for (final item in items.take(3)) {
              if (item is Map<String, dynamic> && item['id'] != null) {
                // Récupérer le détail complet de chaque item
                final detail = await _fetchItemDetail(
                  resource,
                  item['id'].toString(),
                );
                if (detail != null) {
                  examples.add(detail);
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('    ⚠️  Impossible de récupérer les exemples: $e');
    }

    return examples;
  }

  /// Récupère le détail complet d'un item
  Future<Map<String, dynamic>?> _fetchItemDetail(
    String resource,
    String id,
  ) async {
    try {
      final response = await _dio.get(
        '/$resource/$id',
        queryParameters: {'output_format': 'JSON'},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          // Extraire l'objet principal
          final singular = _getSingularResourceName(resource);
          return data[singular] ?? data[resource] ?? data;
        }
      }
    } catch (e) {
      print('    ⚠️  Détail de $resource/$id échoué: $e');
    }

    return null;
  }

  /// Convertit un nom de ressource pluriel en singulier
  String _getSingularResourceName(String resource) {
    // Règles simples pour les ressources MVP
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

  /// Analyse une ressource pour extraire des métadonnées
  Map<String, dynamic> _analyzeResource(
    String resource,
    String? schema,
    List<Map<String, dynamic>> examples,
  ) {
    final metadata = <String, dynamic>{
      'has_schema': schema != null,
      'example_count': examples.length,
      'estimated_complexity': 'simple', // Pour le MVP
      'detected_fields': <String>[],
      'detected_types': <String, String>{},
    };

    // Analyser les champs à partir des exemples
    if (examples.isNotEmpty) {
      final firstExample = examples.first;
      metadata['detected_fields'] = firstExample.keys.toList();

      // Détecter les types basiques
      final types = <String, String>{};
      firstExample.forEach((key, value) {
        if (value is int) {
          types[key] = 'int';
        } else if (value is double) {
          types[key] = 'double';
        } else if (value is bool) {
          types[key] = 'bool';
        } else if (value is String) {
          // Détecter des types spéciaux
          if (key.toLowerCase().contains('date') ||
              RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(value)) {
            types[key] = 'DateTime';
          } else if (key.toLowerCase().contains('email') &&
              value.contains('@')) {
            types[key] = 'String'; // Email
          } else {
            types[key] = 'String';
          }
        } else if (value is List) {
          types[key] = 'List<dynamic>';
        } else if (value is Map) {
          types[key] = 'Map<String, dynamic>';
        } else {
          types[key] = 'dynamic';
        }
      });

      metadata['detected_types'] = types;
    }

    return metadata;
  }

  /// Assure que le dossier de sortie existe
  Future<void> _ensureOutputDirectory() async {
    final dir = Directory(_outputDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// Sauvegarde les résultats
  Future<void> _saveResults(Map<String, Map<String, dynamic>> results) async {
    final outputFile = File('$_outputDir/mvp_discovery_results.json');

    final globalResult = {
      'generated_at': DateTime.now().toIso8601String(),
      'mvp_phase': 1,
      'total_resources': results.length,
      'successful_resources': results.values
          .where((r) => r['error'] == null)
          .length,
      'failed_resources': results.values
          .where((r) => r['error'] != null)
          .length,
      'resources': results,
    };

    await outputFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(globalResult),
    );

    print('📁 Résultats sauvegardés dans: ${outputFile.path}');
  }

  /// Point d'entrée principal pour le MVP
  static Future<void> runMvpDiscovery() async {
    print('🚀 Lancement de la découverte MVP Phase 1');

    // Configuration depuis les variables d'environnement ou valeurs par défaut
    const baseUrl = 'http://localhost:8080/prestashop/api';
    const apiKey =
        'WD4YUTKV1136122LWTI64EQCMXAIM99S'; // À mettre en variable d'env

    final discoverer = ResourceDiscoverer(baseUrl: baseUrl, apiKey: apiKey);

    await discoverer.discoverMvpResources();

    print('✅ Découverte MVP terminée avec succès !');
  }
}
