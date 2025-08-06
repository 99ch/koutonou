import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../models/image_model.dart';

/// Widget de galerie d'images avec fonctionnalités de gestion
class ImageGalleryWidget extends StatefulWidget {
  final ImageCategory category;
  final int? entityId; // null = toutes les entités
  final String? title;
  final bool showActions;
  final bool allowMultiSelect;
  final Function(List<PrestaShopImage>)? onSelectionChanged;
  final VoidCallback? onRefresh;

  const ImageGalleryWidget({
    Key? key,
    required this.category,
    this.entityId,
    this.title,
    this.showActions = true,
    this.allowMultiSelect = false,
    this.onSelectionChanged,
    this.onRefresh,
  }) : super(key: key);

  @override
  _ImageGalleryWidgetState createState() => _ImageGalleryWidgetState();
}

class _ImageGalleryWidgetState extends State<ImageGalleryWidget> {
  final Set<int> _selectedImageIds = {};
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadImages();
    });
  }

  void _loadImages() {
    context.read<MediaProvider>().loadImages(
      widget.category,
      entityId: widget.entityId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaProvider>(
      builder: (context, mediaProvider, child) {
        final images = widget.entityId != null
            ? mediaProvider.getImagesForEntity(
                widget.category,
                widget.entityId!,
              )
            : mediaProvider.imagesByCategory[widget.category] ?? [];

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              _buildHeader(images.length, mediaProvider),

              // Actions de sélection
              if (widget.allowMultiSelect && _selectedImageIds.isNotEmpty)
                _buildSelectionActions(mediaProvider),

              // Message d'erreur
              if (mediaProvider.imagesError != null)
                _buildErrorMessage(mediaProvider.imagesError!),

              // État de chargement
              if (mediaProvider.isLoadingImages) _buildLoadingIndicator(),

              // Galerie d'images
              Expanded(
                child: images.isEmpty && !mediaProvider.isLoadingImages
                    ? _buildEmptyState()
                    : _buildImageGrid(images),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(int imageCount, MediaProvider mediaProvider) {
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

          // Compteur d'images
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$imageCount image${imageCount > 1 ? 's' : ''}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Toggle vue grille/liste
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'Vue liste' : 'Vue grille',
          ),

          // Bouton refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadImages();
              widget.onRefresh?.call();
            },
            tooltip: 'Actualiser',
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionActions(MediaProvider mediaProvider) {
    final selectedImages =
        (mediaProvider.imagesByCategory[widget.category] ?? [])
            .where((img) => _selectedImageIds.contains(img.id ?? 0))
            .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          Text(
            '${_selectedImageIds.length} sélectionnée(s)',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),

          const Spacer(),

          // Bouton télécharger
          TextButton.icon(
            onPressed: () => _downloadSelectedImages(selectedImages),
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Télécharger'),
          ),

          // Bouton supprimer
          TextButton.icon(
            onPressed: () =>
                _deleteSelectedImages(selectedImages, mediaProvider),
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Supprimer'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),

          // Bouton annuler sélection
          TextButton(onPressed: _clearSelection, child: const Text('Annuler')),
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
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune image trouvée',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Utilisez le widget d\'upload pour ajouter des images',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<PrestaShopImage> images) {
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return _buildImageGridItem(images[index]);
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return _buildImageListItem(images[index]);
        },
      );
    }
  }

  Widget _buildImageGridItem(PrestaShopImage image) {
    final isSelected = _selectedImageIds.contains(image.id ?? 0);
    final mediaProvider = context.read<MediaProvider>();

    return GestureDetector(
      onTap: () => _onImageTap(image),
      onLongPress: widget.allowMultiSelect
          ? () => _toggleSelection(image.id ?? 0)
          : null,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FutureBuilder<Uint8List?>(
                future: mediaProvider.downloadImage(
                  widget.category,
                  image.entityId ?? 0,
                  image.id ?? 0,
                  imageType: 'small_default',
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.memory(
                      snapshot.data!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    );
                  } else {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image,
                        color: Colors.grey.shade400,
                        size: 32,
                      ),
                    );
                  }
                },
              ),
            ),
          ),

          // Indicateur de sélection
          if (widget.allowMultiSelect)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.white.withOpacity(0.8),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade400,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),

          // Actions rapides
          if (widget.showActions && !widget.allowMultiSelect)
            Positioned(
              bottom: 4,
              right: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQuickAction(
                    Icons.download,
                    () => _downloadImage(image),
                  ),
                  const SizedBox(width: 4),
                  _buildQuickAction(
                    Icons.delete,
                    () => _deleteImage(image, mediaProvider),
                    color: Colors.red,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageListItem(PrestaShopImage image) {
    final isSelected = _selectedImageIds.contains(image.id ?? 0);
    final mediaProvider = context.read<MediaProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: SizedBox(
          width: 60,
          height: 60,
          child: FutureBuilder<Uint8List?>(
            future: mediaProvider.downloadImage(
              widget.category,
              image.entityId ?? 0,
              image.id ?? 0,
              imageType: 'small_default',
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                );
              } else {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.image, color: Colors.grey.shade400),
                );
              }
            },
          ),
        ),
        title: Text('Image #${image.id ?? 0}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Entité: ${image.entityId ?? 0}'),
            if (image.legend?.isNotEmpty == true)
              Text('Légende: ${image.legend}'),
          ],
        ),
        selected: isSelected,
        onTap: () => _onImageTap(image),
        onLongPress: widget.allowMultiSelect
            ? () => _toggleSelection(image.id ?? 0)
            : null,
        trailing: widget.showActions
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _downloadImage(image),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteImage(image, mediaProvider),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.6),
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? Colors.white, size: 16),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _onImageTap(PrestaShopImage image) {
    if (widget.allowMultiSelect) {
      _toggleSelection(image.id ?? 0);
    } else {
      // Afficher l'image en grand ou ouvrir une vue détaillée
      _showImageDetail(image);
    }
  }

  void _toggleSelection(int imageId) {
    setState(() {
      if (_selectedImageIds.contains(imageId)) {
        _selectedImageIds.remove(imageId);
      } else {
        _selectedImageIds.add(imageId);
      }
    });

    if (widget.onSelectionChanged != null) {
      final selectedImages =
          (context.read<MediaProvider>().imagesByCategory[widget.category] ??
                  [])
              .where((img) => _selectedImageIds.contains(img.id ?? 0))
              .toList();
      widget.onSelectionChanged!(selectedImages);
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedImageIds.clear();
    });
    widget.onSelectionChanged?.call([]);
  }

  void _showImageDetail(PrestaShopImage image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Image #${image.id ?? 0}'),
        content: Text('Détails de l\'image à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _downloadImage(PrestaShopImage image) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Téléchargement de l\'image #${image.id ?? 0}')),
    );
  }

  void _downloadSelectedImages(List<PrestaShopImage> images) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Téléchargement de ${images.length} images')),
    );
  }

  Future<void> _deleteImage(
    PrestaShopImage image,
    MediaProvider mediaProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'image'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette image ?'),
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

    if (confirmed == true) {
      final success = await mediaProvider.deleteImage(
        widget.category,
        image.entityId ?? 0,
        image.id ?? 0,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image supprimée avec succès')),
        );
      }
    }
  }

  Future<void> _deleteSelectedImages(
    List<PrestaShopImage> images,
    MediaProvider mediaProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer les images'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${images.length} images ?',
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

    if (confirmed == true) {
      int successCount = 0;

      for (final image in images) {
        final success = await mediaProvider.deleteImage(
          widget.category,
          image.entityId ?? 0,
          image.id ?? 0,
        );
        if (success) successCount++;
      }

      _clearSelection();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$successCount images supprimées')),
      );
    }
  }
}
