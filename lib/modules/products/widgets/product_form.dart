import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product_model.dart';

/// Formulaire pour créer ou modifier un produit
class ProductForm extends StatefulWidget {
  final Product? product; // null pour création, non-null pour modification
  final Function(Product) onSave;
  final VoidCallback? onCancel;

  const ProductForm({
    super.key,
    this.product,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _ean13Controller = TextEditingController();
  final _upcController = TextEditingController();
  final _weightController = TextEditingController();
  final _categoryIdController = TextEditingController();

  // SEO
  final _metaTitleController = TextEditingController();
  final _metaDescriptionController = TextEditingController();
  final _metaKeywordsController = TextEditingController();
  final _linkRewriteController = TextEditingController();

  bool _active = true;
  bool _showPrice = true;
  bool _indexed = true;
  bool _onSale = false;
  String _condition = 'new';

  final List<String> _conditions = ['new', 'used', 'refurbished'];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.product != null) {
      final product = widget.product!;
      _nameController.text = product.name;
      _priceController.text = product.price.toStringAsFixed(2);
      _referenceController.text = product.reference ?? '';
      _descriptionController.text = product.description ?? '';
      _shortDescriptionController.text = product.shortDescription ?? '';
      _ean13Controller.text = product.ean13 ?? '';
      _upcController.text = product.upc ?? '';
      _weightController.text = product.weight?.toString() ?? '';
      _categoryIdController.text = product.categoryId.toString();

      _active = product.active;
      _showPrice = product.showPrice;
      _indexed = product.indexed;
      _onSale = product.onSale;
      _condition = product.condition ?? 'new';

      // SEO
      _metaTitleController.text = product.seo.metaTitle ?? '';
      _metaDescriptionController.text = product.seo.metaDescription ?? '';
      _metaKeywordsController.text = product.seo.metaKeywords ?? '';
      _linkRewriteController.text = product.seo.linkRewrite ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    _shortDescriptionController.dispose();
    _ean13Controller.dispose();
    _upcController.dispose();
    _weightController.dispose();
    _categoryIdController.dispose();
    _metaTitleController.dispose();
    _metaDescriptionController.dispose();
    _metaKeywordsController.dispose();
    _linkRewriteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Nouveau produit' : 'Modifier le produit',
        ),
        actions: [
          TextButton(onPressed: _saveProduct, child: const Text('Enregistrer')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildDescriptionSection(),
              const SizedBox(height: 24),
              _buildTechnicalSection(),
              const SizedBox(height: 24),
              _buildOptionsSection(),
              const SizedBox(height: 24),
              _buildSeoSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection('Informations de base', [
      TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Nom du produit *',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Le nom est requis';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Prix *',
                border: OutlineInputBorder(),
                suffixText: '€',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le prix est requis';
                }
                if (double.tryParse(value) == null) {
                  return 'Prix invalide';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _categoryIdController,
              decoration: const InputDecoration(
                labelText: 'ID Catégorie *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La catégorie est requise';
                }
                if (int.tryParse(value) == null) {
                  return 'ID invalide';
                }
                return null;
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _referenceController,
        decoration: const InputDecoration(
          labelText: 'Référence',
          border: OutlineInputBorder(),
        ),
      ),
    ]);
  }

  Widget _buildDescriptionSection() {
    return _buildSection('Descriptions', [
      TextFormField(
        controller: _shortDescriptionController,
        decoration: const InputDecoration(
          labelText: 'Description courte',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _descriptionController,
        decoration: const InputDecoration(
          labelText: 'Description complète',
          border: OutlineInputBorder(),
        ),
        maxLines: 5,
      ),
    ]);
  }

  Widget _buildTechnicalSection() {
    return _buildSection('Informations techniques', [
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _ean13Controller,
              decoration: const InputDecoration(
                labelText: 'EAN13',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 13,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _upcController,
              decoration: const InputDecoration(
                labelText: 'UPC',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Poids',
                border: OutlineInputBorder(),
                suffixText: 'kg',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _condition,
              decoration: const InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
              items: _conditions.map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Text(_getConditionLabel(condition)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _condition = value ?? 'new';
                });
              },
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildOptionsSection() {
    return _buildSection('Options', [
      SwitchListTile(
        title: const Text('Produit actif'),
        subtitle: const Text('Le produit est visible sur le site'),
        value: _active,
        onChanged: (value) {
          setState(() {
            _active = value;
          });
        },
      ),
      SwitchListTile(
        title: const Text('Afficher le prix'),
        subtitle: const Text('Le prix sera visible sur le site'),
        value: _showPrice,
        onChanged: (value) {
          setState(() {
            _showPrice = value;
          });
        },
      ),
      SwitchListTile(
        title: const Text('Indexé par les moteurs de recherche'),
        subtitle: const Text('Le produit peut être indexé par Google, etc.'),
        value: _indexed,
        onChanged: (value) {
          setState(() {
            _indexed = value;
          });
        },
      ),
      SwitchListTile(
        title: const Text('En promotion'),
        subtitle: const Text('Le produit est affiché comme étant en promo'),
        value: _onSale,
        onChanged: (value) {
          setState(() {
            _onSale = value;
          });
        },
      ),
    ]);
  }

  Widget _buildSeoSection() {
    return _buildSection('SEO', [
      TextFormField(
        controller: _metaTitleController,
        decoration: const InputDecoration(
          labelText: 'Meta titre',
          border: OutlineInputBorder(),
        ),
        maxLength: 70,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _metaDescriptionController,
        decoration: const InputDecoration(
          labelText: 'Meta description',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
        maxLength: 160,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _metaKeywordsController,
        decoration: const InputDecoration(
          labelText: 'Meta mots-clés',
          border: OutlineInputBorder(),
          helperText: 'Séparez les mots-clés par des virgules',
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _linkRewriteController,
        decoration: const InputDecoration(
          labelText: 'URL réécrite',
          border: OutlineInputBorder(),
          helperText: 'Utilisez uniquement des lettres, chiffres et tirets',
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]')),
        ],
      ),
    ]);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveProduct,
            child: const Text('Enregistrer'),
          ),
        ),
      ],
    );
  }

  String _getConditionLabel(String condition) {
    switch (condition) {
      case 'new':
        return 'Neuf';
      case 'used':
        return 'Occasion';
      case 'refurbished':
        return 'Reconditionné';
      default:
        return condition;
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        reference: _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(),
        active: _active,
        categoryId: int.parse(_categoryIdController.text),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        shortDescription: _shortDescriptionController.text.trim().isEmpty
            ? null
            : _shortDescriptionController.text.trim(),
        ean13: _ean13Controller.text.trim().isEmpty
            ? null
            : _ean13Controller.text.trim(),
        upc: _upcController.text.trim().isEmpty
            ? null
            : _upcController.text.trim(),
        weight: _weightController.text.trim().isEmpty
            ? null
            : double.parse(_weightController.text),
        condition: _condition,
        showPrice: _showPrice,
        indexed: _indexed,
        onSale: _onSale,
        categoryIds: [int.parse(_categoryIdController.text)],
        seo: ProductSeo(
          metaTitle: _metaTitleController.text.trim().isEmpty
              ? null
              : _metaTitleController.text.trim(),
          metaDescription: _metaDescriptionController.text.trim().isEmpty
              ? null
              : _metaDescriptionController.text.trim(),
          metaKeywords: _metaKeywordsController.text.trim().isEmpty
              ? null
              : _metaKeywordsController.text.trim(),
          linkRewrite: _linkRewriteController.text.trim().isEmpty
              ? null
              : _linkRewriteController.text.trim(),
        ),
      );

      widget.onSave(product);
    }
  }
}
