#!/usr/bin/env dart

/// Script pour tester la connexion à l'API PrestaShop de PRODUCTION
/// Utilise uniquement les paramètres du fichier .env de production
/// AUCUNE donnée de démonstration ou de test

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  print('🏪 TEST API PRESTASHOP DE PRODUCTION');
  print('===================================\n');

  // Charger UNIQUEMENT l'environnement de production
  try {
    await dotenv.load(fileName: '.env');
    print('✅ Configuration .env de production chargée');
  } catch (e) {
    print('❌ ERREUR: Impossible de charger le fichier .env de production');
    print(
      '   Assurez-vous que le fichier .env existe avec vos paramètres PrestaShop réels',
    );
    exit(1);
  }

  final apiKey = dotenv.env['PRESTASHOP_API_KEY'];
  final baseUrl = dotenv.env['PRESTASHOP_BASE_URL'];

  if (apiKey == null || apiKey.isEmpty) {
    print('❌ ERREUR: Variable PRESTASHOP_API_KEY manquante dans .env');
    print('   Ajoutez: PRESTASHOP_API_KEY=votre-cle-api-prestashop');
    exit(1);
  }

  if (baseUrl == null || baseUrl.isEmpty) {
    print('❌ ERREUR: Variable PRESTASHOP_BASE_URL manquante dans .env');
    print('   Ajoutez: PRESTASHOP_BASE_URL=https://votre-boutique.com');
    exit(1);
  }

  print('🔗 URL de production: $baseUrl');
  print('🔑 Clé API: ${apiKey.substring(0, 8)}...\n');

  // Configuration Dio pour la production
  final dio = Dio();
  dio.options.headers['Accept'] = 'application/json';
  dio.options.headers['User-Agent'] = 'Koutonou-Production-App/1.0';

  // Test 1: Connexion à l'API racine
  await testApiConnection(dio, baseUrl, apiKey);

  // Test 2: Récupération des produits
  await testProductsAPI(dio, baseUrl, apiKey);

  // Test 3: Récupération des catégories
  await testCategoriesAPI(dio, baseUrl, apiKey);

  print('\n🎯 RÉSUMÉ DES TESTS DE PRODUCTION');
  print('================================');
  print(
    '✅ Tous les tests utilisent uniquement votre environnement de production',
  );
  print('✅ Aucune donnée de démonstration utilisée');
  print('✅ Connexion directe à votre PrestaShop');
}

Future<void> testApiConnection(Dio dio, String baseUrl, String apiKey) async {
  print('🔌 Test de connexion à l\'API de production...');

  try {
    final response = await dio.get(
      '$baseUrl/api/',
      queryParameters: {'ws_key': apiKey, 'output_format': 'JSON'},
    );

    if (response.statusCode == 200) {
      print('✅ Connexion API réussie');
      final data = response.data;
      if (data is Map && data.containsKey('api')) {
        print('✅ Réponse API valide reçue');
      }
    } else {
      print('⚠️  Connexion API: Code ${response.statusCode}');
    }
  } catch (e) {
    print('❌ ERREUR de connexion API: $e');
    if (e is DioException) {
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
    }
  }
  print('');
}

Future<void> testProductsAPI(Dio dio, String baseUrl, String apiKey) async {
  print('📦 Test de récupération des produits de production...');

  try {
    final response = await dio.get(
      '$baseUrl/api/products',
      queryParameters: {
        'ws_key': apiKey,
        'output_format': 'JSON',
        'limit': '5',
        'display': '[id,name,price,active]',
      },
    );

    if (response.statusCode == 200) {
      print('✅ API Produits accessible');
      final data = response.data;

      if (data is Map && data.containsKey('products')) {
        final products = data['products'];
        if (products is List) {
          print('✅ ${products.length} produits récupérés de votre boutique');

          // Afficher quelques produits
          for (int i = 0; i < products.length && i < 3; i++) {
            final product = products[i];
            if (product is Map) {
              final id = product['id'] ?? 'N/A';
              final name = product['name'] ?? 'Nom non disponible';
              final price = product['price'] ?? 'Prix non disponible';
              print('   📦 Produit $id: $name ($price€)');
            }
          }
        }
      }
    }
  } catch (e) {
    print('❌ ERREUR API Produits: $e');
    if (e is DioException) {
      print('   Status: ${e.response?.statusCode}');
    }
  }
  print('');
}

Future<void> testCategoriesAPI(Dio dio, String baseUrl, String apiKey) async {
  print('📁 Test de récupération des catégories de production...');

  try {
    final response = await dio.get(
      '$baseUrl/api/categories',
      queryParameters: {
        'ws_key': apiKey,
        'output_format': 'JSON',
        'limit': '5',
        'display': '[id,name,active]',
      },
    );

    if (response.statusCode == 200) {
      print('✅ API Catégories accessible');
      final data = response.data;

      if (data is Map && data.containsKey('categories')) {
        final categories = data['categories'];
        if (categories is List) {
          print(
            '✅ ${categories.length} catégories récupérées de votre boutique',
          );
        }
      }
    }
  } catch (e) {
    print('❌ ERREUR API Catégories: $e');
    if (e is DioException) {
      print('   Status: ${e.response?.statusCode}');
    }
  }
  print('');
}
