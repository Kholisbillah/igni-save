import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

/// NotificationController - Single source of truth for all notification logic.
///
/// Architecture follows awesome_notifications best practices:
/// - All listener methods MUST be static or top-level
/// - Initialization MUST happen before runApp()
/// - Listeners activated in widget initState()
class NotificationController {
  /// Channel key for basic notifications
  static const String channelKey = 'basic_channel';

  /// Unique notification ID counter (avoids hardcoded IDs)
  static int _notificationIdCounter = 0;

  /// Generate unique notification ID
  static int _generateUniqueId() {
    _notificationIdCounter++;
    return DateTime.now().millisecondsSinceEpoch.remainder(100000) +
        _notificationIdCounter;
  }

  /// Initialize local notifications - MUST be called BEFORE runApp()
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
      // Use null to use Flutter's default app icon
      null,
      [
        NotificationChannel(
          channelKey: channelKey,
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for basic notifications',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: true, // Set to false in production
    );

    debugPrint('NotificationController: Initialized');
  }

  /// Start listening for notification events - call in initState()
  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );

    debugPrint('NotificationController: Listeners started');

    // Reset badge when app opens
    await resetBadge();
  }

  /// Called when user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint(
      'NotificationController: Action received - ${receivedAction.id}',
    );

    // Reset badge when notification is clicked
    await resetBadge();

    // Handle navigation or other actions here based on payload
    // Example: Navigate to specific screen based on receivedAction.payload
  }

  /// Called when notification is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint(
      'NotificationController: Notification created - ${receivedNotification.id}',
    );
  }

  /// Called when notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint(
      'NotificationController: Notification displayed - ${receivedNotification.id}',
    );

    // Increment badge when notification is shown
    await incrementBadge();
  }

  /// Called when notification is dismissed
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint(
      'NotificationController: Notification dismissed - ${receivedAction.id}',
    );

    // Decrement badge when notification is dismissed
    await decrementBadge();
  }

  /// Create a local notification with permission check
  static Future<void> createLocalNotification({
    required String title,
    required String body,
    int? id,
    Map<String, String>? payload,
  }) async {
    // Check if permission is granted
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (!isAllowed) {
      debugPrint('NotificationController: Requesting permission...');
      isAllowed = await AwesomeNotifications()
          .requestPermissionToSendNotifications();
    }

    if (!isAllowed) {
      debugPrint('NotificationController: Permission denied');
      return;
    }

    final notificationId = id ?? _generateUniqueId();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: channelKey,
        title: title,
        body: body,
        payload: payload,
        notificationLayout: NotificationLayout.Default,
      ),
    );

    debugPrint(
      'NotificationController: Notification created with ID $notificationId',
    );
  }

  /// Schedule a notification for a specific time
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    int? id,
    Map<String, String>? payload,
    bool repeats = false,
  }) async {
    // Check if permission is granted
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (!isAllowed) {
      isAllowed = await AwesomeNotifications()
          .requestPermissionToSendNotifications();
    }

    if (!isAllowed) {
      debugPrint('NotificationController: Permission denied');
      return;
    }

    final notificationId = id ?? _generateUniqueId();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: channelKey,
        title: title,
        body: body,
        payload: payload,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(
        date: scheduledDate,
        allowWhileIdle: true,
        repeats: repeats,
        preciseAlarm: true,
      ),
    );

    debugPrint(
      'NotificationController: Scheduled notification $notificationId for $scheduledDate',
    );
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
    debugPrint('NotificationController: Cancelled notification $id');
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
    debugPrint('NotificationController: Cancelled all notifications');
  }

  /// Check if notifications are allowed
  static Future<bool> isNotificationAllowed() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  /// Request notification permission
  static Future<bool> requestPermission() async {
    return await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // ========== Badge Management ==========

  static int _badgeCount = 0;

  /// Increment badge count
  static Future<void> incrementBadge() async {
    _badgeCount++;
    await AwesomeNotifications().setGlobalBadgeCounter(_badgeCount);
    debugPrint('NotificationController: Badge incremented to $_badgeCount');
  }

  /// Decrement badge count
  static Future<void> decrementBadge() async {
    if (_badgeCount > 0) {
      _badgeCount--;
      await AwesomeNotifications().setGlobalBadgeCounter(_badgeCount);
      debugPrint('NotificationController: Badge decremented to $_badgeCount');
    }
  }

  /// Reset badge to zero
  static Future<void> resetBadge() async {
    _badgeCount = 0;
    await AwesomeNotifications().resetGlobalBadge();
    debugPrint('NotificationController: Badge reset');
  }

  // ========== Shield Notifications ==========

  /// Notification ID for shield earned
  static const int shieldEarnedNotificationId = 9001;

  /// Notification ID for shield used
  static const int shieldUsedNotificationId = 9002;

  /// Show notification when user earns a new shield
  static Future<void> showShieldEarnedNotification() async {
    await createLocalNotification(
      id: shieldEarnedNotificationId,
      title: '🛡️ Shield Earned!',
      body:
          'Great job! You earned a Streak Shield for 14 days of consistency. '
          'It will protect your streak if you miss a day.',
      payload: {'type': 'shield_earned'},
    );
    debugPrint('NotificationController: Shield earned notification shown');
  }

  /// Show notification when shield is automatically used
  static Future<void> showShieldUsedNotification({int savedStreak = 0}) async {
    await createLocalNotification(
      id: shieldUsedNotificationId,
      title: '🛡️ Shield Activated!',
      body:
          'Your Streak Shield protected your ${savedStreak > 0 ? "$savedStreak day" : ""} streak! '
          'Save today to keep it going.',
      payload: {'type': 'shield_used'},
    );
    debugPrint('NotificationController: Shield used notification shown');
  }

  // ========== Mission Reminder Scheduling ==========

  /// Generate a unique notification ID for a mission + time combination
  /// Using hash of mission ID and time to ensure consistent IDs for the same mission
  static int _generateMissionNotificationId(
    String missionId,
    int timeIndex,
    int dayIndex,
  ) {
    // Create a unique but reproducible ID based on mission ID, time, and day
    final hash = missionId.hashCode.abs();
    return (hash % 10000) * 100 + timeIndex * 10 + dayIndex;
  }

  /// Schedule all reminders for a mission based on its notification settings
  static Future<void> scheduleMissionReminders({
    required String missionId,
    required String missionTitle,
    required bool notificationEnabled,
    required List<String> notificationTimes,
    required List<int> notificationDays,
  }) async {
    // First, cancel any existing notifications for this mission
    await cancelMissionReminders(
      missionId,
      notificationTimes.length,
      notificationDays.length,
    );

    // If notifications are disabled, we're done
    if (!notificationEnabled) {
      debugPrint(
        'NotificationController: Notifications disabled for mission $missionId',
      );
      return;
    }

    // Check permission
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications()
          .requestPermissionToSendNotifications();
    }
    if (!isAllowed) {
      debugPrint(
        'NotificationController: Permission denied, cannot schedule mission reminders',
      );
      return;
    }

    // If no specific days selected, schedule for every day
    final daysToSchedule = notificationDays.isEmpty
        ? [1, 2, 3, 4, 5, 6, 7] // Monday to Sunday
        : notificationDays
              .map((d) => d == 0 ? 7 : d)
              .toList(); // Convert 0 (Sun) to 7

    int scheduledCount = 0;

    for (int timeIndex = 0; timeIndex < notificationTimes.length; timeIndex++) {
      final timeStr = notificationTimes[timeIndex];
      final parts = timeStr.split(':');
      if (parts.length != 2) continue;

      final hour = int.tryParse(parts[0]) ?? 12;
      final minute = int.tryParse(parts[1]) ?? 0;

      for (int dayIndex = 0; dayIndex < daysToSchedule.length; dayIndex++) {
        final weekday = daysToSchedule[dayIndex];
        final notificationId = _generateMissionNotificationId(
          missionId,
          timeIndex,
          dayIndex,
        );

        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationId,
            channelKey: channelKey,
            title: '💰 Waktunya Nabung!',
            body: 'Jangan lupa isi tabungan "$missionTitle" hari ini!',
            payload: {'missionId': missionId, 'type': 'mission_reminder'},
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar(
            weekday: weekday,
            hour: hour,
            minute: minute,
            second: 0,
            millisecond: 0,
            allowWhileIdle: true,
            repeats: true,
            preciseAlarm: true,
          ),
        );

        scheduledCount++;
        debugPrint(
          'NotificationController: Scheduled reminder $notificationId for "$missionTitle" '
          'at $hour:$minute on weekday $weekday',
        );
      }
    }

    debugPrint(
      'NotificationController: Scheduled $scheduledCount reminders for mission "$missionTitle"',
    );
  }

  /// Cancel all reminders for a specific mission
  static Future<void> cancelMissionReminders(
    String missionId,
    int timeCount,
    int dayCount,
  ) async {
    // Cancel all possible notification IDs for this mission
    final maxTimes = timeCount > 0 ? timeCount : 5; // Max 5 times
    final maxDays = dayCount > 0 ? dayCount : 7; // Max 7 days

    for (int timeIndex = 0; timeIndex < maxTimes; timeIndex++) {
      for (int dayIndex = 0; dayIndex < maxDays; dayIndex++) {
        final notificationId = _generateMissionNotificationId(
          missionId,
          timeIndex,
          dayIndex,
        );
        await AwesomeNotifications().cancel(notificationId);
      }
    }

    debugPrint(
      'NotificationController: Cancelled all reminders for mission $missionId',
    );
  }

  /// Cancel all reminders for a mission (simplified version)
  static Future<void> cancelAllMissionReminders(String missionId) async {
    // Cancel with max possible counts
    await cancelMissionReminders(missionId, 5, 7);
  }
}
