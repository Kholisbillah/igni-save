import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for StreakCheckService
final streakCheckServiceProvider = Provider<StreakCheckService>((ref) {
  return StreakCheckService();
});

/// Service for managing streak-related checks.
/// Communicates with native Android to set/check "saved today" flag.
///
/// This is used by the 3-hour reminder system to determine
/// whether to show reminder notifications.
class StreakCheckService {
  static const _channel = MethodChannel('com.firstapp.ignisave/streak');

  /// Mark that user has saved/deposited today.
  /// This flag is used by the reminder system to skip notifications
  /// if user has already saved today.
  Future<bool> markSavedToday() async {
    try {
      final result = await _channel.invokeMethod<bool>('markSavedToday');
      return result ?? false;
    } on PlatformException {
      // Method not implemented yet - fallback to success
      // This allows the app to work while native implementation is added
      return true;
    }
  }

  /// Check if user has already saved today.
  Future<bool> hasSavedToday() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasSavedToday');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Clear the saved today flag (called at midnight or for testing).
  Future<bool> clearSavedToday() async {
    try {
      final result = await _channel.invokeMethod<bool>('clearSavedToday');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
