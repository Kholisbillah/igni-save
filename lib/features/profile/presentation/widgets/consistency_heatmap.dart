import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_theme_colors.dart';
import '../../../savings/providers/savings_provider.dart';

/// GitHub-style consistency heatmap for savings activity
class ConsistencyHeatmap extends ConsumerWidget {
  const ConsistencyHeatmap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmapAsync = ref.watch(savingsHeatmapProvider);

    return heatmapAsync.when(
      loading: () => Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppThemeColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, _) => Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppThemeColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('Failed to load heatmap')),
      ),
      data: (data) => _HeatmapGrid(savingsData: data),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  final Map<DateTime, double> savingsData;

  const _HeatmapGrid({required this.savingsData});

  Color _getColorForAmount(double amount) {
    if (amount <= 0) return AppThemeColors.inputBackground;
    if (amount < 50000) return AppThemeColors.success.withValues(alpha: 0.3);
    if (amount < 200000) return AppThemeColors.success.withValues(alpha: 0.5);
    if (amount < 500000) return AppThemeColors.success.withValues(alpha: 0.7);
    return AppThemeColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 90));

    // Generate 13 weeks (91 days)
    final weeks = <List<DateTime>>[];
    var currentDate = startDate;

    // Find the Monday of the start week
    while (currentDate.weekday != DateTime.monday) {
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    while (currentDate.isBefore(now) || currentDate.isAtSameMomentAs(now)) {
      final week = <DateTime>[];
      for (int i = 0; i < 7; i++) {
        week.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }
      weeks.add(week);
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppThemeColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.cardBorder),
        boxShadow: AppThemeColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day labels
          const Row(
            children: [
              SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('M', style: _labelStyle),
                    Text('W', style: _labelStyle),
                    Text('F', style: _labelStyle),
                    Text('S', style: _labelStyle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Heatmap grid
          SizedBox(
            height: 90,
            child: Row(
              children: weeks.map((week) {
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: week.map((date) {
                      final dateKey = DateTime(date.year, date.month, date.day);
                      final amount = savingsData[dateKey] ?? 0;
                      final isFuture = date.isAfter(now);

                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: isFuture
                                ? Colors.transparent
                                : _getColorForAmount(amount),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Less',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: AppThemeColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              ...[0.0, 0.3, 0.5, 0.7, 1.0].map(
                (opacity) => Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: opacity == 0
                        ? AppThemeColors.inputBackground
                        : AppThemeColors.success.withValues(alpha: opacity),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'More',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: AppThemeColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    color: AppThemeColors.textTertiary,
  );
}
