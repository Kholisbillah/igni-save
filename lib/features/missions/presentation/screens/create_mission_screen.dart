import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/currency_model.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../services/currency_service.dart';
import '../../data/models/mission_model.dart';
import '../../providers/missions_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../profile/providers/user_profile_provider.dart';
import '../widgets/image_upload_widget.dart';
import '../widgets/filling_plan_selector.dart';
import '../widgets/color_theme_picker.dart';

import '../../../../core/widgets/igni_text_field.dart';

class CreateMissionScreen extends ConsumerStatefulWidget {
  final MissionModel? mission;

  const CreateMissionScreen({super.key, this.mission});

  @override
  ConsumerState<CreateMissionScreen> createState() =>
      _CreateMissionScreenState();
}

class _CreateMissionScreenState extends ConsumerState<CreateMissionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _targetAmountController;
  late TextEditingController _fillingNominalController;

  DateTime? _deadline;
  late CurrencyModel
  _selectedCurrency; // Will be set in initState based on user's preferred currency
  FillingPlan _selectedFillingPlan = FillingPlan.daily;

  // Image
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  // Notification
  bool _notificationEnabled = false;
  List<TimeOfDay> _notificationTimes = [const TimeOfDay(hour: 12, minute: 0)];
  List<int> _notificationDays = [];

  // Color theme
  String _selectedColorTheme = MissionModel.defaultColorTheme;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    // Get user's preferred currency from profile
    final profile = ref.read(currentUserProfileProvider);
    final preferredCurrencyCode = profile?.preferredCurrency ?? 'IDR';

    // Set default currency to user's preferred currency
    _selectedCurrency = CurrencyModel.currencies.firstWhere(
      (c) => c.code == preferredCurrencyCode,
      orElse: () => CurrencyModel.currencies.first,
    );

    final mission = widget.mission;
    if (mission != null) {
      _titleController = TextEditingController(text: mission.title);
      _targetAmountController = TextEditingController(
        text: CurrencyInputFormatter.separator != '.'
            ? mission.targetAmount.toStringAsFixed(0)
            : NumberFormat('#,###', 'id_ID').format(mission.targetAmount),
      );
      _fillingNominalController = TextEditingController(
        text: CurrencyInputFormatter.separator != '.'
            ? mission.fillingNominal.toStringAsFixed(0)
            : NumberFormat('#,###', 'id_ID').format(mission.fillingNominal),
      );
      _deadline = mission.deadline;

      // For editing, use mission's currency
      try {
        _selectedCurrency = CurrencyModel.currencies.firstWhere(
          (c) => c.code == mission.currency,
          orElse: () => CurrencyModel.currencies.first,
        );
      } catch (_) {
        // Keep the preferred currency as fallback
      }

      _selectedFillingPlan = mission.fillingPlan;
      _uploadedImageUrl = mission.imageUrl;
      _notificationEnabled = mission.notificationEnabled;

      if (mission.notificationTimes.isNotEmpty) {
        _notificationTimes = [];
        for (final timeStr in mission.notificationTimes) {
          try {
            final parts = timeStr.split(':');
            if (parts.length == 2) {
              _notificationTimes.add(
                TimeOfDay(
                  hour: int.parse(parts[0]),
                  minute: int.parse(parts[1]),
                ),
              );
            }
          } catch (_) {}
        }
        if (_notificationTimes.isEmpty) {
          _notificationTimes = [const TimeOfDay(hour: 12, minute: 0)];
        }
      }

      _notificationDays = mission.notificationDays
          .map((d) => d == 7 ? 0 : d)
          .toList();

      // Color theme
      _selectedColorTheme = mission.colorTheme;
    } else {
      _titleController = TextEditingController();
      _targetAmountController = TextEditingController();
      _fillingNominalController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _fillingNominalController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Note: Use a file picker or image picker package
    // For now assuming existing logic is handled elsewhere or via a helper
    final image = await pickImage(context);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _uploadedImageUrl = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppThemeColors.primary,
              onPrimary: Colors.white,
              surface: AppThemeColors.surface,
              onSurface: AppThemeColors.textPrimary,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppThemeColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _deadline = picked);
      _recalculateNominal();
    }
  }

  void _recalculateNominal() {
    if (_deadline == null) return;

    final targetText = _targetAmountController.text.replaceAll(
      RegExp(r'[^\d]'),
      '',
    );
    final target = double.tryParse(targetText);
    if (target == null || target <= 0) return;

    final nominal = MissionModel.calculateFillingNominal(
      targetAmount: target,
      deadline: _deadline!,
      plan: _selectedFillingPlan,
    );

    // Format the calculated nominal
    // Using a flag to prevent circular triggering if we add listeners
    _fillingNominalController.text = CurrencyFormatter.formatNumber(
      nominal,
      _selectedCurrency.code,
    );
  }

  void _recalculateDeadline() {
    final targetText = _targetAmountController.text.replaceAll(
      RegExp(r'[^\d]'),
      '',
    );
    final nominalText = _fillingNominalController.text.replaceAll(
      RegExp(r'[^\d]'),
      '',
    );

    final target = double.tryParse(targetText);
    final nominal = double.tryParse(nominalText);

    if (target == null || target <= 0 || nominal == null || nominal <= 0) {
      return;
    }

    int daysPerInterval = 1;
    switch (_selectedFillingPlan) {
      case FillingPlan.daily:
        daysPerInterval = 1;
        break;
      case FillingPlan.weekly:
        daysPerInterval = 7;
        break;
      case FillingPlan.monthly:
        daysPerInterval = 30;
        break;
    }

    // Calculate how many intervals needed
    final intervals = (target / nominal).ceil();
    // We subtract 1 because the first payment is made "today"
    // So if we need 2 payments (Today + Tomorrow), the duration is 1 day.
    final totalDays = (intervals - 1) * daysPerInterval;

    setState(() {
      final now = DateTime.now();
      _deadline = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: totalDays));
    });
  }

  Future<void> _openCalculator() async {
    final result = await context.push<Map<String, dynamic>>(
      '/goals/calculator',
    );

    if (result != null && mounted) {
      setState(() {
        if (result['targetAmount'] != null) {
          _targetAmountController.text = result['targetAmount'].toStringAsFixed(
            0,
          );
        }
        if (result['deadline'] != null) {
          _deadline = result['deadline'] as DateTime;
        }
        if (result['fillingPlan'] != null) {
          _selectedFillingPlan = result['fillingPlan'] as FillingPlan;
        }
        if (result['fillingNominal'] != null) {
          _fillingNominalController.text = CurrencyFormatter.formatNumber(
            result['fillingNominal'],
            _selectedCurrency.code,
          );
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_deadline == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a deadline')));
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        setState(() => _isUploadingImage = true);
        final cloudinary = CloudinaryService();
        imageUrl = await cloudinary.uploadImage(_selectedImage!);
        setState(() => _isUploadingImage = false);
      }

      final repository = ref.read(missionRepositoryProvider);

      final targetText = _targetAmountController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );
      final fillingText = _fillingNominalController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );
      final targetAmount = double.parse(targetText);

      // Convert target amount to USD for cross-currency comparison
      double targetAmountUsd = targetAmount;
      if (_selectedCurrency.code != 'USD') {
        final currencyService = CurrencyService();
        targetAmountUsd = await currencyService.convert(
          amount: targetAmount,
          from: _selectedCurrency.code,
          to: 'USD',
        );
      }

      final mission = MissionModel(
        id: widget.mission?.id ?? '',
        ownerId: user.uid,
        title: _titleController.text.trim(),
        description: '',
        targetAmount: targetAmount,
        targetAmountUsd: targetAmountUsd,
        currentAmount: widget.mission?.currentAmount ?? 0,
        deadline: _deadline!,
        status: widget.mission?.status ?? MissionStatus.active,
        currency: _selectedCurrency.code,
        imageUrl: imageUrl ?? _uploadedImageUrl,
        fillingPlan: _selectedFillingPlan,
        fillingNominal: double.tryParse(fillingText) ?? 0,
        notificationEnabled: _notificationEnabled,
        notificationTimes: _notificationTimes
            .map(
              (t) =>
                  '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
            )
            .toList(),
        notificationDays: _notificationDays.map((d) => d == 0 ? 7 : d).toList(),
        colorTheme: _selectedColorTheme,
        createdAt: widget.mission?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.mission != null) {
        await repository.updateMission(mission);
      } else {
        await repository.createMission(mission);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.mission != null
                  ? 'Goal updated successfully!'
                  : 'Goal created successfully!',
            ),
            backgroundColor: AppThemeColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error ${widget.mission != null ? 'updating' : 'creating'} goal: $e',
            ),
            backgroundColor: AppThemeColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.background,
        elevation: 0,
        title: Text(
          widget.mission != null ? 'Edit Goal' : 'Create Goal',
          style: AppTextStyles.headlineSmall,
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppThemeColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppThemeColors.borderLight),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              color: AppThemeColors.textPrimary,
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload
              ImageUploadWidget(
                selectedImage: _selectedImage,
                imageUrl: _uploadedImageUrl,
                isLoading: _isUploadingImage,
                onTap: _pickImage,
              ),
              const SizedBox(height: 24),

              // Color Theme Picker
              ColorThemePicker(
                selectedColor: _selectedColorTheme,
                onColorSelected: (color) {
                  setState(() => _selectedColorTheme = color);
                },
              ),
              const SizedBox(height: 24),

              // Savings Name
              IgniTextField(
                controller: _titleController,
                label: 'Savings Name',
                hint: 'e.g. My Dream House',
                prefixIcon: const Icon(Icons.sort_rounded),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a name'
                    : null,
              ),
              const SizedBox(height: 20),

              // Savings Target
              IgniTextField(
                controller: _targetAmountController,
                label: 'Savings Target',
                hint: '0',
                prefixIcon: const Icon(Icons.grid_view_rounded),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter target amount'
                    : null,
                onChanged: (_) => _recalculateDeadline(),
              ),
              const SizedBox(height: 20),

              // Filling Plan Section
              Text(
                'Filling Plan',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              FillingPlanSelector(
                selectedPlan: _selectedFillingPlan,
                onPlanChanged: (plan) {
                  setState(() => _selectedFillingPlan = plan);
                  _recalculateDeadline();
                },
              ),
              const SizedBox(height: 20),

              // Filling Nominal
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: IgniTextField(
                      controller: _fillingNominalController,
                      label: 'Filling Nominal',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      onChanged: (_) => _recalculateDeadline(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _openCalculator,
                    child: Container(
                      height: 54, // Match typical input height
                      width: 54,
                      decoration: BoxDecoration(
                        color: AppThemeColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppThemeColors.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.calculate_rounded,
                        color: AppThemeColors.primary,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Deadline
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 6),
                    child: Text(
                      'Target Deadline',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppThemeColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemeColors.inputBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppThemeColors.border.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: AppThemeColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _deadline == null
                                ? 'Select Deadline'
                                : DateFormat('dd MMM yyyy').format(_deadline!),
                            style: TextStyle(
                              color: _deadline == null
                                  ? AppThemeColors.textTertiary
                                  : AppThemeColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Calculator Link
              Center(
                child: GestureDetector(
                  onTap: _openCalculator,
                  child: Text(
                    'Still confused? Calculate With Target Calculator',
                    style: TextStyle(
                      color: AppThemeColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppThemeColors.primary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    shadowColor: AppThemeColors.primaryDark,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : Text(
                          widget.mission != null
                              ? 'Save Changes'
                              : 'Create Goal',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
