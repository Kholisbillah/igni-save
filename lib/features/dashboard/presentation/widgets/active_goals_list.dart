import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../missions/data/models/mission_model.dart';
import '../../../missions/providers/missions_provider.dart';

/// List of active savings goals - Vibrant Flat Style
class ActiveGoalsList extends ConsumerWidget {
  const ActiveGoalsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsAsync = ref.watch(activeMissionsStreamProvider);

    return missionsAsync.when(
      loading: () => const _LoadingState(),
      error: (error, _) => _ErrorState(error: error.toString()),
      data: (missions) {
        if (missions.isEmpty) {
          return const _EmptyState();
        }
        return Column(
          children: missions
              .take(3) // Show max 3 on dashboard
              .map(
                (mission) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.md),
                  child: _GoalCard(mission: mission),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  final MissionModel mission;

  const _GoalCard({required this.mission});

  IconData _getIconForType(MissionType type) {
    switch (type) {
      case MissionType.target:
        return Icons.flag_rounded;
      case MissionType.safety:
        return Icons.verified_user_rounded;
      case MissionType.lifestyle:
        return Icons.celebration_rounded;
    }
  }

  Color _getColorForType(MissionType type) {
    switch (type) {
      case MissionType.target:
        return AppThemeColors.primary;
      case MissionType.safety:
        return AppThemeColors.success;
      case MissionType.lifestyle:
        return AppThemeColors.rewardOrange;
    }
  }

  String _getSubtitle() {
    final days = mission.daysRemaining;
    if (days == 0) return 'Due today';
    if (days == 1) return '1 day left';
    return '$days days left';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(mission.type);
    final icon = _getIconForType(mission.type);

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.borderLight, width: 1),
        boxShadow: AppThemeColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon or Image
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  image: mission.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(mission.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: mission.imageUrl == null
                    ? Icon(icon, color: color, size: 28)
                    : null,
              ),

              const SizedBox(width: AppSizes.md),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mission.title, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 4),
                    // Filling Plan Info
                    if (mission.currentFillingNominal > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppThemeColors.inputBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${CurrencyFormatter.format(mission.currentFillingNominal, mission.currency)} / ${mission.fillingPlanDisplayText}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppThemeColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Text(_getSubtitle(), style: AppTextStyles.bodySmall),
                  ],
                ),
              ),

              // Progress percentage badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${mission.progressPercent}%',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.md),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: mission.progress,
              backgroundColor: AppThemeColors.inputBackground,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8, // Thicker progress bar for playful feel
            ),
          ),

          const SizedBox(height: AppSizes.sm),

          // Amount row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.format(
                  mission.currentAmount,
                  mission.currency,
                ),
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppThemeColors.textPrimary,
                ),
              ),
              Text(
                'of ${CurrencyFormatter.format(mission.targetAmount, mission.currency)}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: AppSizes.md),
          height: 140,
          decoration: BoxDecoration(
            color: AppThemeColors.inputBackground,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppThemeColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppThemeColors.error),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              'Failed to load goals',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppThemeColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppThemeColors.borderLight,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppThemeColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flag_rounded,
              color: AppThemeColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text('No active goals yet', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Create your first savings goal!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppThemeColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push(AppStrings.routeCreateMission);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeColors.primary,
                foregroundColor: AppThemeColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Create Goal',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
