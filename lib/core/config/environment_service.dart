import 'package:flutter/foundation.dart';
import '../api/prestashop_api_config.dart';

/// Service de gestion de l'environnement
/// 
/// Cette classe gère la configuration automatique de l'environnement
/// (développement, staging, production) et fournit les bonnes
/// configurations API en fonction du contexte.
class EnvironmentService {
  /// Environnement actuel
  static AppEnvironment get currentEnvironment {
    if (kDebugMode) {
      return AppEnvironment.development;
    } else if (kProfileMode) {
      return AppEnvironment.staging;
    } else {
      return AppEnvironment.production;
    }
  }

  /// Configuration PrestaShop pour l'environnement actuel
  static PrestashopApiConfig get prestashopConfig {
    switch (currentEnvironment) {
      case AppEnvironment.development:
        return PrestashopApiConfig(
          baseUrl: const String.fromEnvironment(
            'API_BASE_URL_LOCAL',
            defaultValue: 'http://localhost:8080/prestashop/proxy.php',
          ),
          apiKey: const String.fromEnvironment(
            'API_KEY_LOCAL',
            defaultValue: 'WD4YUTKV1136122LWTI64EQCMXAIM99S',
          ),
          imageBaseUrl: const String.fromEnvironment(
            'API_IMAGE_BASE_URL',
            defaultValue: 'http://localhost:8080/prestashop/img',
          ),
          defaultLanguage: 'fr',
          debugMode: true,
          timeoutSeconds: 10, // Plus court en dev pour détecter rapidement les problèmes
        );
        
      case AppEnvironment.staging:
        return PrestashopApiConfig(
          baseUrl: const String.fromEnvironment(
            'API_BASE_URL_PROD',
            defaultValue: 'https://marketplace.koutonou.com/api',
          ),
          apiKey: const String.fromEnvironment(
            'API_KEY_PROD',
            defaultValue: 'RLSSKE1B7DKGC9Z8MRR1WFECLTE7H2PV',
          ),
          imageBaseUrl: const String.fromEnvironment(
            'API_IMAGE_BASE_URL',
            defaultValue: 'https://marketplace.koutonou.com/img',
          ),
          defaultLanguage: 'fr',
          debugMode: true, // Debug activé en staging
          timeoutSeconds: 30,
        );
        
      case AppEnvironment.production:
        return PrestashopApiConfig(
          baseUrl: const String.fromEnvironment(
            'API_BASE_URL_PROD',
            defaultValue: 'https://marketplace.koutonou.com/api',
          ),
          apiKey: const String.fromEnvironment(
            'API_KEY_PROD',
            defaultValue: 'RLSSKE1B7DKGC9Z8MRR1WFECLTE7H2PV',
          ),
          imageBaseUrl: const String.fromEnvironment(
            'API_IMAGE_BASE_URL',
            defaultValue: 'https://marketplace.koutonou.com/img',
          ),
          defaultLanguage: 'fr',
          debugMode: false, // Pas de debug en production
          timeoutSeconds: 30,
        );
    }
  }

  /// Nom de l'environnement pour l'affichage
  static String get environmentName {
    switch (currentEnvironment) {
      case AppEnvironment.development:
        return 'Développement';
      case AppEnvironment.staging:
        return 'Pré-production';
      case AppEnvironment.production:
        return 'Production';
    }
  }

  /// Couleur associée à l'environnement
  static int get environmentColor {
    switch (currentEnvironment) {
      case AppEnvironment.development:
        return 0xFF4CAF50; // Vert
      case AppEnvironment.staging:
        return 0xFFFF9800; // Orange
      case AppEnvironment.production:
        return 0xFFF44336; // Rouge
    }
  }

  /// Vérifier si on est en mode développement
  static bool get isDevelopment => currentEnvironment == AppEnvironment.development;

  /// Vérifier si on est en staging
  static bool get isStaging => currentEnvironment == AppEnvironment.staging;

  /// Vérifier si on est en production
  static bool get isProduction => currentEnvironment == AppEnvironment.production;

  /// Configuration pour les logs
  static LogLevel get logLevel {
    switch (currentEnvironment) {
      case AppEnvironment.development:
        return LogLevel.debug;
      case AppEnvironment.staging:
        return LogLevel.info;
      case AppEnvironment.production:
        return LogLevel.warning;
    }
  }

  /// Configuration de cache
  static Duration get cacheExpiration {
    switch (currentEnvironment) {
      case AppEnvironment.development:
        return const Duration(minutes: 1); // Cache court en dev
      case AppEnvironment.staging:
        return const Duration(minutes: 15);
      case AppEnvironment.production:
        return const Duration(hours: 1); // Cache plus long en prod
    }
  }

  /// Nombre d'éléments par page par défaut
  static int get defaultPageSize {
    switch (currentEnvironment) {
      case AppEnvironment.development:
        return 5; // Moins d'éléments en dev pour tester la pagination
      case AppEnvironment.staging:
        return 10;
      case AppEnvironment.production:
        return 20;
    }
  }

  /// URL de base pour les images par défaut
  static String get defaultImageUrl {
    return prestashopConfig.imageBaseUrl;
  }

  /// Configuration Firebase/Analytics
  static Map<String, String> get analyticsConfig {
    switch (currentEnvironment) {
      case AppEnvironment.development:
        return {
          'project_id': 'koutonou-dev',
          'enabled': 'false',
        };
      case AppEnvironment.staging:
        return {
          'project_id': 'koutonou-staging',
          'enabled': 'true',
        };
      case AppEnvironment.production:
        return {
          'project_id': 'koutonou-prod',
          'enabled': 'true',
        };
    }
  }

  /// Configuration Sentry (crash reporting)
  static Map<String, dynamic> get sentryConfig {
    return {
      'dsn': const String.fromEnvironment('SENTRY_DSN', defaultValue: ''),
      'environment': currentEnvironment.name,
      'debug': isDevelopment,
      'sample_rate': isProduction ? 0.1 : 1.0,
    };
  }

  /// Afficher les informations d'environnement
  static void printEnvironmentInfo() {
    if (isDevelopment) {
      print('🚀 ===== KOUTONOU APP =====');
      print('📍 Environnement: $environmentName');
      print('🌐 API URL: ${prestashopConfig.baseUrl}');
      print('🔑 API Key: ${prestashopConfig.apiKey.substring(0, 8)}...');
      print('🖼️ Images URL: ${prestashopConfig.imageBaseUrl}');
      print('🐛 Debug: ${prestashopConfig.debugMode}');
      print('⏱️ Timeout: ${prestashopConfig.timeoutSeconds}s');
      print('💾 Cache: ${cacheExpiration.inMinutes}min');
      print('📄 Page size: $defaultPageSize items');
      print('========================');
    }
  }
}

/// Énumération des environnements
enum AppEnvironment {
  development,
  staging,
  production,
}

/// Niveaux de logs
enum LogLevel {
  debug,
  info,
  warning,
  error,
}
