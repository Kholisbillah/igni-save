import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for GamificationService
final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService();
});

/// Gamification Service - Handles XP, Streak, Level, Shield, and Challenge calculations
///
/// Core Rules:
/// - Base XP: 10 per deposit
/// - Streak Multiplier: 1.0x (1-3d), 1.2x (4-7d), 1.5x (8-14d), 2.0x (15-30d), 2.5x (31+d)
/// - Amount Bonus: min(floor(amount/100000), 5) - Anti pay-to-win
/// - Proof Bonus: +2 XP if proof image attached
/// - Daily Cap: Only 1st deposit per day counts for XP/Streak
/// - Streak Shield: Earned every 14 days, auto-used when missed
class GamificationService {
  // Constants
  static const int baseXP = 10;
  static const int proofBonusXP = 2;
  static const int maxAmountBonusXP = 5;
  static const int streakShieldInterval = 14;

  /// Calculate XP for a deposit
  /// Formula: Total XP = (Base XP * Streak Multiplier) + Amount Bonus + Proof Bonus
  int calculateXP({
    required double amount,
    required int currentStreak,
    required bool hasProof,
  }) {
    // 1. Base XP & Streak Multiplier
    double multiplier = _getStreakMultiplier(currentStreak);
    double xpFromBase = baseXP * multiplier;

    // 2. Amount Bonus (Anti Pay-to-Win)
    // Bonus = min(floor(amount / 100.000), 5)
    int amountBonus = (amount / 100000).floor();
    amountBonus = min(amountBonus, maxAmountBonusXP);

    // 3. Proof Bonus
    int proofBonus = hasProof ? proofBonusXP : 0;

    return (xpFromBase + amountBonus + proofBonus).round();
  }

  /// Get streak multiplier based on consecutive days
  double _getStreakMultiplier(int streak) {
    if (streak >= 31) return 2.5;
    if (streak >= 15) return 2.0;
    if (streak >= 8) return 1.5;
    if (streak >= 4) return 1.2;
    return 1.0;
  }

  /// Calculate new streak based on last deposit date (using LOCAL timezone)
  /// Returns a map with:
  /// - 'streak': new streak value
  /// - 'isNewDay': whether this is the first deposit today
  /// - 'shieldUsed': whether a shield was auto-used
  /// - 'streakBroken': whether streak was broken (no shield available)
  Map<String, dynamic> calculateStreak({
    required DateTime? lastDepositDate,
    required int currentStreak,
    required int streakShields,
  }) {
    final now = DateTime.now(); // Uses local timezone

    // If never deposited, it's day 1
    if (lastDepositDate == null) {
      return {
        'streak': 1,
        'isNewDay': true,
        'shieldUsed': false,
        'streakBroken': false,
      };
    }

    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      lastDepositDate.year,
      lastDepositDate.month,
      lastDepositDate.day,
    );

    final difference = today.difference(last).inDays;

    if (difference == 0) {
      // Same day - streak doesn't change, not a new day for XP
      return {
        'streak': currentStreak,
        'isNewDay': false,
        'shieldUsed': false,
        'streakBroken': false,
      };
    } else if (difference == 1) {
      // Consecutive day - increment streak
      return {
        'streak': currentStreak + 1,
        'isNewDay': true,
        'shieldUsed': false,
        'streakBroken': false,
      };
    } else if (difference == 2 && streakShields > 0) {
      // Missed 1 day but have shield - auto-use shield, maintain streak
      return {
        'streak': currentStreak + 1, // Continue streak as if no miss
        'isNewDay': true,
        'shieldUsed': true,
        'streakBroken': false,
      };
    } else {
      // Streak broken (difference > 1 without shield, or > 2)
      return {
        'streak': 1,
        'isNewDay': true,
        'shieldUsed': false,
        'streakBroken': true,
      };
    }
  }

  /// Calculate new shield count based on streak
  /// User earns 1 shield every 14 days of streak (non-stackable max 1)
  int calculateShieldEarned(int newStreak, int currentShields) {
    // Earn a shield when reaching 14, 28, 42, etc. day streak
    if (newStreak > 0 && newStreak % streakShieldInterval == 0) {
      // Max 1 shield at a time (non-stackable per spec)
      return min(currentShields + 1, 1);
    }
    return currentShields;
  }

  /// Check if user levels up
  /// Formula: XP Required = 50 * (Level ^ 1.6)
  int checkLevelUp({required int currentLevel, required int currentXp}) {
    int xpRequired = getXpRequiredForLevel(currentLevel + 1);

    if (currentXp >= xpRequired) {
      // Could level up multiple times, find correct level
      int newLevel = currentLevel;
      while (currentXp >= getXpRequiredForLevel(newLevel + 1)) {
        newLevel++;
      }
      return newLevel;
    }
    return currentLevel;
  }

  /// Calculate XP required to REACH a specific level
  /// Formula: 50 * (Level ^ 1.6)
  int getXpRequiredForLevel(int level) {
    if (level <= 1) return 0;
    return (50 * pow(level, 1.6)).round();
  }

  /// Calculate level based on total XP (inverse of getXpRequiredForLevel)
  /// Used for directly computing level from XP without iteration
  int calculateLevel(int totalXp) {
    if (totalXp < 50) return 1;
    // Binary search for level
    int level = 1;
    while (getXpRequiredForLevel(level + 1) <= totalXp) {
      level++;
    }
    return level;
  }

  /// Calculate progress to next level (0.0 to 1.0)
  double calculateLevelProgress(int totalXp, int currentLevel) {
    final currentLevelXp = getXpRequiredForLevel(currentLevel);
    final nextLevelXp = getXpRequiredForLevel(currentLevel + 1);

    final xpInLevel = totalXp - currentLevelXp;
    final xpNeeded = nextLevelXp - currentLevelXp;

    if (xpNeeded <= 0) return 1.0;
    return (xpInLevel / xpNeeded).clamp(0.0, 1.0);
  }

  /// Get title for a level
  String getLevelTitle(int level) {
    if (level >= 50) return 'Wealth God';
    if (level >= 40) return 'Financial Titan';
    if (level >= 30) return 'Money Master';
    if (level >= 20) return 'Savings Guru';
    if (level >= 10) return 'Disciplined Saver';
    if (level >= 5) return 'Consistent Saver';
    return 'Novice Saver';
  }
}

/// Challenge types
enum ChallengeType { weekly, monthly }

/// Challenge status
enum ChallengeStatus { active, completed, failed }

/// Challenge model for weekly/monthly challenges
class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int targetDays; // e.g., 5 days per week, 20 days per month
  final int currentDays;
  final int xpReward;
  final String? badgeId;
  final DateTime startDate;
  final DateTime endDate;
  final ChallengeStatus status;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetDays,
    this.currentDays = 0,
    required this.xpReward,
    this.badgeId,
    required this.startDate,
    required this.endDate,
    this.status = ChallengeStatus.active,
  });

  double get progress =>
      targetDays > 0 ? (currentDays / targetDays).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => currentDays >= targetDays;

  Challenge copyWith({int? currentDays, ChallengeStatus? status}) {
    return Challenge(
      id: id,
      title: title,
      description: description,
      type: type,
      targetDays: targetDays,
      currentDays: currentDays ?? this.currentDays,
      xpReward: xpReward,
      badgeId: badgeId,
      startDate: startDate,
      endDate: endDate,
      status: status ?? this.status,
    );
  }
}

/// Challenge definitions
class ChallengeDefinitions {
  /// Get current weekly challenge
  static Challenge getCurrentWeeklyChallenge() {
    final now = DateTime.now();
    // Week starts on Monday
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return Challenge(
      id: 'weekly_${startOfWeek.toIso8601String().substring(0, 10)}',
      title: 'Weekly Warrior',
      description: 'Menabung 5 hari dalam seminggu ini',
      type: ChallengeType.weekly,
      targetDays: 5,
      xpReward: 50,
      startDate: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      endDate: DateTime(
        endOfWeek.year,
        endOfWeek.month,
        endOfWeek.day,
        23,
        59,
        59,
      ),
    );
  }

  /// Get current monthly challenge
  static Challenge getCurrentMonthlyChallenge() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return Challenge(
      id: 'monthly_${now.year}_${now.month}',
      title: 'Monthly Master',
      description: 'Aktif menabung 20 hari dalam bulan ini',
      type: ChallengeType.monthly,
      targetDays: 20,
      xpReward: 150,
      badgeId: 'monthly_master_badge',
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }
}
