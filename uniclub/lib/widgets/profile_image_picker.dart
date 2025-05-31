import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? currentImageUrl;
  final Function(String?) onImageChanged;
  final String userId;
  final String imageType; // 'profile' or 'background'
  final double size;
  final bool isCircular;

  const ProfileImagePicker({
    super.key,
    this.currentImageUrl,
    required this.onImageChanged,
    required this.userId,
    required this.imageType,
    this.size = 100,
    this.isCircular = true,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  final StorageService _storageService = StorageService();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        String? downloadUrl;
        
        if (widget.imageType == 'profile') {
          downloadUrl = await _storageService.uploadProfileImage(
            widget.userId,
            pickedFile,
          );
        } else if (widget.imageType == 'background') {
          downloadUrl = await _storageService.uploadBackgroundImage(
            widget.userId,
            pickedFile,
          );
        }

        if (downloadUrl != null) {
          widget.onImageChanged(downloadUrl);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (_isUploading) {
      imageWidget = Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.isCircular ? null : BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (widget.currentImageUrl != null) {
      imageWidget = widget.isCircular
          ? CircleAvatar(
              radius: widget.size / 2,
              backgroundImage: CachedNetworkImageProvider(widget.currentImageUrl!),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: widget.currentImageUrl!,
                width: widget.size,
                height: widget.size,
                fit: BoxFit.cover,
              ),
            );
    } else {
      imageWidget = Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.isCircular ? null : BorderRadius.circular(12),
        ),
        child: Icon(
          widget.imageType == 'profile' ? Icons.person : Icons.image,
          size: widget.size * 0.4,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return GestureDetector(
      onTap: _isUploading ? null : _pickAndUploadImage,
      child: Stack(
        children: [
          imageWidget,
          if (!_isUploading)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}