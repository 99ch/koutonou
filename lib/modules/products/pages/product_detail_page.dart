// Page de détail d'un produit
// Affiche toutes les informations détaillées d'un produit avec support HTML

import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../../../shared/widgets/html_content.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implémenter le partage
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images du produit (placeholder pour l'instant)
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image, size: 100, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // Nom et prix
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${product.price.toStringAsFixed(2)}€',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Informations de base
            _buildInfoRow('Référence', product.reference ?? 'N/A'),
            _buildInfoRow('Catégorie', 'ID: ${product.categoryId}'),
            _buildInfoRow('Stock', '${product.quantity ?? 0} unités'),
            _buildInfoRow('Poids', '${product.weight ?? 0} kg'),
            _buildInfoRow('Condition', product.condition ?? 'new'),
            _buildInfoRow('EAN13', product.ean13 ?? 'N/A'),

            const SizedBox(height: 24),

            // Description courte
            if (product.shortDescription != null &&
                product.shortDescription!.isNotEmpty) ...[
              Text(
                'Description courte',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ProductShortDescription(
                description: product.shortDescription,
                maxLines: 10, // Plus de lignes pour la page de détail
              ),
              const SizedBox(height: 24),
            ],

            // Description complète
            if (product.description != null &&
                product.description!.isNotEmpty) ...[
              Text(
                'Description détaillée',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ProductFullDescription(description: product.description),
              const SizedBox(height: 24),
            ],

            // Informations techniques
            Text(
              'Informations techniques',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow('ID', '${product.id}'),
                    _buildInfoRow('Actif', product.active ? 'Oui' : 'Non'),
                    _buildInfoRow(
                      'En promotion',
                      product.onSale ? 'Oui' : 'Non',
                    ),
                    _buildInfoRow(
                      'Rupture de stock',
                      product.outOfStock ? 'Oui' : 'Non',
                    ),
                    _buildInfoRow(
                      'Afficher prix',
                      product.showPrice ? 'Oui' : 'Non',
                    ),
                    _buildInfoRow('Indexé', product.indexed ? 'Oui' : 'Non'),
                    if (product.dateAdd != null)
                      _buildInfoRow('Créé le', _formatDate(product.dateAdd!)),
                    if (product.dateUpd != null)
                      _buildInfoRow(
                        'Modifié le',
                        _formatDate(product.dateUpd!),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Ajouter au panier
        },
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Ajouter au panier'),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
