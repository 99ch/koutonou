import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';

/// Page de formulaire pour créer ou éditer une catégorie
class CategoryFormPage extends StatefulWidget {
  final Category? category;

  const CategoryFormPage({super.key, this.category});

  bool get isEditing => category != null;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _metaTitleController = TextEditingController();
  final _metaDescriptionController = TextEditingController();
  final _metaKeywordsController = TextEditingController();
  final _linkRewriteController = TextEditingController();

  bool _active = true;
  bool _isRootCategory = true;
  Category? _selectedParentCategory;
  List<Category> _availableParents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadParentCategories();
  }

  void _initializeForm() {
    if (widget.isEditing) {
      final category = widget.category!;
      _nameController.text = category.name;
      _descriptionController.text = category.description ?? '';
      _metaTitleController.text = category.metaTitle ?? '';
      _metaDescriptionController.text = category.metaDescription ?? '';
      _metaKeywordsController.text = category.metaKeywords ?? '';
      _linkRewriteController.text = category.linkRewrite;
      _active = category.active;
      _isRootCategory = category.idParent == null || category.idParent == 0;
    }
  }

  Future<void> _loadParentCategories() async {
    if (!mounted) return;

    final provider = context.read<CategoryProvider>();
    await provider.loadCategories(reset: true);

    if (mounted) {
      setState(() {
        _availableParents = provider.categories
            .where((cat) {
              // Exclure la catégorie actuelle si on édite
              if (widget.isEditing && cat.id == widget.category!.id) {
                return false;
              }
              return true;
            })
            .cast<Category>()
            .toList();

        // Sélectionner le parent actuel si on édite
        if (widget.isEditing && widget.category!.idParent != null) {
          _selectedParentCategory = _availableParents.firstWhere(
            (cat) => cat.id == widget.category!.idParent,
            orElse: () => _availableParents.first,
          );
          _isRootCategory = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
          widget.isEditing ? 'Modifier la catégorie' : 'Nouvelle catégorie',
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveCategory,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sauvegarder'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Informations de base
            _buildSectionHeader('Informations de base'),
            _buildNameField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildActiveSwitch(),

            const SizedBox(height: 24),

            // Hiérarchie
            _buildSectionHeader('Hiérarchie'),
            _buildParentCategorySection(),

            const SizedBox(height: 24),

            // SEO
            _buildSectionHeader('Référencement (SEO)'),
            _buildMetaTitleField(),
            const SizedBox(height: 16),
            _buildMetaDescriptionField(),
            const SizedBox(height: 16),
            _buildMetaKeywordsField(),
            const SizedBox(height: 16),
            _buildLinkRewriteField(),

            const SizedBox(height: 32),

            // Boutons d'action
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nom de la catégorie *',
        hintText: 'Entrez le nom de la catégorie',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Le nom est obligatoire';
        }
        if (value.trim().length < 2) {
          return 'Le nom doit contenir au moins 2 caractères';
        }
        return null;
      },
      onChanged: (value) {
        // Auto-générer le link_rewrite si vide
        if (_linkRewriteController.text.isEmpty) {
          _linkRewriteController.text = _generateSlug(value);
        }
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Description de la catégorie',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildActiveSwitch() {
    return SwitchListTile(
      title: const Text('Catégorie active'),
      subtitle: const Text('La catégorie sera visible sur le site'),
      value: _active,
      onChanged: (value) {
        setState(() {
          _active = value;
        });
      },
    );
  }

  Widget _buildParentCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Catégorie racine'),
          subtitle: const Text('Cette catégorie n\'a pas de parent'),
          value: _isRootCategory,
          onChanged: (value) {
            setState(() {
              _isRootCategory = value;
              if (value) {
                _selectedParentCategory = null;
              }
            });
          },
        ),
        if (!_isRootCategory) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<Category>(
            value: _selectedParentCategory,
            decoration: const InputDecoration(
              labelText: 'Catégorie parente',
              border: OutlineInputBorder(),
            ),
            items: _availableParents.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (category) {
              setState(() {
                _selectedParentCategory = category;
              });
            },
            validator: (value) {
              if (!_isRootCategory && value == null) {
                return 'Sélectionnez une catégorie parente';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildMetaTitleField() {
    return TextFormField(
      controller: _metaTitleController,
      decoration: const InputDecoration(
        labelText: 'Titre meta',
        hintText: 'Titre pour les moteurs de recherche',
        border: OutlineInputBorder(),
      ),
      maxLength: 70,
    );
  }

  Widget _buildMetaDescriptionField() {
    return TextFormField(
      controller: _metaDescriptionController,
      decoration: const InputDecoration(
        labelText: 'Description meta',
        hintText: 'Description pour les moteurs de recherche',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
      maxLength: 160,
    );
  }

  Widget _buildMetaKeywordsField() {
    return TextFormField(
      controller: _metaKeywordsController,
      decoration: const InputDecoration(
        labelText: 'Mots-clés meta',
        hintText: 'Mots-clés séparés par des virgules',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildLinkRewriteField() {
    return TextFormField(
      controller: _linkRewriteController,
      decoration: const InputDecoration(
        labelText: 'URL personnalisée',
        hintText: 'URL conviviale pour cette catégorie',
        border: OutlineInputBorder(),
        prefixText: '/',
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (!RegExp(r'^[a-z0-9-]+$').hasMatch(value)) {
            return 'Utilisez uniquement des lettres minuscules, chiffres et tirets';
          }
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveCategory,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(widget.isEditing ? 'Modifier' : 'Créer'),
          ),
        ),
      ],
    );
  }

  String _generateSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ýÿ]'), 'y')
        .replaceAll('ç', 'c')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<CategoryProvider>();

      final category = Category(
        id: widget.category?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        active: _active,
        idParent: _isRootCategory ? null : _selectedParentCategory?.id,
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
            ? _generateSlug(_nameController.text.trim())
            : _linkRewriteController.text.trim(),
        position: widget.category?.position ?? 0,
        productIds: widget.category?.productIds ?? [],
        dateAdd: widget.category?.dateAdd,
        dateUpd: widget.category?.dateUpd,
      );

      bool success;
      if (widget.isEditing) {
        success = await provider.updateCategory(category);
      } else {
        success = await provider.createCategory(category);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isEditing
                    ? 'Catégorie modifiée avec succès'
                    : 'Catégorie créée avec succès',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erreur lors de ${widget.isEditing ? 'la modification' : 'la création'} de la catégorie',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
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
