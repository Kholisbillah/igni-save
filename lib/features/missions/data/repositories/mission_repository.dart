import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../notification_controller.dart';
import '../../../../services/currency_service.dart';
import '../models/mission_model.dart';

class MissionRepository {
  final FirebaseFirestore _firestore;

  MissionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _missions => _firestore.collection('missions');

  // Create a new mission
  Future<void> createMission(MissionModel mission) async {
    final docRef = await _missions.add(mission.toFirestore());

    // Schedule notifications if enabled
    if (mission.notificationEnabled) {
      await NotificationController.scheduleMissionReminders(
        missionId: docRef.id,
        missionTitle: mission.title,
        notificationEnabled: mission.notificationEnabled,
        notificationTimes: mission.notificationTimes,
        notificationDays: mission.notificationDays,
      );
    }
  }

  // Get active missions for a user
  Stream<List<MissionModel>> getUserActiveMissions(String userId) {
    return _missions
        .where('owner_id', isEqualTo: userId)
        .where('status', isEqualTo: MissionStatus.active.name)
        .orderBy('deadline')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MissionModel.fromFirestore(doc))
              .where(
                (m) => m.status != MissionStatus.deleted,
              ) // Extra safety check
              .toList();
        });
  }

  // Get all missions for a user (including completed/failed but excluding deleted)
  Stream<List<MissionModel>> getAllUserMissions(String userId) {
    return _missions
        .where('owner_id', isEqualTo: userId)
        .orderBy('deadline')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MissionModel.fromFirestore(doc))
              .where((m) => m.status != MissionStatus.deleted)
              .toList();
        });
  }

  // Update mission (including notification changes)
  Future<void> updateMission(MissionModel mission) async {
    await _missions.doc(mission.id).update(mission.toFirestore());

    // Reschedule notifications based on updated settings
    await NotificationController.scheduleMissionReminders(
      missionId: mission.id,
      missionTitle: mission.title,
      notificationEnabled: mission.notificationEnabled,
      notificationTimes: mission.notificationTimes,
      notificationDays: mission.notificationDays,
    );
  }

  // Add amount to mission
  Future<void> addToMission(String missionId, double amount) async {
    final docRef = _missions.doc(missionId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Mission does not exist!");
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final currentAmount = (data['current_amount'] ?? 0.0).toDouble();
      final targetAmount = (data['target_amount'] ?? 0.0).toDouble();
      final newAmount = currentAmount + amount;

      final updates = <String, dynamic>{'current_amount': newAmount};

      // Auto-complete if target reached
      if (newAmount >= targetAmount &&
          (data['status'] ?? '') != MissionStatus.completed.name) {
        updates['status'] = MissionStatus.completed.name;

        // Cancel notifications when mission is completed
        // We do this outside the transaction
      }

      transaction.update(docRef, updates);
    });

    // Check if mission was completed and cancel notifications
    final updatedDoc = await docRef.get();
    final data = updatedDoc.data() as Map<String, dynamic>?;
    if (data != null && data['status'] == MissionStatus.completed.name) {
      await NotificationController.cancelAllMissionReminders(missionId);
    }
  }

  // Menghapus misi (Soft Delete) dengan konversi mata uang yang benar
  Future<void> deleteMission(String missionId, String userId) async {
    final currencyService = CurrencyService();

    await _firestore.runTransaction((transaction) async {
      final userRef = _firestore.collection('users').doc(userId);
      final missionRef = _missions.doc(missionId);

      // 1. Ambil data misi untuk membaca currentAmount & currency
      final missionDoc = await transaction.get(missionRef);
      if (!missionDoc.exists) throw Exception("Mission not found!");

      final missionData = missionDoc.data() as Map<String, dynamic>;
      final currentAmount = (missionData['current_amount'] ?? 0.0).toDouble();
      final missionCurrency = missionData['currency'] as String? ?? 'IDR';

      // 2. Ambil data user
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) throw Exception("User not found!");

      final userData = userDoc.data()!;
      final currentTotalSavings = (userData['total_savings'] ?? 0.0).toDouble();
      final userCurrency = userData['preferred_currency'] as String? ?? 'IDR';

      // 3. Konversi amount ke mata uang user jika berbeda
      double amountToSubtract = currentAmount;
      if (missionCurrency != userCurrency && currentAmount > 0) {
        amountToSubtract = await currencyService.convert(
          amount: currentAmount,
          from: missionCurrency,
          to: userCurrency,
        );
      }

      // 4. Update status misi ke deleted
      transaction.update(missionRef, {
        'status': MissionStatus.deleted.name,
        'deleted_at': Timestamp.now(),
      });

      // 5. Kurangi total_savings user dengan jumlah yang sudah dikonversi
      transaction.update(userRef, {
        'total_savings': (currentTotalSavings - amountToSubtract).clamp(
          0.0,
          double.infinity,
        ),
      });
    });

    // Batalkan semua notifikasi untuk misi ini
    await NotificationController.cancelAllMissionReminders(missionId);
  }

  // Archive a mission (hides from main list but keeps data)
  Future<void> archiveMission(String missionId) async {
    await _missions.doc(missionId).update({
      'is_archived': true,
      'archived_at': Timestamp.now(),
      'updated_at': Timestamp.now(),
    });

    // Cancel notifications when archived
    await NotificationController.cancelAllMissionReminders(missionId);
  }

  // Unarchive a mission (restores to active list)
  Future<void> unarchiveMission(String missionId) async {
    await _missions.doc(missionId).update({
      'is_archived': false,
      'archived_at': null,
      'updated_at': Timestamp.now(),
    });
  }

  // Mark mission as completed
  Future<void> completeMission(String missionId) async {
    await _missions.doc(missionId).update({
      'status': MissionStatus.completed.name,
      'completed_at': Timestamp.now(),
      'updated_at': Timestamp.now(),
    });

    // Cancel notifications when completed
    await NotificationController.cancelAllMissionReminders(missionId);
  }

  // Get a single mission by ID
  Future<MissionModel?> getMissionById(String missionId) async {
    final doc = await _missions.doc(missionId).get();
    if (!doc.exists) return null;
    return MissionModel.fromFirestore(doc);
  }

  // Update mission color theme
  Future<void> updateMissionColor(String missionId, String colorTheme) async {
    await _missions.doc(missionId).update({
      'color_theme': colorTheme,
      'updated_at': Timestamp.now(),
    });
  }

  /// Convert all user's missions to a new currency
  Future<void> convertAllMissionsCurrency(
    String userId,
    String newCurrency,
  ) async {
    final currencyService = CurrencyService();
    final batch = _firestore.batch();

    // Get all non-deleted missions for the user
    final snapshot = await _missions
        .where('owner_id', isEqualTo: userId)
        .where('status', isNotEqualTo: MissionStatus.deleted.name)
        .get();

    if (snapshot.docs.isEmpty) return;

    // Fetch latest rates to ensure accuracy
    await currencyService.getExchangeRates();

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final oldCurrency = data['currency'] as String? ?? 'IDR';

      // Skip if currency is already the same
      if (oldCurrency == newCurrency) continue;

      final currentAmount = (data['current_amount'] ?? 0.0).toDouble();
      final targetAmount = (data['target_amount'] ?? 0.0).toDouble();
      final fillingNominal = (data['filling_nominal'] ?? 0.0).toDouble();

      // Convert amounts
      final newCurrentAmount = await currencyService.convert(
        amount: currentAmount,
        from: oldCurrency,
        to: newCurrency,
      );

      final newTargetAmount = await currencyService.convert(
        amount: targetAmount,
        from: oldCurrency,
        to: newCurrency,
      );

      final newFillingNominal = await currencyService.convert(
        amount: fillingNominal,
        from: oldCurrency,
        to: newCurrency,
      );

      final newTargetAmountUsd = await currencyService.toUSD(
        newTargetAmount,
        newCurrency,
      );

      // Add to batch update
      batch.update(doc.reference, {
        'currency': newCurrency,
        'current_amount': newCurrentAmount,
        'target_amount': newTargetAmount,
        'target_amount_usd': newTargetAmountUsd,
        'filling_nominal': newFillingNominal,
        'updated_at': Timestamp.now(),
      });
    }

    // Commit all changes
    await batch.commit();
  }
}
