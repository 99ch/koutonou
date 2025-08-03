// MVP Frontend Demo - Consommation des 3 ressources PrestaShop
// Démontre la faisabilité pour toutes les autres ressources
// Phase 1 MVP - Proof of Concept complet

import 'package:flutter/material.dart';
import 'package:koutonou/modules/configs/services/languageservice.dart';
import 'package:koutonou/modules/configs/services/currencyservice.dart';
import 'package:koutonou/modules/configs/services/countryservice.dart';
import 'package:koutonou/modules/configs/models/languagemodel.dart';
import 'package:koutonou/modules/configs/models/currencymodel.dart';
import 'package:koutonou/modules/configs/models/countrymodel.dart';
import 'package:koutonou/core/utils/logger.dart';
import 'package:koutonou/ecommerce_simulation.dart';

/// Page de démonstration MVP Frontend
/// Prouve la faisabilité de consommation API PrestaShop
class MvpFrontendDemo extends StatefulWidget {
  const MvpFrontendDemo({super.key});

  @override
  State<MvpFrontendDemo> createState() => _MvpFrontendDemoState();
}

class _MvpFrontendDemoState extends State<MvpFrontendDemo> {
  final AppLogger _logger = AppLogger();
  
  // Services
  final _languageService = LanguageService();
  final _currencyService = CurrencyService();
  final _countryService = CountryService();
  
  // États des données
  List<LanguageModel> _languages = [];
  List<CurrencyModel> _currencies = [];
  List<CountryModel> _countries = [];
  
  // États UI
  bool _isLoading = false;
  String? _error;
  
  // Sélections utilisateur
  LanguageModel? _selectedLanguage;
  CurrencyModel? _selectedCurrency;
  CountryModel? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  /// Charge toutes les données des 3 ressources
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _logger.info('🚀 Début chargement MVP Frontend Demo');
      
      // Chargement parallèle des 3 ressources
      final results = await Future.wait([
        _languageService.getAll(),
        _currencyService.getAll(),
        _countryService.getAll(),
      ]);

      setState(() {
        _languages = results[0] as List<LanguageModel>;
        _currencies = results[1] as List<CurrencyModel>;
        _countries = results[2] as List<CountryModel>;
        
        // Sélections par défaut
        _selectedLanguage = _languages.isNotEmpty ? _languages.first : null;
        _selectedCurrency = _currencies.isNotEmpty ? _currencies.first : null;
        _selectedCountry = _countries.where((c) => c.active == 1).firstOrNull ?? 
                           (_countries.isNotEmpty ? _countries.first : null);
        
        _isLoading = false;
      });
      
      _logger.info('✅ MVP Demo chargé: ${_languages.length} langues, ${_currencies.length} devises, ${_countries.length} pays');
      
    } catch (e, stackTrace) {
      _logger.error('❌ Erreur chargement MVP Demo', e, stackTrace);
      setState(() {
        _error = 'Erreur de chargement: $e';
        _isLoading = false;
      });
    }
  }

  /// Simule un scénario e-commerce complet
  Future<void> _simulateEcommerceScenario() async {
    if (_selectedLanguage == null || _selectedCurrency == null || _selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner tous les paramètres')),
      );
      return;
    }

    _logger.info('🛒 Simulation scénario e-commerce');
    _logger.info('📍 Langue: ${_selectedLanguage!.name}');
    _logger.info('💰 Devise: ${_selectedCurrency!.name} (${_selectedCurrency!.symbol})');
    _logger.info('🌍 Pays: ${_selectedCountry!.name}');

    // Simulation des prochaines étapes
    final nextSteps = [
      '1. Récupération catalogue produits (API products)',
      '2. Affichage prix en ${_selectedCurrency!.symbol}',
      '3. Filtrage par pays de livraison',
      '4. Interface en ${_selectedLanguage!.name}',
      '5. Création compte client (API customers)',
      '6. Gestion panier (API carts)',
      '7. Processus commande (API orders)',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚀 Scénario E-commerce Simulé'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configuration actuelle:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('🌐 ${_selectedLanguage!.name}'),
            Text('💰 ${_selectedCurrency!.name} (${_selectedCurrency!.symbol})'),
            Text('📍 ${_selectedCountry!.name}'),
            const SizedBox(height: 16),
            Text('Prochaines étapes faisables:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...nextSteps.map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(step, style: const TextStyle(fontSize: 12)),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Compris !'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EcommerceSimulation(
                    language: _selectedLanguage!,
                    currency: _selectedCurrency!,
                    country: _selectedCountry!,
                  ),
                ),
              );
            },
            child: const Text('Voir Simulation'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MVP Frontend Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? _buildErrorWidget()
          : _buildMainContent(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedLanguage != null && _selectedCurrency != null && _selectedCountry != null)
            FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EcommerceSimulation(
                      language: _selectedLanguage!,
                      currency: _selectedCurrency!,
                      country: _selectedCountry!,
                    ),
                  ),
                );
              },
              heroTag: 'simulation',
              child: const Icon(Icons.play_arrow),
              backgroundColor: Colors.purple,
            ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            onPressed: _simulateEcommerceScenario,
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Simuler E-commerce'),
            backgroundColor: Colors.green,
            heroTag: 'scenario',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAllData,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsCard(),
          const SizedBox(height: 16),
          _buildLanguageSection(),
          const SizedBox(height: 16),
          _buildCurrencySection(),
          const SizedBox(height: 16),
          _buildCountrySection(),
          const SizedBox(height: 16),
          _buildFeasibilitySection(),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 Statistiques MVP', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('🌐', '${_languages.length}', 'Langues'),
                _buildStatItem('💰', '${_currencies.length}', 'Devises'),
                _buildStatItem('🌍', '${_countries.length}', 'Pays'),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'API PrestaShop 100% fonctionnelle !',
                      style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🌐 Langues', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_languages.isEmpty)
              const Text('Aucune langue disponible')
            else
              DropdownButtonFormField<LanguageModel>(
                value: _selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Sélectionner une langue',
                  border: OutlineInputBorder(),
                ),
                items: _languages.map((lang) => DropdownMenuItem(
                  value: lang,
                  child: Text('${lang.name} (${lang.iso_code})'),
                )).toList(),
                onChanged: (value) => setState(() => _selectedLanguage = value),
              ),
            if (_selectedLanguage != null) ...[
              const SizedBox(height: 8),
              Text('Détails: ${_selectedLanguage!.locale} - ${_selectedLanguage!.date_format_lite}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💰 Devises', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_currencies.isEmpty)
              const Text('Aucune devise disponible')
            else
              DropdownButtonFormField<CurrencyModel>(
                value: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Sélectionner une devise',
                  border: OutlineInputBorder(),
                ),
                items: _currencies.map((currency) => DropdownMenuItem(
                  value: currency,
                  child: Text('${currency.name} (${currency.symbol}) - ${currency.iso_code}'),
                )).toList(),
                onChanged: (value) => setState(() => _selectedCurrency = value),
              ),
            if (_selectedCurrency != null) ...[
              const SizedBox(height: 8),
              Text('Taux: ${_selectedCurrency!.conversion_rate} - Précision: ${_selectedCurrency!.precision}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySection() {
    final activeCountries = _countries.where((c) => c.active == 1).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('🌍 Pays', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Chip(
                  label: Text('${activeCountries.length} actifs'),
                  backgroundColor: Colors.green.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_countries.isEmpty)
              const Text('Aucun pays disponible')
            else
              DropdownButtonFormField<CountryModel>(
                value: _selectedCountry,
                decoration: const InputDecoration(
                  labelText: 'Sélectionner un pays',
                  border: OutlineInputBorder(),
                ),
                items: _countries.map((country) => DropdownMenuItem(
                  value: country,
                  child: Row(
                    children: [
                      Text(country.name ?? 'Inconnu'),
                      if (country.active == 1) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      ],
                    ],
                  ),
                )).toList(),
                onChanged: (value) => setState(() => _selectedCountry = value),
              ),
            if (_selectedCountry != null) ...[
              const SizedBox(height: 8),
              Text('Code: ${_selectedCountry!.iso_code} - Préfixe: +${_selectedCountry!.call_prefix}'),
              if (_selectedCountry!.zip_code_format?.isNotEmpty == true)
                Text('Format CP: ${_selectedCountry!.zip_code_format}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeasibilitySection() {
    return Card(
      color: Colors.blue.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🚀 Faisabilité Démontrée', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildFeasibilityItem('✅', 'API PrestaShop accessible', 'Toutes les requêtes réussissent'),
            _buildFeasibilityItem('✅', 'Données complètes récupérées', 'Format JSON avec tous les champs'),
            _buildFeasibilityItem('✅', 'Cache intelligent', 'Performance optimisée'),
            _buildFeasibilityItem('✅', 'Gestion d\'erreurs', 'Robuste et gracieuse'),
            _buildFeasibilityItem('✅', 'UI responsive', 'Interface utilisateur fluide'),
            const Divider(),
            Text('📋 Prochaines ressources utilisables:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            const Text('• Products (catalogue)', style: TextStyle(fontSize: 12)),
            const Text('• Customers (comptes)', style: TextStyle(fontSize: 12)),
            const Text('• Categories (navigation)', style: TextStyle(fontSize: 12)),
            const Text('• Orders (commandes)', style: TextStyle(fontSize: 12)),
            const Text('• Carts (paniers)', style: TextStyle(fontSize: 12)),
            const Text('• + 20+ autres ressources...', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeasibilityItem(String icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
