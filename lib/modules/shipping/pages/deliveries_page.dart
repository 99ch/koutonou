import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shipping_provider.dart';
import '../models/delivery_model.dart';

class DeliveriesPage extends StatefulWidget {
  const DeliveriesPage({Key? key}) : super(key: key);

  @override
  State<DeliveriesPage> createState() => _DeliveriesPageState();
}

class _DeliveriesPageState extends State<DeliveriesPage> {
  String _searchQuery = '';
  int? _filterCarrierId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShippingProvider>().loadDeliveries();
      context.read<ShippingProvider>().loadCarriers();
      context.read<ShippingProvider>().loadZones();
      context.read<ShippingProvider>().loadPriceRanges();
      context.read<ShippingProvider>().loadWeightRanges();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Livraisons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_searchQuery.isNotEmpty || _filterCarrierId != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                children: [
                  if (_searchQuery.isNotEmpty) ...[
                    Chip(
                      label: Text('Recherche: $_searchQuery'),
                      onDeleted: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (_filterCarrierId != null) ...[
                    Chip(
                      label: Text('Transporteur: $_filterCarrierId'),
                      onDeleted: () {
                        setState(() {
                          _filterCarrierId = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _filterCarrierId = null;
                      });
                    },
                    child: const Text('Effacer tout'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Consumer<ShippingProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingDeliveries) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.deliveriesError != null) {
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
                          provider.deliveriesError!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadDeliveries(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredDeliveries = _filterDeliveries(
                  provider.deliveries,
                );

                if (filteredDeliveries.isEmpty) {
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
                          _searchQuery.isNotEmpty
                              ? 'Aucune livraison trouvée'
                              : 'Aucune configuration de livraison',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddDeliveryDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter une livraison'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadDeliveries(),
                  child: ListView.builder(
                    itemCount: filteredDeliveries.length,
                    itemBuilder: (context, index) {
                      final delivery = filteredDeliveries[index];
                      final carrier = provider.carriers
                          .cast<dynamic>()
                          .firstWhere(
                            (c) => c.id == delivery.idCarrier,
                            orElse: () => null,
                          );
                      final zone = provider.zones.cast<dynamic>().firstWhere(
                        (z) => z.id == delivery.idZone,
                        orElse: () => null,
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              delivery.id?.toString() ?? '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            carrier?.name ??
                                'Transporteur ${delivery.idCarrier}',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Zone: ${zone?.name ?? delivery.idZone}'),
                              Text(
                                'Prix: ${delivery.price.toStringAsFixed(2)} €',
                              ),
                              Text(
                                'Gamme prix: ${delivery.idRangePrice} | Gamme poids: ${delivery.idRangeWeight}',
                              ),
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
                                  _showEditDeliveryDialog(context, delivery);
                                  break;
                                case 'delete':
                                  _showDeleteDeliveryDialog(context, delivery);
                                  break;
                              }
                            },
                          ),
                          onTap: () =>
                              _showDeliveryDetails(context, delivery, provider),
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
        onPressed: () => _showAddDeliveryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Delivery> _filterDeliveries(List<Delivery> deliveries) {
    return deliveries.where((delivery) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          delivery.price.toString().contains(_searchQuery) ||
          delivery.id.toString().contains(_searchQuery);

      final matchesFilter =
          _filterCarrierId == null || delivery.idCarrier == _filterCarrierId;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Entrez votre recherche...',
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final provider = context.read<ShippingProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer par transporteur'),
        content: DropdownButton<int?>(
          value: _filterCarrierId,
          isExpanded: true,
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Tous les transporteurs'),
            ),
            ...provider.carriers.map(
              (carrier) => DropdownMenuItem<int?>(
                value: carrier.id,
                child: Text(carrier.name),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _filterCarrierId = value;
            });
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showAddDeliveryDialog(BuildContext context) {
    final provider = context.read<ShippingProvider>();

    showDialog(
      context: context,
      builder: (context) => DeliveryFormDialog(
        provider: provider,
        onSave: (deliveryData) async {
          final success = await provider.createDelivery(deliveryData);
          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Configuration de livraison créée avec succès'),
              ),
            );
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  provider.deliveriesError ?? 'Erreur lors de la création',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditDeliveryDialog(BuildContext context, Delivery delivery) {
    final provider = context.read<ShippingProvider>();

    showDialog(
      context: context,
      builder: (context) => DeliveryFormDialog(
        provider: provider,
        delivery: delivery,
        onSave: (deliveryData) async {
          final success = await provider.updateDelivery(
            delivery.id!,
            deliveryData,
          );
          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Configuration de livraison mise à jour avec succès',
                ),
              ),
            );
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  provider.deliveriesError ?? 'Erreur lors de la mise à jour',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteDeliveryDialog(BuildContext context, Delivery delivery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer cette configuration de livraison (ID: ${delivery.id}) ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final provider = context.read<ShippingProvider>();
              final success = await provider.deleteDelivery(delivery.id!);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configuration supprimée avec succès'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.deliveriesError ??
                            'Erreur lors de la suppression',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeliveryDetails(
    BuildContext context,
    Delivery delivery,
    ShippingProvider provider,
  ) {
    final carrier = provider.carriers.cast<dynamic>().firstWhere(
      (c) => c.id == delivery.idCarrier,
      orElse: () => null,
    );
    final zone = provider.zones.cast<dynamic>().firstWhere(
      (z) => z.id == delivery.idZone,
      orElse: () => null,
    );

    showModalBottomSheet(
      context: context,
      builder: (context) => DeliveryDetailsSheet(
        delivery: delivery,
        carrierName: carrier?.name ?? 'Transporteur ${delivery.idCarrier}',
        zoneName: zone?.name ?? 'Zone ${delivery.idZone}',
      ),
    );
  }
}

class DeliveryFormDialog extends StatefulWidget {
  final ShippingProvider provider;
  final Delivery? delivery;
  final Function(Map<String, dynamic>) onSave;

  const DeliveryFormDialog({
    Key? key,
    required this.provider,
    this.delivery,
    required this.onSave,
  }) : super(key: key);

  @override
  State<DeliveryFormDialog> createState() => _DeliveryFormDialogState();
}

class _DeliveryFormDialogState extends State<DeliveryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _priceController;
  int? _selectedCarrierId;
  int? _selectedZoneId;
  int? _selectedPriceRangeId;
  int? _selectedWeightRangeId;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.delivery?.price.toString() ?? '',
    );
    _selectedCarrierId = widget.delivery?.idCarrier;
    _selectedZoneId = widget.delivery?.idZone;
    _selectedPriceRangeId = widget.delivery?.idRangePrice;
    _selectedWeightRangeId = widget.delivery?.idRangeWeight;
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.delivery == null
            ? 'Nouvelle configuration'
            : 'Modifier la configuration',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: _selectedCarrierId,
                  decoration: const InputDecoration(
                    labelText: 'Transporteur',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.provider.carriers
                      .map(
                        (carrier) => DropdownMenuItem(
                          value: carrier.id,
                          child: Text(carrier.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCarrierId = value),
                  validator: (value) => value == null
                      ? 'Veuillez sélectionner un transporteur'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedZoneId,
                  decoration: const InputDecoration(
                    labelText: 'Zone',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.provider.zones
                      .map(
                        (zone) => DropdownMenuItem(
                          value: zone.id,
                          child: Text(zone.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedZoneId = value),
                  validator: (value) =>
                      value == null ? 'Veuillez sélectionner une zone' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedPriceRangeId,
                  decoration: const InputDecoration(
                    labelText: 'Gamme de prix',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.provider.priceRanges
                      .map(
                        (range) => DropdownMenuItem(
                          value: range.id,
                          child: Text(
                            'De ${range.delimiter1} à ${range.delimiter2}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedPriceRangeId = value),
                  validator: (value) => value == null
                      ? 'Veuillez sélectionner une gamme de prix'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedWeightRangeId,
                  decoration: const InputDecoration(
                    labelText: 'Gamme de poids',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.provider.weightRanges
                      .map(
                        (range) => DropdownMenuItem(
                          value: range.id,
                          child: Text(
                            'De ${range.delimiter1} à ${range.delimiter2} kg',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedWeightRangeId = value),
                  validator: (value) => value == null
                      ? 'Veuillez sélectionner une gamme de poids'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix de livraison',
                    suffixText: '€',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir un prix';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez saisir un prix valide';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave({
                'id_carrier': _selectedCarrierId,
                'id_zone': _selectedZoneId,
                'id_range_price': _selectedPriceRangeId,
                'id_range_weight': _selectedWeightRangeId,
                'price': double.parse(_priceController.text),
              });
            }
          },
          child: Text(widget.delivery == null ? 'Créer' : 'Modifier'),
        ),
      ],
    );
  }
}

class DeliveryDetailsSheet extends StatelessWidget {
  final Delivery delivery;
  final String carrierName;
  final String zoneName;

  const DeliveryDetailsSheet({
    Key? key,
    required this.delivery,
    required this.carrierName,
    required this.zoneName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Détails de la configuration',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildDetailRow('ID', delivery.id?.toString() ?? 'N/A'),
          _buildDetailRow('Transporteur', carrierName),
          _buildDetailRow('Zone', zoneName),
          _buildDetailRow('Prix', '${delivery.price.toStringAsFixed(2)} €'),
          _buildDetailRow('Gamme de prix', delivery.idRangePrice.toString()),
          _buildDetailRow('Gamme de poids', delivery.idRangeWeight.toString()),
          if (delivery.idShop != null)
            _buildDetailRow('Boutique', delivery.idShop.toString()),
          if (delivery.idShopGroup != null)
            _buildDetailRow(
              'Groupe de boutiques',
              delivery.idShopGroup.toString(),
            ),
        ],
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
            width: 120,
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
