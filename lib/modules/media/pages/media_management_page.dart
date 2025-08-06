import 'package:flutter/material.dart';
import '../widgets/image_upload_widget.dart';
import '../widgets/image_gallery_widget.dart';
import '../widgets/image_type_manager_widget.dart';
import '../models/image_model.dart';

/// Page principale de gestion des médias
class MediaManagementPage extends StatefulWidget {
  const MediaManagementPage({Key? key}) : super(key: key);

  @override
  _MediaManagementPageState createState() => _MediaManagementPageState();
}

class _MediaManagementPageState extends State<MediaManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ImageCategory _selectedCategory = ImageCategory.products;
  int? _selectedEntityId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Gestion des Médias'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.photo_library), text: 'Galerie'),
            Tab(icon: Icon(Icons.upload), text: 'Upload'),
            Tab(icon: Icon(Icons.settings), text: 'Types d\'Images'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet Galerie
          _buildGalleryTab(),

          // Onglet Upload
          _buildUploadTab(),

          // Onglet Types d'Images
          _buildImageTypesTab(),
        ],
      ),
    );
  }

  Widget _buildGalleryTab() {
    return Column(
      children: [
        // Filtres
        _buildGalleryFilters(),

        // Galerie
        Expanded(
          child: ImageGalleryWidget(
            category: _selectedCategory,
            entityId: _selectedEntityId,
            title: 'Images ${_getCategoryDisplayName(_selectedCategory)}',
            showActions: true,
            allowMultiSelect: true,
            onRefresh: () {
              // Refresh callback
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtres',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),

            // Sélecteur de catégorie
            Row(
              children: [
                const Text('Catégorie: '),
                Expanded(
                  child: DropdownButton<ImageCategory>(
                    value: _selectedCategory,
                    isExpanded: true,
                    onChanged: (ImageCategory? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                          _selectedEntityId = null; // Reset entity filter
                        });
                      }
                    },
                    items: ImageCategory.values.map((ImageCategory category) {
                      return DropdownMenuItem<ImageCategory>(
                        value: category,
                        child: Text(_getCategoryDisplayName(category)),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Filtre par entité
            Row(
              children: [
                const Text('Entité ID: '),
                Expanded(
                  child: TextFormField(
                    initialValue: _selectedEntityId?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Tous (optionnel)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedEntityId = int.tryParse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Informations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload d\'Images',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Uploadez des images pour vos ${_getCategoryDisplayName(_selectedCategory).toLowerCase()}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sélecteur de catégorie pour upload
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Catégorie: '),
                  Expanded(
                    child: DropdownButton<ImageCategory>(
                      value: _selectedCategory,
                      isExpanded: true,
                      onChanged: (ImageCategory? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                      items: ImageCategory.values.map((ImageCategory category) {
                        return DropdownMenuItem<ImageCategory>(
                          value: category,
                          child: Text(_getCategoryDisplayName(category)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ID de l'entité pour l'upload
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ID de l\'entité',
                  hintText: 'Ex: 1, 2, 3...',
                  helperText:
                      'L\'ID du ${_getCategoryDisplayName(_selectedCategory).toLowerCase().substring(0, _getCategoryDisplayName(_selectedCategory).length - 1)} concerné',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedEntityId = int.tryParse(value);
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Widget d'upload simple
          if (_selectedEntityId != null) ...[
            ImageUploadWidget(
              category: _selectedCategory,
              entityId: _selectedEntityId!,
              title: 'Upload Simple',
              hint: 'Sélectionnez une image à uploader',
              onUploadComplete: () {
                // Callback après upload
              },
            ),

            const SizedBox(height: 16),

            // Widget d'upload multiple
            MultiImageUploadWidget(
              category: _selectedCategory,
              entityId: _selectedEntityId!,
              title: 'Upload Multiple',
              maxImages: 10,
              onUploadComplete: () {
                // Callback après upload
              },
            ),
          ] else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Veuillez saisir un ID d\'entité pour commencer l\'upload',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageTypesTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: ImageTypeManagerWidget(title: 'Gestion des Types d\'Images'),
    );
  }

  String _getCategoryDisplayName(ImageCategory category) {
    switch (category) {
      case ImageCategory.products:
        return 'Produits';
      case ImageCategory.categories:
        return 'Catégories';
      case ImageCategory.manufacturers:
        return 'Fabricants';
      case ImageCategory.suppliers:
        return 'Fournisseurs';
      case ImageCategory.stores:
        return 'Magasins';
      case ImageCategory.customizations:
        return 'Personnalisations';
      case ImageCategory.general:
        return 'Général';
    }
  }
}
