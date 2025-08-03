// Simulation E-commerce complète basée sur les 3 ressources validées
// Démontre comment ajouter products, customers, orders etc.
// Preuve de concept pour la scalabilité de l'architecture

import 'package:flutter/material.dart';
import 'package:koutonou/modules/configs/models/languagemodel.dart';
import 'package:koutonou/modules/configs/models/currencymodel.dart';
import 'package:koutonou/modules/configs/models/countrymodel.dart';
import 'package:koutonou/core/utils/logger.dart';

/// Simulation d'un produit (futur ProductModel)
class SimulatedProduct {
  final int id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final int categoryId;

  SimulatedProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.categoryId,
  });
}

/// Simulation d'un client (futur CustomerModel)
class SimulatedCustomer {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final int countryId;

  SimulatedCustomer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.countryId,
  });
}

/// Page de simulation e-commerce complète
class EcommerceSimulation extends StatefulWidget {
  final LanguageModel language;
  final CurrencyModel currency;
  final CountryModel country;

  const EcommerceSimulation({
    super.key,
    required this.language,
    required this.currency,
    required this.country,
  });

  @override
  State<EcommerceSimulation> createState() => _EcommerceSimulationState();
}

class _EcommerceSimulationState extends State<EcommerceSimulation> {
  final AppLogger _logger = AppLogger();
  
  // Données simulées (remplacées par les vraies APIs plus tard)
  final List<SimulatedProduct> _products = [
    SimulatedProduct(
      id: 1,
      name: 'Smartphone Galaxy Pro',
      price: 899.99,
      description: 'Dernier modèle avec écran OLED',
      imageUrl: 'https://via.placeholder.com/150',
      categoryId: 1,
    ),
    SimulatedProduct(
      id: 2,
      name: 'Laptop MacBook Air',
      price: 1299.99,
      description: 'Ultrabook léger et performant',
      imageUrl: 'https://via.placeholder.com/150',
      categoryId: 2,
    ),
    SimulatedProduct(
      id: 3,
      name: 'Casque Audio Wireless',
      price: 199.99,
      description: 'Son haute qualité sans fil',
      imageUrl: 'https://via.placeholder.com/150',
      categoryId: 3,
    ),
  ];

  final List<SimulatedProduct> _cart = [];
  SimulatedCustomer? _currentCustomer;

  @override
  void initState() {
    super.initState();
    _logger.info('🛒 Simulation e-commerce initialisée');
    _logger.info('Configuration: ${widget.language.name}, ${widget.currency.symbol}, ${widget.country.name}');
  }

  String _formatPrice(double price) {
    // Conversion fictive (vraie conversion via API plus tard)
    final conversionRate = double.tryParse(widget.currency.conversion_rate ?? '1.0') ?? 1.0;
    final convertedPrice = price * conversionRate;
    return '${convertedPrice.toStringAsFixed(widget.currency.precision ?? 2)} ${widget.currency.symbol}';
  }

  void _addToCart(SimulatedProduct product) {
    setState(() {
      _cart.add(product);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ajouté au panier'),
        backgroundColor: Colors.green,
      ),
    );
    
    _logger.info('Produit ajouté au panier: ${product.name}');
  }

  void _simulateLogin() {
    setState(() {
      _currentCustomer = SimulatedCustomer(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        countryId: widget.country.id ?? 1,
      );
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion simulée réussie'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _simulateCheckout() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Panier vide'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_currentCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez vous connecter'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final total = _cart.fold<double>(0, (sum, product) => sum + product.price);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Commande Simulée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${_currentCustomer!.firstName} ${_currentCustomer!.lastName}'),
            Text('Email: ${_currentCustomer!.email}'),
            Text('Pays: ${widget.country.name}'),
            Text('Langue: ${widget.language.name}'),
            const SizedBox(height: 8),
            Text('Produits: ${_cart.length}'),
            Text('Total: ${_formatPrice(total)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '✅ Cette simulation montre que l\'architecture peut gérer un processus e-commerce complet !',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _cart.clear();
              });
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
    
    _logger.info('Commande simulée pour ${_cart.length} produits, total: ${_formatPrice(total)}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulation E-commerce'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (_cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_cart.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _simulateCheckout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Configuration actuelle
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.purple.withOpacity(0.1),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🌐 ${widget.language.name}'),
                      Text('💰 ${widget.currency.name} (${widget.currency.symbol})'),
                      Text('📍 ${widget.country.name}'),
                    ],
                  ),
                ),
                if (_currentCustomer != null)
                  Chip(
                    label: Text('${_currentCustomer!.firstName}'),
                    backgroundColor: Colors.green.withOpacity(0.2),
                  )
                else
                  ElevatedButton(
                    onPressed: _simulateLogin,
                    child: const Text('Se connecter'),
                  ),
              ],
            ),
          ),
          
          // Catalogue produits
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                    title: Text(product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.description),
                        const SizedBox(height: 4),
                        Text(
                          _formatPrice(product.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _addToCart(product),
                      child: const Text('Ajouter'),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Indicateur panier
          if (_cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.withOpacity(0.1),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Panier: ${_cart.length} article(s)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _simulateCheckout,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Commander', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.blue.withOpacity(0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '💡 Cette simulation utilise les VRAIES données de configuration PrestaShop',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const Text(
              'Les produits, clients et commandes suivront le même pattern d\'API',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
