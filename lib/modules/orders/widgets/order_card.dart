import 'package:flutter/material.dart';
import '../models/order_model.dart';

// Widget pour afficher une carte de commande
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  final Function(int)? onStateChanged;
  final bool showActions;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onStateChanged,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec référence et état
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Commande ${order.reference ?? order.id}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Client ID: ${order.customerId ?? 'N/A'}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),

              const SizedBox(height: 12),

              // Informations principales
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'Total',
                      '${order.totalPaid.toStringAsFixed(2)} €',
                      Icons.euro,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'Date',
                      order.dateAdd != null
                          ? _formatDate(order.dateAdd!)
                          : 'N/A',
                      Icons.calendar_today,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'Produits',
                      '${order.totalProducts.toStringAsFixed(2)} €',
                      Icons.shopping_cart,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'Livraison',
                      '${order.totalShipping.toStringAsFixed(2)} €',
                      Icons.local_shipping,
                    ),
                  ),
                ],
              ),

              if (order.paymentMethod?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                _buildInfoItem(
                  context,
                  'Paiement',
                  order.paymentMethod!,
                  Icons.payment,
                ),
              ],

              // Actions
              if (showActions && onStateChanged != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.visibility),
                      label: const Text('Voir détails'),
                    ),
                    PopupMenuButton<int>(
                      onSelected: onStateChanged,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 2,
                          child: ListTile(
                            leading: Icon(Icons.payment, color: Colors.orange),
                            title: Text('En attente de paiement'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 3,
                          child: ListTile(
                            leading: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            title: Text('Paiement accepté'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 4,
                          child: ListTile(
                            leading: Icon(
                              Icons.local_shipping,
                              color: Colors.blue,
                            ),
                            title: Text('En préparation'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 5,
                          child: ListTile(
                            leading: Icon(Icons.done_all, color: Colors.green),
                            title: Text('Expédiée'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                      child: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    String statusText;

    // Mappage des états courants (peut être amélioré avec les vrais états)
    switch (order.currentState?.toString()) {
      case '1': // Awaiting check payment
        chipColor = Colors.orange;
        statusText = 'En attente';
        break;
      case '2': // Payment accepted
        chipColor = Colors.green;
        statusText = 'Payée';
        break;
      case '3': // Processing in progress
        chipColor = Colors.blue;
        statusText = 'En cours';
        break;
      case '4': // Shipped
        chipColor = Colors.indigo;
        statusText = 'Expédiée';
        break;
      case '5': // Delivered
        chipColor = Colors.green[700]!;
        statusText = 'Livrée';
        break;
      case '6': // Canceled
        chipColor = Colors.red;
        statusText = 'Annulée';
        break;
      case '7': // Refunded
        chipColor = Colors.grey;
        statusText = 'Remboursée';
        break;
      default:
        chipColor = Colors.grey;
        statusText = 'État ${order.currentState ?? 'N/A'}';
    }

    return Chip(
      label: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor.withOpacity(0.1),
      side: BorderSide(color: chipColor, width: 1),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
