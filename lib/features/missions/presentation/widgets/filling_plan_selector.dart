import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../data/models/mission_model.dart';
import '../../../../core/constants/app_sizes.dart';

class FillingPlanSelector extends StatelessWidget {
  final FillingPlan selectedPlan;
  final Function(FillingPlan) onPlanChanged;

  const FillingPlanSelector({
    super.key,
    required this.selectedPlan,
    required this.onPlanChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: AppThemeColors.borderLight),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: FillingPlan.values.map((plan) {
          final isSelected = selectedPlan == plan;
          return Expanded(
            child: GestureDetector(
              onTap: () => onPlanChanged(plan),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    plan.name[0].toUpperCase() + plan.name.substring(1),
                    style: isSelected
                        ? AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppThemeColors.textPrimary,
                          )
                        : AppTextStyles.labelLarge.copyWith(
                            color: AppThemeColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
