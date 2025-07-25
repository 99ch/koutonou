import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:koutonou/core/api/api_config.dart';

void main() {
  setUpAll(() async {
    /// Récupère dynamiquement la racine du projet
    final root = Directory.current.path;
    final envPath = p.join(root, '.env.test');
    await dotenv.load(fileName: envPath);
  });

  test('ApiConfig should use the correct baseUrl and API key', () {
    final apiConfig = ApiConfig();

    /// Vérifie que baseUrl est bien une URL
    expect(apiConfig.baseUrl, isNotEmpty);
    expect(apiConfig.baseUrl, startsWith('http'));

    /// Vérifie que la clé API est bien chargée
    final expectedApiKey = dotenv.get('API_KEY', fallback: '');
    expect(expectedApiKey, isNotEmpty);
    expect(apiConfig.dio.options.headers['X-API-KEY'], equals(expectedApiKey));
  });
}
