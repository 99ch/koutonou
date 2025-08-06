import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shipping_provider.dart';
import '../models/price_range_model.dart';
import '../models/weight_range_model.dart';

class RangesPage extends StatefulWidget {
  const RangesPage({super.key});

  @override
  State<RangesPage> createState() => _RangesPageState();
}

class _RangesPageState extends State<RangesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ShippingProvider>();
      provider.loadPriceRanges();
      provider.loadWeightRanges();
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
        title: const Text('Tranches de livraison'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Prix'),
            Tab(text: 'Poids'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPriceRangesTab(), _buildWeightRangesTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRangeDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPriceRangesTab() {
    return Consumer<ShippingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingPriceRanges) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.priceRangesError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Erreur: ${provider.priceRangesError}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadPriceRanges(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (provider.priceRanges.isEmpty) {
          return const Center(child: Text('Aucune tranche de prix trouvée'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.priceRanges.length,
          itemBuilder: (context, index) {
            final range = provider.priceRanges[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('${range.delimiter1} - ${range.delimiter2}'),
                subtitle: Text('Transporteur: ${range.idCarrier}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deletePriceRange(range),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWeightRangesTab() {
    return Consumer<ShippingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingWeightRanges) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.weightRangesError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Erreur: ${provider.weightRangesError}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadWeightRanges(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (provider.weightRanges.isEmpty) {
          return const Center(child: Text('Aucune tranche de poids trouvée'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.weightRanges.length,
          itemBuilder: (context, index) {
            final range = provider.weightRanges[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('${range.delimiter1}kg - ${range.delimiter2}kg'),
                subtitle: Text('Transporteur: ${range.idCarrier}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteWeightRange(range),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddRangeDialog() {
    final isPrice = _tabController.index == 0;
    showDialog(
      context: context,
      builder: (context) => _AddRangeDialog(isPriceRange: isPrice),
    );
  }

  void _deletePriceRange(PriceRange range) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la tranche'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette tranche de prix ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ShippingProvider>().deletePriceRange(range.id!);
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _deleteWeightRange(WeightRange range) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la tranche'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette tranche de poids ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ShippingProvider>().deleteWeightRange(range.id!);
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _AddRangeDialog extends StatefulWidget {
  final bool isPriceRange;

  const _AddRangeDialog({required this.isPriceRange});

  @override
  State<_AddRangeDialog> createState() => _AddRangeDialogState();
}

class _AddRangeDialogState extends State<_AddRangeDialog> {
  final _delimiter1Controller = TextEditingController();
  final _delimiter2Controller = TextEditingController();
  final _carrierController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isPriceRange
            ? 'Ajouter une tranche de prix'
            : 'Ajouter une tranche de poids',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _delimiter1Controller,
            decoration: InputDecoration(
              labelText: widget.isPriceRange
                  ? 'Prix minimum (€)'
                  : 'Poids minimum (kg)',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _delimiter2Controller,
            decoration: InputDecoration(
              labelText: widget.isPriceRange
                  ? 'Prix maximum (€)'
                  : 'Poids maximum (kg)',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _carrierController,
            decoration: const InputDecoration(labelText: 'ID du transporteur'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(onPressed: _addRange, child: const Text('Ajouter')),
      ],
    );
  }

  void _addRange() {
    final delimiter1 = double.tryParse(_delimiter1Controller.text);
    final delimiter2 = double.tryParse(_delimiter2Controller.text);
    final carrierId = int.tryParse(_carrierController.text);

    if (delimiter1 == null || delimiter2 == null || carrierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez remplir tous les champs avec des valeurs valides',
          ),
        ),
      );
      return;
    }

    final provider = context.read<ShippingProvider>();

    if (widget.isPriceRange) {
      final range = PriceRange(
        id: 0,
        idCarrier: carrierId,
        delimiter1: delimiter1,
        delimiter2: delimiter2,
      );
      provider.createPriceRange(range);
    } else {
      final range = WeightRange(
        id: 0,
        idCarrier: carrierId,
        delimiter1: delimiter1,
        delimiter2: delimiter2,
      );
      provider.createWeightRange(range);
    }

    Navigator.pop(context);
  }
}
