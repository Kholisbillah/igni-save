import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../providers/user_profile_provider.dart';
import '../widgets/profile_stat_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileStreamProvider);
    final userLevel = ref.watch(userLevelProvider);
    final userStreak = ref.watch(userStreakProvider);
    final activeLeaderboardAsync = ref.watch(
      leaderboardByCurrentStreakProvider,
    );
    final hofLeaderboardAsync = ref.watch(leaderboardByStreakProvider);

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.background,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppThemeColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppThemeColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppThemeColors.borderLight),
              boxShadow: AppThemeColors.cardShadow,
            ),
            child: IconButton(
              onPressed: () => context.push(AppStrings.routeSettings),
              icon: const Icon(
                Icons.settings_rounded,
                color: AppThemeColors.textSecondary,
                size: 20,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppThemeColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppThemeColors.borderLight),
              boxShadow: AppThemeColors.cardShadow,
            ),
            child: IconButton(
              onPressed: () => context.push(AppStrings.routeEditProfile),
              icon: const Icon(
                Icons.edit_rounded,
                color: AppThemeColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: userProfileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppThemeColors.primary),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('User not found'));
          }

          final activeRank = activeLeaderboardAsync.when(
            data: (users) {
              final index = users.indexWhere((u) => u.uid == profile.uid);
              if (index == -1) return '-';
              return '#${index + 1}';
            },
            loading: () => '...',
            error: (_, _) => '-',
          );

          final hofRank = hofLeaderboardAsync.when(
            data: (users) {
              final index = users.indexWhere((u) => u.uid == profile.uid);
              if (index == -1) return '-';
              return '#${index + 1}';
            },
            loading: () => '...',
            error: (_, _) => '-',
          );

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh logic if needed
            },
            color: AppThemeColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Avatar & Level Badge
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (profile.photoUrl != null) {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: EdgeInsets.zero,
                                child: Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: Colors.black.withValues(
                                          alpha: 0.9,
                                        ),
                                        child: Center(
                                          child: InteractiveViewer(
                                            child: CachedNetworkImage(
                                              imageUrl: profile.photoUrl!,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 40,
                                      right: 20,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppThemeColors.surface,
                            border: Border.all(
                              color: AppThemeColors.primary,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppThemeColors.primary.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: profile.photoUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: profile.photoUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        color: AppThemeColors.primary,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error_outline),
                                  )
                                : const Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: 60,
                                      color: AppThemeColors.textTertiary,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppThemeColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppThemeColors.surface,
                            width: 3,
                          ),
                          boxShadow: AppThemeColors.cardShadow,
                        ),
                        child: Text(
                          'Lvl ${userLevel.level}',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Name & Title
                  Text(
                    profile.username,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppThemeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userLevel.title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppThemeColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (profile.bio != null && profile.bio!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        profile.bio!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppThemeColors.textSecondary,
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Stats Grid
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ProfileStatCard(
                              label: 'Total Savings',
                              value: CurrencyFormatter.formatCompact(
                                profile.totalSavings,
                                profile.preferredCurrency,
                              ),
                              icon: Icons.savings_rounded,
                              color: Colors.green, // Changed to green for money
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ProfileStatCard(
                              label: 'Active Rank',
                              value: activeRank,
                              icon: Icons.trending_up_rounded,
                              color: AppThemeColors.primary,
                              isHorizontal: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ProfileStatCard(
                              label: 'All-Time Rank',
                              value: hofRank,
                              icon: Icons.emoji_events_rounded,
                              color: const Color(0xFFFFD700),
                              isHorizontal: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ProfileStatCard(
                              label: 'Current Streak',
                              value: '${userStreak.current}',
                              icon: Icons.local_fire_department_rounded,
                              color: AppThemeColors.streak,
                              isHorizontal: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ProfileStatCard(
                              label: 'Best Streak',
                              value: '${userStreak.best}',
                              icon: Icons.vertical_align_top_rounded,
                              color: Colors.orange,
                              isHorizontal: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Level Progress
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppThemeColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppThemeColors.border),
                      boxShadow: AppThemeColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Level Progress',
                              style: AppTextStyles.titleMedium,
                            ),
                            Text(
                              '${userLevel.xp} XP',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppThemeColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Stack(
                          children: [
                            Container(
                              height: 16,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppThemeColors.background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return Container(
                                  height: 16,
                                  width:
                                      constraints.maxWidth * userLevel.progress,
                                  decoration: BoxDecoration(
                                    color: AppThemeColors.primary,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppThemeColors.primary
                                            .withValues(alpha: 0.4),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            // Dashed pattern or shine could go here
                          ],
                        ),

                        const SizedBox(height: 12),
                        Text(
                          '${(userLevel.progress * 100).toInt()}% to next level',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppThemeColors.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Shield Status
                  if (profile.streakShields > 0)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppThemeColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppThemeColors.info,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppThemeColors.info,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shield_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Streak Shield Active',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppThemeColors.info,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You have ${profile.streakShields} shield(s) protection',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppThemeColors.info,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(
                    height: 100,
                  ), // Bottom padding for FAB if needed
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
