import 'package:cloud_firestore/cloud_firestore.dart';

enum MissionType { target, safety, lifestyle }

enum MissionStatus { active, completed, failed, deleted }

enum FillingPlan { daily, weekly, monthly }

class MissionModel {
  // Color palette for goal cards
  static const List<String> goalColors = [
    '#E67E22', // Orange
    '#F1C40F', // Yellow
    '#E74C3C', // Red
    '#2ECC71', // Green
    '#1ABC9C', // Turquoise
    '#9B59B6', // Purple (default)
    '#34495E', // Dark Gray
  ];

  static const String defaultColorTheme = '#9B59B6'; // Purple

  final String id;
  final String ownerId;
  final String title;
  final String description;
  final double targetAmount;
  final double targetAmountUsd; // Normalized to USD for comparison
  final double currentAmount;
  final DateTime deadline;
  final MissionStatus status;
  final MissionType type;
  final String currency;

  // Enhanced goal creation fields
  final String? imageUrl;
  final String? imagePublicId; // Cloudinary public_id for deletion
  final FillingPlan fillingPlan;
  final double fillingNominal;
  final bool notificationEnabled;
  final List<String> notificationTimes; // Format: ["08:00", "12:00"]
  final List<int> notificationDays; // 0=Sunday, 1=Monday, ..., 6=Saturday

  // Color theme for goal card
  final String colorTheme;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Archive functionality
  final bool isArchived;
  final DateTime? archivedAt;

  // Completion and deletion timestamps
  final DateTime? completedAt;
  final DateTime? deletedAt;

  const MissionModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.targetAmount,
    this.targetAmountUsd = 0,
    this.currentAmount = 0,
    required this.deadline,
    this.status = MissionStatus.active,
    this.type = MissionType.target,
    this.currency = 'IDR',
    this.imageUrl,
    this.imagePublicId,
    this.fillingPlan = FillingPlan.daily,
    this.fillingNominal = 0,
    this.notificationEnabled = false,
    this.notificationTimes = const ['12:00'],
    this.notificationDays = const [],
    this.colorTheme = defaultColorTheme,
    this.createdAt,
    this.updatedAt,
    this.isArchived = false,
    this.archivedAt,
    this.completedAt,
    this.deletedAt,
  });

  factory MissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MissionModel(
      id: doc.id,
      ownerId: data['owner_id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      targetAmount: (data['target_amount'] ?? 0).toDouble(),
      targetAmountUsd: (data['target_amount_usd'] ?? 0).toDouble(),
      currentAmount: (data['current_amount'] ?? 0).toDouble(),
      deadline: (data['deadline'] as Timestamp).toDate(),
      status: MissionStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'active'),
        orElse: () => MissionStatus.active,
      ),
      type: MissionType.values.firstWhere(
        (e) => e.name == (data['type'] ?? 'target'),
        orElse: () => MissionType.target,
      ),
      currency: data['currency'] ?? 'IDR',
      imageUrl: data['image_url'],
      imagePublicId: data['image_public_id'],
      fillingPlan: FillingPlan.values.firstWhere(
        (e) => e.name == (data['filling_plan'] ?? 'daily'),
        orElse: () => FillingPlan.daily,
      ),
      fillingNominal: (data['filling_nominal'] ?? 0).toDouble(),
      notificationEnabled: data['notification_enabled'] ?? false,
      // Handle migration: support both old 'notification_time' and new 'notification_times'
      notificationTimes: data['notification_times'] != null
          ? List<String>.from(data['notification_times'])
          : (data['notification_time'] != null
                ? [data['notification_time'] as String]
                : ['12:00']),
      notificationDays: List<int>.from(data['notification_days'] ?? []),
      colorTheme: data['color_theme'] ?? defaultColorTheme,
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : null,
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] as Timestamp).toDate()
          : null,
      isArchived: data['is_archived'] ?? false,
      archivedAt: data['archived_at'] != null
          ? (data['archived_at'] as Timestamp).toDate()
          : null,
      completedAt: data['completed_at'] != null
          ? (data['completed_at'] as Timestamp).toDate()
          : null,
      deletedAt: data['deleted_at'] != null
          ? (data['deleted_at'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'target_amount': targetAmount,
      'target_amount_usd': targetAmountUsd,
      'current_amount': currentAmount,
      'deadline': Timestamp.fromDate(deadline),
      'status': status.name,
      'type': type.name,
      'currency': currency,
      'image_url': imageUrl,
      'image_public_id': imagePublicId,
      'filling_plan': fillingPlan.name,
      'filling_nominal': fillingNominal,
      'notification_enabled': notificationEnabled,
      'notification_times': notificationTimes,
      'notification_days': notificationDays,
      'color_theme': colorTheme,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'is_archived': isArchived,
      'archived_at': archivedAt != null
          ? Timestamp.fromDate(archivedAt!)
          : null,
      'completed_at': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'deleted_at': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  MissionModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    double? targetAmount,
    double? targetAmountUsd,
    double? currentAmount,
    DateTime? deadline,
    MissionStatus? status,
    MissionType? type,
    String? currency,
    String? imageUrl,
    String? imagePublicId,
    FillingPlan? fillingPlan,
    double? fillingNominal,
    bool? notificationEnabled,
    List<String>? notificationTimes,
    List<int>? notificationDays,
    String? colorTheme,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    DateTime? archivedAt,
    DateTime? completedAt,
    DateTime? deletedAt,
  }) {
    return MissionModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      targetAmountUsd: targetAmountUsd ?? this.targetAmountUsd,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePublicId: imagePublicId ?? this.imagePublicId,
      fillingPlan: fillingPlan ?? this.fillingPlan,
      fillingNominal: fillingNominal ?? this.fillingNominal,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationTimes: notificationTimes ?? this.notificationTimes,
      notificationDays: notificationDays ?? this.notificationDays,
      colorTheme: colorTheme ?? this.colorTheme,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
      completedAt: completedAt ?? this.completedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // Getters for UI helpers
  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  int get progressPercent => (progress * 100).toInt();
  int get daysRemaining {
    final diff = deadline.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  bool get isCompleted => currentAmount >= targetAmount;

  /// Calculate filling nominal based on target, deadline and plan
  static double calculateFillingNominal({
    required double targetAmount,
    required DateTime deadline,
    required FillingPlan plan,
  }) {
    final now = DateTime.now();
    final daysUntilDeadline = deadline.difference(now).inDays;

    if (daysUntilDeadline <= 0) return targetAmount;

    switch (plan) {
      case FillingPlan.daily:
        return targetAmount / daysUntilDeadline;
      case FillingPlan.weekly:
        final weeks = (daysUntilDeadline / 7).ceil();
        return weeks > 0 ? targetAmount / weeks : targetAmount;
      case FillingPlan.monthly:
        final months = (daysUntilDeadline / 30).ceil();
        return months > 0 ? targetAmount / months : targetAmount;
    }
  }

  /// Calculate dynamic filling nominal based on remaining amount and time
  double get currentFillingNominal {
    final remainingAmount = targetAmount - currentAmount;
    if (remainingAmount <= 0) return 0;

    final now = DateTime.now();
    final daysUntilDeadline = deadline.difference(now).inDays;

    // If deadline passed or today, return remaining amount
    if (daysUntilDeadline <= 0) return remainingAmount;

    switch (fillingPlan) {
      case FillingPlan.daily:
        return remainingAmount / daysUntilDeadline;
      case FillingPlan.weekly:
        final weeks = (daysUntilDeadline / 7).ceil();
        return weeks > 0 ? remainingAmount / weeks : remainingAmount;
      case FillingPlan.monthly:
        final months = (daysUntilDeadline / 30).ceil();
        return months > 0 ? remainingAmount / months : remainingAmount;
    }
  }

  /// Get filling plan display text
  String get fillingPlanDisplayText {
    switch (fillingPlan) {
      case FillingPlan.daily:
        return 'Daily';
      case FillingPlan.weekly:
        return 'Weekly';
      case FillingPlan.monthly:
        return 'Monthly';
    }
  }
}
