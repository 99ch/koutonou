import 'dart:convert';

/// Configuration pour l'API PrestaShop
/// 
/// Cette classe gère la configuration globale de l'API PrestaShop
/// incluant les URLs, clés d'authentification et paramètres par défaut.
class PrestashopApiConfig {
  /// URL de base de l'API PrestaShop (ex: https://monshop.com/api)
  final String baseUrl;
  
  /// Clé API pour l'authentification
  final String apiKey;
  
  /// Langue par défaut pour les requêtes
  final String defaultLanguage;
  
  /// URL de base pour les images
  final String imageBaseUrl;
  
  /// Boutique par défaut (multi-shop)
  final int? defaultShopId;
  
  /// Timeout pour les requêtes HTTP (en secondes)
  final int timeoutSeconds;
  
  /// Activer le mode debug
  final bool debugMode;
  
  /// Version de l'API PrestaShop
  final String apiVersion;

  const PrestashopApiConfig({
    required this.baseUrl,
    required this.apiKey,
    this.defaultLanguage = 'fr',
    required this.imageBaseUrl,
    this.defaultShopId,
    this.timeoutSeconds = 30,
    this.debugMode = false,
    this.apiVersion = '1.7',
  });

  /// Configuration depuis les variables d'environnement
  factory PrestashopApiConfig.fromEnvironment() {
    return PrestashopApiConfig(
      baseUrl: const String.fromEnvironment(
        'PRESTASHOP_API_BASE_URL',
        defaultValue: '',
      ),
      apiKey: const String.fromEnvironment(
        'PRESTASHOP_API_KEY',
        defaultValue: '',
      ),
      imageBaseUrl: const String.fromEnvironment(
        'PRESTASHOP_IMAGE_BASE_URL',
        defaultValue: '',
      ),
      defaultLanguage: const String.fromEnvironment(
        'PRESTASHOP_DEFAULT_LANGUAGE',
        defaultValue: 'fr',
      ),
      defaultShopId: const int.fromEnvironment(
        'PRESTASHOP_DEFAULT_SHOP_ID',
        defaultValue: 1,
      ),
      debugMode: const bool.fromEnvironment(
        'PRESTASHOP_DEBUG_MODE',
        defaultValue: false,
      ),
    );
  }

  /// Validation de la configuration
  bool get isValid {
    return baseUrl.isNotEmpty && 
           apiKey.isNotEmpty && 
           imageBaseUrl.isNotEmpty;
  }

  /// URL complète pour un endpoint
  String getEndpointUrl(String endpoint) {
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$cleanBaseUrl$cleanEndpoint';
  }

  /// Headers par défaut pour les requêtes
  Map<String, String> get defaultHeaders {
    return {
      'Content-Type': 'application/xml',
      'Accept': 'application/xml',
      'Authorization': 'Basic ${_encodeApiKey()}',
      'User-Agent': 'Koutonou-Flutter-App/$apiVersion',
    };
  }

  /// Encodage de la clé API en base64
  String _encodeApiKey() {
    final credentials = '$apiKey:';
    return base64Encode(utf8.encode(credentials));
  }

  @override
  String toString() {
    return 'PrestashopApiConfig(baseUrl: $baseUrl, language: $defaultLanguage, shop: $defaultShopId, debug: $debugMode)';
  }
}

/// Configuration globale singleton
class PrestashopConfig {
  static PrestashopApiConfig? _instance;
  
  /// Instance de configuration globale
  static PrestashopApiConfig get instance {
    if (_instance == null) {
      throw StateError('PrestashopConfig not initialized. Call PrestashopConfig.initialize() first.');
    }
    return _instance!;
  }
  
  /// Initialisation de la configuration
  static void initialize(PrestashopApiConfig config) {
    if (!config.isValid) {
      throw ArgumentError('Invalid PrestaShop configuration: missing required fields');
    }
    _instance = config;
  }
  
  /// Vérifier si la configuration est initialisée
  static bool get isInitialized => _instance != null;
}
