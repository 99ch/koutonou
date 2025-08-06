import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/geography_provider.dart';
import '../models/country_model.dart';
import '../widgets/country_card.dart';
import '../widgets/geography_form_fields.dart';

class CountriesPage extends StatefulWidget {
  const CountriesPage({super.key});

  @override
  State<CountriesPage> createState() => _CountriesPageState();
}

class _CountriesPageState extends State<CountriesPage> {
  String _searchQuery = '';
  bool _showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GeographyProvider>().loadCountries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pays'),
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
            onPressed: () => context.read<GeographyProvider>().loadCountries(
              forceRefresh: true,
            ),
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
                hintText: 'Rechercher un pays...',
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

          // Countries list
          Expanded(
            child: Consumer<GeographyProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingCountries && provider.countries.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.countriesError != null &&
                    provider.countries.isEmpty) {
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
                          provider.countriesError!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              provider.loadCountries(forceRefresh: true),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredCountries = _filterCountries(provider.countries);

                if (filteredCountries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flag, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _showActiveOnly
                              ? 'Aucun pays trouvé'
                              : 'Aucun pays configuré',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddCountryDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter un pays'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadCountries(forceRefresh: true),
                  child: ListView.builder(
                    itemCount: filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = filteredCountries[index];
                      return CountryCard(
                        country: country,
                        onTap: () => _showCountryDetails(context, country),
                        onEdit: () => _showEditCountryDialog(context, country),
                        onDelete: () =>
                            _showDeleteCountryDialog(context, country),
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
        onPressed: () => _showAddCountryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Country> _filterCountries(List<Country> countries) {
    return countries.where((country) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          country.displayName.toLowerCase().contains(_searchQuery) ||
          country.isoCode.toLowerCase().contains(_searchQuery);

      final matchesActiveFilter = !_showActiveOnly || country.isActive;

      return matchesSearch && matchesActiveFilter;
    }).toList();
  }

  void _showCountryDetails(BuildContext context, Country country) {
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
              'Détails du pays',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('ID', country.id?.toString() ?? 'N/A'),
            _buildDetailRow('Nom', country.displayName),
            _buildDetailRow('Code ISO', country.isoCode),
            _buildDetailRow('Zone ID', country.idZone.toString()),
            if (country.idCurrency != null)
              _buildDetailRow('Devise ID', country.idCurrency.toString()),
            if (country.callPrefix != null)
              _buildDetailRow('Préfixe tél.', country.callPrefix.toString()),
            _buildDetailRow('Statut', country.isActive ? 'Actif' : 'Inactif'),
            _buildDetailRow(
              'États/Provinces',
              country.containsStates ? 'Oui' : 'Non',
            ),
            _buildDetailRow(
              'ID requis',
              country.needIdentificationNumber ? 'Oui' : 'Non',
            ),
            if (country.needZipCode != null)
              _buildDetailRow(
                'Code postal requis',
                country.needZipCode! ? 'Oui' : 'Non',
              ),
            if (country.zipCodeFormat != null)
              _buildDetailRow('Format code postal', country.zipCodeFormat!),
            _buildDetailRow(
              'Affichage taxe',
              country.displayTaxLabel ? 'Oui' : 'Non',
            ),
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

  void _showAddCountryDialog(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddEditCountryPage()));
  }

  void _showEditCountryDialog(BuildContext context, Country country) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditCountryPage(country: country),
      ),
    );
  }

  void _showDeleteCountryDialog(BuildContext context, Country country) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le pays'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${country.displayName}" ?',
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
                  .deleteCountry(country.id!);
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

class AddEditCountryPage extends StatefulWidget {
  final Country? country;

  const AddEditCountryPage({super.key, this.country});

  @override
  State<AddEditCountryPage> createState() => _AddEditCountryPageState();
}

class _AddEditCountryPageState extends State<AddEditCountryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _isoCodeController = TextEditingController();
  final _callPrefixController = TextEditingController();
  final _zipCodeFormatController = TextEditingController();

  int? _selectedZoneId;
  int? _selectedCurrencyId;
  bool _active = true;
  bool _containsStates = false;
  bool _needIdentificationNumber = false;
  bool? _needZipCode;
  bool _displayTaxLabel = true;

  bool get isEditing => widget.country != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final country = widget.country!;
    _nameController.text = country.displayName;
    _isoCodeController.text = country.isoCode;
    _callPrefixController.text = country.callPrefix?.toString() ?? '';
    _zipCodeFormatController.text = country.zipCodeFormat ?? '';
    _selectedZoneId = country.idZone;
    _selectedCurrencyId = country.idCurrency;
    _active = country.active;
    _containsStates = country.containsStates;
    _needIdentificationNumber = country.needIdentificationNumber;
    _needZipCode = country.needZipCode;
    _displayTaxLabel = country.displayTaxLabel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le pays' : 'Ajouter un pays'),
        actions: [
          TextButton(onPressed: _saveCountry, child: const Text('Enregistrer')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GeographyFormFields.countryNameField(controller: _nameController),
              const SizedBox(height: 16),
              GeographyFormFields.isoCodeField(controller: _isoCodeController),
              const SizedBox(height: 16),
              // Zone selection (simplified for demo)
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
              GeographyFormFields.callPrefixField(
                controller: _callPrefixController,
              ),
              const SizedBox(height: 16),
              GeographyFormFields.zipCodeFormatField(
                controller: _zipCodeFormatController,
              ),
              const SizedBox(height: 24),
              GeographyFormFields.activeSwitch(
                value: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
              GeographyFormFields.containsStatesSwitch(
                value: _containsStates,
                onChanged: (value) => setState(() => _containsStates = value),
              ),
              GeographyFormFields.needIdentificationSwitch(
                value: _needIdentificationNumber,
                onChanged: (value) =>
                    setState(() => _needIdentificationNumber = value),
              ),
              SwitchListTile(
                title: const Text('Code postal requis'),
                subtitle: Text(
                  _needZipCode == null
                      ? 'Non défini'
                      : (_needZipCode! ? 'Requis' : 'Non requis'),
                ),
                value: _needZipCode ?? false,
                onChanged: (value) => setState(() => _needZipCode = value),
                secondary: Icon(
                  Icons.mail,
                  color: _needZipCode == true ? Colors.purple : Colors.grey,
                ),
              ),
              GeographyFormFields.displayTaxLabelSwitch(
                value: _displayTaxLabel,
                onChanged: (value) => setState(() => _displayTaxLabel = value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveCountry() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final country = Country(
      id: isEditing ? widget.country!.id : null,
      idZone: _selectedZoneId!,
      idCurrency: _selectedCurrencyId,
      callPrefix: _callPrefixController.text.isNotEmpty
          ? int.tryParse(_callPrefixController.text)
          : null,
      isoCode: _isoCodeController.text,
      active: _active,
      containsStates: _containsStates,
      needIdentificationNumber: _needIdentificationNumber,
      needZipCode: _needZipCode,
      zipCodeFormat: _zipCodeFormatController.text.isNotEmpty
          ? _zipCodeFormatController.text
          : null,
      displayTaxLabel: _displayTaxLabel,
      name: {'1': _nameController.text},
    );

    final provider = context.read<GeographyProvider>();
    final success = isEditing
        ? await provider.updateCountry(country)
        : await provider.createCountry(country);

    if (success && context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Pays modifié avec succès' : 'Pays créé avec succès',
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
    _callPrefixController.dispose();
    _zipCodeFormatController.dispose();
    super.dispose();
  }
}
