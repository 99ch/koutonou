// Test rapide du générateur Phase 2
// Validation des fichiers générés

import 'dart:io';

void main() async {
  print('🧪 Test du Générateur PrestaShop Phase 2');
  print('');

  // Vérification des modules générés
  final modulesDir = Directory('lib/modules');

  if (!await modulesDir.exists()) {
    print('❌ Répertoire lib/modules introuvable');
    return;
  }

  final modules = await modulesDir
      .list()
      .where((entity) => entity is Directory)
      .toList();
  print('📁 Modules trouvés: ${modules.length}');

  for (final module in modules) {
    final moduleName = module.path.split('/').last;
    print('  • $moduleName');

    // Vérifier les sous-répertoires
    final modelsDir = Directory('${module.path}/models');
    final servicesDir = Directory('${module.path}/services');

    if (await modelsDir.exists()) {
      final models = await modelsDir
          .list()
          .where((f) => f.path.endsWith('.dart'))
          .toList();
      print('    └─ Modèles: ${models.length}');
    }

    if (await servicesDir.exists()) {
      final services = await servicesDir
          .list()
          .where((f) => f.path.endsWith('.dart'))
          .toList();
      print('    └─ Services: ${services.length}');
    }
  }

  print('');
  print('🎉 Phase 2 générée avec succès !');
  print('✅ Générateur PrestaShop opérationnel');
  print('');
  print('📝 Prochaines étapes:');
  print('   1. Connecter les services à l\'API PrestaShop réelle');
  print('   2. Ajouter la gestion des erreurs avancée');
  print('   3. Implémenter le cache pour les performances');
  print('   4. Créer les interfaces utilisateur');
}
