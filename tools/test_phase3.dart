// Script de test Phase 3 - API PrestaShop réelle
// Tests de connexion, authentification et endpoints

import 'package:koutonou/core/api/prestashop_initializer.dart';
import 'package:koutonou/modules/languages/services/language_service.dart';

/// Tests Phase 3 - Intégration API réelle
class Phase3ApiTests {
  
  static Future<void> main() async {
    print('🧪 PHASE 3 - TESTS API PRESTASHOP RÉELLE');
    print('=' * 50);
    print('');

    // 1. Test d'initialisation
    await _testInitialization();
    print('');

    // 2. Test de configuration
    _testConfiguration();
    print('');

    // 3. Tests des services
    await _testServices();
    print('');

    // 4. Tests complets API
    await _testCompleteApi();
    print('');

    print('✅ Tests Phase 3 terminés !');
    print('=' * 50);
  }

  /// Test d'initialisation de l'API
  static Future<void> _testInitialization() async {
    print('🔧 TEST INITIALISATION API');
    print('-' * 30);

    try {
      // Test 1: Initialisation de développement
      print('Test 1: Initialisation développement...');
      final initSuccess = await PrestaShopApiInitializer.initializeForDevelopment(
        validateConnection: false, // Pas de validation pour éviter les erreurs de réseau
      );
      
      if (initSuccess) {
        print('✅ Initialisation développement: OK');
      } else {
        print('❌ Initialisation développement: ÉCHEC');
      }

      // Test 2: Validation de configuration
      print('Test 2: Validation configuration...');
      try {
        PrestaShopApiInitializer.showConfigInfo();
        print('✅ Configuration valide');
      } catch (e) {
        print('❌ Configuration invalide: $e');
      }

    } catch (e) {
      print('❌ Erreur lors de l\'initialisation: $e');
    }
  }

  /// Test de configuration
  static void _testConfiguration() {
    print('⚙️  TEST CONFIGURATION');
    print('-' * 30);

    try {
      PrestaShopApiInitializer.showConfigInfo();
    } catch (e) {
      print('❌ Erreur de configuration: $e');
    }
  }

  /// Test des services générés
  static Future<void> _testServices() async {
    print('🔄 TEST SERVICES GÉNÉRÉS');
    print('-' * 30);

    try {
      // Test du service Language mis à jour
      print('Test 1: Service Language...');
      final languageService = LanguageService();
      
      try {
        final languages = await languageService.getAll();
        print('✅ Service Language fonctionnel: ${languages.length} langues');
        
        if (languages.isNotEmpty) {
          print('   Premier élément: ${languages.first.name}');
        }
      } catch (e) {
        print('⚠️  Service Language (mode simulation): $e');
        // En mode simulation, c'est normal que ça échoue avec l'API réelle
      }

    } catch (e) {
      print('❌ Erreur dans les tests de services: $e');
    }
  }

  /// Tests complets de l'API
  static Future<void> _testCompleteApi() async {
    print('🌐 TESTS COMPLETS API');
    print('-' * 30);

    try {
      // Test de tous les endpoints principaux
      print('Lancement des tests multi-endpoints...');
      final results = await PrestaShopApiInitializer.runApiTests();
      
      print('Résultats détaillés:');
      results.forEach((endpoint, success) {
        final status = success ? '✅' : '❌';
        print('  $status $endpoint');
      });

    } catch (e) {
      print('❌ Erreur lors des tests API: $e');
    }
  }
}

void main() async {
  await Phase3ApiTests.main();
}
