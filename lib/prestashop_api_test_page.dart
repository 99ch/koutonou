import 'package:flutter/material.dart';
import 'core/api/prestashop_api.dart';
import 'core/config/environment_service.dart';

/// Page de test pour l'API PrestaShop
/// 
/// Cette page permet de tester les fonctionnalités de base
/// de l'API PrestaShop dans l'application.
class PrestashopApiTestPage extends StatefulWidget {
  const PrestashopApiTestPage({super.key});

  @override
  State<PrestashopApiTestPage> createState() => _PrestashopApiTestPageState();
}

class _PrestashopApiTestPageState extends State<PrestashopApiTestPage> {
  final PrestashopApiService _apiService = PrestashopApiService();
  bool _isInitialized = false;
  bool _isLoading = false;
  String _status = 'Non initialisé';
  List<Map<String, dynamic>> _products = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    EnvironmentService.printEnvironmentInfo();
    _initializeApi();
  }

  Future<void> _initializeApi() async {
    setState(() {
      _isLoading = true;
      _status = 'Initialisation...';
      _errorMessage = null;
    });

    try {
      // Utiliser la configuration d'environnement
      final config = EnvironmentService.prestashopConfig;

      await _apiService.initialize(config);

      setState(() {
        _isInitialized = true;
        _status = 'Initialisé avec succès ✅';
      });
    } catch (e) {
      setState(() {
        _isInitialized = false;
        _status = 'Erreur d\'initialisation ❌';
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testConnection() async {
    if (!_isInitialized) return;

    setState(() {
      _isLoading = true;
      _status = 'Test de connexion...';
      _errorMessage = null;
    });

    try {
      final isConnected = await _apiService.testConnection();
      setState(() {
        _status = isConnected 
            ? 'Connexion réussie ✅' 
            : 'Connexion échouée ❌';
      });
    } catch (e) {
      setState(() {
        _status = 'Erreur de connexion ❌';
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    if (!_isInitialized) return;

    setState(() {
      _isLoading = true;
      _status = 'Chargement des produits...';
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getList(
        PrestashopApiEndpoints.products,
        limit: 10,
      );

      setState(() {
        _products = response.data;
        _status = '${_products.length} produits chargés ✅';
      });
    } catch (e) {
      setState(() {
        _status = 'Erreur de chargement ❌';
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchProducts() async {
    if (!_isInitialized) return;

    setState(() {
      _isLoading = true;
      _status = 'Recherche de produits...';
      _errorMessage = null;
    });

    try {
      final response = await _apiService.advancedSearch(
        resource: PrestashopApiEndpoints.products,
        query: 'test',
        itemsPerPage: 5,
      );

      setState(() {
        _products = response.data;
        _status = 'Recherche: ${_products.length} résultats ✅';
      });
    } catch (e) {
      setState(() {
        _status = 'Erreur de recherche ❌';
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API PrestaShop'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Environment Info Card
            Card(
              color: Color(EnvironmentService.environmentColor).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(EnvironmentService.environmentColor),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Environnement: ${EnvironmentService.environmentName}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Color(EnvironmentService.environmentColor),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'API: ${EnvironmentService.prestashopConfig.baseUrl}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Images: ${EnvironmentService.prestashopConfig.imageBaseUrl}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statut de l\'API',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Erreur: $_errorMessage',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _initializeApi,
                  child: const Text('Réinitialiser'),
                ),
                ElevatedButton(
                  onPressed: _isLoading || !_isInitialized ? null : _testConnection,
                  child: const Text('Tester Connexion'),
                ),
                ElevatedButton(
                  onPressed: _isLoading || !_isInitialized ? null : _loadProducts,
                  child: const Text('Charger Produits'),
                ),
                ElevatedButton(
                  onPressed: _isLoading || !_isInitialized ? null : _searchProducts,
                  child: const Text('Rechercher'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Products List
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Produits (${_products.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _products.isEmpty
                              ? const Center(
                                  child: Text('Aucun produit chargé'),
                                )
                              : ListView.builder(
                                  itemCount: _products.length,
                                  itemBuilder: (context, index) {
                                    final product = _products[index];
                                    return ListTile(
                                      title: Text(
                                        product['name']?.toString() ?? 
                                        'Produit ${product['id']}',
                                      ),
                                      subtitle: Text(
                                        'ID: ${product['id']} - ${product['reference'] ?? 'N/A'}',
                                      ),
                                      trailing: Text(
                                        '${product['price'] ?? '0'} €',
                                      ),
                                      onTap: () {
                                        _showProductDetails(product);
                                      },
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Produit ${product['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: product.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '${entry.key}:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(entry.value?.toString() ?? 'null'),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
