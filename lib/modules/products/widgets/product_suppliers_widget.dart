import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_supplier_model.dart';
import '../providers/product_provider.dart';

/// Widget pour afficher et gérer les fournisseurs d'un produit
class ProductSuppliersWidget extends StatefulWidget {
  final int? productId;
  final bool showActions;

  const ProductSuppliersWidget({
    super.key,
    this.productId,
    this.showActions = true,
  });

  @override
  State<ProductSuppliersWidget> createState() => _ProductSuppliersWidgetState();
}

class _ProductSuppliersWidgetState extends State<ProductSuppliersWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSuppliers();
    });
  }

  void _loadSuppliers() {
    final provider = context.read<ProductProvider>();
    if (widget.productId != null) {
      provider.loadProductSuppliers(productId: widget.productId);
    } else {
      provider.loadProductSuppliers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingSubResources) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.productSuppliers.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(provider),
            const SizedBox(height: 16),
            _buildSuppliersList(provider),
          ],
        );
      },
    );
  }

  Widget _buildHeader(ProductProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Fournisseurs (${provider.productSuppliers.length})',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (widget.showActions)
          IconButton(
            onPressed: _showAddSupplierDialog,
            icon: const Icon(Icons.add_business),
            tooltip: 'Ajouter un fournisseur',
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.business_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            widget.productId != null
                ? 'Aucun fournisseur pour ce produit'
                : 'Aucun fournisseur disponible',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          if (widget.showActions) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddSupplierDialog,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un fournisseur'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuppliersList(ProductProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.productSuppliers.length,
      itemBuilder: (context, index) {
        final supplier = provider.productSuppliers[index];
        return _buildSupplierCard(supplier, provider);
      },
    );
  }

  Widget _buildSupplierCard(
    ProductSupplier supplier,
    ProductProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fournisseur ID: ${supplier.idSupplier}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (supplier.productSupplierReference != null)
                        Text(
                          'Réf: ${supplier.productSupplierReference}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
                if (widget.showActions)
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleAction(value, supplier, provider),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Modifier'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Supprimer'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Produit ID',
                    supplier.idProduct.toString(),
                    Icons.inventory,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Attribut ID',
                    supplier.idProductAttribute.toString(),
                    Icons.category,
                  ),
                ),
              ],
            ),

            if (supplier.productSupplierPriceTe != null) ...[
              const SizedBox(height: 8),
              _buildInfoItem(
                'Prix HT',
                '${supplier.productSupplierPriceTe!.toStringAsFixed(2)} €',
                Icons.euro,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleAction(
    String action,
    ProductSupplier supplier,
    ProductProvider provider,
  ) {
    switch (action) {
      case 'edit':
        _showEditSupplierDialog(supplier);
        break;
      case 'delete':
        _showDeleteConfirmation(supplier, provider);
        break;
    }
  }

  void _showAddSupplierDialog() {
    showDialog(
      context: context,
      builder: (context) => ProductSupplierDialog(
        productId: widget.productId,
        onSupplierSaved: _loadSuppliers,
      ),
    );
  }

  void _showEditSupplierDialog(ProductSupplier supplier) {
    showDialog(
      context: context,
      builder: (context) => ProductSupplierDialog(
        supplier: supplier,
        productId: widget.productId,
        onSupplierSaved: _loadSuppliers,
      ),
    );
  }

  void _showDeleteConfirmation(
    ProductSupplier supplier,
    ProductProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce fournisseur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (supplier.id != null) {
                final success = await provider.deleteProductSupplier(
                  supplier.id!,
                  supplier.idProduct,
                );
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fournisseur supprimé avec succès'),
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

/// Dialog pour ajouter/modifier un fournisseur de produit
class ProductSupplierDialog extends StatefulWidget {
  final ProductSupplier? supplier;
  final int? productId;
  final VoidCallback? onSupplierSaved;

  const ProductSupplierDialog({
    super.key,
    this.supplier,
    this.productId,
    this.onSupplierSaved,
  });

  @override
  State<ProductSupplierDialog> createState() => _ProductSupplierDialogState();
}

class _ProductSupplierDialogState extends State<ProductSupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _productIdController;
  late final TextEditingController _productAttributeController;
  late final TextEditingController _supplierIdController;
  late final TextEditingController _currencyIdController;
  late final TextEditingController _referenceController;
  late final TextEditingController _priceController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _productIdController = TextEditingController(
      text:
          widget.supplier?.idProduct.toString() ??
          widget.productId?.toString() ??
          '',
    );
    _productAttributeController = TextEditingController(
      text: widget.supplier?.idProductAttribute.toString() ?? '0',
    );
    _supplierIdController = TextEditingController(
      text: widget.supplier?.idSupplier.toString() ?? '',
    );
    _currencyIdController = TextEditingController(
      text: widget.supplier?.idCurrency?.toString() ?? '',
    );
    _referenceController = TextEditingController(
      text: widget.supplier?.productSupplierReference ?? '',
    );
    _priceController = TextEditingController(
      text: widget.supplier?.productSupplierPriceTe?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _productIdController.dispose();
    _productAttributeController.dispose();
    _supplierIdController.dispose();
    _currencyIdController.dispose();
    _referenceController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.supplier == null
            ? 'Ajouter un fournisseur'
            : 'Modifier le fournisseur',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _productIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Produit *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Champ requis';
                    if (int.tryParse(value!) == null) return 'Nombre invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _productAttributeController,
                  decoration: const InputDecoration(
                    labelText: 'ID Attribut Produit *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Champ requis';
                    if (int.tryParse(value!) == null) return 'Nombre invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _supplierIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Fournisseur *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Champ requis';
                    if (int.tryParse(value!) == null) return 'Nombre invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _currencyIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Devise',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isNotEmpty ?? false) {
                      if (int.tryParse(value!) == null)
                        return 'Nombre invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Référence fournisseur',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 64,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix HT',
                    border: OutlineInputBorder(),
                    suffixText: '€',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value?.isNotEmpty ?? false) {
                      if (double.tryParse(value!) == null)
                        return 'Prix invalide';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveSupplier,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.supplier == null ? 'Ajouter' : 'Modifier'),
        ),
      ],
    );
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supplier = ProductSupplier(
        id: widget.supplier?.id,
        idProduct: int.parse(_productIdController.text),
        idProductAttribute: int.parse(_productAttributeController.text),
        idSupplier: int.parse(_supplierIdController.text),
        idCurrency: _currencyIdController.text.isNotEmpty
            ? int.parse(_currencyIdController.text)
            : null,
        productSupplierReference: _referenceController.text.isNotEmpty
            ? _referenceController.text
            : null,
        productSupplierPriceTe: _priceController.text.isNotEmpty
            ? double.parse(_priceController.text)
            : null,
      );

      final provider = context.read<ProductProvider>();
      bool success;

      if (widget.supplier == null) {
        success = await provider.createProductSupplier(supplier);
      } else {
        success = await provider.updateProductSupplier(
          widget.supplier!.id!,
          supplier,
        );
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        widget.onSupplierSaved?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.supplier == null
                  ? 'Fournisseur ajouté avec succès'
                  : 'Fournisseur modifié avec succès',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
