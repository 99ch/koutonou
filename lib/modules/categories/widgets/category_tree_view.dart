import 'package:flutter/material.dart';
import '../models/category_model.dart';

/// Widget pour afficher les catégories sous forme d'arbre hiérarchique
class CategoryTreeView extends StatefulWidget {
  final List<CategoryTree> categoryTree;
  final Function(Category) onCategoryTap;
  final Function(Category)? onCategoryEdit;
  final Function(Category)? onCategoryDelete;

  const CategoryTreeView({
    super.key,
    required this.categoryTree,
    required this.onCategoryTap,
    this.onCategoryEdit,
    this.onCategoryDelete,
  });

  @override
  State<CategoryTreeView> createState() => _CategoryTreeViewState();
}

class _CategoryTreeViewState extends State<CategoryTreeView> {
  final Set<int> _expandedCategories = <int>{};

  @override
  Widget build(BuildContext context) {
    if (widget.categoryTree.isEmpty) {
      return const Center(child: Text('Aucune catégorie trouvée'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: widget.categoryTree.map((categoryTreeNode) {
        return _buildCategoryNode(categoryTreeNode, 0);
      }).toList(),
    );
  }

  Widget _buildCategoryNode(CategoryTree categoryTreeNode, int depth) {
    final category = categoryTreeNode.category;
    final hasChildren = categoryTreeNode.children.isNotEmpty;
    final isExpanded = _expandedCategories.contains(category.id);
    final indent = depth * 24.0;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: indent, bottom: 4),
          child: Card(
            elevation: depth > 0 ? 1 : 2,
            child: InkWell(
              onTap: () => widget.onCategoryTap(category),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Bouton d'expansion/contraction
                    if (hasChildren)
                      GestureDetector(
                        onTap: () => _toggleExpansion(category.id!),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_right,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 28),

                    // Icône de catégorie
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: category.active
                            ? Colors.blue[100]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.folder,
                        size: 20,
                        color: category.active
                            ? Colors.blue[700]
                            : Colors.grey[600],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Informations de la catégorie
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: category.active
                                            ? Colors.black87
                                            : Colors.grey[600],
                                      ),
                                ),
                              ),
                              _buildStatusIndicator(category),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildInfoTag(
                                '${category.productIds.length} produits',
                                Icons.inventory_2_outlined,
                              ),
                              const SizedBox(width: 8),
                              if (categoryTreeNode.children.isNotEmpty)
                                _buildInfoTag(
                                  '${categoryTreeNode.children.length} sous-catégories',
                                  Icons.account_tree_outlined,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Menu d'actions
                    _buildActionMenu(categoryTreeNode),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Enfants (si expanded)
        if (hasChildren && isExpanded) ...[
          ...categoryTreeNode.children.map((child) {
            return _buildCategoryNode(child, depth + 1);
          }),
        ],
      ],
    );
  }

  Widget _buildStatusIndicator(Category category) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: category.active ? Colors.green : Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInfoTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 2),
          Text(text, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildActionMenu(CategoryTree categoryTreeNode) {
    final category = categoryTreeNode.category;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
      onSelected: (value) {
        switch (value) {
          case 'view':
            widget.onCategoryTap(category);
            break;
          case 'edit':
            widget.onCategoryEdit?.call(category);
            break;
          case 'delete':
            widget.onCategoryDelete?.call(category);
            break;
          case 'expand_all':
            _expandAll(categoryTreeNode);
            break;
          case 'collapse_all':
            _collapseAll(categoryTreeNode);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: ListTile(
            leading: Icon(Icons.visibility, size: 18),
            title: Text('Voir détails'),
            dense: true,
          ),
        ),
        if (widget.onCategoryEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit, size: 18),
              title: Text('Modifier'),
              dense: true,
            ),
          ),
        if (categoryTreeNode.children.isNotEmpty) ...[
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'expand_all',
            child: ListTile(
              leading: Icon(Icons.expand_more, size: 18),
              title: Text('Tout développer'),
              dense: true,
            ),
          ),
          const PopupMenuItem(
            value: 'collapse_all',
            child: ListTile(
              leading: Icon(Icons.expand_less, size: 18),
              title: Text('Tout réduire'),
              dense: true,
            ),
          ),
        ],
        if (widget.onCategoryDelete != null) ...[
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete, size: 18, color: Colors.red),
              title: Text('Supprimer', style: TextStyle(color: Colors.red)),
              dense: true,
            ),
          ),
        ],
      ],
    );
  }

  void _toggleExpansion(int categoryId) {
    setState(() {
      if (_expandedCategories.contains(categoryId)) {
        _expandedCategories.remove(categoryId);
      } else {
        _expandedCategories.add(categoryId);
      }
    });
  }

  void _expandAll(CategoryTree categoryTreeNode) {
    setState(() {
      _addCategoryAndChildrenToExpanded(categoryTreeNode);
    });
  }

  void _collapseAll(CategoryTree categoryTreeNode) {
    setState(() {
      _removeCategoryAndChildrenFromExpanded(categoryTreeNode);
    });
  }

  void _addCategoryAndChildrenToExpanded(CategoryTree categoryTreeNode) {
    if (categoryTreeNode.category.id != null) {
      _expandedCategories.add(categoryTreeNode.category.id!);
    }
    for (final child in categoryTreeNode.children) {
      _addCategoryAndChildrenToExpanded(child);
    }
  }

  void _removeCategoryAndChildrenFromExpanded(CategoryTree categoryTreeNode) {
    if (categoryTreeNode.category.id != null) {
      _expandedCategories.remove(categoryTreeNode.category.id!);
    }
    for (final child in categoryTreeNode.children) {
      _removeCategoryAndChildrenFromExpanded(child);
    }
  }
}
