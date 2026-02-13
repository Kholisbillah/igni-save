import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/constants.dart';

/// Main shell with custom floating bottom navigation bar
class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 2) {
      // Center button (Piggy Bank) - Navigate to Add Saving
      context.push(AppStrings.routeProofOfSaving);
      return;
    }

    // Adjust index for mapping to routes (since index 2 is now center action, we might need logic if we strictly follow 0,1,2,3 for tabs)
    // Actually, let's keep it simple: 0=Home, 1=Goals, 2=Leagues, 3=Profile.
    // The center button is separate.

    // But we need to highlight the correct tab.
    // Let's store visual index.

    setState(() {
      _currentIndex = index;
    });

    // Map visual index to route
    switch (index) {
      case 0:
        context.go(AppStrings.routeDashboard);
        break;
      case 1:
        context.go(AppStrings.routeGoals);
        break;
      case 3:
        context.go(AppStrings.routeLeagues);
        break;
      case 4:
        context.go(AppStrings.routeProfile);
        break;
    }
  }

  // Update current index based on location to ensure sync on back navigation
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppStrings.routeDashboard)) {
      _currentIndex = 0;
    } else if (location.startsWith(AppStrings.routeGoals)) {
      _currentIndex = 1;
    } else if (location.startsWith(AppStrings.routeLeagues)) {
      _currentIndex = 3;
    } else if (location.startsWith(AppStrings.routeProfile)) {
      _currentIndex = 4;
    }
    // Note: ProofOfSaving is a push route, so it doesn't replace the shell, usually.
    // If it *does* replace shell, we need to handle it. Assuming it's a full screen page pushed ON TOP of shell or within?
    // Usually 'go' switches branches. If ProofOfSaving is a separate route, it might not show navbar.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Standard background
      extendBody: true, // Content goes behind navbar
      body: widget.child,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.peterRiver,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(
                1,
                Icons.flag_rounded,
                'Goals',
              ), // Changed icon to represent Goals better or stick to flag
              _buildCenterIcon(),
              _buildNavItem(3, Icons.emoji_events_rounded, 'Leagues'),
              _buildNavItem(4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              size: 28,
            ),
            // Optional: Label or Dot indicator? Design usually minimal.
            // User design shows minimal. Let's start with just Icon, maybe small dot if selected?
            // "It will contain Home, Goals, a center icon, Leagues, and Profile."
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterIcon() {
    return GestureDetector(
      onTap: () => _onTabTapped(2),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset('assets/icons/Saving Icon.svg'),
      ),
    );
  }
}
