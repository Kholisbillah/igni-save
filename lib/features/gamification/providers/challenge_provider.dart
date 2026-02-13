import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/logic/gamification_service.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for current weekly challenge
final weeklyChallengeprovider = StreamProvider<Challenge>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(ChallengeDefinitions.getCurrentWeeklyChallenge());
  }

  final weeklyChallenge = ChallengeDefinitions.getCurrentWeeklyChallenge();

  // Get user's progress for this week
  return FirebaseFirestore.instance
      .collection('savings_history')
      .where('user_id', isEqualTo: user.uid)
      .where(
        'timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(weeklyChallenge.startDate),
      )
      .where(
        'timestamp',
        isLessThanOrEqualTo: Timestamp.fromDate(weeklyChallenge.endDate),
      )
      .snapshots()
      .map((snapshot) {
        // Count unique days with savings
        final uniqueDays = <String>{};
        for (var doc in snapshot.docs) {
          final timestamp = (doc.data()['timestamp'] as Timestamp?)?.toDate();
          if (timestamp != null) {
            uniqueDays.add(
              '${timestamp.year}-${timestamp.month}-${timestamp.day}',
            );
          }
        }

        final currentDays = uniqueDays.length;
        final isCompleted = currentDays >= weeklyChallenge.targetDays;

        return weeklyChallenge.copyWith(
          currentDays: currentDays,
          status: isCompleted
              ? ChallengeStatus.completed
              : ChallengeStatus.active,
        );
      });
});

/// Provider for current monthly challenge
final monthlyChallengeProvider = StreamProvider<Challenge>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(ChallengeDefinitions.getCurrentMonthlyChallenge());
  }

  final monthlyChallenge = ChallengeDefinitions.getCurrentMonthlyChallenge();

  // Get user's progress for this month
  return FirebaseFirestore.instance
      .collection('savings_history')
      .where('user_id', isEqualTo: user.uid)
      .where(
        'timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(monthlyChallenge.startDate),
      )
      .where(
        'timestamp',
        isLessThanOrEqualTo: Timestamp.fromDate(monthlyChallenge.endDate),
      )
      .snapshots()
      .map((snapshot) {
        // Count unique days with savings
        final uniqueDays = <String>{};
        for (var doc in snapshot.docs) {
          final timestamp = (doc.data()['timestamp'] as Timestamp?)?.toDate();
          if (timestamp != null) {
            uniqueDays.add(
              '${timestamp.year}-${timestamp.month}-${timestamp.day}',
            );
          }
        }

        final currentDays = uniqueDays.length;
        final isCompleted = currentDays >= monthlyChallenge.targetDays;

        return monthlyChallenge.copyWith(
          currentDays: currentDays,
          status: isCompleted
              ? ChallengeStatus.completed
              : ChallengeStatus.active,
        );
      });
});

/// Provider for all active challenges
final activeChallengesProvider = Provider<AsyncValue<List<Challenge>>>((ref) {
  final weekly = ref.watch(weeklyChallengeprovider);
  final monthly = ref.watch(monthlyChallengeProvider);

  return weekly.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (weeklyData) => monthly.when(
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
      data: (monthlyData) => AsyncValue.data([weeklyData, monthlyData]),
    ),
  );
});
