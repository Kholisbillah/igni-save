import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/goals_filter_provider.dart';
import '../../providers/missions_provider.dart';
import '../widgets/goal_card.dart';
import '../widgets/goals_filter_sheet.dart';

/// Goals Screen - Matching Figma design with persistent search bar
class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final missionsAsync = ref.watch(userMissionsStreamProvider);
    final filterState = ref.watch(goalsFilterProvider);

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      'My Goals',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar (always visible - matches Figma)
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppThemeColors.inputBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppThemeColors.borderLight,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(
                          Icons.search_rounded,
                          color: AppThemeColors.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search Your Goals',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: AppThemeColors.textSecondary,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: AppTextStyles.bodyMedium,
                            onChanged: (value) {
                              ref
                                  .read(goalsFilterProvider.notifier)
                                  .setSearchQuery(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Row (shows active filter + sort icon)
                  Row(
                    children: [
                      // Active filter indicator
                      Expanded(child: _buildActiveFilterIndicator(filterState)),
                      // Sort/Filter icon
                      GestureDetector(
                        onTap: () => GoalsFilterSheet.show(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.tune_rounded,
                            color: AppThemeColors.textSecondary,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Goals List
            Expanded(
              child: missionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: AppThemeColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load goals',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppThemeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                data: (missions) {
                  final filteredMissions = filterState.apply(missions);

                  if (filteredMissions.isEmpty) {
                    return _EmptyState(
                      message: filterState.hasActiveFilters
                          ? 'No goals match your filters'
                          : 'No goals yet',
                      icon: filterState.hasActiveFilters
                          ? Icons.filter_list_off_rounded
                          : Icons.flag_rounded,
                      showClearFilters: filterState.hasActiveFilters,
                      onClearFilters: () {
                        ref
                            .read(goalsFilterProvider.notifier)
                            .clearAllFilters();
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: filteredMissions.length,
                    itemBuilder: (context, index) {
                      final mission = filteredMissions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GoalCard(
                          mission: mission,
                          showDaysRemaining: !mission.isCompleted,
                          onTap: () async {
                            final result = await context.pushNamed(
                              'missionDetail',
                              pathParameters: {'id': mission.id},
                              extra: mission,
                            );

                            if (result == true && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Goal deleted successfully'),
                                  backgroundColor: AppThemeColors.primary,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => context.push(AppStrings.routeCreateMission),
          backgroundColor: AppThemeColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, size: 32),
        ),
      ),
    );
  }

  /// Build the active filter indicator (Newest, Colors with dots, Completed, etc.)
  Widget _buildActiveFilterIndicator(GoalsFilterState filterState) {
    // Show sort option name
    final sortLabel = _getSortLabel(filterState.sortOption);

    // Check if colors are selected
    final hasColors = filterState.selectedColors.isNotEmpty;

    return Row(
      children: [
        // Sort option label
        Text(
          sortLabel,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppThemeColors.textPrimary,
          ),
        ),

        // Color indicators (if any colors selected)
        if (hasColors) ...[
          const SizedBox(width: 8),
          ...filterState.selectedColors.take(3).map((colorHex) {
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _parseColor(colorHex),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            );
          }),
          if (filterState.selectedColors.length > 3)
            Text(
              '+${filterState.selectedColors.length - 3}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppThemeColors.textSecondary,
              ),
            ),
        ],
      ],
    );
  }

  String _getSortLabel(GoalSortOption option) {
    switch (option) {
      case GoalSortOption.newest:
        return 'Newest';
      case GoalSortOption.oldest:
        return 'Oldest';
      case GoalSortOption.progressHighToLow:
        return 'Progress ↓';
      case GoalSortOption.progressLowToHigh:
        return 'Progress ↑';
      case GoalSortOption.amountHighToLow:
        return 'Amount ↓';
      case GoalSortOption.amountLowToHigh:
        return 'Amount ↑';
      case GoalSortOption.deadlineNearest:
        return 'Deadline ↑';
      case GoalSortOption.deadlineFarthest:
        return 'Deadline ↓';
      case GoalSortOption.alphabeticalAZ:
        return 'A-Z';
      case GoalSortOption.alphabeticalZA:
        return 'Z-A';
    }
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF9B59B6);
    }
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool showClearFilters;
  final VoidCallback? onClearFilters;

  const _EmptyState({
    required this.message,
    required this.icon,
    this.showClearFilters = false,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppThemeColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppThemeColors.borderLight, width: 2),
              boxShadow: AppThemeColors.cardShadow,
            ),
            child: Icon(icon, size: 40, color: AppThemeColors.primary),
          ),
          const SizedBox(height: AppSizes.lg),
          Text(message, style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSizes.xs),
          if (showClearFilters)
            TextButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.filter_list_off_rounded, size: 18),
              label: const Text('Clear Filters'),
              style: TextButton.styleFrom(
                foregroundColor: AppThemeColors.primary,
              ),
            )
          else
            Text(
              'Tap + to create a new goal',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppThemeColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
