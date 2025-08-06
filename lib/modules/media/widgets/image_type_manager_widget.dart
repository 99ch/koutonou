import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../models/image_type_model.dart';

/// Widget pour gérer les types d'images
class ImageTypeManagerWidget extends StatefulWidget {
  final String? title;
  final Function(ImageType)? onImageTypeSelected;

  const ImageTypeManagerWidget({Key? key, this.title, this.onImageTypeSelected})
    : super(key: key);

  @override
  _ImageTypeManagerWidgetState createState() => _ImageTypeManagerWidgetState();
}

class _ImageTypeManagerWidgetState extends State<ImageTypeManagerWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MediaProvider>().loadImageTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaProvider>(
      builder: (context, mediaProvider, child) {
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              _buildHeader(mediaProvider),

              // Message d'erreur
              if (mediaProvider.imageTypesError != null)
                _buildErrorMessage(mediaProvider.imageTypesError!),

              // État de chargement
              if (mediaProvider.isLoadingImageTypes)
                _buildLoadingIndicator()
              else
                // Liste des types d'images
                Expanded(
                  child: mediaProvider.imageTypes.isEmpty
                      ? _buildEmptyState()
                      : _buildImageTypesList(mediaProvider.imageTypes),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(MediaProvider mediaProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (widget.title != null)
            Expanded(
              child: Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

          // Compteur de types
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${mediaProvider.imageTypes.length} type${mediaProvider.imageTypes.length > 1 ? 's' : ''}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Bouton ajouter
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateImageTypeDialog(),
            tooltip: 'Ajouter un type d\'image',
          ),

          // Bouton refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => mediaProvider.loadImageTypes(),
            tooltip: 'Actualiser',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(error, style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_aspect_ratio, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aucun type d\'image trouvé',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showCreateImageTypeDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Créer un type d\'image'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageTypesList(List<ImageType> imageTypes) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: imageTypes.length,
      itemBuilder: (context, index) {
        return _buildImageTypeItem(imageTypes[index]);
      },
    );
  }

  Widget _buildImageTypeItem(ImageType imageType) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            imageType.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          imageType.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('${imageType.width}x${imageType.height}px'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicateur actif
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handleImageTypeAction(value, imageType),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Modifier'),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Supprimer'),
                    dense: true,
                  ),
                ),
                if (widget.onImageTypeSelected != null)
                  const PopupMenuItem(
                    value: 'select',
                    child: ListTile(
                      leading: Icon(Icons.check),
                      title: Text('Sélectionner'),
                      dense: true,
                    ),
                  ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dimensions et propriétés
                Row(
                  children: [
                    _buildInfoChip('Largeur', '${imageType.width}px'),
                    const SizedBox(width: 8),
                    _buildInfoChip('Hauteur', '${imageType.height}px'),
                  ],
                ),
                const SizedBox(height: 8),

                // Catégories supportées
                const Text(
                  'Catégories supportées:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (imageType.products) _buildCategoryChip('Produits'),
                    if (imageType.categories) _buildCategoryChip('Catégories'),
                    if (imageType.manufacturers)
                      _buildCategoryChip('Fabricants'),
                    if (imageType.suppliers) _buildCategoryChip('Fournisseurs'),
                    if (imageType.stores) _buildCategoryChip('Magasins'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleImageTypeAction(String action, ImageType imageType) async {
    final mediaProvider = context.read<MediaProvider>();

    switch (action) {
      case 'edit':
        _showEditImageTypeDialog(imageType);
        break;
      case 'delete':
        final confirmed = await _showDeleteConfirmationDialog(imageType.name);
        if (confirmed == true) {
          final success = await mediaProvider.deleteImageType(imageType.id!);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Type d\'image supprimé')),
            );
          }
        }
        break;
      case 'select':
        widget.onImageTypeSelected?.call(imageType);
        break;
    }
  }

  void _showCreateImageTypeDialog() {
    _showImageTypeDialog(null);
  }

  void _showEditImageTypeDialog(ImageType imageType) {
    _showImageTypeDialog(imageType);
  }

  void _showImageTypeDialog(ImageType? imageType) {
    final isEdit = imageType != null;
    final nameController = TextEditingController(text: imageType?.name ?? '');
    final widthController = TextEditingController(
      text: imageType?.width.toString() ?? '',
    );
    final heightController = TextEditingController(
      text: imageType?.height.toString() ?? '',
    );

    bool products = imageType?.products ?? true;
    bool categories = imageType?.categories ?? false;
    bool manufacturers = imageType?.manufacturers ?? false;
    bool suppliers = imageType?.suppliers ?? false;
    bool stores = imageType?.stores ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            isEdit ? 'Modifier le type d\'image' : 'Nouveau type d\'image',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Largeur (px)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Hauteur (px)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text(
                  'Catégories supportées:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                CheckboxListTile(
                  title: const Text('Produits'),
                  value: products,
                  onChanged: (value) =>
                      setState(() => products = value ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Catégories'),
                  value: categories,
                  onChanged: (value) =>
                      setState(() => categories = value ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Fabricants'),
                  value: manufacturers,
                  onChanged: (value) =>
                      setState(() => manufacturers = value ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Fournisseurs'),
                  value: suppliers,
                  onChanged: (value) =>
                      setState(() => suppliers = value ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Magasins'),
                  value: stores,
                  onChanged: (value) => setState(() => stores = value ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => _saveImageType(
                context,
                isEdit,
                imageType?.id,
                nameController.text,
                int.tryParse(widthController.text) ?? 0,
                int.tryParse(heightController.text) ?? 0,
                products,
                categories,
                manufacturers,
                suppliers,
                stores,
              ),
              child: Text(isEdit ? 'Modifier' : 'Créer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveImageType(
    BuildContext context,
    bool isEdit,
    int? id,
    String name,
    int width,
    int height,
    bool products,
    bool categories,
    bool manufacturers,
    bool suppliers,
    bool stores,
  ) async {
    if (name.isEmpty || width <= 0 || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final newImageType = ImageType(
      id: isEdit ? id : null,
      name: name,
      width: width,
      height: height,
      products: products,
      categories: categories,
      manufacturers: manufacturers,
      suppliers: suppliers,
      stores: stores,
    );

    final mediaProvider = context.read<MediaProvider>();
    bool success;

    if (isEdit && id != null) {
      success = await mediaProvider.updateImageType(id, newImageType);
    } else {
      success = await mediaProvider.createImageType(newImageType);
    }

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Type d\'image modifié avec succès'
                : 'Type d\'image créé avec succès',
          ),
        ),
      );
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(String typeName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le type d\'image'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le type "$typeName" ?',
        ),
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
  }
}
