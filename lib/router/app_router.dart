import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_strings.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/dashboard/presentation/screens/main_shell.dart';
import '../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../features/missions/presentation/screens/create_mission_screen.dart';
import '../features/missions/presentation/screens/mission_detail_screen.dart';
import '../features/missions/data/models/mission_model.dart';
import '../features/missions/presentation/screens/goals_screen.dart';
import '../features/missions/presentation/screens/target_calculator_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/other_user_profile_screen.dart';

import '../features/savings/presentation/screens/proof_of_saving_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/notification_settings_screen.dart';
import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../services/local_storage_service.dart';

/// App router configuration using GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppStrings.routeOnboarding,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnboardingComplete = LocalStorageService.isOnboardingComplete;
      final currentPath = state.uri.path;

      // Auth routes
      final authRoutes = [
        AppStrings.routeOnboarding,
        AppStrings.routeLogin,
        AppStrings.routeSignup,
        AppStrings.routeForgotPassword,
      ];
      final isAuthRoute = authRoutes.contains(currentPath);

      // If not onboarding complete, go to onboarding
      if (!isOnboardingComplete && currentPath != AppStrings.routeOnboarding) {
        return AppStrings.routeOnboarding;
      }

      // If onboarding complete but not logged in, go to login
      if (isOnboardingComplete && !isLoggedIn && !isAuthRoute) {
        return AppStrings.routeLogin;
      }

      // If logged in and on auth route, go to dashboard
      if (isLoggedIn && isAuthRoute) {
        return AppStrings.routeDashboard;
      }

      return null;
    },
    routes: [
      // Onboarding
      GoRoute(
        path: AppStrings.routeOnboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppStrings.routeLogin,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AuthScreen(initialIsLogin: true),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child; // Instant transition
          },
        ),
      ),
      GoRoute(
        path: AppStrings.routeSignup,
        name: 'signup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AuthScreen(initialIsLogin: false),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child; // Instant transition
          },
        ),
      ),
      GoRoute(
        path: AppStrings.routeForgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppStrings.routeDashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppStrings.routeGoals,
            name: 'goals',
            builder: (context, state) => const GoalsScreen(),
          ),
          GoRoute(
            path: AppStrings.routeLeagues,
            name: 'leagues',
            builder: (context, state) => const LeaderboardScreen(),
          ),
          GoRoute(
            path: AppStrings.routeProfile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/profile/edit', // static path must be before dynamic
            name: 'editProfile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: AppStrings.routeOtherProfile, // '/profile/:id'
            name: 'otherProfile',
            builder: (context, state) {
              final userId = state.pathParameters['id']!;
              return OtherUserProfileScreen(userId: userId);
            },
          ),
        ],
      ),

      // Settings
      GoRoute(
        path: AppStrings.routeSettings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Notification Settings
      GoRoute(
        path: AppStrings.routeNotificationSettings,
        name: 'notificationSettings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),

      // Create Mission (Modal/Full Screen)
      GoRoute(
        path: AppStrings.routeCreateMission,
        name: 'createMission',
        builder: (context, state) {
          final mission = state.extra as MissionModel?;
          return CreateMissionScreen(mission: mission);
        },
      ),

      // Proof of Saving Screen
      GoRoute(
        path: AppStrings.routeProofOfSaving,
        name: 'proofOfSaving',
        builder: (context, state) {
          final mission = state.extra as MissionModel?;
          return ProofOfSavingScreen(initialMission: mission);
        },
      ),

      // Target Calculator
      GoRoute(
        path: AppStrings.routeTargetCalculator,
        name: 'targetCalculator',
        builder: (context, state) => const TargetCalculatorScreen(),
      ),

      // Mission Detail
      GoRoute(
        path: AppStrings.routeMissionDetail,
        name: 'missionDetail',
        builder: (context, state) {
          final mission = state.extra as MissionModel;
          return MissionDetailScreen(mission: mission);
        },
      ),

      // Analytics
      GoRoute(
        path: AppStrings.routeAnalytics,
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri.path}')),
    ),
  );
});
