// Page de test pour le générateur Phase 2
// Test de génération complète avec toutes les ressources PrestaShop
// Interface graphique pour tester le générateur

import 'package:flutter/material.dart';
import 'package:koutonou/core/generators/prestashop_generator.dart';
import 'package:koutonou/core/theme.dart';
import 'package:koutonou/core/utils/logger.dart';

/// Page de test pour le générateur Phase 2
class GeneratorTestPage extends StatefulWidget {
  const GeneratorTestPage({super.key});

  @override
  State<GeneratorTestPage> createState() => _GeneratorTestPageState();
}

class _GeneratorTestPageState extends State<GeneratorTestPage> {
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  bool _isGenerating = false;
  final PrestaShopGenerator _generator = PrestaShopGenerator();
  static final AppLogger _logger = AppLogger();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  /// Génère tous les modèles et services
  Future<void> _generateAll() async {
    setState(() {
      _isGenerating = true;
      _logs.clear();
    });

    try {
      _addLog('🚀 Démarrage génération complète Phase 2');
      await _generator.generateAll();
      _addLog('✅ Génération complète terminée avec succès');
    } catch (e) {
      _addLog('❌ Erreur génération complète: $e');
      _logger.error('Erreur génération complète', e);
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  /// Génère une ressource spécifique
  Future<void> _generateResource(String resourceName) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      _addLog('📦 Génération $resourceName...');

      final config = PrestaShopGenerator.resourceConfigs[resourceName];
      if (config == null) {
        throw Exception('Configuration non trouvée pour: $resourceName');
      }

      await _generator.generateResource(config);
      _addLog('✅ $resourceName généré avec succès');
    } catch (e) {
      _addLog('❌ Erreur génération $resourceName: $e');
      _logger.error('Erreur génération $resourceName', e);
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générateur PrestaShop - Phase 2'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            const Text(
              'Générateur complet PrestaShop',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Phase 2 - Génération automatique de modèles et services\n'
              'pour toutes les ressources PrestaShop avec cache et gestion d\'erreurs.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Statistiques des ressources
            _buildResourceStats(),
            const SizedBox(height: 16),

            // Boutons de génération
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateAll,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Générer tout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isGenerating
                      ? null
                      : () => _generateResource('products'),
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Products'),
                ),
                OutlinedButton.icon(
                  onPressed: _isGenerating
                      ? null
                      : () => _generateResource('categories'),
                  icon: const Icon(Icons.category),
                  label: const Text('Categories'),
                ),
                OutlinedButton.icon(
                  onPressed: _isGenerating
                      ? null
                      : () => _generateResource('customers'),
                  icon: const Icon(Icons.people),
                  label: const Text('Customers'),
                ),
                OutlinedButton.icon(
                  onPressed: _isGenerating
                      ? null
                      : () => _generateResource('orders'),
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Orders'),
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
                            'Console de Génération',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          if (_isGenerating)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearLogs,
                            tooltip: 'Effacer les logs',
                            iconSize: 18,
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
                                  'Aucun log pour le moment.\nCliquez sur un bouton pour commencer la génération.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: _logs.length,
                                itemBuilder: (context, index) {
                                  final log = _logs[index];
                                  Color textColor = Colors.black87;

                                  if (log.contains('✅')) {
                                    textColor = Colors.green.shade700;
                                  } else if (log.contains('❌')) {
                                    textColor = Colors.red.shade700;
                                  } else if (log.contains('🚀') ||
                                      log.contains('📦')) {
                                    textColor = Colors.blue.shade700;
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
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

  Widget _buildResourceStats() {
    final configs = PrestaShopGenerator.resourceConfigs;

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Ressources disponibles',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: configs.entries.map((entry) {
                final name = entry.key;
                final config = entry.value;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getResourceIcon(name),
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$name (${config.fieldTypes.length} champs)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${configs.length} ressources prêtes à générer',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getResourceIcon(String resourceName) {
    switch (resourceName) {
      case 'products':
        return Icons.shopping_bag;
      case 'categories':
        return Icons.category;
      case 'customers':
        return Icons.people;
      case 'orders':
        return Icons.shopping_cart;
      default:
        return Icons.api;
    }
  }
}
