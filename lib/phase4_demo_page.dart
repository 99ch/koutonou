// Page de démonstration Phase 4 - Cache & UI Widgets
// Démonstration du cache intelligent et des widgets UI

import 'package:flutter/material.dart';
import 'package:koutonou/core/theme.dart';
import 'package:koutonou/core/api/prestashop_initializer.dart';
import 'package:koutonou/core/cache/prestashop_cache_service.dart';
import 'package:koutonou/modules/languages/services/language_service.dart';
import 'package:koutonou/modules/languages/models/language_model.dart';
import 'package:koutonou/modules/languages/widgets/language_widgets.dart';
import 'package:koutonou/shared/widgets/prestashop_widgets.dart';

/// Page de démonstration Phase 4
class Phase4DemoPage extends StatefulWidget {
  const Phase4DemoPage({super.key});

  @override
  State<Phase4DemoPage> createState() => _Phase4DemoPageState();
}

class _Phase4DemoPageState extends State<Phase4DemoPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  List<LanguageModel> _languages = [];
  Map<String, dynamic> _cacheStats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializePhase4();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializePhase4() async {
    _addLog('🚀 Initialisation Phase 4...');

    try {
      // 1. Initialiser l'API
      _addLog('📡 Initialisation API PrestaShop...');
      await PrestaShopApiInitializer.initializeForDevelopment(
        validateConnection: false,
      );
      _addLog('✅ API initialisée');

      // 2. Initialiser le cache
      _addLog('💾 Initialisation du cache intelligent...');
      final cacheService = PrestaShopCacheService();
      cacheService.configureForEnvironment('development');
      _addLog('✅ Cache configuré pour développement');

      // 3. Charger les données de test
      await _loadTestData();

      setState(() {
        _isInitialized = true;
      });

      _addLog('🎉 Phase 4 initialisée avec succès !');
    } catch (e) {
      _addLog('❌ Erreur initialisation: $e');
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _loadTestData() async {
    try {
      _addLog('📊 Chargement des données de test...');

      // Créer des langues de test si pas de connexion API
      _languages = [
        const LanguageModel(
          id: 1,
          name: 'Français',
          iso_code: 'fr',
          language_code: 'fr-FR',
          active: 1,
          is_rtl: 0,
          date_format_lite: 'd/m/Y',
          date_format_full: 'd/m/Y H:i:s',
        ),
        const LanguageModel(
          id: 2,
          name: 'English',
          iso_code: 'en',
          language_code: 'en-US',
          active: 1,
          is_rtl: 0,
          date_format_lite: 'm/d/Y',
          date_format_full: 'm/d/Y H:i:s',
        ),
        const LanguageModel(
          id: 3,
          name: 'Español',
          iso_code: 'es',
          language_code: 'es-ES',
          active: 1,
          is_rtl: 0,
          date_format_lite: 'd/m/Y',
          date_format_full: 'd/m/Y H:i:s',
        ),
        const LanguageModel(
          id: 4,
          name: 'العربية',
          iso_code: 'ar',
          language_code: 'ar-SA',
          active: 0,
          is_rtl: 1,
          date_format_lite: 'd/m/Y',
          date_format_full: 'd/m/Y H:i:s',
        ),
      ];

      // Mettre en cache les données
      final cacheService = PrestaShopCacheService();
      await cacheService.cacheList('languages', _languages);

      _addLog(
        '✅ ${_languages.length} langues de test chargées et mises en cache',
      );

      // Récupérer les stats du cache
      _cacheStats = await cacheService.getResourceStats('languages');
    } catch (e) {
      _addLog('❌ Erreur chargement données: $e');
    }
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logMessage = '[$timestamp] $message';

    setState(() {
      _logs.add(logMessage);
    });

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

  Future<void> _testCache() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('🧪 Test du cache intelligent...');

      final cacheService = PrestaShopCacheService();

      // Test 1: Cache miss puis hit
      _addLog('Test 1: Cache miss...');
      final cached1 = await cacheService.getList<LanguageModel>('languages');
      _addLog(
        cached1 != null
            ? '✅ Cache hit (${cached1.length} éléments)'
            : '❌ Cache miss',
      );

      // Test 2: Invalidation
      _addLog('Test 2: Invalidation du cache...');
      await cacheService.invalidateResource('languages');
      final cached2 = await cacheService.getList<LanguageModel>('languages');
      _addLog(cached2 == null ? '✅ Cache invalidé' : '❌ Cache encore présent');

      // Test 3: Re-cache
      _addLog('Test 3: Re-mise en cache...');
      await cacheService.cacheList('languages', _languages);
      final cached3 = await cacheService.getList<LanguageModel>('languages');
      _addLog(
        cached3 != null
            ? '✅ Cache restauré (${cached3.length} éléments)'
            : '❌ Erreur cache',
      );

      // Mettre à jour les stats
      _cacheStats = await cacheService.getResourceStats('languages');

      _addLog('🎉 Tests cache terminés !');
    } catch (e) {
      _addLog('❌ Erreur test cache: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<LanguageModel>> _refreshLanguages() async {
    _addLog('🔄 Actualisation des langues...');

    try {
      final languageService = LanguageService();
      final languages = await languageService.getAll();

      _addLog('✅ ${languages.length} langues chargées');
      return languages;
    } catch (e) {
      _addLog('⚠️ Utilisation des données de test: $e');
      return _languages;
    }
  }

  void _onLanguageTap(LanguageModel language) {
    _addLog('👆 Langue sélectionnée: ${language.name}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails - ${language.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: LanguageDetailsWidget(language: language),
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

  void _onToggleActive(LanguageModel language) {
    final newStatus = language.active == 1 ? 'désactivée' : 'activée';
    _addLog('🔄 Langue ${language.name} $newStatus');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Langue ${language.name} $newStatus'),
        action: SnackBarAction(label: 'Annuler', onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 4 - Cache & UI Widgets'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Démo'),
            Tab(icon: Icon(Icons.language), text: 'Langues'),
            Tab(icon: Icon(Icons.storage), text: 'Cache'),
          ],
        ),
      ),
      body: !_isInitialized
          ? _buildInitializingView()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDemoTab(),
                _buildLanguagesTab(),
                _buildCacheTab(),
              ],
            ),
    );
  }

  Widget _buildInitializingView() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Erreur d\'initialisation',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _logs.clear();
                });
                _initializePhase4();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Initialisation Phase 4...'),
        ],
      ),
    );
  }

  Widget _buildDemoTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Phase 4 Initialisée',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Cache intelligent et widgets UI prêts !'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionButton(
                        label: 'Tester Cache',
                        icon: Icons.storage,
                        onPressed: _testCache,
                        isLoading: _isLoading,
                      ),
                      ActionButton(
                        label: 'Vider Logs',
                        icon: Icons.clear,
                        onPressed: () => setState(() => _logs.clear()),
                        isOutlined: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Console Phase 4',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: _logs.isEmpty
                          ? const Center(
                              child: Text(
                                'Aucun log pour le moment',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                final log = _logs[index];
                                Color? textColor;
                                if (log.contains('❌')) textColor = Colors.red;
                                if (log.contains('✅')) textColor = Colors.green;
                                if (log.contains('🚀') || log.contains('🧪'))
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
    );
  }

  Widget _buildLanguagesTab() {
    return LanguageListView(
      onRefresh: _refreshLanguages,
      onLanguageTap: _onLanguageTap,
      onToggleActive: _onToggleActive,
      onEditLanguage: (language) => _addLog('✏️ Édition: ${language.name}'),
      onDeleteLanguage: (language) =>
          _addLog('🗑️ Suppression: ${language.name}'),
    );
  }

  Widget _buildCacheTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques du Cache',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          if (_cacheStats.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoRow(
                      icon: Icons.storage,
                      label: 'Stratégie',
                      value:
                          _cacheStats['globalStats']?['strategy']
                              ?.toString()
                              .split('.')
                              .last ??
                          'N/A',
                    ),
                    InfoRow(
                      icon: Icons.timer,
                      label: 'TTL Langues',
                      value: '${_cacheStats['ttlMinutes']} minutes',
                    ),
                    InfoRow(
                      icon: Icons.memory,
                      label: 'Entrées Mémoire',
                      value:
                          _cacheStats['globalStats']?['memoryEntries']
                              ?.toString() ??
                          '0',
                    ),
                    InfoRow(
                      icon: Icons.folder,
                      label: 'Entrées Disque',
                      value:
                          _cacheStats['globalStats']?['diskEntries']
                              ?.toString() ??
                          '0',
                    ),
                  ],
                ),
              ),
            ),
          ] else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aucune statistique disponible'),
              ),
            ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionButton(
                label: 'Actualiser Stats',
                icon: Icons.refresh,
                onPressed: () async {
                  final cacheService = PrestaShopCacheService();
                  final stats = await cacheService.getResourceStats(
                    'languages',
                  );
                  setState(() {
                    _cacheStats = stats;
                  });
                  _addLog('📊 Statistiques cache actualisées');
                },
              ),
              ActionButton(
                label: 'Vider Cache',
                icon: Icons.clear_all,
                onPressed: () async {
                  final cacheService = PrestaShopCacheService();
                  await cacheService.clearAll();
                  _addLog('🗑️ Cache vidé');
                },
                color: Colors.red,
                isOutlined: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
