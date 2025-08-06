import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../../../shared/widgets/html_content.dart';
import '../pages/product_detail_page.dart';

/// Widget pour afficher une carte produit
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap:
            onTap ??
            () {
              // Navigation par défaut vers la page de détail
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
            },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec nom et statut
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.reference != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Réf: ${product.reference}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(context),
                ],
              ),

              const SizedBox(height: 12),

              // Prix et quantité
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(2)} €',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (product.quantity != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.inventory_2,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Stock: ${product.quantity}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showActions) _buildActionButtons(context),
                ],
              ),

              // Description courte si disponible
              if (product.shortDescription != null &&
                  product.shortDescription!.isNotEmpty) ...[
                const SizedBox(height: 8),
                ProductShortDescription(
                  description: product.shortDescription,
                  maxLines: 2,
                  textStyle: Theme.of(context).textTheme.bodySmall,
                ),
              ],

              // Informations supplémentaires
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (product.onSale) _buildInfoChip('Promo', Colors.orange),
                  if (product.outOfStock) _buildInfoChip('Rupture', Colors.red),
                  if (product.condition != 'new')
                    _buildInfoChip(
                      product.condition?.toUpperCase() ?? '',
                      Colors.grey,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: product.active ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        product.active ? 'Actif' : 'Inactif',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: onEdit,
            tooltip: 'Modifier',
          ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
            onPressed: () => _confirmDelete(context),
            tooltip: 'Supprimer',
          ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer le produit "${product.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher les détails d'un produit
class ProductDetails extends StatelessWidget {
  final Product product;
  final VoidCallback? onEdit;

  const ProductDetails({super.key, required this.product, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Modifier',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations principales
            _buildSection(context, 'Informations principales', [
              _buildInfoRow('ID', product.id?.toString() ?? 'N/A'),
              _buildInfoRow('Nom', product.name),
              _buildInfoRow('Prix', '${product.price.toStringAsFixed(2)} €'),
              _buildInfoRow('Référence', product.reference ?? 'N/A'),
              _buildInfoRow('Statut', product.active ? 'Actif' : 'Inactif'),
              _buildInfoRow('Condition', product.condition ?? 'N/A'),
            ]),

            const SizedBox(height: 24),

            // Stock et disponibilité
            _buildSection(context, 'Stock et disponibilité', [
              _buildInfoRow('Quantité', product.quantity?.toString() ?? 'N/A'),
              _buildInfoRow(
                'Rupture de stock',
                product.outOfStock ? 'Oui' : 'Non',
              ),
              _buildInfoRow('Affiché en promo', product.onSale ? 'Oui' : 'Non'),
              _buildInfoRow('Prix affiché', product.showPrice ? 'Oui' : 'Non'),
              _buildInfoRow('Indexé', product.indexed ? 'Oui' : 'Non'),
            ]),

            const SizedBox(height: 24),

            // Descriptions
            if (product.description != null || product.shortDescription != null)
              _buildSection(context, 'Descriptions', [
                if (product.shortDescription != null)
                  _buildDescriptionRow(
                    'Description courte',
                    product.shortDescription!,
                  ),
                if (product.description != null)
                  _buildDescriptionRow(
                    'Description complète',
                    product.description!,
                  ),
              ]),

            const SizedBox(height: 24),

            // Caractéristiques techniques
            _buildSection(context, 'Caractéristiques techniques', [
              _buildInfoRow('EAN13', product.ean13 ?? 'N/A'),
              _buildInfoRow('UPC', product.upc ?? 'N/A'),
              _buildInfoRow(
                'Poids',
                product.weight != null ? '${product.weight} kg' : 'N/A',
              ),
              _buildInfoRow(
                'Catégorie principale',
                product.categoryId.toString(),
              ),
            ]),

            const SizedBox(height: 24),

            // Dates
            if (product.dateAdd != null || product.dateUpd != null)
              _buildSection(context, 'Dates', [
                if (product.dateAdd != null)
                  _buildInfoRow('Date d\'ajout', _formatDate(product.dateAdd!)),
                if (product.dateUpd != null)
                  _buildInfoRow(
                    'Dernière modification',
                    _formatDate(product.dateUpd!),
                  ),
              ]),

            const SizedBox(height: 24),

            // SEO
            if (product.seo.metaTitle != null ||
                product.seo.metaDescription != null ||
                product.seo.metaKeywords != null ||
                product.seo.linkRewrite != null)
              _buildSection(context, 'SEO', [
                if (product.seo.metaTitle != null)
                  _buildInfoRow('Meta titre', product.seo.metaTitle!),
                if (product.seo.metaDescription != null)
                  _buildDescriptionRow(
                    'Meta description',
                    product.seo.metaDescription!,
                  ),
                if (product.seo.metaKeywords != null)
                  _buildInfoRow('Meta mots-clés', product.seo.metaKeywords!),
                if (product.seo.linkRewrite != null)
                  _buildInfoRow('URL réécrite', product.seo.linkRewrite!),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(children: children),
        ),
      ],
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
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDescriptionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
