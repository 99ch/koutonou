import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koutonou/core/utils/constants.dart';
import 'package:path/path.dart' as p;

void main() {
  group('AppConstants Tests', () {
    setUpAll(() async {
      /// Récupère dynamiquement la racine du projet
      final root = Directory.current.path;
      final envPath = p.join(root, '.env.test');
      await dotenv.load(fileName: envPath);
    });

    test('API base URLs should not be empty', () {
      expect(AppConstants.apiBaseUrlLocal, isNotEmpty);
      expect(AppConstants.apiBaseUrlProd, isNotEmpty);
    });

    test('API timeout is 30000 ms', () {
      expect(AppConstants.apiTimeout, 30000);
    });

    test('Debug mode is boolean', () {
      expect(AppConstants.isDebugMode, isA<bool>());
    });

    test('Pagination defaults are correct', () {
      expect(AppConstants.defaultLimit, 20);
      expect(AppConstants.defaultOffset, 0);
    });

    test('Navigation routes are correctly defined', () {
      expect(AppConstants.homeRoute, '/');
      expect(AppConstants.loginRoute, '/login');
      expect(AppConstants.productListRoute, '/products');
      expect(AppConstants.cartRoute, '/cart');
    });

    test('UI constants have correct values', () {
      expect(AppConstants.defaultPadding, 16.0);
      expect(AppConstants.cardElevation, 4.0);
    });
  });
}
