import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../profile/providers/user_profile_provider.dart';

/// Streak card widget with flat fire design - Duolingo Style
class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakInfo = ref.watch(userStreakProvider);
    final streakDays = streakInfo.current;
    final hasSavedToday = streakInfo.hasSavedToday;

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppThemeColors.streak.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: AppThemeColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label with Streak Color
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeColors.streak.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'DAILY STREAK',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppThemeColors.streak,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // Streak days
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$streakDays',
                      style: AppTextStyles.streakNumber.copyWith(fontSize: 42),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Days',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppThemeColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.sm),

                Row(
                  children: [
                    Flexible(
                      child: Text(
                        hasSavedToday
                            ? 'Great job! Keep it up! 🔥'
                            : 'Save today to keep your streak!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppThemeColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                if (hasSavedToday) ...[
                  const SizedBox(height: AppSizes.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppThemeColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppThemeColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Saved today',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppThemeColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: AppSizes.md),

          // Fire Icon Container - Flat style
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppThemeColors.streak.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppThemeColors.streak.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppThemeColors.streak,
              size: 42,
            ),
          ),
        ],
      ),
    );
  }
}
