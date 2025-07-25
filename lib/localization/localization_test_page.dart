// Page de test pour valider le système de localisation
// Permet de tester les traductions, le changement de langue et les fonctionnalités de base

import 'package:flutter/material.dart';
import 'package:koutonou/localization/app_localizations.dart';
import 'package:koutonou/localization/localization_service.dart';
import 'package:koutonou/core/theme.dart';

class LocalizationTestPage extends StatefulWidget {
  const LocalizationTestPage({super.key});

  @override
  State<LocalizationTestPage> createState() => _LocalizationTestPageState();
}

class _LocalizationTestPageState extends State<LocalizationTestPage> {
  final LocalizationService _localizationService = LocalizationService();
  String _currentLanguage = 'fr';
  LocalizationStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
    _loadStats();
  }

  void _loadCurrentLanguage() {
    setState(() {
      _currentLanguage = _localizationService.currentLanguageCode;
    });
  }

  void _loadStats() {
    setState(() {
      _stats = _localizationService.getStats();
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    final success = await _localizationService.changeLanguage(languageCode);
    if (success && mounted) {
      setState(() {
        _currentLanguage = languageCode;
      });
      _loadStats();

      // Utiliser un BuildContext local pour éviter le warning
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      // Afficher un message de succès
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Language changed to ${languageCode.toUpperCase()}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${context.l10n.appName} - Localisation Test'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: _changeLanguage,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'fr',
                child: Row(
                  children: [
                    const Text('🇫🇷'),
                    const SizedBox(width: 8),
                    const Text('Français'),
                    if (_currentLanguage == 'fr') const SizedBox(width: 8),
                    if (_currentLanguage == 'fr')
                      const Icon(Icons.check, color: Colors.green),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    const Text('🇺🇸'),
                    const SizedBox(width: 8),
                    const Text('English'),
                    if (_currentLanguage == 'en') const SizedBox(width: 8),
                    if (_currentLanguage == 'en')
                      const Icon(Icons.check, color: Colors.green),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLanguageInfo(),
            const SizedBox(height: 24),
            _buildGeneralTexts(),
            const SizedBox(height: 24),
            _buildNavigationTexts(),
            const SizedBox(height: 24),
            _buildAuthTexts(),
            const SizedBox(height: 24),
            _buildECommerceTexts(),
            const SizedBox(height: 24),
            _buildErrorMessages(),
            const SizedBox(height: 24),
            _buildParametricMessages(),
            const SizedBox(height: 24),
            _buildCulturalElements(),
            const SizedBox(height: 24),
            _buildStats(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Capturer le context avant l'await
          final l10n = context.l10n;
          final scaffoldMessenger = ScaffoldMessenger.of(context);

          await _localizationService.reloadTranslations();
          _loadStats();
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('${l10n.refresh} completed'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        },
        icon: const Icon(Icons.refresh),
        label: Text(context.l10n.refresh),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildLanguageInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.language, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text('Current: $_currentLanguage'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _currentLanguage.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralTexts() {
    return _buildSection('General Texts', [
      context.l10n.loading,
      context.l10n.error,
      context.l10n.ok,
      context.l10n.cancel,
      context.l10n.save,
      context.l10n.delete,
      context.l10n.search,
    ]);
  }

  Widget _buildNavigationTexts() {
    return _buildSection('Navigation', [
      context.l10n.home,
      context.l10n.products,
      context.l10n.categories,
      context.l10n.cart,
      context.l10n.orders,
      context.l10n.account,
      context.l10n.settings,
    ]);
  }

  Widget _buildAuthTexts() {
    return _buildSection('Authentication', [
      context.l10n.login,
      context.l10n.register,
      context.l10n.email,
      context.l10n.password,
      context.l10n.firstName,
      context.l10n.lastName,
      context.l10n.phone,
    ]);
  }

  Widget _buildECommerceTexts() {
    return _buildSection('E-Commerce', [
      context.l10n.price,
      context.l10n.quantity,
      context.l10n.addToCart,
      context.l10n.checkout,
      context.l10n.shipping,
      context.l10n.inStock,
      context.l10n.outOfStock,
    ]);
  }

  Widget _buildErrorMessages() {
    return _buildSection('Error Messages', [
      context.l10n.errorGeneral,
      context.l10n.errorNetwork,
      context.l10n.errorInvalidEmail,
      context.l10n.errorFieldRequired,
    ]);
  }

  Widget _buildParametricMessages() {
    return _buildSection('Parametric Messages', [
      context.l10n.welcomeMessage('John Doe'),
      context.l10n.itemsInCart(3),
      context.l10n.priceWithCurrency(25.99, 'EUR'),
      context.l10n.orderNumber('KTN-2024-001'),
    ]);
  }

  Widget _buildCulturalElements() {
    return _buildSection('Cultural Elements', [
      _localizationService.translate('traditional_clothing'),
      _localizationService.translate('african_print'),
      _localizationService.translate('handmade'),
      _localizationService.translate('authentic'),
      _localizationService.translate('artisan'),
      _localizationService.translate('community'),
    ]);
  }

  Widget _buildSection(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    if (_stats == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              'Current Language',
              _stats!.currentLanguage.toUpperCase(),
            ),
            _buildStatRow(
              'Supported Languages',
              _stats!.supportedLanguages.join(', ').toUpperCase(),
            ),
            _buildStatRow(
              'Total Translations',
              _stats!.totalTranslations.toString(),
            ),
            _buildStatRow(
              'Last Update',
              _stats!.lastUpdate.toString().split('.')[0],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
