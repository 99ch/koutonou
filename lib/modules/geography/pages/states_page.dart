import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/geography_provider.dart';
import '../models/state_model.dart' as geo_models;
import '../widgets/state_card.dart';
import '../widgets/geography_form_fields.dart';

class StatesPage extends StatefulWidget {
  final int? countryId;

  const StatesPage({super.key, this.countryId});

  @override
  State<StatesPage> createState() => _StatesPageState();
}

class _StatesPageState extends State<StatesPage> {
  String _searchQuery = '';
  bool _showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.countryId != null) {
        context.read<GeographyProvider>().loadStatesByCountry(
          widget.countryId!,
        );
      } else {
        context.read<GeographyProvider>().loadStates();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.countryId != null
              ? 'États/Provinces'
              : 'Tous les États/Provinces',
        ),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (widget.countryId != null) {
                context.read<GeographyProvider>().loadStatesByCountry(
                  widget.countryId!,
                );
              } else {
                context.read<GeographyProvider>().loadStates(
                  forceRefresh: true,
                );
              }
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
                hintText: 'Rechercher un état/province...',
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

          // States list
          Expanded(
            child: Consumer<GeographyProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingStates && provider.states.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.statesError != null && provider.states.isEmpty) {
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
                          provider.statesError!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (widget.countryId != null) {
                              provider.loadStatesByCountry(widget.countryId!);
                            } else {
                              provider.loadStates(forceRefresh: true);
                            }
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredStates = _filterStates(provider.states);

                if (filteredStates.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_city,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _showActiveOnly
                              ? 'Aucun état/province trouvé'
                              : 'Aucun état/province configuré',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddStateDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter un état/province'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (widget.countryId != null) {
                      await provider.loadStatesByCountry(widget.countryId!);
                    } else {
                      await provider.loadStates(forceRefresh: true);
                    }
                  },
                  child: ListView.builder(
                    itemCount: filteredStates.length,
                    itemBuilder: (context, index) {
                      final state = filteredStates[index];
                      final country = provider.getCountryById(state.idCountry);
                      return StateCard(
                        state: state,
                        countryName: country?.displayName,
                        onTap: () => _showStateDetails(context, state),
                        onEdit: () => _showEditStateDialog(context, state),
                        onDelete: () => _showDeleteStateDialog(context, state),
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
        onPressed: () => _showAddStateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<geo_models.State> _filterStates(List<geo_models.State> states) {
    return states.where((state) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          state.displayName.toLowerCase().contains(_searchQuery) ||
          state.isoCode.toLowerCase().contains(_searchQuery);

      final matchesActiveFilter = !_showActiveOnly || state.isActive;

      return matchesSearch && matchesActiveFilter;
    }).toList();
  }

  void _showStateDetails(BuildContext context, geo_models.State state) {
    final provider = context.read<GeographyProvider>();
    final country = provider.getCountryById(state.idCountry);

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
              'Détails de l\'état/province',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('ID', state.id?.toString() ?? 'N/A'),
            _buildDetailRow('Nom', state.displayName),
            _buildDetailRow('Code ISO', state.isoCode),
            _buildDetailRow(
              'Pays',
              country?.displayName ?? 'ID: ${state.idCountry}',
            ),
            _buildDetailRow('Zone ID', state.idZone.toString()),
            _buildDetailRow('Statut', state.isActive ? 'Actif' : 'Inactif'),
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

  void _showAddStateDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddEditStatePage(defaultCountryId: widget.countryId),
      ),
    );
  }

  void _showEditStateDialog(BuildContext context, geo_models.State state) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddEditStatePage(state: state)),
    );
  }

  void _showDeleteStateDialog(BuildContext context, geo_models.State state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'état/province'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${state.displayName}" ?',
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
                  .deleteState(state.id!);
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

class AddEditStatePage extends StatefulWidget {
  final geo_models.State? state;
  final int? defaultCountryId;

  const AddEditStatePage({super.key, this.state, this.defaultCountryId});

  @override
  State<AddEditStatePage> createState() => _AddEditStatePageState();
}

class _AddEditStatePageState extends State<AddEditStatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _isoCodeController = TextEditingController();

  int? _selectedZoneId;
  int? _selectedCountryId;
  bool _active = true;

  bool get isEditing => widget.state != null;

  @override
  void initState() {
    super.initState();
    _selectedCountryId = widget.defaultCountryId;
    if (isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final state = widget.state!;
    _nameController.text = state.name;
    _isoCodeController.text = state.isoCode;
    _selectedZoneId = state.idZone;
    _selectedCountryId = state.idCountry;
    _active = state.active;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Modifier l\'état/province' : 'Ajouter un état/province',
        ),
        actions: [
          TextButton(onPressed: _saveState, child: const Text('Enregistrer')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GeographyFormFields.stateNameField(controller: _nameController),
              const SizedBox(height: 16),
              GeographyFormFields.isoCodeField(
                controller: _isoCodeController,
                maxLength: 7,
                hint: 'Ex: NY, CA, TX',
              ),
              const SizedBox(height: 16),
              // Zone selection (simplified)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Zone ID *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.public),
                ),
                keyboardType: TextInputType.number,
                initialValue: _selectedZoneId?.toString(),
                onSaved: (value) => _selectedZoneId = int.tryParse(value ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Zone ID requis';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Zone ID invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Country selection (simplified)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Pays ID *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                keyboardType: TextInputType.number,
                initialValue: _selectedCountryId?.toString(),
                onSaved: (value) =>
                    _selectedCountryId = int.tryParse(value ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pays ID requis';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Pays ID invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              GeographyFormFields.activeSwitch(
                value: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveState() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final state = geo_models.State(
      id: isEditing ? widget.state!.id : null,
      idZone: _selectedZoneId!,
      idCountry: _selectedCountryId!,
      isoCode: _isoCodeController.text,
      name: _nameController.text,
      active: _active,
    );

    final provider = context.read<GeographyProvider>();
    final success = isEditing
        ? await provider.updateState(state)
        : await provider.createState(state);

    if (success && context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'État/Province modifié avec succès'
                : 'État/Province créé avec succès',
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
    _isoCodeController.dispose();
    super.dispose();
  }
}
