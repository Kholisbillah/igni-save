import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String photoUrl;
  final String bio;
  final int level;
  final int currentXp;
  final double totalSavings;
  final int currentStreak;
  final int maxStreak;
  final int streakShields;
  final DateTime? lastDepositDate;
  final bool isPrivate;

  const UserModel({
    required this.uid,
    required this.username,
    required this.photoUrl,
    this.bio = '',
    this.level = 1,
    this.currentXp = 0,
    this.totalSavings = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.streakShields = 0,
    this.lastDepositDate,
    this.isPrivate = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      photoUrl: data['photo_url'] ?? '',
      bio: data['bio'] ?? '',
      level: data['level'] ?? 1,
      currentXp: data['current_xp'] ?? 0,
      totalSavings: (data['total_savings'] ?? 0).toDouble(),
      currentStreak: data['current_streak'] ?? 0,
      maxStreak: data['max_streak'] ?? 0,
      streakShields: data['streak_shields'] ?? 0,
      lastDepositDate: data['last_deposit_date'] != null
          ? (data['last_deposit_date'] as Timestamp).toDate()
          : null,
      isPrivate: data['is_private'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'photo_url': photoUrl,
      'bio': bio,
      'level': level,
      'current_xp': currentXp,
      'total_savings': totalSavings,
      'current_streak': currentStreak,
      'max_streak': maxStreak,
      'streak_shields': streakShields,
      'last_deposit_date': lastDepositDate != null
          ? Timestamp.fromDate(lastDepositDate!)
          : null,
      'is_private': isPrivate,
    };
  }

  UserModel copyWith({
    String? username,
    String? photoUrl,
    String? bio,
    int? level,
    int? currentXp,
    double? totalSavings,
    int? currentStreak,
    int? maxStreak,
    int? streakShields,
    DateTime? lastDepositDate,
    bool? isPrivate,
  }) {
    return UserModel(
      uid: uid,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      totalSavings: totalSavings ?? this.totalSavings,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      streakShields: streakShields ?? this.streakShields,
      lastDepositDate: lastDepositDate ?? this.lastDepositDate,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}
