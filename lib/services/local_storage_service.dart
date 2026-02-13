import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_strings.dart';

/// Local storage service using SharedPreferences
class LocalStorageService {
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized');
    }
    return _prefs!;
  }

  // Onboarding
  static bool get isOnboardingComplete {
    return prefs.getBool(AppStrings.keyOnboardingComplete) ?? false;
  }

  static Future<void> setOnboardingComplete(bool value) async {
    await prefs.setBool(AppStrings.keyOnboardingComplete, value);
  }

  // Preferred Currency
  static String get preferredCurrency {
    return prefs.getString(AppStrings.keyPreferredCurrency) ??
        AppStrings.currencyIDR;
  }

  static Future<void> setPreferredCurrency(String currency) async {
    await prefs.setString(AppStrings.keyPreferredCurrency, currency);
  }

  // Preferred Language
  static String get preferredLanguage {
    return prefs.getString(AppStrings.keyPreferredLanguage) ??
        AppStrings.langIndonesian;
  }

  static Future<void> setPreferredLanguage(String language) async {
    await prefs.setString(AppStrings.keyPreferredLanguage, language);
  }

  // Last Sync Time
  static DateTime? get lastSyncTime {
    final timestamp = prefs.getInt(AppStrings.keyLastSyncTime);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  static Future<void> setLastSyncTime(DateTime time) async {
    await prefs.setInt(AppStrings.keyLastSyncTime, time.millisecondsSinceEpoch);
  }

  // Daily Reminder
  static bool get dailyReminderEnabled {
    return prefs.getBool(AppStrings.keyDailyReminderEnabled) ?? true;
  }

  static Future<void> setDailyReminderEnabled(bool value) async {
    await prefs.setBool(AppStrings.keyDailyReminderEnabled, value);
  }

  // Clear all data (for logout)
  static Future<void> clearAll() async {
    await prefs.clear();
  }
}
