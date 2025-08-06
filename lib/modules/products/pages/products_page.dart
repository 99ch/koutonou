import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form.dart';

/// Page principale pour la gestion des produits
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeProducts();
    _setupScrollListener();
  }

  void _initializeProducts() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(reset: true);
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // Charger plus de produits quand on approche du bas
        context.read<ProductProvider>().loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtres',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createProduct,
            tooltip: 'Nouveau produit',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildProductsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createProduct,
        tooltip: 'Nouveau produit',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un produit...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<ProductProvider>().clearFilters();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            context.read<ProductProvider>().searchProducts(value.trim());
          } else {
            context.read<ProductProvider>().clearFilters();
          }
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final hasFilters =
            provider.searchQuery != null ||
            provider.categoryFilter != null ||
            provider.activeOnlyFilter;

        if (!hasFilters) return const SizedBox.shrink();

        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (provider.searchQuery != null)
                _buildFilterChip(
                  'Recherche: "${provider.searchQuery}"',
                  () => context.read<ProductProvider>().searchProducts(''),
                ),
              if (provider.categoryFilter != null)
                _buildFilterChip(
                  'Catégorie: ${provider.categoryFilter}',
                  () => context.read<ProductProvider>().filterByCategory(null),
                ),
              if (provider.activeOnlyFilter)
                _buildFilterChip(
                  'Actifs seulement',
                  () => context.read<ProductProvider>().toggleActiveFilter(),
                ),
              _buildFilterChip(
                'Effacer tous les filtres',
                () => context.read<ProductProvider>().clearFilters(),
                isAction: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    VoidCallback onPressed, {
    bool isAction = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        onSelected: (_) => onPressed(),
        backgroundColor: isAction ? Colors.red[50] : null,
        deleteIcon: isAction
            ? const Icon(Icons.clear_all)
            : const Icon(Icons.close),
        onDeleted: onPressed,
      ),
    );
  }

  Widget _buildProductsList() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  provider.errorMessage!,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.refresh(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (provider.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun produit trouvé',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text('Commencez par ajouter votre premier produit'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _createProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('Nouveau produit'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: provider.products.length + (provider.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.products.length) {
                // Indicateur de chargement en bas de liste
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final product = provider.products[index];
              return ProductCard(
                product: product,
                onTap: () => _viewProduct(product),
                onEdit: () => _editProduct(product),
                onDelete: () => _deleteProduct(product.id!),
              );
            },
          ),
        );
      },
    );
  }

  void _createProduct() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductForm(
          onSave: (product) async {
            final success = await context.read<ProductProvider>().createProduct(
              product,
            );
            if (success && mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Produit créé avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Erreur lors de la création du produit'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _editProduct(product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductForm(
          product: product,
          onSave: (updatedProduct) async {
            final success = await context.read<ProductProvider>().updateProduct(
              updatedProduct,
            );
            if (success && mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Produit modifié avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Erreur lors de la modification du produit'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _viewProduct(product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetails(
          product: product,
          onEdit: () {
            Navigator.of(context).pop(); // Fermer la vue détail
            _editProduct(product); // Ouvrir l'édition
          },
        ),
      ),
    );
  }

  Future<void> _deleteProduct(int productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Cette action est irréversible. Continuer ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context.read<ProductProvider>().deleteProduct(
        productId,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression du produit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtres'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Produits actifs seulement'),
              trailing: Consumer<ProductProvider>(
                builder: (context, provider, child) => Switch(
                  value: provider.activeOnlyFilter,
                  onChanged: (_) {
                    provider.toggleActiveFilter();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            // Vous pouvez ajouter d'autres filtres ici
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ProductProvider>().clearFilters();
              Navigator.of(context).pop();
            },
            child: const Text('Effacer les filtres'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
