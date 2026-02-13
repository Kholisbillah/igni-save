import 'package:flutter_test/flutter_test.dart';
import 'package:igni_save/features/gamification/domain/logic/gamification_service.dart';

void main() {
  late GamificationService service;

  setUp(() {
    service = GamificationService();
  });

  group('XP Calculation', () {
    test('Base XP calculation (Day 1)', () {
      // Base (10) * Streak (1.0) + Amount (0) + Proof (0) = 10
      expect(
        service.calculateXP(amount: 50000, currentStreak: 1, hasProof: false),
        10,
      );
    });

    test('Streak Multiplier (Day 4 - x1.2)', () {
      // Base (10) * Streak (1.2) = 12
      expect(
        service.calculateXP(amount: 50000, currentStreak: 4, hasProof: false),
        12,
      );
    });

    test('Streak Multiplier (Day 10 - x1.5)', () {
      // Base (10) * Streak (1.5) = 15
      expect(
        service.calculateXP(amount: 50000, currentStreak: 10, hasProof: false),
        15,
      );
    });

    test('Amount Bonus', () {
      // 200k / 100k = 2 bonus
      // Total = 10 + 2 = 12
      expect(
        service.calculateXP(amount: 200000, currentStreak: 1, hasProof: false),
        12,
      );
    });

    test('Amount Bonus Cap', () {
      // 1M / 100k = 10, but cap is 5
      // Total = 10 + 5 = 15
      expect(
        service.calculateXP(amount: 1000000, currentStreak: 1, hasProof: false),
        15,
      );
    });

    test('Proof Bonus', () {
      // Base 10 + Proof 2 = 12
      expect(
        service.calculateXP(amount: 50000, currentStreak: 1, hasProof: true),
        12,
      );
    });

    test('Complex Calculation', () {
      // Day 10 (x1.5) + 200k (2 bonus) + Proof (2 bonus)
      // (10 * 1.5) + 2 + 2 = 15 + 4 = 19
      expect(
        service.calculateXP(amount: 200000, currentStreak: 10, hasProof: true),
        19,
      );
    });
  });

  group('Streak Calculation', () {
    test('First deposit ever', () {
      final result = service.calculateStreak(
        lastDepositDate: null,
        currentStreak: 0,
        streakShields: 0,
      );
      expect(result['streak'], 1);
      expect(result['isNewDay'], true);
      expect(result['shieldUsed'], false);
    });

    test('Consecutive day deposit', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = service.calculateStreak(
        lastDepositDate: yesterday,
        currentStreak: 5,
        streakShields: 0,
      );
      expect(result['streak'], 6);
      expect(result['isNewDay'], true);
      expect(result['shieldUsed'], false);
    });

    test('Same day deposit', () {
      final today = DateTime.now();
      final result = service.calculateStreak(
        lastDepositDate: today,
        currentStreak: 5,
        streakShields: 0,
      );
      expect(result['streak'], 5);
      expect(result['isNewDay'], false);
      expect(result['shieldUsed'], false);
    });

    test('Missed a day without shield (Reset)', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final result = service.calculateStreak(
        lastDepositDate: twoDaysAgo,
        currentStreak: 5,
        streakShields: 0,
      );
      expect(result['streak'], 1);
      expect(result['isNewDay'], true);
      expect(result['shieldUsed'], false);
      expect(result['streakBroken'], true);
    });

    test('Missed a day with shield (Shield auto-used)', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final result = service.calculateStreak(
        lastDepositDate: twoDaysAgo,
        currentStreak: 5,
        streakShields: 1,
      );
      expect(result['streak'], 6);
      expect(result['isNewDay'], true);
      expect(result['shieldUsed'], true);
      expect(result['streakBroken'], false);
    });
  });
}
