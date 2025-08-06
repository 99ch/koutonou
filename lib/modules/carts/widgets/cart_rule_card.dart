import 'package:flutter/material.dart';
import '../models/cart_rule_model.dart';

class CartRuleCard extends StatelessWidget {
  final CartRule cartRule;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onApply;
  final bool showApplyButton;

  const CartRuleCard({
    Key? key,
    required this.cartRule,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onApply,
    this.showApplyButton = false,
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
                  Expanded(
                    child: Text(
                      cartRule.getNameForLanguage('1').isNotEmpty
                          ? cartRule.getNameForLanguage('1')
                          : 'Promotion #${cartRule.id}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatusChip(context),
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

              if (cartRule.description != null &&
                  cartRule.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  cartRule.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Discount information
              if (cartRule.hasPercentageDiscount) ...[
                _buildDiscountRow(
                  context,
                  Icons.percent,
                  'Réduction',
                  '${cartRule.reductionPercent!.toStringAsFixed(1)}%',
                  Colors.green,
                ),
              ],

              if (cartRule.hasAmountDiscount) ...[
                _buildDiscountRow(
                  context,
                  Icons.euro,
                  'Réduction',
                  '${cartRule.reductionAmount!.toStringAsFixed(2)}€',
                  Colors.green,
                ),
              ],

              if (cartRule.freeShipping) ...[
                _buildDiscountRow(
                  context,
                  Icons.local_shipping,
                  'Livraison gratuite',
                  'Oui',
                  Colors.blue,
                ),
              ],

              if (cartRule.hasGiftProduct) ...[
                _buildDiscountRow(
                  context,
                  Icons.card_giftcard,
                  'Produit cadeau',
                  'ID: ${cartRule.giftProduct}',
                  Colors.orange,
                ),
              ],

              const SizedBox(height: 8),

              // Code and validity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (cartRule.hasCode)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Code: ${cartRule.code}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  if (!cartRule.isExpired && cartRule.remainingTime.inDays > 0)
                    Text(
                      'Expire dans ${cartRule.remainingTime.inDays} jour(s)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cartRule.remainingTime.inDays <= 7
                            ? Colors.orange
                            : Colors.grey[600],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Validity period
              Text(
                'Valide du ${_formatDate(cartRule.dateFrom)} au ${_formatDate(cartRule.dateTo)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),

              // Minimum amount
              if (cartRule.hasMinimumAmount) ...[
                const SizedBox(height: 4),
                Text(
                  'Montant minimum: ${cartRule.minimumAmount!.toStringAsFixed(2)}€',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],

              // Usage limits
              if (cartRule.quantity != null ||
                  cartRule.quantityPerUser != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Utilisation: ${cartRule.quantity != null ? 'Total ${cartRule.quantity}' : ''}${cartRule.quantity != null && cartRule.quantityPerUser != null ? ', ' : ''}${cartRule.quantityPerUser != null ? 'Par utilisateur ${cartRule.quantityPerUser}' : ''}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],

              if (showApplyButton && onApply != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cartRule.isActive ? onApply : null,
                    child: const Text('Appliquer'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    String text;

    if (cartRule.isActive) {
      color = Colors.green;
      text = 'Actif';
    } else if (cartRule.isExpired) {
      color = Colors.red;
      text = 'Expiré';
    } else if (cartRule.isNotYetValid) {
      color = Colors.orange;
      text = 'Pas encore valide';
    } else {
      color = Colors.grey;
      text = 'Inactif';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDiscountRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
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
