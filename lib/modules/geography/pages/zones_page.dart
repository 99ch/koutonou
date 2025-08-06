import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/geography_provider.dart';
import '../models/geographic_zone_model.dart';
import '../widgets/geographic_zone_card.dart';
import '../widgets/geography_form_fields.dart';

class GeographicZonesPage extends StatefulWidget {
  const GeographicZonesPage({super.key});

  @override
  State<GeographicZonesPage> createState() => _GeographicZonesPageState();
}

class _GeographicZonesPageState extends State<GeographicZonesPage> {
  String _searchQuery = '';
  bool _showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GeographyProvider>().loadZones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zones Géographiques'),
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
            tooltip: _showActiveOnly ? 'Afficher toutes' : 'Actives uniquement',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GeographyProvider>().loadZones(forceRefresh: true);
            },
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
                hintText: 'Rechercher une zone géographique...',
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

          // Geographic zones list
          Expanded(
            child: Consumer<GeographyProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingZones && provider.zones.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.zonesError != null && provider.zones.isEmpty) {
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
                          provider.zonesError!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.loadZones(forceRefresh: true);
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredZones = _filterGeographicZones(provider.zones);

                if (filteredZones.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.public, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _showActiveOnly
                              ? 'Aucune zone géographique trouvée'
                              : 'Aucune zone géographique configurée',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddZoneDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter une zone géographique'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await provider.loadZones(forceRefresh: true);
                  },
                  child: ListView.builder(
                    itemCount: filteredZones.length,
                    itemBuilder: (context, index) {
                      final zone = filteredZones[index];
                      return GeographicZoneCard(
                        zone: zone,
                        onTap: () => _showZoneDetails(context, zone),
                        onEdit: () => _showEditZoneDialog(context, zone),
                        onDelete: () => _showDeleteZoneDialog(context, zone),
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
        onPressed: () => _showAddZoneDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<GeographicZone> _filterGeographicZones(List<GeographicZone> zones) {
    return zones.where((zone) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          zone.displayName.toLowerCase().contains(_searchQuery);

      final matchesActiveFilter = !_showActiveOnly || zone.isActive;

      return matchesSearch && matchesActiveFilter;
    }).toList();
  }

  void _showZoneDetails(BuildContext context, GeographicZone zone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Détails de la zone géographique',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('ID', zone.id?.toString() ?? 'N/A'),
            _buildDetailRow('Nom', zone.displayName),
            _buildDetailRow('Statut', zone.isActive ? 'Active' : 'Inactive'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showZoneCountries(context, zone);
              },
              icon: const Icon(Icons.flag),
              label: const Text('Voir les pays de cette zone'),
            ),
          ],
        ),
      ),
    );
  }

  void _showZoneCountries(BuildContext context, GeographicZone zone) {
    final provider = context.read<GeographyProvider>();

    // Filter countries that belong to this zone
    final zoneCountries = provider.countries
        .where((country) => country.idZone == zone.id)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pays dans "${zone.displayName}"'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: zoneCountries.isEmpty
              ? const Center(child: Text('Aucun pays dans cette zone'))
              : ListView.builder(
                  itemCount: zoneCountries.length,
                  itemBuilder: (context, index) {
                    final country = zoneCountries[index];
                    return ListTile(
                      leading: const Icon(Icons.flag),
                      title: Text(country.displayName),
                      subtitle: Text(country.isoCode),
                      trailing: Icon(
                        country.isActive ? Icons.check_circle : Icons.cancel,
                        color: country.isActive ? Colors.green : Colors.red,
                      ),
                    );
                  },
                ),
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

  void _showAddZoneDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditGeographicZonePage(),
      ),
    );
  }

  void _showEditZoneDialog(BuildContext context, GeographicZone zone) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditGeographicZonePage(zone: zone),
      ),
    );
  }

  void _showDeleteZoneDialog(BuildContext context, GeographicZone zone) {
    final provider = context.read<GeographyProvider>();

    // Check if zone has countries
    final hasCountries = provider.countries.any(
      (country) => country.idZone == zone.id,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la zone géographique'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir supprimer "${zone.displayName}" ?'),
            if (hasCountries) ...[
              const SizedBox(height: 8),
              Text(
                'Attention : Cette zone contient des pays. La suppression peut affecter ces pays.',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<GeographyProvider>()
                  .deleteZone(zone.id!);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur lors de la suppression'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class AddEditGeographicZonePage extends StatefulWidget {
  final GeographicZone? zone;

  const AddEditGeographicZonePage({super.key, this.zone});

  @override
  State<AddEditGeographicZonePage> createState() =>
      _AddEditGeographicZonePageState();
}

class _AddEditGeographicZonePageState extends State<AddEditGeographicZonePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _active = true;

  bool get isEditing => widget.zone != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final zone = widget.zone!;
    _nameController.text = zone.name;
    _active = zone.active;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Modifier la zone géographique'
              : 'Ajouter une zone géographique',
        ),
        actions: [
          TextButton(onPressed: _saveZone, child: const Text('Enregistrer')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GeographyFormFields.zoneNameField(controller: _nameController),
              const SizedBox(height: 24),
              GeographyFormFields.activeSwitch(
                value: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
              if (isEditing) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations supplémentaires',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('ID: ${widget.zone!.id}'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showZoneCountries(context),
                          icon: const Icon(Icons.flag),
                          label: const Text('Voir les pays de cette zone'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showZoneCountries(BuildContext context) {
    if (!isEditing) return;

    final provider = context.read<GeographyProvider>();
    final zoneCountries = provider.countries
        .where((country) => country.idZone == widget.zone!.id)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pays dans "${widget.zone!.displayName}"'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: zoneCountries.isEmpty
              ? const Center(child: Text('Aucun pays dans cette zone'))
              : ListView.builder(
                  itemCount: zoneCountries.length,
                  itemBuilder: (context, index) {
                    final country = zoneCountries[index];
                    return ListTile(
                      leading: const Icon(Icons.flag),
                      title: Text(country.displayName),
                      subtitle: Text(country.isoCode),
                      trailing: Icon(
                        country.isActive ? Icons.check_circle : Icons.cancel,
                        color: country.isActive ? Colors.green : Colors.red,
                      ),
                    );
                  },
                ),
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

  void _saveZone() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final zone = GeographicZone(
      id: isEditing ? widget.zone!.id : null,
      name: _nameController.text,
      active: _active,
    );

    final provider = context.read<GeographyProvider>();
    final success = isEditing
        ? await provider.updateZone(zone)
        : await provider.createZone(zone);

    if (success && context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Zone géographique modifiée avec succès'
                : 'Zone géographique créée avec succès',
          ),
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'enregistrement')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
