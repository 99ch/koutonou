import 'package:flutter/material.dart';
import '../models/cart_model.dart';

class CartCard extends StatelessWidget {
  final Cart cart;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CartCard({
    Key? key,
    required this.cart,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Panier #${cart.id}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: onEdit,
                          tooltip: 'Modifier',
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: onDelete,
                          tooltip: 'Supprimer',
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Client ID', cart.idCustomer?.toString() ?? 'N/A'),
              _buildInfoRow('Devise ID', cart.idCurrency.toString()),
              _buildInfoRow('Langue ID', cart.idLang.toString()),
              _buildInfoRow('Articles', '${cart.totalItems}'),
              _buildInfoRow('Quantité totale', '${cart.totalQuantity.toInt()}'),

              if (cart.gift) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.card_giftcard,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    const Text('Cadeau'),
                    if (cart.hasGiftMessage) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cart.giftMessage!,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              if (cart.recyclable) ...[
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.recycling, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text('Recyclable'),
                  ],
                ),
              ],

              if (cart.dateAdd != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Créé le ${_formatDate(cart.dateAdd!)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],

              if (cart.cartRows != null && cart.cartRows!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Produits dans le panier:'),
                const SizedBox(height: 4),
                ...cart.cartRows!
                    .take(3)
                    .map(
                      (row) => Padding(
                        padding: const EdgeInsets.only(left: 16, top: 2),
                        child: Text(
                          '• Produit ${row.idProduct} (Qté: ${row.quantity})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                if (cart.cartRows!.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 2),
                    child: Text(
                      '... et ${cart.cartRows!.length - 3} autres produits',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
