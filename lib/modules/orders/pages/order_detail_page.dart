import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/order_details_list.dart';
import '../widgets/order_history_list.dart';
import '../widgets/order_actions.dart';

/// Page de détail d'une commande
class OrderDetailPage extends StatefulWidget {
  final Order order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrderDetails();
  }

  void _loadOrderDetails() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OrderProvider>();
      provider.selectOrder(widget.order);
      provider.loadOrderById(widget.order.id!);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commande ${widget.order.reference}'),
        actions: [
          Consumer<OrderProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) => _handleAction(value, provider),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'refresh',
                    child: ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('Actualiser'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit_state',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Changer l\'état'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Icons.download),
                      title: Text('Exporter'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Résumé', icon: Icon(Icons.summarize)),
            Tab(text: 'Détails', icon: Icon(Icons.list)),
            Tab(text: 'Historique', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadOrderById(widget.order.id!),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final order = provider.selectedOrder ?? widget.order;

          return TabBarView(
            controller: _tabController,
            children: [
              // Onglet Résumé
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OrderSummaryCard(order: order),
                    const SizedBox(height: 16),
                    OrderActions(
                      order: order,
                      onStateChanged: (newStateId) =>
                          _updateOrderState(provider, newStateId),
                    ),
                  ],
                ),
              ),

              // Onglet Détails
              OrderDetailsList(
                orderDetails: provider.selectedOrderDetails,
                isLoading: provider.isLoading,
              ),

              // Onglet Historique
              OrderHistoryList(
                orderHistory: provider.selectedOrderHistory,
                orderStates: provider.orderStates,
                isLoading: provider.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleAction(String action, OrderProvider provider) {
    switch (action) {
      case 'refresh':
        provider.loadOrderById(widget.order.id!);
        break;
      case 'edit_state':
        _showStateEditor(provider);
        break;
      case 'export':
        _exportOrder();
        break;
    }
  }

  void _showStateEditor(OrderProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer l\'état de la commande'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provider.orderStates.length,
            itemBuilder: (context, index) {
              final state = provider.orderStates[index];
              final isSelected = state.id == widget.order.currentState;

              return ListTile(
                leading: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(
                        '0xFF${(state.color ?? '#000000').replaceAll('#', '')}',
                      ),
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(state.name),
                trailing: isSelected ? const Icon(Icons.check) : null,
                selected: isSelected,
                onTap: () {
                  Navigator.of(context).pop();
                  _updateOrderState(provider, state.id ?? 0);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _updateOrderState(OrderProvider provider, int newStateId) async {
    // Demander confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le changement d\'état'),
        content: Text(
          'Voulez-vous changer l\'état de la commande ${widget.order.reference} ?\n\n'
          'Un email de notification sera envoyé au client.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.updateOrderState(
        widget.order.id!,
        newStateId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'État de la commande mis à jour'
                  : 'Erreur lors de la mise à jour',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  void _exportOrder() {
    // TODO: Implémenter l'export de la commande (PDF, CSV, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité d\'export à implémenter')),
    );
  }
}
