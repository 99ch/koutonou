import 'package:flutter/material.dart';
import '../models/order_history_model.dart';
import '../models/order_state_model.dart';

/// Widget pour afficher l'historique d'une commande
class OrderHistoryList extends StatelessWidget {
  final List<OrderHistory> orderHistory;
  final List<OrderState> orderStates;
  final bool isLoading;

  const OrderHistoryList({
    super.key,
    required this.orderHistory,
    required this.orderStates,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucun historique disponible'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orderHistory.length,
      itemBuilder: (context, index) {
        final historyItem = orderHistory[index];
        final isLast = index == orderHistory.length - 1;

        return _buildHistoryItem(context, historyItem, isLast);
      },
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    OrderHistory historyItem,
    bool isLast,
  ) {
    final stateId = historyItem.idOrderState;
    final orderState = _findOrderState(stateId);
    final dateAdd = historyItem.dateAdd;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: orderState != null && orderState.color != null
                    ? Color(
                        int.parse(
                          '0xFF${orderState.color!.replaceAll('#', '')}',
                        ),
                      )
                    : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 3,
                ),
              ),
              child: Icon(
                _getStateIcon(orderState),
                color: Colors.white,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Contenu
        Expanded(
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec état et date
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          orderState?.name ?? 'État $stateId',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (dateAdd != null)
                        Text(
                          _formatDate(dateAdd),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Informations sur l'état
                  if (orderState != null) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (orderState.paid)
                          _buildStateChip('Payé', Icons.payment, Colors.green),
                        if (orderState.shipped)
                          _buildStateChip(
                            'Expédié',
                            Icons.local_shipping,
                            Colors.blue,
                          ),
                        if (orderState.delivery)
                          _buildStateChip(
                            'Livraison',
                            Icons.delivery_dining,
                            Colors.orange,
                          ),
                        if (orderState.pdfInvoice)
                          _buildStateChip(
                            'Facture PDF',
                            Icons.picture_as_pdf,
                            Colors.red,
                          ),
                        if (orderState.pdfDelivery)
                          _buildStateChip(
                            'Bon de livraison PDF',
                            Icons.description,
                            Colors.indigo,
                          ),
                      ],
                    ),
                  ],

                  // Employee info (si disponible)
                  if (historyItem.idEmployee != null &&
                      historyItem.idEmployee != 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Par l\'employé ID: ${historyItem.idEmployee}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStateChip(String label, IconData icon, Color color) {
    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      avatar: Icon(icon, size: 16, color: color),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  OrderState? _findOrderState(int? stateId) {
    if (stateId == null) return null;
    try {
      return orderStates.firstWhere((state) => state.id == stateId);
    } catch (e) {
      return null;
    }
  }

  IconData _getStateIcon(OrderState? state) {
    if (state == null) return Icons.help_outline;

    if (state.delivery) return Icons.delivery_dining;
    if (state.shipped) return Icons.local_shipping;
    if (state.paid) return Icons.payment;
    if (state.logable) return Icons.event_note;

    return Icons.radio_button_checked;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    String timeAgo;
    if (difference.inDays > 0) {
      timeAgo =
          'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      timeAgo =
          'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      timeAgo =
          'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      timeAgo = 'à l\'instant';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}\n'
        '$timeAgo';
  }
}
