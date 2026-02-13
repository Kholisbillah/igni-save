import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../notification_controller.dart';
import '../../../services/local_storage_service.dart';
import '../../profile/providers/user_profile_provider.dart';

class SettingsState {
  final String preferredCurrency;
  final String preferredLanguage;
  final bool dailyReminderEnabled;

  const SettingsState({
    required this.preferredCurrency,
    required this.preferredLanguage,
    required this.dailyReminderEnabled,
  });

  SettingsState copyWith({
    String? preferredCurrency,
    String? preferredLanguage,
    bool? dailyReminderEnabled,
  }) {
    return SettingsState(
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref _ref;

  SettingsNotifier(this._ref)
    : super(
        SettingsState(
          preferredCurrency: LocalStorageService.preferredCurrency,
          preferredLanguage: LocalStorageService.preferredLanguage,
          dailyReminderEnabled: LocalStorageService.dailyReminderEnabled,
        ),
      );

  Future<void> setPreferredCurrency(String currency) async {
    await LocalStorageService.setPreferredCurrency(currency);
    state = state.copyWith(preferredCurrency: currency);
  }

  Future<void> setPreferredLanguage(String language) async {
    await LocalStorageService.setPreferredLanguage(language);
    state = state.copyWith(preferredLanguage: language);
  }

  Future<void> setDailyReminderEnabled(bool value) async {
    if (value) {
      final granted = await NotificationController.requestPermission();
      if (!granted) {
        // If permission is denied, we don't enable the toggle
        return;
      }
    }

    await LocalStorageService.setDailyReminderEnabled(value);
    state = state.copyWith(dailyReminderEnabled: value);

    // Sync with UserProfile if logged in
    try {
      final notifier = _ref.read(userProfileNotifierProvider.notifier);
      await notifier.updateProfile(notificationsEnabled: value);
    } catch (_) {
      // User might not be logged in or profile not loaded
    }

    // Note: Mission-specific scheduling will be handled by NotificationController
    // when we integrate it with the mission system
    debugPrint('SettingsNotifier: Daily reminder set to $value');
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier(ref);
  },
);
