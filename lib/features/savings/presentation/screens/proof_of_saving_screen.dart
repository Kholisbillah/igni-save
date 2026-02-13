import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../missions/data/models/mission_model.dart';
import '../../../missions/providers/missions_provider.dart';
import '../../../profile/providers/user_profile_provider.dart';
import '../../providers/savings_provider.dart';

/// Proof of Saving Screen - Upload photo proof and save to mission
class ProofOfSavingScreen extends ConsumerStatefulWidget {
  final MissionModel? initialMission;

  const ProofOfSavingScreen({super.key, this.initialMission});

  @override
  ConsumerState<ProofOfSavingScreen> createState() =>
      _ProofOfSavingScreenState();
}

class _ProofOfSavingScreenState extends ConsumerState<ProofOfSavingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  File? _selectedImage;
  MissionModel? _selectedMission;
  bool _isLoading = false;
  String _currency = 'IDR';

  @override
  void initState() {
    super.initState();
    // Pre-select mission if provided
    _selectedMission = widget.initialMission;

    // Get user's preferred currency
    Future.microtask(() {
      final profile = ref.read(currentUserProfileProvider);
      if (profile != null) {
        setState(() {
          _currency = profile.preferredCurrency;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: const BoxDecoration(
          color: AppThemeColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Text('Choose Photo Source', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSizes.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ImageSourceButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _ImageSourceButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMission == null) {
      _showError('Please select a goal');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse amount
      final amount =
          double.tryParse(
            _amountController.text.replaceAll(RegExp(r'[^\d]'), ''),
          ) ??
          0;

      // Add savings (image upload is handled internally by repository)
      final success = await ref
          .read(savingsNotifierProvider.notifier)
          .addSavings(
            missionId: _selectedMission!.id,
            amount: amount,
            proofImage: _selectedImage,
            note: _noteController.text.isNotEmpty ? _noteController.text : null,
          );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          _showSuccess();
          context.pop();
        } else {
          _showError('Failed to save. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppThemeColors.error),
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Savings added successfully! 🎉'),
          ],
        ),
        backgroundColor: AppThemeColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final missions = ref.watch(activeMissionsStreamProvider).valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppThemeColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppThemeColors.borderLight),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: AppThemeColors.textPrimary,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: Text('Add Savings', style: AppTextStyles.headlineSmall),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Proof of Saving', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Take a photo of your cash or screenshot of your transfer.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppThemeColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSizes.xl),

              // Image Picker Area
              GestureDetector(
                onTap: _showImagePicker,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppThemeColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _selectedImage != null
                          ? AppThemeColors.primary
                          : AppThemeColors.border,
                      width: _selectedImage != null ? 2 : 1,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(_selectedImage!, fit: BoxFit.cover),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() => _selectedImage = null);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppThemeColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 40,
                                color: AppThemeColors.primary,
                              ),
                            ),
                            const SizedBox(height: AppSizes.md),
                            Text(
                              'Tap to add proof photo',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppThemeColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '(Optional but recommended)',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppThemeColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: AppSizes.xl),

              // Amount Input
              Text(
                'AMOUNT',
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppThemeColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppThemeColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppThemeColors.border),
                ),
                child: Row(
                  children: [
                    Text(
                      CurrencyFormatter.getSymbol(_currency),
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppThemeColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyInputFormatter()],
                        style: AppTextStyles.headlineSmall,
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: AppTextStyles.headlineSmall.copyWith(
                            color: AppThemeColors.textHint,
                          ),
                          filled: false,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter amount';
                          }
                          final amount = double.tryParse(
                            value.replaceAll(RegExp(r'[^\d]'), ''),
                          );
                          if (amount == null || amount <= 0) {
                            return 'Enter valid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              // Select Goal
              Text(
                'ALLOCATE TO GOAL',
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppThemeColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppSizes.sm),

              if (missions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppThemeColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppThemeColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppThemeColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No active goals. Create a goal first.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppThemeColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: missions.map((mission) {
                    final isSelected = _selectedMission?.id == mission.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMission = mission),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppThemeColors.primary
                              : AppThemeColors.surface,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected
                                ? AppThemeColors.primary
                                : AppThemeColors.border,
                            width: isSelected ? 0 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppThemeColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : AppThemeColors.cardShadow,
                        ),
                        child: Text(
                          mission.title,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppThemeColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: AppSizes.lg),

              // Note (optional)
              Text(
                'NOTE (OPTIONAL)',
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppThemeColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Add a note about this saving...',
                  hintStyle: const TextStyle(color: AppThemeColors.textHint),
                  filled: true,
                  fillColor: AppThemeColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppThemeColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppThemeColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppThemeColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: AppSizes.xl),

              // XP Bonus Indicator
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppThemeColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppThemeColors.success.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppThemeColors.success.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: AppThemeColors.success,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Earn XP for saving!',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppThemeColors.success,
                            ),
                          ),
                          Text(
                            '+10 base XP + streak bonus',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppThemeColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.xl),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: AppThemeColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                        shadowColor: AppThemeColors.primary.withValues(
                          alpha: 0.4,
                        ),
                        minimumSize: const Size(0, 56),
                      ).copyWith(
                        elevation: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.pressed)) return 0;
                          return 4;
                        }),
                      ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save & Add XP',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppThemeColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppThemeColors.border),
              boxShadow: AppThemeColors.cardShadow,
            ),
            child: Icon(icon, size: 32, color: AppThemeColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppThemeColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
