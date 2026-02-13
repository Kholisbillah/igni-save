import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_theme_colors.dart';

class ImageUploadWidget extends StatelessWidget {
  final File? selectedImage;
  final String? imageUrl;
  final bool isLoading;
  final VoidCallback onTap;

  const ImageUploadWidget({
    super.key,
    this.selectedImage,
    this.imageUrl,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color:
              AppThemeColors.surface, // Changed to surface for better contrast
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppThemeColors.borderLight, // Standard border color
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppThemeColors.primary),
      );
    }

    if (selectedImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(selectedImage!, fit: BoxFit.cover),
          _buildEditIcon(),
        ],
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: AppThemeColors.primary),
              );
            },
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          ),
          _buildEditIcon(),
        ],
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildEditIcon() {
    return Positioned(
      bottom: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppThemeColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.edit, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppThemeColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_a_photo_rounded,
            size: 32,
            color: AppThemeColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Add your goal image ✨',
          style: TextStyle(
            color: AppThemeColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'JPEG, PNG • Max 5MB',
          style: TextStyle(
            color: AppThemeColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Helper function to show image source picker
Future<File?> pickImage(BuildContext context) async {
  final picker = ImagePicker();

  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Wrap(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppThemeColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          _buildSourceOption(
            context,
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            source: ImageSource.gallery,
          ),
          const SizedBox(height: 12),
          _buildSourceOption(
            context,
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            source: ImageSource.camera,
          ),
        ],
      ),
    ),
  );

  if (source == null) return null;

  final pickedFile = await picker.pickImage(
    source: source,
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 85,
  );

  if (pickedFile != null) {
    return File(pickedFile.path);
  }
  return null;
}

Widget _buildSourceOption(
  BuildContext context, {
  required IconData icon,
  required String label,
  required ImageSource source,
}) {
  return InkWell(
    onTap: () => Navigator.pop(context, source),
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppThemeColors.borderLight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppThemeColors.primary),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppThemeColors.textPrimary,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppThemeColors.textTertiary,
          ),
        ],
      ),
    ),
  );
}
