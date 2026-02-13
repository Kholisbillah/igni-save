import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../notification_controller.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../gamification/domain/logic/gamification_service.dart';
import '../../../missions/data/models/mission_model.dart';
import '../models/savings_record_model.dart';

class SavingsRepository {
  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinaryService;
  final GamificationService _gamificationService;

  SavingsRepository({
    FirebaseFirestore? firestore,
    CloudinaryService? cloudinaryService,
    GamificationService? gamificationService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _cloudinaryService = cloudinaryService ?? CloudinaryService(),
       _gamificationService = gamificationService ?? GamificationService();

  Future<void> addSavings({
    required String userId,
    required String missionId,
    required double amount,
    File? proofImage,
    String? note,
  }) async {
    // 1. Upload Image if exists
    String? imageUrl;
    if (proofImage != null) {
      imageUrl = await _cloudinaryService.uploadImage(proofImage);
    }

    // 2. Run Transaction
    final result = await _firestore.runTransaction<Map<String, dynamic>?>((
      transaction,
    ) async {
      // References
      final userRef = _firestore.collection('users').doc(userId);
      final missionRef = _firestore.collection('missions').doc(missionId);
      final savingsRef = _firestore.collection('savings_history').doc();

      // Get current data
      final userDoc = await transaction.get(userRef);
      final missionDoc = await transaction.get(missionRef);

      if (!userDoc.exists || !missionDoc.exists) {
        throw Exception("User or Mission not found!");
      }

      final user = UserModel.fromFirestore(userDoc);
      final mission = MissionModel.fromFirestore(missionDoc);

      // 3. Calculate Gamification Updates (with streak shield support)
      final streakInfo = _gamificationService.calculateStreak(
        lastDepositDate: user.lastDepositDate,
        currentStreak: user.currentStreak,
        streakShields: user.streakShields,
      );

      final bool isNewDay = streakInfo['isNewDay'];
      final int newStreak = streakInfo['streak'];
      final bool shieldUsed = streakInfo['shieldUsed'];

      // Calculate new shield count (earn 1 every 14 days, use 1 if missed)
      int newShields = user.streakShields;
      bool shieldWasEarned = false;
      if (shieldUsed) {
        newShields = (newShields - 1).clamp(0, 1);
      }
      // Award new shield at streak milestones (14, 28, 42...)
      final previousShields = newShields;
      newShields = _gamificationService.calculateShieldEarned(
        newStreak,
        newShields,
      );
      shieldWasEarned = newShields > previousShields;

      // Only give XP if it's a new day (Anti-Spam Rule)
      int xpEarned = 0;
      if (isNewDay) {
        xpEarned = _gamificationService.calculateXP(
          amount: amount,
          currentStreak: newStreak,
          hasProof: imageUrl != null,
        );
      }

      final int newTotalXp = user.currentXp + xpEarned;
      final int newLevel = _gamificationService.checkLevelUp(
        currentLevel: user.level,
        currentXp: newTotalXp,
      );

      // 4. Create Savings Record
      final newRecord = SavingsRecord(
        id: savingsRef.id,
        missionId: missionId,
        userId: userId,
        amount: amount,
        proofImageUrl: imageUrl,
        note: note,
        timestamp: DateTime.now(),
        xpEarned: xpEarned,
      );

      // 5. Update Mission
      final newMissionAmount = mission.currentAmount + amount;
      final isCompleted = newMissionAmount >= mission.targetAmount;

      transaction.update(missionRef, {
        'current_amount': newMissionAmount,
        'status': isCompleted ? 'completed' : mission.status.name,
      });

      // 6. Update User
      transaction.update(userRef, {
        'total_savings': user.totalSavings + amount,
        'current_xp': newTotalXp,
        'level': newLevel,
        'current_streak': isNewDay ? newStreak : user.currentStreak,
        'max_streak': (isNewDay && newStreak > user.maxStreak)
            ? newStreak
            : user.maxStreak,
        'streak_shields': newShields,
        'last_deposit_date': FieldValue.serverTimestamp(),
      });

      // 7. Save Record
      transaction.set(savingsRef, newRecord.toFirestore());

      // 8. Return shield notification flags for post-transaction handling
      return {
        'shieldUsed': shieldUsed,
        'shieldEarned': shieldWasEarned,
        'savedStreak': newStreak,
      };
    });

    // 9. Show shield notifications (outside transaction)
    if (result != null) {
      if (result['shieldEarned'] == true) {
        await NotificationController.showShieldEarnedNotification();
      }
      if (result['shieldUsed'] == true) {
        await NotificationController.showShieldUsedNotification(
          savedStreak: result['savedStreak'] ?? 0,
        );
      }
    }
  }

  /// Withdraw savings from a goal
  /// This will reduce both the mission's current_amount and user's total_savings
  Future<void> withdrawSavings({
    required String userId,
    required String missionId,
    required double amount,
    String? note,
  }) async {
    await _firestore.runTransaction((transaction) async {
      // References
      final userRef = _firestore.collection('users').doc(userId);
      final missionRef = _firestore.collection('missions').doc(missionId);
      final savingsRef = _firestore.collection('savings_history').doc();

      // Get current data
      final userDoc = await transaction.get(userRef);
      final missionDoc = await transaction.get(missionRef);

      if (!userDoc.exists || !missionDoc.exists) {
        throw Exception("User or Mission not found!");
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final missionData = missionDoc.data() as Map<String, dynamic>;

      final currentMissionAmount = (missionData['current_amount'] ?? 0.0)
          .toDouble();
      final currentTotalSavings = (userData['total_savings'] ?? 0.0).toDouble();

      // Validate: cannot withdraw more than available
      if (amount > currentMissionAmount) {
        throw Exception(
          "Insufficient balance! Available: $currentMissionAmount, Requested: $amount",
        );
      }

      // Create withdrawal record
      final withdrawalRecord = SavingsRecord.withdrawal(
        missionId: missionId,
        userId: userId,
        amount: amount,
        currency: missionData['currency'] ?? 'IDR',
        note: note,
      );

      // Update Mission - reduce current amount
      transaction.update(missionRef, {
        'current_amount': currentMissionAmount - amount,
        // If it was completed and we withdraw, set back to active
        'status':
            (currentMissionAmount - amount) <
                (missionData['target_amount'] ?? 0)
            ? 'active'
            : missionData['status'],
      });

      // Update User - reduce total savings
      transaction.update(userRef, {
        'total_savings': (currentTotalSavings - amount).clamp(
          0.0,
          double.infinity,
        ),
      });

      // Save withdrawal record
      transaction.set(savingsRef, withdrawalRecord.toFirestore());
    });
  }
}
