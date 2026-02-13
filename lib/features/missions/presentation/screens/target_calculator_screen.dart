import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/text_styles.dart';
import '../../data/models/mission_model.dart';

class TargetCalculatorScreen extends StatefulWidget {
  const TargetCalculatorScreen({super.key});

  @override
  State<TargetCalculatorScreen> createState() => _TargetCalculatorScreenState();
}

class _TargetCalculatorScreenState extends State<TargetCalculatorScreen> {
  final _targetController = TextEditingController();
  DateTime? _completedDate;
  FillingPlan _selectedPlan = FillingPlan.daily;
  double? _calculatedNominal;

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
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
      setState(() {
        _completedDate = picked;
        _calculatedNominal = null;
      });
    }
  }

  void _calculate() {
    final targetText = _targetController.text.replaceAll(RegExp(r'[^\d.]'), '');
    final target = double.tryParse(targetText);

    if (target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid target amount')),
      );
      return;
    }

    if (_completedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a completion date')),
      );
      return;
    }

    setState(() {
      _calculatedNominal = MissionModel.calculateFillingNominal(
        targetAmount: target,
        deadline: _completedDate!,
        plan: _selectedPlan,
      );
    });
  }

  void _applyResult() {
    if (_calculatedNominal == null || _completedDate == null) return;

    final targetText = _targetController.text.replaceAll(RegExp(r'[^\d.]'), '');
    final target = double.tryParse(targetText) ?? 0;

    context.pop({
      'targetAmount': target,
      'deadline': _completedDate,
      'fillingPlan': _selectedPlan,
      'fillingNominal': _calculatedNominal,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.background,
        elevation: 0,
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
        title: Text('Target Calculator', style: AppTextStyles.headlineSmall),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target Nominal Input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    'Target Nominal',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppThemeColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextFormField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTextStyles.headlineSmall,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppThemeColors.inputBackground,
                    hintText: '0',
                    hintStyle: AppTextStyles.headlineSmall.copyWith(
                      color: AppThemeColors.textTertiary.withValues(alpha: 0.5),
                    ),
                    prefixIcon: const Icon(
                      Icons.grid_view_rounded,
                      color: AppThemeColors.primary,
                      size: 28,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppThemeColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppThemeColors.borderLight,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppThemeColors.primary,
                        width: 2,
                      ),
                    ),
                    // Shadow effect via container could be better but this is fine for now
                  ),
                  onChanged: (_) => setState(() => _calculatedNominal = null),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Completed Date Picker
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
                      border: Border.all(color: AppThemeColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: AppThemeColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _completedDate == null
                              ? 'Select Deadline'
                              : DateFormat(
                                  'dd MMM yyyy',
                                ).format(_completedDate!),
                          style: AppTextStyles.titleMedium.copyWith(
                            color: _completedDate == null
                                ? AppThemeColors.textTertiary
                                : AppThemeColors.textPrimary,
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

            // Filling Plan Selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    'Filling Plan',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Row(
                  children: FillingPlan.values.map((plan) {
                    final isSelected = _selectedPlan == plan;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _selectedPlan = plan;
                          _calculatedNominal = null;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          margin: EdgeInsets.only(
                            right: plan != FillingPlan.monthly ? 8 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppThemeColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? AppThemeColors.primary
                                  : AppThemeColors.borderLight,
                              width: isSelected ? 0 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              plan.name[0].toUpperCase() +
                                  plan.name.substring(1),
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppThemeColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  shadowColor: AppThemeColors.primaryDark,
                ),
                child: Text(
                  'Calculate Filling Plan',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Result
            if (_calculatedNominal != null) ...[
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppThemeColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppThemeColors.borderLight,
                    width: 2,
                  ),
                  boxShadow: AppThemeColors.cardShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      'Your ${_selectedPlan.name} saving:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppThemeColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp',
                        decimalDigits: 0,
                      ).format(_calculatedNominal),
                      style: AppTextStyles.displaySmall.copyWith(
                        color: AppThemeColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _applyResult,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemeColors.secondary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                          ),
                        ),
                        child: Text(
                          'Apply to Goal',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
