import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../gamification/domain/logic/gamification_service.dart';
import '../../../../core/constants/app_strings.dart';
import '../models/user_profile_model.dart';

/// Repository for user profile operations
class UserRepository {
  final FirebaseFirestore _firestore;
  final GamificationService _gamificationService;

  UserRepository({
    FirebaseFirestore? firestore,
    GamificationService? gamificationService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _gamificationService = gamificationService ?? GamificationService();

  /// Get users collection reference
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(AppStrings.collectionUsers);

  /// Get user profile stream
  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  /// Get user profile once
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  /// Create new user profile
  Future<void> createUserProfile(UserProfile profile) async {
    await _usersRef.doc(profile.uid).set(profile.toFirestore());
  }

  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    await _usersRef.doc(profile.uid).update({
      ...profile.toFirestore(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Update specific fields
  Future<void> updateProfileFields(
    String uid,
    Map<String, dynamic> fields,
  ) async {
    await _usersRef.doc(uid).update({
      ...fields,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Menambahkan XP dan cek level up (atomik via transaction)
  Future<void> addXp(String uid, int xpAmount) async {
    final docRef = _usersRef.doc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final currentXp = (data['current_xp'] ?? 0) as int;
      final newXp = currentXp + xpAmount;
      final newLevel = _gamificationService.calculateLevel(newXp);

      transaction.update(docRef, {
        'current_xp': newXp,
        'level': newLevel,
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Add savings amount to total
  Future<void> addSavings(String uid, double amount) async {
    await _usersRef.doc(uid).update({
      'total_savings': FieldValue.increment(amount),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Memperbarui streak (atomik via transaction untuk mencegah race condition)
  Future<void> updateStreak(String uid, {required bool hasSavedToday}) async {
    if (!hasSavedToday) return;

    final docRef = _usersRef.doc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final now = DateTime.now();

      // Baca data terbaru dari transaction snapshot
      final lastDepositTimestamp = data['last_deposit_date'] as Timestamp?;
      final lastSaving = lastDepositTimestamp?.toDate();
      int newStreak = (data['current_streak'] ?? 0) as int;
      int newMaxStreak = (data['max_streak'] ?? 0) as int;
      int streakShields = (data['streak_shields'] ?? 0) as int;
      DateTime? lastShieldUsed;
      final lastShieldTimestamp = data['last_shield_used_date'] as Timestamp?;
      if (lastShieldTimestamp != null) {
        lastShieldUsed = lastShieldTimestamp.toDate();
      }

      // Cek apakah ini kelanjutan streak
      if (lastSaving == null) {
        newStreak = 1;
      } else {
        final daysSinceLastSaving = now.difference(lastSaving).inDays;

        // Cek apakah sudah menabung hari ini (hari yang sama)
        final isSameDay =
            lastSaving.year == now.year &&
            lastSaving.month == now.month &&
            lastSaving.day == now.day;

        if (isSameDay) {
          // Sudah menabung hari ini, tidak perlu update streak
          return;
        }

        if (daysSinceLastSaving <= 1) {
          // Hari berikutnya - lanjutkan streak
          newStreak++;
        } else {
          // Streak putus, cek shield
          if (daysSinceLastSaving == 2 && streakShields > 0) {
            // Gunakan shield
            streakShields--;
            lastShieldUsed = now;
            newStreak++; // Streak tetap lanjut
          } else {
            // Streak putus
            newStreak = 1;
          }
        }
      }

      // Update max streak
      if (newStreak > newMaxStreak) {
        newMaxStreak = newStreak;
      }

      // Logika Shield: 1 Shield per 14 hari streak
      if (newStreak > 0 && newStreak % 14 == 0) {
        if (streakShields < 1) {
          streakShields = 1; // Maksimal 1 shield aktif
        }
      }

      transaction.update(docRef, {
        'current_streak': newStreak,
        'max_streak': newMaxStreak,
        'last_deposit_date': Timestamp.fromDate(now),
        'streak_shields': streakShields,
        'last_shield_used_date': lastShieldUsed != null
            ? Timestamp.fromDate(lastShieldUsed)
            : null,
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Get leaderboard by streak (excludes private accounts)
  Future<List<UserProfile>> getLeaderboardByStreak({int limit = 50}) async {
    try {
      // Try optimized query (requires index)
      final query = await _usersRef
          .where('is_private', isEqualTo: false)
          .orderBy('max_streak', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      // Fallback if index is missing (failed-precondition)
      if (e.code == 'failed-precondition') {
        debugPrint(
          '⚠️ Firestore Index Missing. Falling back to client-side filtering.',
        );
        debugPrint('Create index here: ${e.message}');

        // Fetch more items to ensure we have enough after filtering
        final query = await _usersRef
            .orderBy('max_streak', descending: true)
            .limit(limit * 2)
            .get();

        return query.docs
            .map((doc) => UserProfile.fromFirestore(doc))
            .where((user) => !user.isPrivate)
            .take(limit)
            .toList();
      }
      rethrow;
    }
  }

  /// Get public user profile (masks data if private)
  Future<UserProfile?> getPublicUserProfile(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;

    final profile = UserProfile.fromFirestore(doc);
    if (profile.isPrivate) {
      return profile.masked();
    }

    return profile;
  }

  /// Get leaderboard by CURRENT active streak (not max/historical)
  /// This shows who is on the longest active streak right now
  Future<List<UserProfile>> getLeaderboardByCurrentStreak({
    int limit = 20,
  }) async {
    try {
      // Try optimized query (requires index)
      final query = await _usersRef
          .where('is_private', isEqualTo: false)
          .where('current_streak', isGreaterThan: 0) // Only active streaks
          .orderBy('current_streak', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      // Fallback if index is missing (failed-precondition)
      if (e.code == 'failed-precondition') {
        debugPrint(
          '⚠️ Firestore Index Missing. Falling back to client-side filtering.',
        );
        debugPrint('Create index here: ${e.message}');

        // Fetch more items to ensure we have enough after filtering
        final query = await _usersRef
            .orderBy('current_streak', descending: true)
            .limit(limit * 2)
            .get();

        return query.docs
            .map((doc) => UserProfile.fromFirestore(doc))
            .where((user) => !user.isPrivate && user.currentStreak > 0)
            .take(limit)
            .toList();
      }
      rethrow;
    }
  }
}

/// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final gamificationService = ref.watch(gamificationServiceProvider);
  return UserRepository(gamificationService: gamificationService);
});
