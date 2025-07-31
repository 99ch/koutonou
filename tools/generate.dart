// Outil en ligne de commande pour la génération PrestaShop
// Phase 2 - Générateur complet
// Usage: dart run tools/generate.dart [resource] [--all] [--force]

import 'dart:io';
import 'package:koutonou/core/generators/prestashop_generator.dart';
import 'package:koutonou/core/utils/logger.dart';

/// Outil CLI pour la génération de code PrestaShop
class GeneratorCLI {
  static final AppLogger _logger = AppLogger();

  /// Point d'entrée principal
  static Future<void> main(List<String> args) async {
    try {
      _logger.info('🚀 PrestaShop Generator CLI - Phase 2');

      if (args.isEmpty) {
        _printUsage();
        exit(1);
      }

      final generator = PrestaShopGenerator();

      // Analyser les arguments
      final command = args.first;
      final options = args.skip(1).toList();

      switch (command) {
        case 'all':
          await generator.generateAll();
          break;

        // Ressources principales e-commerce
        case 'products':
        case 'customers':
        case 'orders':

        // Gestion des partenaires
        case 'manufacturers':
        case 'suppliers':

        // Gestion du panier et commandes
        case 'carts':
        case 'combinations':

        // Options et attributs produits
        case 'product_options':
        case 'product_option_values':
        case 'product_features':
        case 'product_feature_values':
        case 'product_suppliers':

        // Transport et logistique
        case 'carriers':
        case 'zones':
        case 'price_ranges':
        case 'weight_ranges':

        // États et workflow
        case 'order_states':
        case 'order_details':
        case 'order_carriers':
        case 'states':

        // Stock et inventaire
        case 'stock_availables':
        case 'stock_movement_reasons':
        case 'specific_prices':

        // Boutiques et configuration
        case 'shops':
        case 'shop_groups':
        case 'shop_urls':
        case 'configurations':
        case 'translated_configurations':

        // Gestion des groupes et clients
        case 'groups':
        case 'guests':

        // Administration et employés
        case 'employees':
        case 'contacts':

        // Localisation et langues
        case 'languages':
        case 'image_types':

        // Magasins physiques
        case 'stores':

        // Taxes et règles fiscales
        case 'tax_rule_groups':
        case 'tax_rules':
          await _generateSingleResource(generator, command);
          break;

        case 'list':
          _listAvailableResources();
          break;

        case 'help':
          _printUsage();
          break;

        default:
          _logger.error('❌ Ressource inconnue: $command');
          _printUsage();
          exit(1);
      }

      _logger.info('✅ Génération terminée avec succès');
    } catch (e, stackTrace) {
      _logger.error('❌ Erreur lors de la génération', e, stackTrace);
      exit(1);
    }
  }

  /// Génère une ressource spécifique
  static Future<void> _generateSingleResource(
    PrestaShopGenerator generator,
    String resourceName,
  ) async {
    final config = PrestaShopGenerator.resourceConfigs[resourceName];
    if (config == null) {
      _logger.error('❌ Configuration non trouvée pour: $resourceName');
      exit(1);
    }

    await generator.generateResource(config);
  }

  /// Affiche l'aide
  static void _printUsage() {
    print('''
PrestaShop Generator CLI - Phase 2

Usage:
  dart run tools/generate.dart <command> [options]

Commands:
  all                       Génère tous les modèles et services (39 ressources ✅)
  
  # E-commerce principal
  products                  Produits
  customers                 Clients
  orders                    Commandes
  
  # Partenaires
  manufacturers             Fabricants
  suppliers                 Fournisseurs
  
  # Panier et déclinaisons
  carts                     Paniers
  combinations              Déclinaisons produits
  
  # Attributs produits
  product_options           Options de produits
  product_option_values     Valeurs d'options
  product_features          Caractéristiques
  product_feature_values    Valeurs de caractéristiques
  product_suppliers         Fournisseurs de produits
  
  # Transport et zones
  carriers                  Transporteurs
  zones                     Zones géographiques
  price_ranges              Tranches de prix
  weight_ranges             Tranches de poids
  
  # États et détails commandes
  order_states              États de commande
  order_details             Détails de commande
  order_carriers            Transporteurs de commande
  states                    États/Régions
  
  # Stock et prix
  stock_availables          Stocks disponibles
  stock_movement_reasons    Raisons de mouvement de stock
  specific_prices           Prix spécifiques
  
  # Configuration boutique
  shops                     Boutiques
  shop_groups               Groupes de boutiques
  shop_urls                 URLs de boutique
  configurations            Configurations
  translated_configurations Configurations traduites
  
  # Clients et groupes
  groups                    Groupes de clients
  guests                    Invités
  
  # Administration
  employees                 Employés
  contacts                  Contacts
  
  # Localisation
  languages                 Langues
  image_types               Types d'images
  
  # Magasins physiques
  stores                    Magasins
  
  # Fiscalité
  tax_rule_groups           Groupes de règles fiscales
  tax_rules                 Règles fiscales
  
  list                      Liste toutes les ressources disponibles
  help                      Affiche cette aide

Options:
  --force       Force la régénération même si les fichiers existent
  --web-only    Génère seulement les services web (sans cache)
  --no-cache    Génère les services sans support de cache

Examples:
  dart run tools/generate.dart all                    # Génère toutes les 39 ressources PrestaShop ✅
  dart run tools/generate.dart products               # Génère seulement les produits
  dart run tools/generate.dart orders --force         # Force la régénération des commandes
  dart run tools/generate.dart list                   # Liste toutes les ressources disponibles
  dart run tools/generate.dart carriers               # Génère les transporteurs
  dart run tools/generate.dart stock_availables       # Génère la gestion de stock
''');
  }

  /// Liste les ressources disponibles
  static void _listAvailableResources() {
    _logger.info('📋 Ressources PrestaShop disponibles:');

    final configs = PrestaShopGenerator.resourceConfigs;
    for (final entry in configs.entries) {
      final name = entry.key;
      final config = entry.value;
      print('  • $name');
      print('    └─ Modèle: ${config.modelClassName}');
      print('    └─ Service: ${config.serviceClassName}');
      print('    └─ Endpoint: /${config.endpoint}');
      print('    └─ Champs: ${config.fieldTypes.length}');
      if (config.hasTranslations) print('    └─ 🌐 Traductions supportées');
      if (config.hasStates) print('    └─ 📊 États supportés');
      print('');
    }
  }
}

/// Point d'entrée du script
Future<void> main(List<String> args) async {
  await GeneratorCLI.main(args);
}
