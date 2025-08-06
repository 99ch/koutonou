import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shipping_provider.dart';
import '../models/zone_model.dart';

class ZonesPage extends StatefulWidget {
  const ZonesPage({super.key});

  @override
  State<ZonesPage> createState() => _ZonesPageState();
}

class _ZonesPageState extends State<ZonesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShippingProvider>().loadZones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zones de livraison'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ShippingProvider>().loadZones(),
          ),
        ],
      ),
      body: Consumer<ShippingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingZones) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.zonesError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erreur: ${provider.zonesError}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadZones(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (provider.zones.isEmpty) {
            return const Center(child: Text('Aucune zone trouvée'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.zones.length,
            itemBuilder: (context, index) {
              final zone = provider.zones[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(zone.name),
                  subtitle: Text('Actif: ${zone.active ? "Oui" : "Non"}'),
                  onTap: () => _showZoneDetails(context, zone),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddZoneDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showZoneDetails(BuildContext context, Zone zone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(zone.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${zone.id}'),
            Text('Nom: ${zone.name}'),
            Text('Actif: ${zone.active ? "Oui" : "Non"}'),
          ],
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

  void _showAddZoneDialog(BuildContext context) {
    final nameController = TextEditingController();
    bool active = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une zone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nom de la zone'),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) => CheckboxListTile(
                title: const Text('Active'),
                value: active,
                onChanged: (value) => setState(() => active = value ?? true),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final zone = Zone(
                  id: 0, // L'API assignera un ID
                  name: nameController.text.trim(),
                  active: active,
                );
                context.read<ShippingProvider>().createZone(zone);
                Navigator.pop(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
