import 'package:flutter/material.dart';
import '../models/order_detail_model.dart';

/// Widget pour afficher la liste des détails d'une commande
class OrderDetailsList extends StatelessWidget {
  final List<OrderDetail> orderDetails;
  final bool isLoading;

  const OrderDetailsList({
    super.key,
    required this.orderDetails,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderDetails.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucun détail de commande disponible'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orderDetails.length + 1, // +1 pour le résumé
      itemBuilder: (context, index) {
        if (index == orderDetails.length) {
          return _buildSummaryCard(context);
        }

        final detail = orderDetails[index];
        return _buildDetailCard(context, detail, index + 1);
      },
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    OrderDetail detail,
    int itemNumber,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec numéro d'article
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      itemNumber.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.productName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (detail.productReference != null &&
                          detail.productReference!.isNotEmpty)
                        Text(
                          'Réf: ${detail.productReference}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Informations du produit
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Quantité',
                    detail.productQuantity.toString(),
                    Icons.inventory,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Prix unitaire',
                    '${detail.productPrice.toStringAsFixed(2)} €',
                    Icons.euro,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Total HT',
                    '${(detail.totalPriceTaxExcl ?? 0.0).toStringAsFixed(2)} €',
                    Icons.calculate,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Total TTC',
                    '${(detail.totalPriceTaxIncl ?? 0.0).toStringAsFixed(2)} €',
                    Icons.receipt,
                    isHighlighted: true,
                  ),
                ),
              ],
            ),

            // Codes-barres si disponibles
            if (detail.productEan13 != null &&
                    detail.productEan13!.isNotEmpty ||
                detail.productUpc != null && detail.productUpc!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (detail.productEan13 != null &&
                      detail.productEan13!.isNotEmpty)
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'EAN13',
                        detail.productEan13!,
                        Icons.qr_code,
                      ),
                    ),
                  if (detail.productUpc != null &&
                      detail.productUpc!.isNotEmpty)
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'UPC',
                        detail.productUpc!,
                        Icons.qr_code_2,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    // Calculer les totaux
    final totalQuantity = orderDetails.fold<int>(
      0,
      (sum, detail) => sum + detail.productQuantity,
    );

    final totalHT = orderDetails.fold<double>(
      0,
      (sum, detail) => sum + (detail.totalPriceTaxExcl ?? 0.0),
    );

    final totalTTC = orderDetails.fold<double>(
      0,
      (sum, detail) => sum + (detail.totalPriceTaxIncl ?? 0.0),
    );

    return Card(
      margin: const EdgeInsets.only(top: 16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.summarize,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Résumé des produits',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Articles',
                    '${orderDetails.length}',
                    Icons.inventory_2,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Quantité totale',
                    totalQuantity.toString(),
                    Icons.add_shopping_cart,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Total HT',
                    '${totalHT.toStringAsFixed(2)} €',
                    Icons.calculate,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Total TTC',
                    '${totalTTC.toStringAsFixed(2)} €',
                    Icons.euro,
                    isHighlighted: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isHighlighted
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                  color: isHighlighted
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isHighlighted
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isHighlighted
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
