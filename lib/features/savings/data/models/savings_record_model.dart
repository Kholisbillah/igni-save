import 'package:cloud_firestore/cloud_firestore.dart';

/// Type of savings transaction
enum SavingsType { deposit, withdrawal }

/// Savings record model for proof of saving entries
class SavingsRecord {
  final String id;
  final String missionId;
  final String userId;
  final double amount;
  final String currency;
  final String? proofImageUrl;
  final String? note;
  final DateTime timestamp;
  final int xpEarned;
  final SavingsType type;

  const SavingsRecord({
    required this.id,
    required this.missionId,
    required this.userId,
    required this.amount,
    this.currency = 'IDR',
    this.proofImageUrl,
    this.note,
    required this.timestamp,
    this.xpEarned = 0,
    this.type = SavingsType.deposit,
  });

  /// Create from Firestore document
  factory SavingsRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavingsRecord(
      id: doc.id,
      missionId: data['mission_id'] ?? '',
      userId: data['user_id'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'IDR',
      proofImageUrl: data['proof_image_url'],
      note: data['note'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      xpEarned: data['xp_earned'] ?? 0,
      type: SavingsType.values.firstWhere(
        (e) => e.name == (data['type'] ?? 'deposit'),
        orElse: () => SavingsType.deposit,
      ),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'mission_id': missionId,
      'user_id': userId,
      'amount': amount,
      'currency': currency,
      'proof_image_url': proofImageUrl,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
      'xp_earned': xpEarned,
      'type': type.name,
    };
  }

  /// Create new savings record (deposit)
  factory SavingsRecord.create({
    required String missionId,
    required String userId,
    required double amount,
    String currency = 'IDR',
    String? proofImageUrl,
    String? note,
    int xpEarned = 10,
  }) {
    return SavingsRecord(
      id: '', // Will be set by Firestore
      missionId: missionId,
      userId: userId,
      amount: amount,
      currency: currency,
      proofImageUrl: proofImageUrl,
      note: note,
      timestamp: DateTime.now(),
      xpEarned: xpEarned,
      type: SavingsType.deposit,
    );
  }

  /// Create withdrawal record
  factory SavingsRecord.withdrawal({
    required String missionId,
    required String userId,
    required double amount,
    String currency = 'IDR',
    String? note,
  }) {
    return SavingsRecord(
      id: '', // Will be set by Firestore
      missionId: missionId,
      userId: userId,
      amount: amount, // Stored as positive, type indicates withdrawal
      currency: currency,
      note: note,
      timestamp: DateTime.now(),
      xpEarned: 0, // No XP for withdrawals
      type: SavingsType.withdrawal,
    );
  }

  /// Check if this is a withdrawal
  bool get isWithdrawal => type == SavingsType.withdrawal;

  /// Get display amount (negative for withdrawal display purposes)
  double get displayAmount => isWithdrawal ? -amount : amount;
}
