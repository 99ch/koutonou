import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_suppliers_widget.dart';
import '../widgets/product_options_widget.dart';
import '../widgets/customization_fields_widget.dart';

/// Page pour gérer toutes les sous-ressources des produits
class ProductSubResourcesPage extends StatefulWidget {
  final int? productId;

  const ProductSubResourcesPage({super.key, this.productId});

  @override
  State<ProductSubResourcesPage> createState() =>
      _ProductSubResourcesPageState();
}

class _ProductSubResourcesPageState extends State<ProductSubResourcesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.productId != null
              ? 'Sous-ressources du produit ${widget.productId}'
              : 'Sous-ressources des produits',
        ),
        actions: [
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: provider.isLoadingSubResources
                    ? null
                    : () => _refreshAll(provider),
                icon: provider.isLoadingSubResources
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                tooltip: 'Actualiser tout',
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.business), text: 'Fournisseurs'),
            Tab(icon: Icon(Icons.tune), text: 'Options'),
            Tab(icon: Icon(Icons.featured_play_list), text: 'Caractéristiques'),
            Tab(icon: Icon(Icons.edit_attributes), text: 'Personnalisation'),
            Tab(icon: Icon(Icons.price_change), text: 'Plages de prix'),
          ],
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.errorMessage != null) {
            return _buildErrorState(provider);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Fournisseurs
              Padding(
                padding: const EdgeInsets.all(16),
                child: ProductSuppliersWidget(productId: widget.productId),
              ),
              // Options
              const Padding(
                padding: EdgeInsets.all(16),
                child: ProductOptionsWidget(),
              ),
              // Caractéristiques
              const Padding(
                padding: EdgeInsets.all(16),
                child: ProductFeaturesWidget(),
              ),
              // Champs de personnalisation
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomizationFieldsWidget(productId: widget.productId),
              ),
              // Plages de prix
              const Padding(
                padding: EdgeInsets.all(16),
                child: PriceRangesWidget(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(ProductProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Erreur',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _refreshAll(provider),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  void _refreshAll(ProductProvider provider) {
    if (widget.productId != null) {
      provider.loadProductSubResources(widget.productId!);
    } else {
      provider.loadProductSuppliers();
      provider.loadProductOptions();
      provider.loadProductOptionValues();
      provider.loadProductFeatures();
      provider.loadProductFeatureValues();
      provider.loadCustomizationFields();
      provider.loadPriceRanges();
    }
  }
}
