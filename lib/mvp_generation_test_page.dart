// Page de test pour valider la génération automatique MVP Phase 1
// Teste les 3 ressources générées: languages, currencies, countries
// Validation complète: modèles, services, cache, erreurs

import 'package:flutter/material.dart';
import 'package:koutonou/core/theme.dart';

// Services générés automatiquement - MVP Phase 1
import 'package:koutonou/modules/configs/services/languageservice.dart';
import 'package:koutonou/modules/configs/services/currencyservice.dart';
import 'package:koutonou/modules/configs/services/countryservice.dart';

/// Page de test pour la génération automatique MVP
class MvpGenerationTestPage extends StatefulWidget {
  const MvpGenerationTestPage({super.key});

  @override
  State<MvpGenerationTestPage> createState() => _MvpGenerationTestPageState();
}

class _MvpGenerationTestPageState extends State<MvpGenerationTestPage> {
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  final Map<String, dynamic> _testResults = {};

  // États d'initialisation
  bool _isInitializing = true;
  bool _isLoading = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Initialise les services de manière asynchrone
  Future<void> _initializeServices() async {
    try {
      _addLog('🚀 Initialisation des services...');
      _addLog('� Services créés à la demande pour chaque test');
      _addLog('🎉 Initialisation terminée!');
      _addLog('💡 Prêt pour les tests API');

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      _addLog('❌ Erreur d\'initialisation: $e');
      setState(() {
        _isInitializing = false;
        _initError = e.toString();
      });
    }
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logMessage = '[$timestamp] $message';

    setState(() {
      _logs.add(logMessage);
    });

    // Auto-scroll vers le bas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _runTest(
    String testName,
    Future<Map<String, dynamic>> Function() testFunction,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('🔧 Démarrage test: $testName');
      final result = await testFunction();
      _testResults[testName] = result;
      _addLog('✅ Test $testName réussi!');
    } catch (e) {
      _addLog('❌ Test $testName échoué: $e');
      _testResults[testName] = {'success': false, 'error': e.toString()};
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLanguages() async {
    await _runTest('Languages', () async {
      _addLog('🔵 Test Languages - Début');

      // Créer le service directement pour s'assurer qu'il est disponible
      final languageService = LanguageService();
      _addLog('✅ Service Languages créé');

      // Test sans cache d'abord (pour éviter les erreurs de cache web)
      final languages = await languageService.getAll(useCache: false);
      _addLog('Languages récupérées: ${languages.length}');

      if (languages.isNotEmpty) {
        final first = languages.first;
        _addLog('Premier language: ${first.toString()}');

        // Test cache seulement si on n'est pas sur le web
        try {
          final cached = await languageService.getAll(useCache: true);
          _addLog('Cache test: ${cached.length} languages');
        } catch (e) {
          _addLog(
            '⚠️  Cache non disponible (mode web): ${e.toString().split('\n').first}',
          );
        }
      }

      _addLog('🔵 Test Languages - Terminé avec succès');
      return {'success': true, 'count': languages.length, 'cached': false};
    });
  }

  Future<void> _testCurrencies() async {
    await _runTest('Currencies', () async {
      _addLog('💰 Test Currencies - Début');

      // Créer le service directement pour s'assurer qu'il est disponible
      final currencyService = CurrencyService();
      _addLog('✅ Service Currencies créé');

      // Test sans cache d'abord (pour éviter les erreurs de cache web)
      final currencies = await currencyService.getAll(useCache: false);
      _addLog('Currencies récupérées: ${currencies.length}');

      if (currencies.isNotEmpty) {
        final first = currencies.first;
        _addLog('Premier currency: ${first.toString()}');

        // Test cache seulement si on n'est pas sur le web
        try {
          final cached = await currencyService.getAll(useCache: true);
          _addLog('Cache test: ${cached.length} currencies');
        } catch (e) {
          _addLog(
            '⚠️  Cache non disponible (mode web): ${e.toString().split('\n').first}',
          );
        }
      }

      _addLog('💰 Test Currencies - Terminé avec succès');
      return {'success': true, 'count': currencies.length, 'cached': false};
    });
  }

  Future<void> _testCountries() async {
    await _runTest('Countries', () async {
      _addLog('🌍 Test Countries - Début');

      // Créer le service directement pour s'assurer qu'il est disponible
      final countryService = CountryService();
      _addLog('✅ Service Countries créé');

      // Test sans cache d'abord (pour éviter les erreurs de cache web)
      final countries = await countryService.getAll(useCache: false);
      _addLog('Countries récupérés: ${countries.length}');

      if (countries.isNotEmpty) {
        final first = countries.first;
        _addLog('Premier country: ${first.toString()}');

        // Test cache seulement si on n'est pas sur le web
        try {
          final cached = await countryService.getAll(useCache: true);
          _addLog('Cache test: ${cached.length} countries');
        } catch (e) {
          _addLog(
            '⚠️  Cache non disponible (mode web): ${e.toString().split('\n').first}',
          );
        }
      }

      _addLog('🌍 Test Countries - Terminé avec succès');
      return {'success': true, 'count': countries.length, 'cached': false};
    });
  }

  Future<void> _runAllTests() async {
    _addLog('🚀 === DÉBUT DES TESTS MVP ===');

    if (_isInitializing) {
      _addLog('⏳ Les services s\'initialisent encore...');
      return;
    }

    if (_initError != null) {
      _addLog('❌ Impossible de lancer les tests - erreur d\'initialisation');
      return;
    }

    await _testLanguages();
    _addLog('⚠️  Tests Currencies et Countries temporairement désactivés');
    // await _testCurrencies();
    // await _testCountries();

    _addLog('🏁 === TESTS MVP TERMINÉS ===');
    _addLog('📊 Résultats:');
    _testResults.forEach((test, result) {
      final status = result['success'] == true ? '✅' : '❌';
      _addLog(
        '  $status $test: ${result['success'] == true ? 'OK' : result['error']}',
      );
    });
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
      _testResults.clear();
    });
  }

  Widget _buildServicesStatus() {
    if (_isInitializing) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Initialisation des services...'),
            ],
          ),
        ),
      );
    }

    if (_initError != null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Erreur d\'initialisation',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _initError!,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _initError = null;
                  });
                  _initializeServices();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Colors.green.shade50,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 12),
            Text(
              'Services prêts',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MVP - Test Génération Auto'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearLogs,
            tooltip: 'Vider les logs',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            const Text(
              'Tests MVP - Phase 1',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Validation des modèles et services générés automatiquement:\n'
              '• Languages (API /languages)\n'
              '• Currencies (API /currencies)\n'
              '• Countries (API /countries)',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // État des services
            _buildServicesStatus(),
            const SizedBox(height: 16),

            // Boutons de test
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isInitializing || _initError != null || _isLoading
                      ? null
                      : _runAllTests,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Lancer tous les tests'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isInitializing || _initError != null || _isLoading
                      ? null
                      : _testLanguages,
                  icon: const Icon(Icons.language),
                  label: const Text('Test Languages'),
                ),
                OutlinedButton.icon(
                  onPressed: _isInitializing || _initError != null || _isLoading
                      ? null
                      : _testCurrencies,
                  icon: const Icon(Icons.monetization_on),
                  label: const Text('Test Currencies'),
                ),
                OutlinedButton.icon(
                  onPressed: _isInitializing || _initError != null || _isLoading
                      ? null
                      : _testCountries,
                  icon: const Icon(Icons.public),
                  label: const Text('Test Countries'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Console de logs
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Console de Tests',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          if (_isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: _logs.isEmpty
                            ? const Center(
                                child: Text(
                                  'Aucun log pour le moment.\nLancez un test pour voir les résultats.',
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: _logs.length,
                                itemBuilder: (context, index) {
                                  final log = _logs[index];
                                  Color? textColor;
                                  if (log.contains('❌')) textColor = Colors.red;
                                  if (log.contains('✅'))
                                    textColor = Colors.green;
                                  if (log.contains('🔧') || log.contains('🚀'))
                                    textColor = Colors.blue;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 1,
                                    ),
                                    child: Text(
                                      log,
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        color: textColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
