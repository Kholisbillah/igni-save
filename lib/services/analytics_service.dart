import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App Events constants for consistent tracking
class AppEvents {
  static const String goalViewed = 'goal_viewed';
  static const String addSavingClicked = 'add_saving_clicked';
  static const String savingAdded = 'saving_added';
  static const String goalDeleted = 'goal_deleted';
}

/// Service to handle app analytics (fire-and-forget)
class AnalyticsService {
  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    // For now, we log to console in debug mode.
    // This can be easily connected to Firebase Analytics or Mixpanel later.
    if (kDebugMode) {
      print('[Analytics] Event: $name, Params: $parameters');
    }
  }

  void logGoalViewed(String goalId, String userId) {
    logEvent(
      AppEvents.goalViewed,
      parameters: {'goal_id': goalId, 'user_id': userId},
    );
  }

  void logAddSavingClicked(String goalId, String userId) {
    logEvent(
      AppEvents.addSavingClicked,
      parameters: {'goal_id': goalId, 'user_id': userId},
    );
  }

  void logSavingAdded(String goalId, String userId, double amount) {
    logEvent(
      AppEvents.savingAdded,
      parameters: {'goal_id': goalId, 'user_id': userId, 'amount': amount},
    );
  }

  void logGoalDeleted(String goalId, String userId, double finalAmount) {
    logEvent(
      AppEvents.goalDeleted,
      parameters: {'goal_id': goalId, 'user_id': userId, 'amount': finalAmount},
    );
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
