// Widgets spécialisés pour les Languages - Phase 4
// Components Flutter pour l'affichage et la gestion des langues

import 'package:flutter/material.dart';
import 'package:koutonou/modules/languages/models/language_model.dart';
import 'package:koutonou/shared/widgets/prestashop_widgets.dart';

/// Card pour afficher une langue
class LanguageCard extends StatelessWidget {
  final LanguageModel language;
  final VoidCallback? onTap;
  final VoidCallback? onToggleActive;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const LanguageCard({
    super.key,
    required this.language,
    this.onTap,
    this.onToggleActive,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = language.active == 1;

    return PrestaShopItemCard(
      title: language.name ?? 'Langue sans nom',
      subtitle: _buildSubtitle(),
      leading: _buildFlag(),
      trailing: StatusChip(
        label: isActive ? 'Active' : 'Inactive',
        isActive: isActive,
      ),
      onTap: onTap,
      isActive: isActive,
      actions: showActions ? _buildActions(context) : null,
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];

    if (language.iso_code != null) {
      parts.add('Code: ${language.iso_code}');
    }

    if (language.language_code != null) {
      parts.add('Langue: ${language.language_code}');
    }

    if (language.is_rtl == 1) {
      parts.add('RTL');
    }

    return parts.join(' • ');
  }

  Widget _buildFlag() {
    // Pour l'instant, afficher un icône générique
    // Plus tard, on pourra ajouter de vrais drapeaux
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          language.iso_code?.toUpperCase() ?? '??',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];

    if (onToggleActive != null) {
      actions.add(
        ActionButton(
          label: language.active == 1 ? 'Désactiver' : 'Activer',
          icon: language.active == 1 ? Icons.visibility_off : Icons.visibility,
          onPressed: onToggleActive,
          isOutlined: true,
          color: language.active == 1 ? Colors.orange : Colors.green,
        ),
      );
    }

    if (onEdit != null) {
      actions.add(
        ActionButton(
          label: 'Modifier',
          icon: Icons.edit,
          onPressed: onEdit,
          isOutlined: true,
        ),
      );
    }

    if (onDelete != null) {
      actions.add(
        ActionButton(
          label: 'Supprimer',
          icon: Icons.delete,
          onPressed: () => _confirmDelete(context),
          isOutlined: true,
          color: Colors.red,
        ),
      );
    }

    return actions;
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer la langue "${language.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

/// Liste des langues avec fonctionnalités avancées
class LanguageListView extends StatelessWidget {
  final Future<List<LanguageModel>> Function() onRefresh;
  final Function(LanguageModel)? onLanguageTap;
  final Function(LanguageModel)? onToggleActive;
  final Function(LanguageModel)? onEditLanguage;
  final Function(LanguageModel)? onDeleteLanguage;
  final bool showActions;

  const LanguageListView({
    super.key,
    required this.onRefresh,
    this.onLanguageTap,
    this.onToggleActive,
    this.onEditLanguage,
    this.onDeleteLanguage,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return PrestaShopListView<LanguageModel>(
      onRefresh: onRefresh,
      itemBuilder: (context, language, index) => LanguageCard(
        language: language,
        onTap: onLanguageTap != null ? () => onLanguageTap!(language) : null,
        onToggleActive: onToggleActive != null
            ? () => onToggleActive!(language)
            : null,
        onEdit: onEditLanguage != null ? () => onEditLanguage!(language) : null,
        onDelete: onDeleteLanguage != null
            ? () => onDeleteLanguage!(language)
            : null,
        showActions: showActions,
      ),
      emptyWidget: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.language, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune langue disponible',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Ajoutez des langues pour votre boutique',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sélecteur de langue avec recherche
class LanguageSelector extends StatefulWidget {
  final List<LanguageModel> languages;
  final LanguageModel? selectedLanguage;
  final Function(LanguageModel) onLanguageSelected;
  final bool showActiveOnly;

  const LanguageSelector({
    super.key,
    required this.languages,
    this.selectedLanguage,
    required this.onLanguageSelected,
    this.showActiveOnly = true,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String _searchQuery = '';

  List<LanguageModel> get _filteredLanguages {
    var languages = widget.languages;

    if (widget.showActiveOnly) {
      languages = languages.where((lang) => lang.active == 1).toList();
    }

    if (_searchQuery.isNotEmpty) {
      languages = languages.where((lang) {
        final name = lang.name?.toLowerCase() ?? '';
        final code = lang.iso_code?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || code.contains(query);
      }).toList();
    }

    return languages;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher une langue...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Liste des langues
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredLanguages.length,
            itemBuilder: (context, index) {
              final language = _filteredLanguages[index];
              final isSelected = widget.selectedLanguage?.id == language.id;

              return ListTile(
                leading: Container(
                  width: 32,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(
                      language.iso_code?.toUpperCase() ?? '??',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                title: Text(language.name ?? 'Langue sans nom'),
                subtitle: Text(
                  language.language_code ?? language.iso_code ?? '',
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                selected: isSelected,
                onTap: () {
                  widget.onLanguageSelected(language);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Détails d'une langue
class LanguageDetailsWidget extends StatelessWidget {
  final LanguageModel language;

  const LanguageDetailsWidget({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec drapeau et nom
        Row(
          children: [
            Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  language.iso_code?.toUpperCase() ?? '??',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name ?? 'Langue sans nom',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  StatusChip(
                    label: language.active == 1 ? 'Active' : 'Inactive',
                    isActive: language.active == 1,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Informations détaillées
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informations',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                InfoRow(
                  icon: Icons.tag,
                  label: 'ID',
                  value: language.id.toString(),
                ),

                if (language.iso_code != null)
                  InfoRow(
                    icon: Icons.code,
                    label: 'Code ISO',
                    value: language.iso_code!,
                  ),

                if (language.language_code != null)
                  InfoRow(
                    icon: Icons.language,
                    label: 'Code Langue',
                    value: language.language_code!,
                  ),

                InfoRow(
                  icon: Icons.visibility,
                  label: 'Statut',
                  value: language.active == 1 ? 'Active' : 'Inactive',
                ),

                InfoRow(
                  icon: Icons.format_textdirection_r_to_l,
                  label: 'Direction',
                  value: language.is_rtl == 1
                      ? 'Droite vers Gauche (RTL)'
                      : 'Gauche vers Droite (LTR)',
                ),

                if (language.date_format_lite != null)
                  InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Format Date Court',
                    value: language.date_format_lite!,
                  ),

                if (language.date_format_full != null)
                  InfoRow(
                    icon: Icons.date_range,
                    label: 'Format Date Complet',
                    value: language.date_format_full!,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
