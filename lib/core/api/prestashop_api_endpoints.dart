/// Endpoints de l'API PrestaShop
/// 
/// Cette classe définit tous les endpoints disponibles dans l'API PrestaShop
/// et les paramètres associés pour chaque type de ressource.
class PrestashopApiEndpoints {
  // ==================== ENDPOINTS PRINCIPAUX ====================
  
  /// Produits
  static const String products = 'products';
  
  /// Catégories
  static const String categories = 'categories';
  
  /// Clients
  static const String customers = 'customers';
  
  /// Commandes
  static const String orders = 'orders';
  
  /// Paniers
  static const String carts = 'carts';
  
  /// Adresses
  static const String addresses = 'addresses';
  
  // ==================== CATALOGUE ====================
  
  /// Fabricants
  static const String manufacturers = 'manufacturers';
  
  /// Fournisseurs
  static const String suppliers = 'suppliers';
  
  /// Caractéristiques produits
  static const String productFeatures = 'product_features';
  
  /// Valeurs de caractéristiques
  static const String productFeatureValues = 'product_feature_values';
  
  /// Options produits (couleur, taille, etc.)
  static const String productOptions = 'product_options';
  
  /// Valeurs d'options produits
  static const String productOptionValues = 'product_option_values';
  
  /// Combinaisons (déclinaisons) de produits
  static const String combinations = 'combinations';
  
  /// Images produits
  static const String productImages = 'images/products';
  
  /// Images catégories
  static const String categoryImages = 'images/categories';
  
  /// Images fabricants
  static const String manufacturerImages = 'images/manufacturers';
  
  /// Pièces jointes
  static const String attachments = 'attachments';
  
  /// Tags
  static const String tags = 'tags';
  
  // ==================== COMMANDES & PANIERS ====================
  
  /// Détails de commandes
  static const String orderDetails = 'order_details';
  
  /// États de commandes
  static const String orderStates = 'order_states';
  
  /// Historique des commandes
  static const String orderHistories = 'order_histories';
  
  /// Factures
  static const String orderInvoices = 'order_invoices';
  
  /// Bons de livraison
  static const String orderSlips = 'order_slip';
  
  /// Paiements
  static const String orderPayments = 'order_payments';
  
  /// Transporteurs de commandes
  static const String orderCarriers = 'order_carriers';
  
  /// Règles de panier
  static const String cartRules = 'cart_rules';
  
  /// Règles de panier pour commandes
  static const String orderCartRules = 'order_cart_rules';
  
  /// Retours
  static const String orderReturns = 'order_returns';
  
  // ==================== GESTION DES STOCKS ====================
  
  /// Stocks disponibles
  static const String stockAvailables = 'stock_availables';
  
  /// Mouvements de stock
  static const String stockMovements = 'stock_movements';
  
  /// Raisons de mouvement de stock
  static const String stockMovementReasons = 'stock_movement_reasons';
  
  /// Stocks
  static const String stocks = 'stocks';
  
  /// Entrepôts
  static const String warehouses = 'warehouses';
  
  // ==================== LIVRAISON & TRANSPORT ====================
  
  /// Transporteurs
  static const String carriers = 'carriers';
  
  /// Livraisons
  static const String deliveries = 'deliveries';
  
  /// Pays
  static const String countries = 'countries';
  
  /// États/Régions
  static const String states = 'states';
  
  /// Zones
  static const String zones = 'zones';
  
  /// Gammes de prix
  static const String priceRanges = 'price_ranges';
  
  /// Gammes de poids
  static const String weightRanges = 'weight_ranges';
  
  // ==================== TAXES & PRIX ====================
  
  /// Taxes
  static const String taxes = 'taxes';
  
  /// Règles de taxes
  static const String taxRules = 'tax_rules';
  
  /// Groupes de règles de taxes
  static const String taxRuleGroups = 'tax_rule_groups';
  
  /// Prix spécifiques
  static const String specificPrices = 'specific_prices';
  
  /// Règles de prix spécifiques
  static const String specificPriceRules = 'specific_price_rules';
  
  // ==================== CONFIGURATION ====================
  
  /// Configurations
  static const String configurations = 'configurations';
  
  /// Configurations traduites
  static const String translatedConfigurations = 'translated_configurations';
  
  /// Langues
  static const String languages = 'languages';
  
  /// Devises
  static const String currencies = 'currencies';
  
  /// Boutiques
  static const String shops = 'shops';
  
  /// Groupes de boutiques
  static const String shopGroups = 'shop_groups';
  
  /// URLs de boutiques
  static const String shopUrls = 'shop_urls';
  
  // ==================== CMS & CONTENU ====================
  
  /// Pages CMS
  static const String cms = 'content_management_system';
  
  /// Catégories CMS
  static const String cmsCategories = 'cms_categories';
  
  /// Magasins physiques
  static const String stores = 'stores';
  
  // ==================== CLIENTS & GROUPES ====================
  
  /// Groupes de clients
  static const String customerGroups = 'groups';
  
  /// Invités
  static const String guests = 'guests';
  
  /// Messages clients
  static const String customerMessages = 'customer_messages';
  
  /// Threads de messages clients
  static const String customerThreads = 'customer_threads';
  
  // ==================== EMPLOYÉS & CONTACTS ====================
  
  /// Employés
  static const String employees = 'employees';
  
  /// Contacts
  static const String contacts = 'contacts';
  
  /// Messages
  static const String messages = 'messages';
  
  // ==================== PERSONNALISATION ====================
  
  /// Personnalisations
  static const String customizations = 'customizations';
  
  /// Champs de personnalisation de produit
  static const String productCustomizationFields = 'product_customization_fields';
  
  // ==================== RECHERCHE ====================
  
  /// Recherches
  static const String search = 'search';
  
  // ==================== MÉTHODES UTILITAIRES ====================
  
  /// Vérifier si un endpoint existe
  static bool isValidEndpoint(String endpoint) {
    return getAllEndpoints().contains(endpoint);
  }
  
  /// Obtenir tous les endpoints disponibles
  static List<String> getAllEndpoints() {
    return [
      // Principaux
      products, categories, customers, orders, carts, addresses,
      
      // Catalogue
      manufacturers, suppliers, productFeatures, productFeatureValues,
      productOptions, productOptionValues, combinations, attachments, tags,
      
      // Images
      productImages, categoryImages, manufacturerImages,
      
      // Commandes
      orderDetails, orderStates, orderHistories, orderInvoices, orderSlips,
      orderPayments, orderCarriers, cartRules, orderCartRules, orderReturns,
      
      // Stocks
      stockAvailables, stockMovements, stockMovementReasons, stocks, warehouses,
      
      // Livraison
      carriers, deliveries, countries, states, zones, priceRanges, weightRanges,
      
      // Taxes
      taxes, taxRules, taxRuleGroups, specificPrices, specificPriceRules,
      
      // Configuration
      configurations, translatedConfigurations, languages, currencies,
      shops, shopGroups, shopUrls,
      
      // CMS
      cms, cmsCategories, stores,
      
      // Clients
      customerGroups, guests, customerMessages, customerThreads,
      
      // Employés
      employees, contacts, messages,
      
      // Personnalisation
      customizations, productCustomizationFields,
      
      // Recherche
      search,
    ];
  }
  
  /// Obtenir les endpoints liés aux produits
  static List<String> getProductRelatedEndpoints() {
    return [
      products, categories, manufacturers, suppliers,
      productFeatures, productFeatureValues, productOptions,
      productOptionValues, combinations, productImages, attachments, tags,
    ];
  }
  
  /// Obtenir les endpoints liés aux commandes
  static List<String> getOrderRelatedEndpoints() {
    return [
      orders, orderDetails, orderStates, orderHistories,
      orderInvoices, orderSlips, orderPayments, orderCarriers,
      cartRules, orderCartRules, orderReturns,
    ];
  }
  
  /// Obtenir les endpoints liés aux stocks
  static List<String> getStockRelatedEndpoints() {
    return [
      stockAvailables, stockMovements, stockMovementReasons,
      stocks, warehouses,
    ];
  }
  
  /// Obtenir les endpoints de configuration
  static List<String> getConfigurationEndpoints() {
    return [
      configurations, translatedConfigurations, languages,
      currencies, shops, shopGroups, shopUrls,
    ];
  }
}

/// Paramètres de requête courants pour l'API PrestaShop
class PrestashopApiParams {
  /// Format de sortie (JSON, XML)
  static const String outputFormat = 'output_format';
  
  /// Type d'affichage (full, synopsis, etc.)
  static const String display = 'display';
  
  /// Limite d'éléments
  static const String limit = 'limit';
  
  /// Décalage pour la pagination
  static const String offset = 'offset';
  
  /// Tri
  static const String sort = 'sort';
  
  /// Filtres
  static const String filter = 'filter';
  
  /// Langue
  static const String language = 'language';
  
  /// Boutique
  static const String shop = 'shop';
  
  /// Mode schema (pour obtenir la structure)
  static const String schema = 'schema';
  
  /// Valeurs par défaut
  static const Map<String, String> defaults = {
    outputFormat: 'XML',
    display: 'full',
  };
}
