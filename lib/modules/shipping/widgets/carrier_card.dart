import 'package:flutter/material.dart';
import '../models/carrier_model.dart';

class CarrierCard extends StatelessWidget {
  final Carrier carrier;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CarrierCard({
    super.key,
    required this.carrier,
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
                  // Status indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: carrier.isActive ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name and ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          carrier.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (carrier.id != null)
                          Text(
                            'ID: ${carrier.id}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ),

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

              // Badges row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (carrier.isFreeShipping)
                    _buildBadge('Gratuit', Colors.green, Icons.money_off),
                  if (carrier.isModuleBased)
                    _buildBadge('Module', Colors.blue, Icons.extension),
                  if (carrier.hasExternalModule)
                    _buildBadge('Externe', Colors.orange, Icons.cloud),
                  if (carrier.shippingHandling)
                    _buildBadge('Manutention', Colors.purple, Icons.build),
                  _buildBadge(
                    carrier.shippingMethodName,
                    Colors.grey,
                    Icons.local_shipping,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Details
              if (carrier.hasUrl ||
                  carrier.hasMaxDimensions ||
                  carrier.hasMaxWeight)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (carrier.hasUrl)
                      _buildDetailRow(
                        Icons.link,
                        'URL de tracking',
                        carrier.url!,
                      ),
                    if (carrier.hasMaxDimensions)
                      _buildDetailRow(
                        Icons.straighten,
                        'Dimensions max',
                        '${carrier.maxWidth ?? '∞'} x ${carrier.maxHeight ?? '∞'} x ${carrier.maxDepth ?? '∞'} cm',
                      ),
                    if (carrier.hasMaxWeight)
                      _buildDetailRow(
                        Icons.monitor_weight,
                        'Poids max',
                        '${carrier.maxWeight!.toStringAsFixed(1)} kg',
                      ),
                  ],
                ),

              // Delay information
              if (carrier.delay.isNotEmpty) const SizedBox(height: 8),
              if (carrier.delay.isNotEmpty)
                _buildDetailRow(
                  Icons.schedule,
                  'Délai',
                  carrier.getDelayForLanguage('1').isNotEmpty
                      ? carrier.getDelayForLanguage('1')
                      : carrier.delay.values.first,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
