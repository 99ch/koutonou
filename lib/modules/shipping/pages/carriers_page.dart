import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shipping_provider.dart';
import '../models/carrier_model.dart';

class CarriersPage extends StatefulWidget {
  const CarriersPage({Key? key}) : super(key: key);

  @override
  State<CarriersPage> createState() => _CarriersPageState();
}

class _CarriersPageState extends State<CarriersPage> {
  String _searchQuery = '';
  bool _showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShippingProvider>().loadCarriers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transporteurs'),
        actions: [
          IconButton(
            icon: Icon(
              _showActiveOnly ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _showActiveOnly = !_showActiveOnly;
              });
            },
            tooltip: _showActiveOnly ? 'Afficher tous' : 'Actifs uniquement',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un transporteur...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Carriers list
          Expanded(
            child: Consumer<ShippingProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingCarriers && provider.carriers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.carriersError != null &&
                    provider.carriers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.carriersError!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadCarriers(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredCarriers = _filterCarriers(provider.carriers);

                if (filteredCarriers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _showActiveOnly
                              ? 'Aucun transporteur trouvé'
                              : 'Aucun transporteur configuré',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddCarrierDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter un transporteur'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadCarriers(),
                  child: ListView.builder(
                    itemCount: filteredCarriers.length,
                    itemBuilder: (context, index) {
                      final carrier = filteredCarriers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: carrier.active
                                ? Colors.green
                                : Colors.grey,
                            child: const Icon(
                              Icons.local_shipping,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(carrier.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Position: ${carrier.position ?? "Non définie"}',
                              ),
                              if (carrier.delay.isNotEmpty)
                                Text('Délai: ${carrier.delay}'),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Modifier'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete),
                                    SizedBox(width: 8),
                                    Text('Supprimer'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  _showEditCarrierDialog(context, carrier);
                                  break;
                                case 'delete':
                                  _showDeleteCarrierDialog(context, carrier);
                                  break;
                              }
                            },
                          ),
                          onTap: () => _showCarrierDetails(context, carrier),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCarrierDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Carrier> _filterCarriers(List<Carrier> carriers) {
    return carriers.where((carrier) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          carrier.name.toLowerCase().contains(_searchQuery) ||
          carrier.id.toString().contains(_searchQuery);

      final matchesActiveFilter = !_showActiveOnly || carrier.active;

      return matchesSearch && matchesActiveFilter;
    }).toList();
  }

  void _showAddCarrierDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité à implémenter')),
    );
  }

  void _showEditCarrierDialog(BuildContext context, Carrier carrier) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité à implémenter')),
    );
  }

  void _showDeleteCarrierDialog(BuildContext context, Carrier carrier) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité à implémenter')),
    );
  }

  void _showCarrierDetails(BuildContext context, Carrier carrier) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Détails du transporteur',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('ID', carrier.id?.toString() ?? 'N/A'),
            _buildDetailRow('Nom', carrier.name),
            _buildDetailRow('Status', carrier.active ? 'Actif' : 'Inactif'),
            _buildDetailRow('Position', carrier.position?.toString() ?? 'N/A'),
            if (carrier.delay.isNotEmpty)
              _buildDetailRow('Délai', carrier.getDelayForLanguage('1')),
            if (carrier.hasUrl) _buildDetailRow('URL', carrier.url ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
