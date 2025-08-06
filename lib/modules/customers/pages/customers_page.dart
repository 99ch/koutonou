import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../widgets/customer_card.dart';

/// Page principale pour la gestion des clients
class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
      context.read<CustomerProvider>().loadGroups();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateCustomerDialog(),
            tooltip: 'Ajouter un client',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CustomerProvider>().loadCustomers(),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          _buildSearchAndFilters(),

          // Liste des clients
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingCustomers) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.customersError != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur lors du chargement',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.customersError!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            provider.clearError();
                            provider.loadCustomers();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final customers = _getFilteredCustomers(provider);

                if (customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun client trouvé',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Commencez par ajouter votre premier client',
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return CustomerCard(
                      customer: customer,
                      onTap: () => _showCustomerDetails(customer),
                      onEdit: () => _showEditCustomerDialog(customer),
                      onDelete: () => _showDeleteConfirmation(customer),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher par nom ou email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<CustomerProvider>().loadCustomers();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                context.read<CustomerProvider>().searchCustomers(value);
              } else {
                context.read<CustomerProvider>().loadCustomers();
              }
            },
          ),
          const SizedBox(height: 12),

          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'Tous', Icons.people),
                _buildFilterChip('active', 'Actifs', Icons.check_circle),
                _buildFilterChip('inactive', 'Inactifs', Icons.cancel),
                _buildFilterChip('newsletter', 'Newsletter', Icons.email),
                _buildFilterChip('business', 'Entreprises', Icons.business),
                _buildFilterChip('guest', 'Invités', Icons.person_outline),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label, IconData icon) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(icon, size: 16),
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? filter : 'all';
          });
        },
      ),
    );
  }

  List<dynamic> _getFilteredCustomers(CustomerProvider provider) {
    switch (_selectedFilter) {
      case 'active':
        return provider.activeCustomers;
      case 'inactive':
        return provider.inactiveCustomers;
      case 'newsletter':
        return provider.newsletterSubscribers;
      case 'business':
        return provider.businessCustomers;
      case 'guest':
        return provider.guestAccounts;
      default:
        return provider.customers;
    }
  }

  void _showCreateCustomerDialog() {
    // TODO: Implémenter le dialogue de création
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Création de client à implémenter')),
    );
  }

  void _showEditCustomerDialog(customer) {
    // TODO: Implémenter le dialogue d'édition
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Édition de ${customer.fullName} à implémenter')),
    );
  }

  void _showCustomerDetails(customer) {
    // TODO: Implémenter la page de détails
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Détails de ${customer.fullName} à implémenter')),
    );
  }

  void _showDeleteConfirmation(customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le client'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${customer.fullName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<CustomerProvider>().deleteCustomer(
                  customer.id!,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${customer.fullName} supprimé')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
