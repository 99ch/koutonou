import 'package:flutter/material.dart';
import '../models/order_model.dart';

/// Widget pour afficher le résumé d'une commande
class OrderSummaryCard extends StatelessWidget {
  final Order order;

  const OrderSummaryCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Résumé de la commande',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Informations principales
            _buildInfoRow('Référence', order.reference ?? 'N/A'),
            _buildInfoRow('Client ID', order.customerId?.toString() ?? 'N/A'),
            _buildInfoRow(
              'Date de commande',
              order.dateAdd != null ? _formatDate(order.dateAdd!) : 'N/A',
            ),
            _buildInfoRow(
              'Dernière mise à jour',
              order.dateUpd != null ? _formatDate(order.dateUpd!) : 'N/A',
            ),

            const Divider(height: 32),

            // Montants
            Text(
              'Montants',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildAmountRow(
              'Produits (HT)',
              order.totalProducts,
              isSubtotal: true,
            ),
            _buildAmountRow(
              'Produits (TTC)',
              order.totalProductsWt,
              isSubtotal: true,
            ),
            _buildAmountRow(
              'Livraison (HT)',
              order.totalShipping,
              isSubtotal: true,
            ),
            _buildAmountRow(
              'Livraison (TTC)',
              order.totalShippingTaxIncl,
              isSubtotal: true,
            ),
            if (order.totalDiscounts > 0) ...[
              _buildAmountRow(
                'Remises (HT)',
                -order.totalDiscounts,
                isDiscount: true,
                isSubtotal: true,
              ),
              _buildAmountRow(
                'Remises (TTC)',
                -order.totalDiscountsTaxIncl,
                isDiscount: true,
                isSubtotal: true,
              ),
            ],

            const Divider(height: 24),

            _buildAmountRow('Total payé', order.totalPaid, isTotal: true),
            _buildAmountRow(
              'Total encaissé',
              order.totalPaidReal,
              isSubtotal: true,
            ),

            const Divider(height: 32),

            // Informations de paiement et livraison
            Text(
              'Paiement et livraison',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (order.paymentMethod?.isNotEmpty == true)
              _buildInfoRow('Méthode de paiement', order.paymentMethod!),
            _buildInfoRow(
              'Transporteur ID',
              order.carrierId?.toString() ?? 'N/A',
            ),
            _buildInfoRow(
              'Adresse de livraison',
              order.addressDeliveryId?.toString() ?? 'N/A',
            ),
            _buildInfoRow(
              'Adresse de facturation',
              order.addressInvoiceId?.toString() ?? 'N/A',
            ),
            _buildInfoRow('Devise', order.currency ?? 'EUR'),

            // Statut de validité
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  (order.valid == true) ? Icons.check_circle : Icons.error,
                  color: (order.valid == true) ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  (order.valid == true)
                      ? 'Commande valide'
                      : 'Commande invalide',
                  style: TextStyle(
                    color: (order.valid == true) ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
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
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    double amount, {
    bool isTotal = false,
    bool isSubtotal = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                fontSize: isTotal ? 16 : 14,
                color: isDiscount ? Colors.red : null,
              ),
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} €',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isDiscount ? Colors.red : (isTotal ? Colors.green : null),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} à '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
