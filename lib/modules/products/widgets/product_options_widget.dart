import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_option_model.dart';
import '../models/product_option_value_model.dart';
import '../models/product_feature_model.dart';
import '../models/product_feature_value_model.dart';
import '../providers/product_provider.dart';

/// Widget pour afficher et gérer les options de produits
class ProductOptionsWidget extends StatefulWidget {
  final bool showActions;

  const ProductOptionsWidget({super.key, this.showActions = true});

  @override
  State<ProductOptionsWidget> createState() => _ProductOptionsWidgetState();
}

class _ProductOptionsWidgetState extends State<ProductOptionsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOptions();
    });
  }

  void _loadOptions() {
    final provider = context.read<ProductProvider>();
    provider.loadProductOptions();
    provider.loadProductOptionValues();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingSubResources) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(provider),
            const SizedBox(height: 16),
            if (provider.productOptions.isEmpty)
              _buildEmptyState()
            else
              _buildOptionsList(provider),
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
          'Options de produits (${provider.productOptions.length})',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (widget.showActions)
          IconButton(
            onPressed: _loadOptions,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.tune, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Aucune option de produit disponible',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList(ProductProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.productOptions.length,
      itemBuilder: (context, index) {
        final option = provider.productOptions[index];
        return _buildOptionCard(option, provider);
      },
    );
  }

  Widget _buildOptionCard(ProductOption option, ProductProvider provider) {
    final optionValues = provider.productOptionValues
        .where((value) => value.idAttributeGroup == option.id)
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: option.isColorGroup == true ? Colors.purple : Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            option.isColorGroup == true ? Icons.palette : Icons.tune,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          option.getNameInLanguage('1'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${option.groupType}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            if (option.isColorGroup == true)
              const Chip(
                label: Text('Groupe couleur'),
                backgroundColor: Colors.purple,
                labelStyle: TextStyle(color: Colors.white, fontSize: 10),
              ),
          ],
        ),
        children: [
          if (optionValues.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valeurs disponibles (${optionValues.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: optionValues
                        .map((value) => _buildValueChip(value))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Aucune valeur disponible pour cette option',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildValueChip(ProductOptionValue value) {
    return Chip(
      avatar: value.isColor
          ? Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _parseColor(value.color!),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            )
          : const Icon(Icons.label, size: 16),
      label: Text(
        value.getNameInLanguage('1'),
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: value.isColor
          ? _parseColor(value.color!).withOpacity(0.1)
          : null,
    );
  }

  Color _parseColor(String colorString) {
    try {
      String cleanColor = colorString.replaceAll('#', '');
      if (cleanColor.length == 6) {
        return Color(int.parse('0xFF$cleanColor'));
      }
    } catch (e) {
      // Si le parsing échoue, retourner une couleur par défaut
    }
    return Colors.grey;
  }
}

/// Widget pour afficher les caractéristiques de produits
class ProductFeaturesWidget extends StatefulWidget {
  final bool showActions;

  const ProductFeaturesWidget({super.key, this.showActions = true});

  @override
  State<ProductFeaturesWidget> createState() => _ProductFeaturesWidgetState();
}

class _ProductFeaturesWidgetState extends State<ProductFeaturesWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeatures();
    });
  }

  void _loadFeatures() {
    final provider = context.read<ProductProvider>();
    provider.loadProductFeatures();
    provider.loadProductFeatureValues();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingSubResources) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(provider),
            const SizedBox(height: 16),
            if (provider.productFeatures.isEmpty)
              _buildEmptyState()
            else
              _buildFeaturesList(provider),
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
          'Caractéristiques (${provider.productFeatures.length})',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (widget.showActions)
          IconButton(
            onPressed: _loadFeatures,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.featured_play_list_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune caractéristique disponible',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(ProductProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.productFeatures.length,
      itemBuilder: (context, index) {
        final feature = provider.productFeatures[index];
        return _buildFeatureCard(feature, provider);
      },
    );
  }

  Widget _buildFeatureCard(ProductFeature feature, ProductProvider provider) {
    final featureValues = provider.productFeatureValues
        .where((value) => value.idFeature == feature.id)
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.featured_play_list,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          feature.getNameInLanguage('1'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Position: ${feature.position ?? 0}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        children: [
          if (featureValues.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valeurs disponibles (${featureValues.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...featureValues.map(
                    (value) => _buildFeatureValueTile(value),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Aucune valeur disponible pour cette caractéristique',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureValueTile(ProductFeatureValue value) {
    return ListTile(
      dense: true,
      leading: Icon(
        value.custom == true ? Icons.edit : Icons.check_circle,
        size: 16,
        color: value.custom == true ? Colors.orange : Colors.green,
      ),
      title: Text(
        value.getValueInLanguage('1'),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: value.custom == true
          ? const Text('Valeur personnalisée', style: TextStyle(fontSize: 10))
          : null,
    );
  }
}
