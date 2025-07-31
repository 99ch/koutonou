// Configuration API PrestaShop - Phase 3
// Gestion des endpoints, authentification et paramètres de connexion

import 'dart:io';

/// Configuration pour l'API PrestaShop
class PrestaShopConfig {
  static const String _defaultHost = 'localhost';
  static const String _defaultPath = '/prestashop/api';
  static const bool _defaultUseHttps = false;
  static const int _defaultTimeout = 30000; // 30 secondes

  /// URL de base de l'API PrestaShop
  final String baseUrl;
  
  /// Clé API PrestaShop
  final String apiKey;
  
  /// Utiliser HTTPS
  final bool useHttps;
  
  /// Timeout des requêtes en millisecondes
  final int timeoutMs;
  
  /// Format de sortie (xml ou json)
  final String outputFormat;
  
  /// Langue par défaut
  final String defaultLanguage;
  
  /// Debug mode
  final bool debug;

  const PrestaShopConfig({
    required this.baseUrl,
    required this.apiKey,
    this.useHttps = _defaultUseHttps,
    this.timeoutMs = _defaultTimeout,
    this.outputFormat = 'JSON',
    this.defaultLanguage = 'fr',
    this.debug = false,
  });

  /// Configuration de développement local
  factory PrestaShopConfig.development({
    String host = _defaultHost,
    String path = _defaultPath,
    required String apiKey,
    bool debug = true,
  }) {
    final protocol = _defaultUseHttps ? 'https' : 'http';
    final baseUrl = '$protocol://$host$path';
    
    return PrestaShopConfig(
      baseUrl: baseUrl,
      apiKey: apiKey,
      useHttps: _defaultUseHttps,
      debug: debug,
      timeoutMs: 10000, // Plus court en dev
    );
  }

  /// Configuration de production
  factory PrestaShopConfig.production({
    required String host,
    String path = '/api',
    required String apiKey,
    bool useHttps = true,
  }) {
    final protocol = useHttps ? 'https' : 'http';
    final baseUrl = '$protocol://$host$path';
    
    return PrestaShopConfig(
      baseUrl: baseUrl,
      apiKey: apiKey,
      useHttps: useHttps,
      debug: false,
      timeoutMs: _defaultTimeout,
    );
  }

  /// Configuration depuis variables d'environnement
  factory PrestaShopConfig.fromEnvironment() {
    final host = Platform.environment['PRESTASHOP_HOST'] ?? _defaultHost;
    final path = Platform.environment['PRESTASHOP_PATH'] ?? _defaultPath;
    final apiKey = Platform.environment['PRESTASHOP_API_KEY'];
    final useHttpsStr = Platform.environment['PRESTASHOP_USE_HTTPS'];
    final debugStr = Platform.environment['PRESTASHOP_DEBUG'];
    
    if (apiKey == null || apiKey.isEmpty) {
      throw ArgumentError(
        'PRESTASHOP_API_KEY environment variable is required'
      );
    }

    final useHttps = useHttpsStr?.toLowerCase() == 'true';
    final debug = debugStr?.toLowerCase() == 'true';
    final protocol = useHttps ? 'https' : 'http';
    final baseUrl = '$protocol://$host$path';

    return PrestaShopConfig(
      baseUrl: baseUrl,
      apiKey: apiKey,
      useHttps: useHttps,
      debug: debug,
    );
  }

  /// URL complète pour une ressource
  String getResourceUrl(String resource, {Map<String, String>? params}) {
    final uri = Uri.parse('$baseUrl/$resource');
    
    final queryParams = <String, String>{
      'output_format': outputFormat,
      'language': defaultLanguage,
      ...?params,
    };

    return uri.replace(queryParameters: queryParams).toString();
  }

  /// Headers HTTP par défaut
  Map<String, String> get defaultHeaders => {
    'Authorization': 'Basic ${_encodeApiKey()}',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Koutonou-Flutter-App/1.0',
  };

  /// Encode la clé API en Base64 pour l'authentification Basic
  String _encodeApiKey() {
    // PrestaShop utilise apiKey:password (mot de passe vide)
    final credentials = '$apiKey:';
    return credentials; // dart:convert base64 sera appliqué par http client
  }

  /// Durée de timeout
  Duration get timeout => Duration(milliseconds: timeoutMs);

  /// Validation de la configuration
  bool get isValid {
    return baseUrl.isNotEmpty && 
           apiKey.isNotEmpty && 
           Uri.tryParse(baseUrl) != null;
  }

  @override
  String toString() {
    return 'PrestaShopConfig('
           'baseUrl: $baseUrl, '
           'useHttps: $useHttps, '
           'timeout: ${timeoutMs}ms, '
           'format: $outputFormat, '
           'debug: $debug'
           ')';
  }

  /// Copie avec modifications
  PrestaShopConfig copyWith({
    String? baseUrl,
    String? apiKey,
    bool? useHttps,
    int? timeoutMs,
    String? outputFormat,
    String? defaultLanguage,
    bool? debug,
  }) {
    return PrestaShopConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      useHttps: useHttps ?? this.useHttps,
      timeoutMs: timeoutMs ?? this.timeoutMs,
      outputFormat: outputFormat ?? this.outputFormat,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      debug: debug ?? this.debug,
    );
  }
}

/// Instance globale de configuration (singleton)
class PrestaShopConfigManager {
  static PrestaShopConfig? _instance;
  
  /// Configuration actuelle
  static PrestaShopConfig get instance {
    if (_instance == null) {
      throw StateError(
        'PrestaShop configuration not initialized. '
        'Call PrestaShopConfigManager.initialize() first.'
      );
    }
    return _instance!;
  }
  
  /// Initialise la configuration
  static void initialize(PrestaShopConfig config) {
    if (!config.isValid) {
      throw ArgumentError('Invalid PrestaShop configuration: $config');
    }
    _instance = config;
  }
  
  /// Vérifie si la configuration est initialisée
  static bool get isInitialized => _instance != null;
  
  /// Reset la configuration (utile pour les tests)
  static void reset() {
    _instance = null;
  }
}
