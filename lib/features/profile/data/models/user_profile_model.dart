import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile model matching Firestore structure
class UserProfile {
  final String uid;
  final String username;
  final String email;
  final String? photoUrl;
  final String? bio;
  final int level;
  final int currentXp; // Changed from xp
  final double totalSavings;
  final int currentStreak;
  final int maxStreak; // Changed from bestStreak
  final DateTime? lastDepositDate; // Changed from lastSavingDate
  final int streakShields; // Changed from shieldCount
  final DateTime? lastShieldUsedDate;
  final bool isPrivate;
  final String preferredCurrency;
  final String preferredLanguage;
  final String savingFrequency;
  final int gracePeriodHours;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.uid,
    required this.username,
    required this.email,
    this.photoUrl,
    this.bio,
    this.level = 1,
    this.currentXp = 0,
    this.totalSavings = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.lastDepositDate,
    this.streakShields = 0,
    this.lastShieldUsedDate,
    this.isPrivate = false,
    this.preferredCurrency = 'IDR',
    this.preferredLanguage = 'id',
    this.savingFrequency = 'daily',
    this.gracePeriodHours = 3,
    this.notificationsEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photo_url'],
      bio: data['bio'],
      level: data['level'] ?? 1,
      currentXp: data['current_xp'] ?? 0, // Changed key
      totalSavings: (data['total_savings'] ?? 0).toDouble(),
      currentStreak: data['current_streak'] ?? 0,
      maxStreak: data['max_streak'] ?? 0, // Changed key
      lastDepositDate:
          data['last_deposit_date'] !=
              null // Changed key
          ? (data['last_deposit_date'] as Timestamp).toDate()
          : null,
      streakShields: data['streak_shields'] ?? 0, // Changed key
      lastShieldUsedDate: data['last_shield_used_date'] != null
          ? (data['last_shield_used_date'] as Timestamp).toDate()
          : null,
      isPrivate: data['is_private'] ?? false,
      preferredCurrency: data['preferred_currency'] ?? 'IDR',
      preferredLanguage: data['preferred_language'] ?? 'id',
      savingFrequency: data['saving_frequency'] ?? 'daily',
      gracePeriodHours: data['grace_period_hours'] ?? 3,
      notificationsEnabled: data['notifications_enabled'] ?? true,
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'photo_url': photoUrl,
      'bio': bio,
      'level': level,
      'current_xp': currentXp, // Changed key
      'total_savings': totalSavings,
      'current_streak': currentStreak,
      'max_streak': maxStreak, // Changed key
      'last_deposit_date':
          lastDepositDate !=
              null // Changed key
          ? Timestamp.fromDate(lastDepositDate!)
          : null,
      'streak_shields': streakShields, // Changed key
      'last_shield_used_date': lastShieldUsedDate != null
          ? Timestamp.fromDate(lastShieldUsedDate!)
          : null,
      'is_private': isPrivate,
      'preferred_currency': preferredCurrency,
      'preferred_language': preferredLanguage,
      'saving_frequency': savingFrequency,
      'grace_period_hours': gracePeriodHours,
      'notifications_enabled': notificationsEnabled,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create new user profile for signup
  factory UserProfile.newUser({
    required String uid,
    required String email,
    String? username,
    String? photoUrl,
  }) {
    final now = DateTime.now();
    return UserProfile(
      uid: uid,
      username: username ?? email.split('@').first,
      email: email,
      photoUrl: photoUrl,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a masked version of the profile for public view
  UserProfile masked() {
    return UserProfile(
      uid: uid,
      username: username,
      email: '', // Hide email
      photoUrl: photoUrl, // Keep photo
      bio: 'This account is private.',
      level: 0, // Hide level
      currentXp: 0, // Hide XP
      totalSavings: 0, // Hide savings
      currentStreak: 0, // Hide streak
      maxStreak: 0, // Hide max streak
      lastDepositDate: null,
      streakShields: 0,
      lastShieldUsedDate: null,
      isPrivate: true,
      preferredCurrency: preferredCurrency,
      preferredLanguage: preferredLanguage,
      savingFrequency: savingFrequency,
      gracePeriodHours: gracePeriodHours,
      notificationsEnabled: false, // Force off for masked
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Copy with modifications
  UserProfile copyWith({
    String? username,
    String? photoUrl,
    String? bio,
    int? level,
    int? currentXp,
    double? totalSavings,
    int? currentStreak,
    int? maxStreak,
    DateTime? lastDepositDate,
    int? streakShields,
    DateTime? lastShieldUsedDate,
    bool? isPrivate,
    String? preferredCurrency,
    String? preferredLanguage,
    String? savingFrequency,
    int? gracePeriodHours,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      uid: uid,
      username: username ?? this.username,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      totalSavings: totalSavings ?? this.totalSavings,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      lastDepositDate: lastDepositDate ?? this.lastDepositDate,
      streakShields: streakShields ?? this.streakShields,
      lastShieldUsedDate: lastShieldUsedDate ?? this.lastShieldUsedDate,
      isPrivate: isPrivate ?? this.isPrivate,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      savingFrequency: savingFrequency ?? this.savingFrequency,
      gracePeriodHours: gracePeriodHours ?? this.gracePeriodHours,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
