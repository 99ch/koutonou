import 'package:flutter/material.dart';
import '../models/delivery_model.dart';

class DeliveryCard extends StatelessWidget {
  final Delivery delivery;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DeliveryCard({
    super.key,
    required this.delivery,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Price indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.euro, size: 14, color: Colors.green),
                        const SizedBox(width: 2),
                        Text(
                          delivery.price.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ID
                  if (delivery.id != null)
                    Text(
                      'ID: ${delivery.id}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                  const Spacer(),

                  // Action buttons
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Modifier'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text(
                                'Supprimer',
                                style: TextStyle(color: Colors.red),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Range Information
              Row(
                children: [
                  // Weight Range
                  if (delivery.idRangeWeight != null)
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.monitor_weight,
                        label: 'Poids',
                        value: 'Range ID: ${delivery.idRangeWeight}',
                        color: Colors.orange,
                      ),
                    ),

                  if (delivery.idRangeWeight != null &&
                      delivery.idRangePrice != null)
                    const SizedBox(width: 12),

                  // Price Range
                  if (delivery.idRangePrice != null)
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.price_change,
                        label: 'Prix',
                        value: 'Range ID: ${delivery.idRangePrice}',
                        color: Colors.blue,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Carrier and Zone info
              Row(
                children: [
                  // Carrier
                  if (delivery.idCarrier != null)
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.local_shipping,
                        label: 'Transporteur',
                        value: 'ID: ${delivery.idCarrier}',
                        color: Colors.purple,
                      ),
                    ),

                  if (delivery.idCarrier != null && delivery.idZone != null)
                    const SizedBox(width: 12),

                  // Zone
                  if (delivery.idZone != null)
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.public,
                        label: 'Zone',
                        value: 'ID: ${delivery.idZone}',
                        color: Colors.teal,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
