import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/profile/data/models/user_profile_model.dart';

/// Provider for StreakValidationService
final streakValidationServiceProvider = Provider<StreakValidationService>((
  ref,
) {
  return StreakValidationService();
});

/// Result of streak validation
class StreakValidationResult {
  final int validatedStreak;
  final bool wasReset;
  final bool shieldUsed;
  final int remainingShields;
  final bool needsFirestoreUpdate;

  const StreakValidationResult({
    required this.validatedStreak,
    required this.wasReset,
    required this.shieldUsed,
    required this.remainingShields,
    required this.needsFirestoreUpdate,
  });
}

/// Service for validating and syncing streak state on app load.
///
/// This service solves the "stale streak" bug where streak value in Firestore
/// remains unchanged until the user makes a new deposit. Now the streak is
/// validated and reset proactively when the user opens the app.
class StreakValidationService {
  final FirebaseFirestore _firestore;

  StreakValidationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Validate streak based on last deposit date and return the correct value.
  ///
  /// This does NOT update Firestore - it just calculates what the streak
  /// should be based on the current date.
  StreakValidationResult validateStreak({
    required DateTime? lastDepositDate,
    required int currentStreak,
    required int streakShields,
  }) {
    if (lastDepositDate == null) {
      // Never deposited - streak should be 0
      return StreakValidationResult(
        validatedStreak: 0,
        wasReset: currentStreak > 0,
        shieldUsed: false,
        remainingShields: streakShields,
        needsFirestoreUpdate: currentStreak > 0,
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDeposit = DateTime(
      lastDepositDate.year,
      lastDepositDate.month,
      lastDepositDate.day,
    );

    final daysSinceDeposit = today.difference(lastDeposit).inDays;

    if (daysSinceDeposit <= 1) {
      // Same day or yesterday - streak is valid
      return StreakValidationResult(
        validatedStreak: currentStreak,
        wasReset: false,
        shieldUsed: false,
        remainingShields: streakShields,
        needsFirestoreUpdate: false,
      );
    } else if (daysSinceDeposit == 2 && streakShields > 0) {
      // Missed 1 day but have shield - streak is protected
      // Note: Shield is actually consumed when user saves, not here
      // But we show the streak as valid to avoid confusion
      return StreakValidationResult(
        validatedStreak: currentStreak,
        wasReset: false,
        shieldUsed: false, // Shield not consumed yet (will be on next save)
        remainingShields: streakShields,
        needsFirestoreUpdate: false,
      );
    } else {
      // Streak is broken (missed 2+ days, or missed 1 day without shield)
      final shouldReset =
          daysSinceDeposit > 2 || (daysSinceDeposit == 2 && streakShields == 0);

      if (shouldReset && currentStreak > 0) {
        return StreakValidationResult(
          validatedStreak: 0,
          wasReset: true,
          shieldUsed: false,
          remainingShields: streakShields,
          needsFirestoreUpdate: true,
        );
      }

      return StreakValidationResult(
        validatedStreak: currentStreak,
        wasReset: false,
        shieldUsed: false,
        remainingShields: streakShields,
        needsFirestoreUpdate: false,
      );
    }
  }

  /// Validate and sync streak to Firestore if needed.
  ///
  /// Call this when the app starts or when dashboard is loaded.
  /// Returns the validation result indicating what happened.
  Future<StreakValidationResult?> validateAndSync(UserProfile? profile) async {
    if (profile == null) return null;

    final result = validateStreak(
      lastDepositDate: profile.lastDepositDate,
      currentStreak: profile.currentStreak,
      streakShields: profile.streakShields,
    );

    if (result.needsFirestoreUpdate) {
      try {
        await _firestore.collection('users').doc(profile.uid).update({
          'current_streak': result.validatedStreak,
          'updated_at': FieldValue.serverTimestamp(),
        });
        debugPrint(
          '🔥 Streak reset: ${profile.currentStreak} → ${result.validatedStreak}',
        );
      } catch (e) {
        debugPrint('❌ Failed to sync streak: $e');
      }
    }

    return result;
  }

  /// Calculate how many days until streak expires.
  /// Returns 0 if already expired, 1 if needs to save today, 2 if has shield buffer.
  int getDaysUntilExpiry({
    required DateTime? lastDepositDate,
    required int streakShields,
  }) {
    if (lastDepositDate == null) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDeposit = DateTime(
      lastDepositDate.year,
      lastDepositDate.month,
      lastDepositDate.day,
    );

    final daysSinceDeposit = today.difference(lastDeposit).inDays;

    if (daysSinceDeposit == 0) {
      // Saved today - has until end of tomorrow (+ shield buffer if any)
      return 1 + (streakShields > 0 ? 1 : 0);
    } else if (daysSinceDeposit == 1) {
      // Last saved yesterday - needs to save today (+ shield buffer)
      return streakShields > 0 ? 1 : 0;
    } else if (daysSinceDeposit == 2 && streakShields > 0) {
      // Missed 1 day, shield will protect - needs to save today
      return 0; // Critical - must save today or lose streak
    } else {
      // Already expired
      return 0;
    }
  }

  /// Calculate days until next shield is earned.
  /// Returns null if already at max shields.
  int? getDaysUntilNextShield({
    required int currentStreak,
    required int streakShields,
  }) {
    // Max 1 shield at a time
    if (streakShields >= 1) return null;

    if (currentStreak == 0) return 14;

    // Shield earned at multiples of 14
    final nextMilestone = ((currentStreak ~/ 14) + 1) * 14;
    return nextMilestone - currentStreak;
  }
}
