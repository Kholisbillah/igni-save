import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/repositories/savings_repository.dart';
import '../../gamification/domain/logic/gamification_service.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../profile/providers/user_profile_provider.dart';
import '../../../services/streak_check_service.dart';

/// Provider for SavingsRepository
final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  final cloudinaryService = ref.watch(cloudinaryServiceProvider);
  final gamificationService = ref.watch(gamificationServiceProvider);
  return SavingsRepository(
    cloudinaryService: cloudinaryService,
    gamificationService: gamificationService,
  );
});

/// Savings Notifier - Handles adding savings with full gamification integration
final savingsNotifierProvider =
    StateNotifierProvider<SavingsNotifier, AsyncValue<void>>((ref) {
      return SavingsNotifier(ref);
    });

class SavingsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  SavingsNotifier(this._ref) : super(const AsyncValue.data(null));

  /// Add savings with proof, calculates XP, Streak, and Level automatically
  Future<bool> addSavings({
    required String missionId,
    required double amount,
    File? proofImage,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('User not logged in');

      final repository = _ref.read(savingsRepositoryProvider);

      await repository.addSavings(
        userId: user.uid,
        missionId: missionId,
        amount: amount,
        proofImage: proofImage,
        note: note,
      );

      // Invalidate leaderboard to refresh it
      _ref.invalidate(leaderboardByStreakProvider);

      // Mark that user has saved today (for reminder system)
      try {
        final streakService = _ref.read(streakCheckServiceProvider);
        await streakService.markSavedToday();
      } catch (e) {
        // Don't fail the save operation if streak marking fails
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Withdraw savings from a goal (no XP, reduces goal and total_savings)
  Future<bool> withdrawSavings({
    required String missionId,
    required double amount,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('User not logged in');

      final repository = _ref.read(savingsRepositoryProvider);

      await repository.withdrawSavings(
        userId: user.uid,
        missionId: missionId,
        amount: amount,
        note: note,
      );

      // Invalidate user profile to refresh balances
      _ref.invalidate(currentUserProfileProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

/// Provider for savings heatmap data (for consistency heatmap widget)
final savingsHeatmapProvider = FutureProvider<Map<DateTime, double>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};

  final snapshot = await FirebaseFirestore.instance
      .collection('savings_history')
      .where('user_id', isEqualTo: user.uid)
      .orderBy('timestamp', descending: true)
      .get();

  final Map<DateTime, double> heatmap = {};

  for (var doc in snapshot.docs) {
    final data = doc.data();
    final timestamp = data['timestamp'] as Timestamp?;
    if (timestamp == null) continue;

    final date = timestamp.toDate();
    final dateKey = DateTime(date.year, date.month, date.day);
    final amount = (data['amount'] as num).toDouble();

    heatmap[dateKey] = (heatmap[dateKey] ?? 0) + amount;
  }

  return heatmap;
});

/// Provider for recent savings history
final recentSavingsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('savings_history')
      .where('user_id', isEqualTo: user.uid)
      .orderBy('timestamp', descending: true)
      .limit(10)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
      );
});

/// Provider for savings history of a specific mission
final missionSavingsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, missionId) {
      final user = ref.watch(currentUserProvider);
      if (user == null) return Stream.value([]);

      return FirebaseFirestore.instance
          .collection('savings_history')
          .where('user_id', isEqualTo: user.uid)
          .where('mission_id', isEqualTo: missionId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => {'id': doc.id, ...doc.data()})
                .toList(),
          );
    });
