import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../profile/providers/user_profile_provider.dart';
import '../../../missions/providers/missions_provider.dart';

/// Stats row showing Level and Total Savings - Vibrant Flat Style
class StatsRow extends ConsumerWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider);
    final levelInfo = ref.watch(userLevelProvider);
    final convertedSavingsAsync = ref.watch(convertedTotalSavingsProvider);

    final level = levelInfo.level;
    final levelTitle = levelInfo.title;
    final currency = profile?.preferredCurrency ?? 'IDR';

    // Use converted savings, fallback to profile totalSavings
    final totalSavings =
        convertedSavingsAsync.valueOrNull ?? (profile?.totalSavings ?? 0.0);

    return Row(
      children: [
        // Level Card
        Expanded(
          child: _StatCard(
            icon: Icons.workspace_premium_rounded,
            iconColor: AppThemeColors.levelBadge,
            value: 'Lvl $level',
            label: levelTitle.toUpperCase(),
          ),
        ),

        const SizedBox(width: AppSizes.md),

        // Total Savings Card
        Expanded(
          child: _StatCard(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: AppThemeColors.success,
            value: CurrencyFormatter.formatCompact(totalSavings, currency),
            label: 'TOTAL SAVINGS',
            isLoading: convertedSavingsAsync.isLoading,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isLoading;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.borderLight, width: 1),
        boxShadow: AppThemeColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                12,
              ), // Rounded square for flat feel
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLoading
                    ? const SizedBox(
                        width: 60,
                        height: 16,
                        child: LinearProgressIndicator(
                          backgroundColor: AppThemeColors.borderLight,
                          color: AppThemeColors.primary,
                        ),
                      )
                    : Text(
                        value,
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
