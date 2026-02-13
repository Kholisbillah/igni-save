import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../auth/providers/auth_provider.dart';
import '../../gamification/domain/logic/gamification_service.dart';
import '../data/models/user_profile_model.dart';
import '../data/repositories/user_repository.dart';

/// Stream provider for current user profile
final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(userRepositoryProvider);

  final user = authState.valueOrNull;
  if (user == null) {
    return Stream.value(null);
  }

  return repository.getUserProfileStream(user.uid);
});

/// Provider for current user profile (sync)
final currentUserProfileProvider = Provider<UserProfile?>((ref) {
  return ref.watch(userProfileStreamProvider).valueOrNull;
});

/// Provider for user's streak info with real-time validation
/// This validates streak based on lastDepositDate to show accurate values
/// even before Firestore is synced
final userStreakProvider =
    Provider<
      ({int current, int best, bool hasSavedToday, int daysUntilExpiry})
    >((ref) {
      final profile = ref.watch(currentUserProfileProvider);
      if (profile == null) {
        return (current: 0, best: 0, hasSavedToday: false, daysUntilExpiry: 0);
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastSaving = profile.lastDepositDate;

      // Check if saved today
      final hasSavedToday =
          lastSaving != null &&
          lastSaving.year == now.year &&
          lastSaving.month == now.month &&
          lastSaving.day == now.day;

      // Real-time streak validation (don't trust stale Firestore value)
      int validatedStreak = profile.currentStreak;
      int daysUntilExpiry = 1;

      if (lastSaving != null) {
        final lastSavingDay = DateTime(
          lastSaving.year,
          lastSaving.month,
          lastSaving.day,
        );
        final daysSinceDeposit = today.difference(lastSavingDay).inDays;

        if (daysSinceDeposit == 0) {
          // Saved today - streak is valid, has until end of tomorrow
          daysUntilExpiry = 1 + (profile.streakShields > 0 ? 1 : 0);
        } else if (daysSinceDeposit == 1) {
          // Last saved yesterday - needs to save today
          daysUntilExpiry = profile.streakShields > 0 ? 1 : 0;
        } else if (daysSinceDeposit == 2 && profile.streakShields > 0) {
          // Missed 1 day, shield will protect - critical, save today
          daysUntilExpiry = 0;
        } else if (daysSinceDeposit > 1) {
          // Streak should be reset (will be synced by validation service)
          if (daysSinceDeposit > 2 || profile.streakShields == 0) {
            validatedStreak = 0;
          }
          daysUntilExpiry = 0;
        }
      } else {
        // Never deposited
        validatedStreak = 0;
        daysUntilExpiry = 0;
      }

      return (
        current: validatedStreak,
        best: profile.maxStreak,
        hasSavedToday: hasSavedToday,
        daysUntilExpiry: daysUntilExpiry,
      );
    });

/// Provider for user's level info
final userLevelProvider =
    Provider<({int level, String title, int xp, double progress})>((ref) {
      final profile = ref.watch(currentUserProfileProvider);
      final gamificationService = ref.watch(gamificationServiceProvider);

      if (profile == null) {
        return (level: 1, title: 'Novice Saver', xp: 0, progress: 0.0);
      }

      return (
        level: profile.level,
        title: gamificationService.getLevelTitle(profile.level),
        xp: profile.currentXp,
        progress: gamificationService.calculateLevelProgress(
          profile.currentXp,
          profile.level,
        ),
      );
    });

/// Notifier for updating user profile
class UserProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final UserRepository _repository;
  final User? _currentUser;

  UserProfileNotifier(this._repository, this._currentUser)
    : super(const AsyncValue.data(null));

  /// Update profile fields
  Future<void> updateProfile({
    String? username,
    String? bio,
    String? photoUrl,
    bool? isPrivate,
    String? preferredCurrency,
    bool? notificationsEnabled,
  }) async {
    if (_currentUser == null) return;

    state = const AsyncValue.loading();
    try {
      final fields = <String, dynamic>{};
      if (username != null) fields['username'] = username;
      if (bio != null) fields['bio'] = bio;
      if (photoUrl != null) fields['photo_url'] = photoUrl;
      if (isPrivate != null) fields['is_private'] = isPrivate;
      if (preferredCurrency != null) {
        fields['preferred_currency'] = preferredCurrency;
      }
      if (notificationsEnabled != null) {
        fields['notifications_enabled'] = notificationsEnabled;
      }

      await _repository.updateProfileFields(_currentUser.uid, fields);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add XP to user
  Future<void> addXp(int amount) async {
    if (_currentUser == null) return;
    await _repository.addXp(_currentUser.uid, amount);
  }

  /// Add savings to total
  Future<void> addSavings(double amount) async {
    if (_currentUser == null) return;
    await _repository.addSavings(_currentUser.uid, amount);
  }

  /// Update streak after saving
  Future<void> updateStreak() async {
    if (_currentUser == null) return;
    await _repository.updateStreak(_currentUser.uid, hasSavedToday: true);
  }
}

/// Provider for UserProfileNotifier
final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(userRepositoryProvider);
      final authState = ref.watch(authStateProvider);
      return UserProfileNotifier(repository, authState.valueOrNull);
    });

/// Provider for leaderboard by streak (Hall of Fame - max streak)
final leaderboardByStreakProvider =
    FutureProvider.autoDispose<List<UserProfile>>((ref) async {
      final repository = ref.watch(userRepositoryProvider);
      return repository.getLeaderboardByStreak();
    });

/// Provider for leaderboard by CURRENT active streak (Active Streaks tab)
final leaderboardByCurrentStreakProvider =
    FutureProvider.autoDispose<List<UserProfile>>((ref) async {
      final repository = ref.watch(userRepositoryProvider);
      return repository.getLeaderboardByCurrentStreak();
    });
