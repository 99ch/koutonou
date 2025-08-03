// Générateur principal MVP Phase 1
// Orchestre la découverte, génération de modèles et services
// Point d'entrée unique pour le pipeline automatique

import 'discovery/resource_discoverer.dart';
import 'models/model_generator.dart';
import 'services/service_generator.dart';

/// Générateur principal MVP
class MvpGenerator {
  /// Exécute le pipeline complet MVP Phase 1
  static Future<void> runMvpPipeline() async {
    print('🚀 === DÉBUT PIPELINE MVP PHASE 1 ===');
    print('Ressources cibles: languages, currencies, countries');
    print('');

    try {
      // Phase 1: Découverte des ressources
      print('📡 ÉTAPE 1: Découverte des ressources');
      print('─' * 50);
      await ResourceDiscoverer.runMvpDiscovery();
      print('');

      // Phase 2: Génération des modèles
      print('🏗️  ÉTAPE 2: Génération des modèles');
      print('─' * 50);
      await ModelGenerator.generateMvpModels();
      print('');

      // Phase 3: Génération des services
      print('🛠️  ÉTAPE 3: Génération des services');
      print('─' * 50);
      await ServiceGenerator.generateMvpServices();
      print('');

      // Phase 4: Instructions post-génération
      print('📋 ÉTAPE 4: Instructions de finalisation');
      print('─' * 50);
      _printPostGenerationInstructions();

      print('🎉 === PIPELINE MVP PHASE 1 TERMINÉ AVEC SUCCÈS ===');
    } catch (e, stackTrace) {
      print('❌ === ERREUR DANS LE PIPELINE ===');
      print('Erreur: $e');
      print('Stack: $stackTrace');
      print('');
      print('💡 Suggestions de dépannage:');
      print('1. Vérifiez que PrestaShop est accessible');
      print('2. Vérifiez la clé API dans resource_discoverer.dart');
      print('3. Vérifiez les permissions des dossiers');
    }
  }

  /// Affiche les instructions post-génération
  static void _printPostGenerationInstructions() {
    print('✅ Génération terminée ! Prochaines étapes:');
    print('');
    print('1. 📦 Ajouter les dépendances au pubspec.yaml:');
    print('   dependencies:');
    print('     json_annotation: ^4.8.1');
    print('   dev_dependencies:');
    print('     build_runner: ^2.4.6');
    print('     json_serializable: ^6.7.1');
    print('');
    print('2. 🔨 Exécuter build_runner:');
    print('   flutter packages pub run build_runner build');
    print('');
    print('3. 📄 Fichiers générés:');
    print('   - lib/modules/configs/models/languagemodel.dart');
    print('   - lib/modules/configs/models/currencymodel.dart');
    print('   - lib/modules/configs/models/countrymodel.dart');
    print('   - lib/modules/configs/services/languageservice.dart');
    print('   - lib/modules/configs/services/currencyservice.dart');
    print('   - lib/modules/configs/services/countryservice.dart');
    print('');
    print('4. 🧪 Tester avec une page de validation:');
    print('   - Créer une page qui teste les 3 services');
    print('   - Vérifier les appels API et la sérialisation');
    print('   - Valider le cache et la gestion d\'erreurs');
    print('');
    print('5. 🔄 Si tout fonctionne:');
    print('   - Passer à la Phase 2 du générateur complet');
    print('   - Étendre à d\'autres ressources');
    print('');
  }

  /// Génère uniquement les modèles (pour debug)
  static Future<void> generateModelsOnly() async {
    print('🏗️  Génération des modèles seulement...');
    await ModelGenerator.generateMvpModels();
  }

  /// Génère uniquement les services (pour debug)
  static Future<void> generateServicesOnly() async {
    print('🛠️  Génération des services seulement...');
    await ServiceGenerator.generateMvpServices();
  }

  /// Découverte seulement (pour debug)
  static Future<void> discoveryOnly() async {
    print('📡 Découverte seulement...');
    await ResourceDiscoverer.runMvpDiscovery();
  }
}

/// Point d'entrée principal
void main(List<String> args) async {
  if (args.isEmpty) {
    // Exécution complète par défaut
    await MvpGenerator.runMvpPipeline();
    return;
  }

  // Commandes spécifiques pour debug
  switch (args.first) {
    case 'discovery':
      await MvpGenerator.discoveryOnly();
      break;
    case 'models':
      await MvpGenerator.generateModelsOnly();
      break;
    case 'services':
      await MvpGenerator.generateServicesOnly();
      break;
    case 'full':
    default:
      await MvpGenerator.runMvpPipeline();
      break;
  }
}
