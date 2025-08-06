import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/media_provider.dart';
import '../models/image_model.dart';

/// Widget pour uploader une seule image
class ImageUploadWidget extends StatefulWidget {
  final ImageCategory category;
  final int entityId;
  final VoidCallback? onUploadComplete;
  final String? title;
  final String? hint;

  const ImageUploadWidget({
    Key? key,
    required this.category,
    required this.entityId,
    this.onUploadComplete,
    this.title,
    this.hint,
  }) : super(key: key);

  @override
  _ImageUploadWidgetState createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaProvider>(
      builder: (context, mediaProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null)
                  Text(
                    widget.title!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                if (widget.title != null) const SizedBox(height: 8),

                // Zone de sélection d'image
                _buildImageSelector(),

                const SizedBox(height: 16),

                // Preview de l'image sélectionnée
                if (_selectedImage != null) _buildImagePreview(),

                // Barre de progression
                if (mediaProvider.isUploading) _buildProgressBar(mediaProvider),

                // Boutons d'action
                _buildActionButtons(mediaProvider),

                // Message d'erreur
                if (mediaProvider.uploadError != null)
                  _buildErrorMessage(mediaProvider.uploadError!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSelector() {
    return GestureDetector(
      onTap: _selectImage,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              widget.hint ?? 'Cliquez pour sélectionner une image',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _selectedImage!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.red,
              radius: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(MediaProvider mediaProvider) {
    return Column(
      children: [
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: mediaProvider.uploadProgress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(mediaProvider.uploadProgress * 100).round()}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildActionButtons(MediaProvider mediaProvider) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _selectedImage != null && !mediaProvider.isUploading
              ? _uploadImage
              : null,
          icon: const Icon(Icons.upload),
          label: const Text('Uploader'),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _selectedImage != null ? _clearSelection : null,
          child: const Text('Annuler'),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection: $e')),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    final mediaProvider = context.read<MediaProvider>();

    final image = await mediaProvider.uploadImage(
      widget.category,
      widget.entityId,
      _selectedImage!,
      onProgress: (progress) {
        // Le progrès est géré par le provider
      },
    );

    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploadée avec succès')),
      );

      _clearSelection();
      widget.onUploadComplete?.call();
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedImage = null;
    });
    context.read<MediaProvider>().resetUploadProgress();
  }
}

/// Widget pour uploader plusieurs images
class MultiImageUploadWidget extends StatefulWidget {
  final ImageCategory category;
  final int entityId;
  final VoidCallback? onUploadComplete;
  final String? title;
  final int maxImages;

  const MultiImageUploadWidget({
    Key? key,
    required this.category,
    required this.entityId,
    this.onUploadComplete,
    this.title,
    this.maxImages = 10,
  }) : super(key: key);

  @override
  _MultiImageUploadWidgetState createState() => _MultiImageUploadWidgetState();
}

class _MultiImageUploadWidgetState extends State<MultiImageUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaProvider>(
      builder: (context, mediaProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null)
                  Text(
                    widget.title!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                if (widget.title != null) const SizedBox(height: 8),

                // Zone de sélection d'images
                _buildImageSelector(),

                const SizedBox(height: 16),

                // Preview des images sélectionnées
                if (_selectedImages.isNotEmpty) _buildImagesPreview(),

                // Barre de progression
                if (mediaProvider.isUploading) _buildProgressBar(mediaProvider),

                // Boutons d'action
                _buildActionButtons(mediaProvider),

                // Message d'erreur
                if (mediaProvider.uploadError != null)
                  _buildErrorMessage(mediaProvider.uploadError!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSelector() {
    return GestureDetector(
      onTap: _selectImages,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Cliquez pour sélectionner plusieurs images',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            Text(
              'Maximum ${widget.maxImages} images',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_selectedImages.length} image(s) sélectionnée(s)',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImages[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 12,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(MediaProvider mediaProvider) {
    return Column(
      children: [
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: mediaProvider.uploadProgress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload en cours... ${(mediaProvider.uploadProgress * 100).round()}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildActionButtons(MediaProvider mediaProvider) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _selectedImages.isNotEmpty && !mediaProvider.isUploading
              ? _uploadImages
              : null,
          icon: const Icon(Icons.upload),
          label: Text('Uploader (${_selectedImages.length})'),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _selectedImages.isNotEmpty ? _clearSelection : null,
          child: const Text('Tout effacer'),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final totalImages = _selectedImages.length + images.length;
        if (totalImages > widget.maxImages) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum ${widget.maxImages} images autorisées'),
            ),
          );
          return;
        }

        setState(() {
          _selectedImages.addAll(images.map((x) => File(x.path)).toList());
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection: $e')),
      );
    }
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) return;

    final mediaProvider = context.read<MediaProvider>();

    final uploadedImages = await mediaProvider.uploadMultipleImages(
      widget.category,
      widget.entityId,
      _selectedImages,
      onProgress: (progress) {
        // Le progrès est géré par le provider
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${uploadedImages.length} image(s) uploadée(s) avec succès',
        ),
      ),
    );

    _clearSelection();
    widget.onUploadComplete?.call();
  }

  void _clearSelection() {
    setState(() {
      _selectedImages.clear();
    });
    context.read<MediaProvider>().resetUploadProgress();
  }
}
