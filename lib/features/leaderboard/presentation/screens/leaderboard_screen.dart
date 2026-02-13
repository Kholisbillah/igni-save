import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../gamification/domain/logic/gamification_service.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../../../profile/providers/user_profile_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  int _selectedIndex = 0; // 0: Active Streak, 1: Hall of Fame

  @override
  Widget build(BuildContext context) {
    // Determine which provider to use based on selection
    final leaderboardAsync = _selectedIndex == 0
        ? ref.watch(leaderboardByCurrentStreakProvider)
        : ref.watch(leaderboardByStreakProvider);

    final currentProfile = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Let background image show
      body: Stack(
        children: [
          // 1. Background Image (Full Screen)
          Positioned.fill(
            child: Image.asset(
              'assets/images/Leaderboard background.png',
              fit: BoxFit.cover,
              alignment: Alignment(0.0, -0.5), // Raise background slightly
            ),
          ),

          // 2. Content Layer
          SafeArea(
            child: Column(
              children: [
                // Header & Tabs
                _buildHeader(),
                const SizedBox(height: 16),
                _buildTabSwitcher(),
                const SizedBox(height: 10), // Reduced gap
                // Data Content
                Expanded(
                  child: leaderboardAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    error: (error, _) => Center(
                      child: Text(
                        'Failed to load data',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    data: (users) {
                      final topThree = users.take(3).toList();
                      final rest = users.skip(3).toList();

                      return Column(
                        children: [
                          // Top 3 Podium (Fixed Height)
                          SizedBox(
                            height: 290, // Tweak height for alignment
                            child: _PodiumSection(
                              users: topThree,
                              showCurrentStreak: _selectedIndex == 0,
                              currentUserId: currentProfile?.uid,
                            ),
                          ),

                          // Remaining List (Floating Card)
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.fromLTRB(
                                20,
                                40,
                                20,
                                20,
                              ), // Increased top margin
                              padding: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: rest.isEmpty
                                  ? _buildEmptyRestList()
                                  : ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        10,
                                        20,
                                        20,
                                      ),
                                      itemCount: rest.length,
                                      itemBuilder: (context, index) {
                                        final user = rest[index];
                                        return _LeaderboardListItem(
                                          user: user,
                                          rank: index + 4,
                                          showCurrentStreak:
                                              _selectedIndex == 0,
                                          isCurrentUser:
                                              user.uid == currentProfile?.uid,
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        'Streak Leaderboard',
        style: AppTextStyles.headlineSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: const Offset(0, 2),
              blurRadius: 4,
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      height: 44, // Fixed height for consistency
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          // Animated Background Pill
          AnimatedAlign(
            alignment: _selectedIndex == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D9CDB),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // Text Labels
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = 0),
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _selectedIndex == 0
                            ? Colors.white
                            : const Color(0xFF2D9CDB),
                      ),
                      child: const Text('Active Streak'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = 1),
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _selectedIndex == 1
                            ? Colors.white
                            : const Color(0xFF2D9CDB),
                      ),
                      child: const Text('Hall of Fame'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRestList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          'Keep saving to climb the ranks!',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppThemeColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Widget to display Top 3 Users on the Podium
class _PodiumSection extends StatelessWidget {
  final List<UserProfile> users;
  final bool showCurrentStreak;
  final String? currentUserId;

  const _PodiumSection({
    required this.users,
    required this.showCurrentStreak,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    UserProfile? first, second, third;
    if (users.isNotEmpty) first = users[0];
    if (users.length > 1) second = users[1];
    if (users.length > 2) third = users[2];

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        // 2nd Place (Left)
        if (second != null)
          Positioned(
            left: 20,
            bottom: 115, // Lowered further
            child: _PodiumUser(
              user: second,
              rank: 2,
              showCurrentStreak: showCurrentStreak,
              isCurrentUser: second.uid == currentUserId,
            ),
          ),

        // 3rd Place (Right)
        if (third != null)
          Positioned(
            right: 20,
            bottom: 95, // Lowered further
            child: _PodiumUser(
              user: third,
              rank: 3,
              showCurrentStreak: showCurrentStreak,
              isCurrentUser: third.uid == currentUserId,
            ),
          ),

        // 1st Place (Center)
        if (first != null)
          Positioned(
            bottom: 145, // Lowered further
            child: _PodiumUser(
              user: first,
              rank: 1,
              showCurrentStreak: showCurrentStreak,
              isCurrentUser: first.uid == currentUserId,
            ),
          ),
      ],
    );
  }
}

class _PodiumUser extends ConsumerStatefulWidget {
  final UserProfile user;
  final int rank;
  final bool showCurrentStreak;
  final bool isCurrentUser;

  const _PodiumUser({
    required this.user,
    required this.rank,
    required this.showCurrentStreak,
    required this.isCurrentUser,
  });

  @override
  ConsumerState<_PodiumUser> createState() => _PodiumUserState();
}

class _PodiumUserState extends ConsumerState<_PodiumUser>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRankColor() {
    switch (widget.rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamificationService = ref.watch(gamificationServiceProvider);
    final streak = widget.showCurrentStreak
        ? widget.user.currentStreak
        : widget.user.maxStreak;
    final levelTitle = gamificationService.getLevelTitle(widget.user.level);
    final glowColor = _getRankColor();
    // Darken the text color for better visibility while keeping the rank color identity
    final hsl = HSLColor.fromColor(glowColor);
    final textColor = hsl
        .withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0))
        .toColor();

    return GestureDetector(
      onTap: () {
        context.push('/profile/${widget.user.uid}');
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Username
              SizedBox(
                width: 100,
                child: Text(
                  widget.user.username,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: textColor,
                    height: 1.1,
                    shadows: [
                      Shadow(
                        color: glowColor.withValues(
                          alpha: 0.6 * _animation.value,
                        ),
                        blurRadius: 8 * _animation.value,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // Level Title
              Text(
                'Lvl ${widget.user.level} • $levelTitle',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: textColor,
                  shadows: [
                    Shadow(
                      color: glowColor.withValues(
                        alpha: 0.6 * _animation.value,
                      ),
                      blurRadius: 4 * _animation.value,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Avatar with Badge and Glow
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: widget.rank == 1 ? 80 : 64,
                    height: widget.rank == 1 ? 80 : 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isCurrentUser
                            ? Colors.white
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        // Static shadow for depth
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                        // Animated Glow
                        BoxShadow(
                          color: glowColor.withValues(
                            alpha: 0.5 * _animation.value,
                          ),
                          blurRadius: 10 + (10 * _animation.value),
                          spreadRadius: 2 + (4 * _animation.value),
                        ),
                        // Inner glow core
                        BoxShadow(
                          color: glowColor.withValues(alpha: 0.3),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: widget.user.photoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: widget.user.photoUrl!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  // Streak Badge
                  Positioned(
                    bottom: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: AppThemeColors.streak,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$streak',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppThemeColors.streak,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LeaderboardListItem extends ConsumerWidget {
  final UserProfile user;
  final int rank;
  final bool showCurrentStreak;
  final bool isCurrentUser;

  const _LeaderboardListItem({
    required this.user,
    required this.rank,
    required this.showCurrentStreak,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamificationService = ref.watch(gamificationServiceProvider);
    final levelTitle = gamificationService.getLevelTitle(user.level);

    return GestureDetector(
      onTap: () {
        context.push('/profile/${user.uid}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? AppThemeColors.primary.withValues(alpha: 0.05)
              : AppThemeColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isCurrentUser
              ? Border.all(color: AppThemeColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 30,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppThemeColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppThemeColors.surfaceVariant,
              ),
              child: ClipOval(
                child: user.photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: user.photoUrl!,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.person, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 12),

            // Name & Level
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.username,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isCurrentUser
                          ? AppThemeColors.primary
                          : AppThemeColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Lvl ${user.level} • $levelTitle',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppThemeColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Streak
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    size: 16,
                    color: AppThemeColors.streak,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${showCurrentStreak ? user.currentStreak : user.maxStreak}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppThemeColors.streak,
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
