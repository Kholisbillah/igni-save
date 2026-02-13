import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme_colors.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../notification_controller.dart';
import '../../../../services/streak_validation_service.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../profile/providers/user_profile_provider.dart';
import '../../../missions/providers/missions_provider.dart';
import '../../../missions/data/models/mission_model.dart';

/// Main dashboard screen - Vibrant Flat Duolingo Style
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Check notification permission on dashboard entry
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isAllowed = await NotificationController.isNotificationAllowed();
      if (!isAllowed) {
        await NotificationController.requestPermission();
      }

      // Validate streak on dashboard load (fixes stale streak bug)
      final profile = ref.read(currentUserProfileProvider);
      final streakValidationService = ref.read(streakValidationServiceProvider);
      await streakValidationService.validateAndSync(profile);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Sticky Header
            const SliverAppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              floating: false,
              pinned: true,
              expandedHeight: 100.0, // Increased to prevent overflow
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _Header(),
                  ),
                ),
              ),
              toolbarHeight: 100, // Matched expanded height
              titleSpacing: 0,
              title:
                  SizedBox.shrink(), // Custom header used in flexibleSpace/bottom or custom logic
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 10),
                  // Streak Card - Aspect Ratio 335:125
                  const AspectRatio(
                    aspectRatio: 335 / 125,
                    child: _StreakCard(),
                  ),
                  const SizedBox(height: 16),

                  // Stats Grid - Custom Aspect Ratios
                  const _StatsGrid(),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Goals',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppThemeColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppStrings.routeGoals),
                        child: Text(
                          'View All',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppThemeColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _ActiveGoalsList(),
                  const SizedBox(height: 100), // Bottom padding for FAB
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Re-fetch to ensure updates on profile change
    final user = ref.watch(currentUserProvider);
    final userProfile = ref.watch(currentUserProfileProvider);
    final streakInfo = ref.watch(userStreakProvider);
    final streakValidationService = ref.read(streakValidationServiceProvider);

    final displayName = userProfile?.username ?? user?.displayName ?? 'Saver';
    final shieldCount = userProfile?.streakShields ?? 0;
    final currentStreak = streakInfo.current;

    // Calculate days until next shield
    final daysUntilShield = streakValidationService.getDaysUntilNextShield(
      currentStreak: currentStreak,
      streakShields: shieldCount,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getGreeting(),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.concrete,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppThemeColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Shield Indicator
            if (shieldCount > 0)
              Tooltip(
                message: 'Streak Shield protects your streak if you miss a day',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeColors.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shield_rounded,
                        size: 18,
                        color: AppThemeColors.info,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$shieldCount',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppThemeColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (daysUntilShield != null && currentStreak > 0)
              Tooltip(
                message: 'Days until you earn a Streak Shield',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.silver.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: AppColors.concrete,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${daysUntilShield}d',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.concrete,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(width: 8),
            // Notification Button
            Stack(
              children: [
                IconButton(
                  onPressed: () =>
                      context.push(AppStrings.routeNotificationSettings),
                  icon: const Icon(Icons.notifications_outlined, size: 28),
                  color: AppThemeColors.textPrimary,
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppThemeColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _StreakCard extends ConsumerWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakInfo = ref.watch(userStreakProvider);
    final hasSavedToday = streakInfo.hasSavedToday;
    final currentStreak = streakInfo.current;

    // Asset selection
    final bgImage = hasSavedToday
        ? 'assets/images/Streak Container (Nyala).png'
        : 'assets/images/Streak Container (Belum Nyala).png';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(bgImage), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          // Text Content
          Positioned(
            left: 27,
            top: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Streak',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$currentStreak',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasSavedToday
                      ? 'Great job keeping it up!'
                      : 'Save today to keep your streak',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // "Days" label usually part of image or layout, adding absolute positioning if needed
          Positioned(
            left: 63,
            top: 72,
            child: const Text(
              'Days',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends ConsumerWidget {
  const _StatsGrid();

  String _getRankAsset(String title) {
    // Correct mapping based on file list
    if (title.toLowerCase() == 'novice saver') {
      return 'assets/images/Novice Save.png';
    }
    return 'assets/images/$title.png';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(currentUserProfileProvider);
    final levelInfo = ref.watch(userLevelProvider);
    final convertedSavingsAsync = ref.watch(convertedTotalSavingsProvider);

    // Level & Rank
    final currentLevel = levelInfo.level;
    final rankTitle = levelInfo.title;
    final rankImage = _getRankAsset(rankTitle);

    // Savings & Progress - use converted value
    final currency = userProfile?.preferredCurrency ?? 'IDR';
    final totalSavings =
        convertedSavingsAsync.valueOrNull ?? (userProfile?.totalSavings ?? 0.0);
    final progress = levelInfo.progress;

    return Row(
      children: [
        // Rank Card - Aspect Ratio 1:1
        // We use Expanded to take half width, then AspectRatio to force square
        Expanded(
          child: AspectRatio(
            aspectRatio: 1, // 1:1 Ratio
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.clouds,
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(rankImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Level Badge
                  Positioned(
                    left: 12,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lvl',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: AppThemeColors.info,
                            ),
                          ),
                          Text(
                            '$currentLevel',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppThemeColors.info,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Removed duplicate rank title text as requested
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        // Right Column (Savings + Progress)
        Expanded(
          child: Column(
            children: [
              // Total Savings - Aspect Ratio 160:75
              GestureDetector(
                onTap: () {
                  context.push(AppStrings.routeAnalytics);
                },
                child: AspectRatio(
                  aspectRatio: 160 / 75,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.clouds,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total Savings',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppThemeColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            CurrencyFormatter.formatCompact(
                              totalSavings,
                              currency,
                            ),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppThemeColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Level Progress - Aspect Ratio 160:75 (Same as above to match height roughly if stacked evenly)
              // User said "card total saving dan level progres adalah W160px dan H75px"
              AspectRatio(
                aspectRatio: 160 / 75,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ), // Reduced padding
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.clouds,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level Progress',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10, // Slightly smaller to fit
                              fontWeight: FontWeight.w600,
                              color: AppThemeColors.textTertiary,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppThemeColors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.silver,
                          valueColor: const AlwaysStoppedAnimation(
                            AppThemeColors.info,
                          ),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActiveGoalsList extends ConsumerWidget {
  const _ActiveGoalsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsAsync = ref.watch(activeMissionsStreamProvider);

    return missionsAsync.when(
      data: (missions) {
        if (missions.isEmpty) {
          return const _EmptyGoalsState();
        }
        return Column(
          children: missions
              .take(3)
              .map(
                (mission) => AspectRatio(
                  aspectRatio: 335 / 130, // Strict Ratio
                  child: _GoalCard(mission: mission),
                ),
              )
              .toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final MissionModel mission;
  const _GoalCard({required this.mission});

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF9B59B6); // Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(mission.colorTheme);
    final percent = (mission.progress * 100).toInt();

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'missionDetail',
          pathParameters: {'id': mission.id},
          extra: mission,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        width: 335,
        height: 130,
        decoration: BoxDecoration(
          color: AppColors.clouds,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // 1. Title
            Positioned(
              left: 21,
              top: 17,
              width: 171,
              child: Text(
                mission.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.midnightBlue,
                  letterSpacing: 0.5,
                  height: 1.0, // Tighter line height
                ),
              ),
            ),

            // 2. Pills Row (Grouped for safety and alignment)
            Positioned(
              left: 21,
              top: 52,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Daily Amount Pill
                  Container(
                    height: 17,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ), // Slightly more padding
                    decoration: BoxDecoration(
                      color: AppColors.silver,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${CurrencyFormatter.formatCompact(mission.currentFillingNominal, mission.currency)}/${mission.fillingPlanDisplayText}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.midnightBlue,
                        letterSpacing: 0.5,
                        height: 1.0,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8), // Gap
                  // Percentage Pill
                  Container(
                    height: 17,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$percent%',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Progress Bar
            Positioned(
              left: 21,
              top: 84,
              right: 135,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.silver,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: mission.progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            // 4. Amounts Row (Aligned to Bar Width)
            Positioned(
              left: 21,
              top: 98, // Adjusted strictly
              right: 135, // Matches Bar Width exactly
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Current Amount
                  Flexible(
                    // Allow flex
                    child: Text(
                      CurrencyFormatter.format(
                        mission.currentAmount,
                        mission.currency,
                      ),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 0.6,
                        height: 1.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Target Amount
                  Flexible(
                    child: Text(
                      CurrencyFormatter.format(
                        mission.targetAmount,
                        mission.currency,
                      ),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AppColors.concrete,
                        letterSpacing: 0.5,
                        height: 1.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // 5. Right Image (Aligned Right)
            Positioned(
              right: 17,
              top: 13,
              width: 104,
              height: 104,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: mission.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: mission.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.image, color: Colors.grey[500]),
                            ),
                    ),
                  ),
                  // Days Badge
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: AppColors.clouds,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${mission.daysRemaining}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: color,
                              height: 1.0,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Days',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: color,
                              height: 1.0,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyGoalsState extends StatelessWidget {
  const _EmptyGoalsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.clouds,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeColors.borderLight, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flag_rounded,
              size: 32,
              color: AppThemeColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No active goals',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start making your goals!',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppThemeColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push(AppStrings.routeCreateMission),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppThemeColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Create Goal',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
