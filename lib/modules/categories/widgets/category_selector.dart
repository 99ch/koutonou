import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';

/// Widget pour sélectionner des catégories (utilisé dans les formulaires de produits)
class CategorySelector extends StatefulWidget {
  final List<int> selectedCategoryIds;
  final Function(List<int>) onCategoriesChanged;
  final bool multiSelect;
  final String? hintText;

  const CategorySelector({
    super.key,
    required this.selectedCategoryIds,
    required this.onCategoriesChanged,
    this.multiSelect = true,
    this.hintText,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final TextEditingController _searchController = TextEditingController();
  List<Category> _filteredCategories = [];
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final provider = context.read<CategoryProvider>();
    if (provider.categories.isEmpty) {
      await provider.loadCategories(reset: true);
    }
    _filterCategories('');
  }

  void _filterCategories(String query) {
    final provider = context.read<CategoryProvider>();
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = provider.categories.cast<Category>();
      } else {
        _filteredCategories = provider.categories
            .where(
              (category) =>
                  category.name.toLowerCase().contains(query.toLowerCase()),
            )
            .cast<Category>()
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Champ de sélection principal
            _buildMainField(),

            // Liste déroulante des catégories
            if (_isExpanded) _buildCategoryList(),
          ],
        );
      },
    );
  }

  Widget _buildMainField() {
    final selectedCategories = _getSelectedCategories();

    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: selectedCategories.isEmpty
                  ? Text(
                      widget.hintText ?? 'Sélectionner des catégories',
                      style: TextStyle(color: Colors.grey[600]),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: selectedCategories.map((category) {
                        return Chip(
                          label: Text(
                            category.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () =>
                              _removeCategorySelection(category.id!),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
            ),
            Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Champ de recherche
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher des catégories...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: _filterCategories,
            ),
          ),

          // Liste des catégories
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: _filteredCategories.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Aucune catégorie trouvée'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      final isSelected = widget.selectedCategoryIds.contains(
                        category.id,
                      );

                      return CheckboxListTile(
                        title: Text(category.name),
                        subtitle: category.description != null
                            ? Text(
                                category.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              )
                            : null,
                        value: isSelected,
                        onChanged: (selected) {
                          if (selected == true) {
                            _addCategorySelection(category.id!);
                          } else {
                            _removeCategorySelection(category.id!);
                          }
                        },
                        dense: true,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Category> _getSelectedCategories() {
    final provider = context.read<CategoryProvider>();
    return provider.categories
        .where((category) => widget.selectedCategoryIds.contains(category.id))
        .cast<Category>()
        .toList();
  }

  void _addCategorySelection(int categoryId) {
    final List<int> newSelection;

    if (widget.multiSelect) {
      newSelection = [...widget.selectedCategoryIds, categoryId];
    } else {
      newSelection = [categoryId];
      setState(() {
        _isExpanded = false;
      });
    }

    widget.onCategoriesChanged(newSelection);
  }

  void _removeCategorySelection(int categoryId) {
    final newSelection = widget.selectedCategoryIds
        .where((id) => id != categoryId)
        .toList();

    widget.onCategoriesChanged(newSelection);
  }
}
