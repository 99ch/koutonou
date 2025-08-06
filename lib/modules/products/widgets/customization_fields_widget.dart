import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customization_field_model.dart';
import '../models/price_range_model.dart';
import '../providers/product_provider.dart';

/// Widget pour afficher et gérer les champs de personnalisation d'un produit
class CustomizationFieldsWidget extends StatefulWidget {
  final int? productId;
  final bool showActions;

  const CustomizationFieldsWidget({
    super.key,
    this.productId,
    this.showActions = true,
  });

  @override
  State<CustomizationFieldsWidget> createState() =>
      _CustomizationFieldsWidgetState();
}

class _CustomizationFieldsWidgetState extends State<CustomizationFieldsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomizationFields();
    });
  }

  void _loadCustomizationFields() {
    final provider = context.read<ProductProvider>();
    if (widget.productId != null) {
      provider.loadCustomizationFields(productId: widget.productId);
    } else {
      provider.loadCustomizationFields();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingSubResources) {
          return const Center(child: CircularProgressIndicator());
        }

        final fields = widget.productId != null
            ? provider.customizationFields
                  .where((f) => f.idProduct == widget.productId)
                  .toList()
            : provider.customizationFields;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(fields.length),
            const SizedBox(height: 16),
            if (fields.isEmpty)
              _buildEmptyState()
            else
              _buildFieldsList(fields),
          ],
        );
      },
    );
  }

  Widget _buildHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Champs de personnalisation ($count)',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (widget.showActions)
          IconButton(
            onPressed: _loadCustomizationFields,
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
            Icons.edit_attributes_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            widget.productId != null
                ? 'Aucun champ de personnalisation pour ce produit'
                : 'Aucun champ de personnalisation disponible',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsList(List<CustomizationField> fields) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fields.length,
      itemBuilder: (context, index) {
        final field = fields[index];
        return _buildFieldCard(field);
      },
    );
  }

  Widget _buildFieldCard(CustomizationField field) {
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
                    color: _getTypeColor(field.type),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(field.type),
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
                        field.getNameInLanguage('1'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        field.typeDescription,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (field.required)
                  Chip(
                    label: const Text('Requis'),
                    backgroundColor: Colors.red.withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Produit ID',
                    field.idProduct.toString(),
                    Icons.inventory,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Type',
                    field.type.toString(),
                    Icons.category,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (field.required)
                  _buildStatusChip('Requis', Icons.star, Colors.red),
                if (field.isModule == true)
                  _buildStatusChip('Module', Icons.extension, Colors.blue),
                if (field.isDeleted == true)
                  _buildStatusChip('Supprimé', Icons.delete, Colors.grey),
              ],
            ),
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

  Widget _buildStatusChip(String label, IconData icon, Color color) {
    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 10)),
      avatar: Icon(icon, size: 14, color: color),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Color _getTypeColor(int type) {
    switch (type) {
      case 0: // Texte
        return Colors.blue;
      case 1: // Fichier
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(int type) {
    switch (type) {
      case 0: // Texte
        return Icons.text_fields;
      case 1: // Fichier
        return Icons.attach_file;
      default:
        return Icons.help_outline;
    }
  }
}

/// Widget pour afficher les plages de prix
class PriceRangesWidget extends StatefulWidget {
  final bool showActions;

  const PriceRangesWidget({super.key, this.showActions = true});

  @override
  State<PriceRangesWidget> createState() => _PriceRangesWidgetState();
}

class _PriceRangesWidgetState extends State<PriceRangesWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPriceRanges();
    });
  }

  void _loadPriceRanges() {
    final provider = context.read<ProductProvider>();
    provider.loadPriceRanges();
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
            if (provider.priceRanges.isEmpty)
              _buildEmptyState()
            else
              _buildRangesList(provider),
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
          'Plages de prix (${provider.priceRanges.length})',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (widget.showActions)
          IconButton(
            onPressed: _loadPriceRanges,
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
          const Icon(Icons.price_change_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Aucune plage de prix disponible',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRangesList(ProductProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.priceRanges.length,
      itemBuilder: (context, index) {
        final range = provider.priceRanges[index];
        return _buildRangeCard(range);
      },
    );
  }

  Widget _buildRangeCard(PriceRange range) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.price_change,
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
                    range.rangeDescription,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Transporteur ID: ${range.idCarrier}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Min: ${range.delimiter1.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Max: ${range.delimiter2.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
