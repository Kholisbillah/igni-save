import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../gamification/domain/logic/gamification_service.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user_profile_model.dart';
import '../widgets/profile_stat_card.dart';
import '../../providers/user_profile_provider.dart';

/// Provider to fetch other user's profile
final otherUserProfileProvider = FutureProvider.family
    .autoDispose<UserProfile?, String>((ref, uid) async {
      final repository = ref.watch(userRepositoryProvider);
      return repository.getPublicUserProfile(uid);
    });

class OtherUserProfileScreen extends ConsumerWidget {
  final String userId;

  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(otherUserProfileProvider(userId));
    final gamificationService = ref.watch(gamificationServiceProvider);
    final activeLeaderboardAsync = ref.watch(
      leaderboardByCurrentStreakProvider,
    );
    final hofLeaderboardAsync = ref.watch(leaderboardByStreakProvider);

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppThemeColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppThemeColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: userProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('User not found'));
          }

          final levelTitle = gamificationService.getLevelTitle(profile.level);
          final levelProgress = gamificationService.calculateLevelProgress(
            profile.currentXp,
            profile.level,
          );

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

          return SingleChildScrollView(
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
                              : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppThemeColors.textSecondary,
                                ),
                        ),
                      ),
                    ),
                    if (!profile.isPrivate)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppThemeColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppThemeColors.background,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'Lvl ${profile.level}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name & Title
                Text(
                  profile.username,
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppThemeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                if (!profile.isPrivate)
                  Text(
                    levelTitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppThemeColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 8),
                if (profile.bio != null && profile.bio!.isNotEmpty)
                  Text(
                    profile.bio!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppThemeColors.textSecondary,
                    ),
                  ),

                const SizedBox(height: 32),

                if (profile.isPrivate) ...[
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: AppThemeColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This account is private',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 18,
                      color: AppThemeColors.textSecondary,
                    ),
                  ),
                ] else ...[
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
                              icon: Icons.account_balance_wallet_outlined,
                              color: Colors.green,
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
                              value: '${profile.currentStreak}',
                              icon: Icons.local_fire_department_rounded,
                              color: AppThemeColors.streak,
                              isHorizontal: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ProfileStatCard(
                              label: 'Best Streak',
                              value: '${profile.maxStreak}',
                              icon: Icons.vertical_align_top_rounded,
                              color: Colors.orange,
                              isHorizontal: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Level Progress
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppThemeColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppThemeColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Level Progress',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppThemeColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${profile.currentXp} XP',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppThemeColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: levelProgress,
                            backgroundColor: AppThemeColors.inputBackground,
                            color: AppThemeColors.primary,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(levelProgress * 100).toInt()}% to next level',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppThemeColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Shield Status
                  if (profile.streakShields > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shield,
                            color: Colors.blue,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Streak Shield Active',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppThemeColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Has ${profile.streakShields} shield(s)',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: AppThemeColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
