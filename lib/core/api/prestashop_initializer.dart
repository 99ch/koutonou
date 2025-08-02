// Initialisation de l'API PrestaShop - Phase 3
// Configuration automatique et validation de connexion

import 'package:koutonou/core/api/prestashop_config.dart';
import 'package:koutonou/core/api/prestashop_http_client.dart';
import 'package:koutonou/core/api/prestashop_exceptions.dart';
import 'package:koutonou/core/utils/logger.dart';

/// Classe d'initialisation pour l'API PrestaShop Phase 3
class PrestaShopApiInitializer {
  static final AppLogger _logger = AppLogger();

  /// Initialise l'API PrestaShop avec la configuration
  static Future<bool> initialize({
    String? host,
    String? apiKey,
    bool useHttps = false,
    bool debug = true,
    bool validateConnection = true,
  }) async {
    try {
      _logger.info('🚀 Initialisation de l\'API PrestaShop - Phase 3');

      // 1. Créer la configuration
      PrestaShopConfig config;

      if (host != null && apiKey != null) {
        // Configuration manuelle
        config = PrestaShopConfig.development(
          host: host,
          apiKey: apiKey,
          debug: debug,
        );
        _logger.info('✅ Configuration manuelle créée');
      } else {
        // Configuration depuis les variables d'environnement
        try {
          config = PrestaShopConfig.fromEnvironment();
          _logger.info('✅ Configuration depuis variables d\'environnement');
        } catch (e) {
          // Fallback vers configuration de développement
          config = PrestaShopConfig.development(
            apiKey: 'demo_api_key',
            debug: true,
          );
          _logger.warning('⚠️ Utilisation de la configuration de démo');
        }
      }

      // 2. Valider la configuration
      if (!config.isValid) {
        _logger.error('❌ Configuration PrestaShop invalide: $config');
        return false;
      }

      // 3. Initialiser le gestionnaire de configuration
      PrestaShopConfigManager.initialize(config);
      _logger.info('✅ Gestionnaire de configuration initialisé');

      // 4. Valider la connexion si demandé
      if (validateConnection) {
        final isConnected = await _validateConnection();
        if (!isConnected) {
          _logger.error('❌ Échec de validation de la connexion API');
          return false;
        }
        _logger.info('✅ Connexion API validée');
      }

      _logger.info(
        '🎉 Initialisation de l\'API PrestaShop terminée avec succès',
      );
      return true;
    } catch (e, stackTrace) {
      _logger.error(
        '❌ Erreur lors de l\'initialisation API: $e',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Valide la connexion à l'API PrestaShop
  static Future<bool> _validateConnection() async {
    try {
      _logger.debug('🔍 Validation de la connexion API...');

      final client = PrestaShopApiClient.instance;

      // Test simple : récupérer la liste des langues (endpoint minimal)
      await client.get('languages', queryParams: {'limit': '1'});

      return true;
    } on PrestaShopException catch (e) {
      _logger.error('❌ Erreur PrestaShop lors de la validation: ${e.message}');

      // Donner des conseils selon le type d'erreur
      switch (e.type) {
        case PrestaShopErrorType.network:
          _logger.info('💡 Vérifiez que PrestaShop est démarré et accessible');
          break;
        case PrestaShopErrorType.authentication:
          _logger.info('💡 Vérifiez votre clé API PrestaShop');
          break;
        case PrestaShopErrorType.notFound:
          _logger.info('💡 Vérifiez l\'URL de base de l\'API');
          break;
        default:
          _logger.info('💡 Vérifiez la configuration PrestaShop');
      }

      return false;
    } catch (e) {
      _logger.error('❌ Erreur inattendue lors de la validation: $e');
      return false;
    }
  }

  /// Initialise avec la configuration de développement par défaut
  static Future<bool> initializeForDevelopment({
    String host = 'localhost',
    String apiKey = 'demo_api_key',
    bool validateConnection = false, // Désactivé par défaut en dev
  }) async {
    return await initialize(
      host: host,
      apiKey: apiKey,
      useHttps: false,
      debug: true,
      validateConnection: validateConnection,
    );
  }

  /// Initialise avec la configuration de production
  static Future<bool> initializeForProduction({
    required String host,
    required String apiKey,
    bool useHttps = true,
    bool validateConnection = true,
  }) async {
    return await initialize(
      host: host,
      apiKey: apiKey,
      useHttps: useHttps,
      debug: false,
      validateConnection: validateConnection,
    );
  }

  /// Test complet de l'API avec plusieurs endpoints
  static Future<Map<String, bool>> runApiTests() async {
    final results = <String, bool>{};

    _logger.info('🧪 Lancement des tests API complets...');

    try {
      final client = PrestaShopApiClient.instance;

      // Test 1: Languages
      try {
        await client.get('languages', queryParams: {'limit': '1'});
        results['languages'] = true;
        _logger.info('✅ Test languages: OK');
      } catch (e) {
        results['languages'] = false;
        _logger.warning('❌ Test languages: ÉCHEC - $e');
      }

      // Test 2: Products
      try {
        await client.get('products', queryParams: {'limit': '1'});
        results['products'] = true;
        _logger.info('✅ Test products: OK');
      } catch (e) {
        results['products'] = false;
        _logger.warning('❌ Test products: ÉCHEC - $e');
      }

      // Test 3: Customers
      try {
        await client.get('customers', queryParams: {'limit': '1'});
        results['customers'] = true;
        _logger.info('✅ Test customers: OK');
      } catch (e) {
        results['customers'] = false;
        _logger.warning('❌ Test customers: ÉCHEC - $e');
      }

      // Test 4: Orders
      try {
        await client.get('orders', queryParams: {'limit': '1'});
        results['orders'] = true;
        _logger.info('✅ Test orders: OK');
      } catch (e) {
        results['orders'] = false;
        _logger.warning('❌ Test orders: ÉCHEC - $e');
      }
    } catch (e) {
      _logger.error('❌ Erreur critique lors des tests API: $e');
    }

    final successCount = results.values.where((success) => success).length;
    final totalCount = results.length;

    _logger.info('📊 Résultats des tests: $successCount/$totalCount réussis');

    return results;
  }

  /// Affiche les informations de configuration actuelle
  static void showConfigInfo() {
    if (!PrestaShopConfigManager.isInitialized) {
      _logger.warning('⚠️ Configuration PrestaShop non initialisée');
      return;
    }

    final config = PrestaShopConfigManager.instance;

    _logger.info('📋 Configuration PrestaShop actuelle:');
    _logger.info('   • URL de base: ${config.baseUrl}');
    _logger.info('   • HTTPS: ${config.useHttps}');
    _logger.info('   • Timeout: ${config.timeoutMs}ms');
    _logger.info('   • Format: ${config.outputFormat}');
    _logger.info('   • Langue: ${config.defaultLanguage}');
    _logger.info('   • Debug: ${config.debug}');
  }

  /// Reset complet de l'API (utile pour les tests)
  static void reset() {
    PrestaShopConfigManager.reset();
    PrestaShopApiClient.reset();
    _logger.info('🔄 API PrestaShop réinitialisée');
  }
}
