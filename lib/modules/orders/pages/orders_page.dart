import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../widgets/order_card.dart';
import '../widgets/order_filters.dart';
import 'order_detail_page.dart';

/// Page principale pour la gestion des commandes
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeOrders();
    _setupScrollListener();
  }

  void _initializeOrders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OrderProvider>();
      provider.loadOrders(reset: true);
      provider.loadOrderStates();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // Charger plus de commandes quand on approche du bas
        context.read<OrderProvider>().loadMoreOrders();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<OrderProvider>().refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par référence...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<OrderProvider>().clearFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<OrderProvider>().searchOrders(value);
                } else {
                  context.read<OrderProvider>().clearFilters();
                }
              },
            ),
          ),

          // Filtres actifs
          Consumer<OrderProvider>(
            builder: (context, provider, child) {
              return _buildActiveFilters(provider);
            },
          ),

          // Liste des commandes
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.orders.isEmpty) {
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
                          onPressed: () => provider.refresh(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.orders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text('Aucune commande trouvée'),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.refresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        provider.orders.length + (provider.hasNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.orders.length) {
                        // Indicateur de chargement pour la pagination
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final order = provider.orders[index];
                      return OrderCard(
                        order: order,
                        onTap: () => _navigateToOrderDetail(order),
                        onStateChanged: (newStateId) =>
                            _updateOrderState(order, newStateId),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(OrderProvider provider) {
    final activeFilters = <Widget>[];

    if (provider.searchQuery != null && provider.searchQuery!.isNotEmpty) {
      activeFilters.add(
        Chip(
          label: Text('Recherche: ${provider.searchQuery}'),
          onDeleted: () {
            _searchController.clear();
            provider.clearFilters();
          },
        ),
      );
    }

    if (provider.stateFilter != null) {
      final state = provider.getOrderStateById(provider.stateFilter!);
      activeFilters.add(
        Chip(
          label: Text('État: ${state?.name ?? provider.stateFilter}'),
          onDeleted: () => provider.filterByState(null),
        ),
      );
    }

    if (provider.customerFilter != null) {
      activeFilters.add(
        Chip(
          label: Text('Client: ${provider.customerFilter}'),
          onDeleted: () => provider.filterByCustomer(null),
        ),
      );
    }

    if (provider.startDateFilter != null || provider.endDateFilter != null) {
      String dateText = 'Période: ';
      if (provider.startDateFilter != null) {
        dateText += '${_formatDate(provider.startDateFilter!)} - ';
      }
      if (provider.endDateFilter != null) {
        dateText += _formatDate(provider.endDateFilter!);
      }

      activeFilters.add(
        Chip(
          label: Text(dateText),
          onDeleted: () => provider.filterByDateRange(null, null),
        ),
      );
    }

    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          ...activeFilters,
          if (activeFilters.length > 1)
            TextButton(
              onPressed: () {
                _searchController.clear();
                provider.clearFilters();
              },
              child: const Text('Effacer tout'),
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

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => OrderFilters(
        onApplyFilters: (filters) {
          final provider = context.read<OrderProvider>();

          if (filters['state'] != null) {
            provider.filterByState(filters['state'] as int);
          }

          if (filters['customer'] != null) {
            provider.filterByCustomer(filters['customer'] as int);
          }

          if (filters['startDate'] != null && filters['endDate'] != null) {
            provider.filterByDateRange(
              filters['startDate'] as DateTime,
              filters['endDate'] as DateTime,
            );
          }
        },
      ),
    );
  }

  void _navigateToOrderDetail(order) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => OrderDetailPage(order: order)),
    );
  }

  void _updateOrderState(order, int newStateId) async {
    final provider = context.read<OrderProvider>();

    // Demander confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le changement d\'état'),
        content: Text(
          'Voulez-vous changer l\'état de la commande ${order.reference} ?',
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
      final success = await provider.updateOrderState(order.id!, newStateId);

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
}
