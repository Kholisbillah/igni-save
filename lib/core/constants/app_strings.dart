/// App-wide string constants (non-localized)
class AppStrings {
  AppStrings._();

  // App Info
  static const String appName = 'IgniSave';
  static const String appTagline = 'Nyalakan Disiplin, Capai Impian';

  // Routes
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeHome = '/';
  static const String routeDashboard = '/dashboard';
  static const String routeGoals = '/goals';
  static const String routeLeagues = '/leagues';
  static const String routeProfile = '/profile';
  static const String routeEditProfile = '/profile/edit';
  static const String routeSettings = '/settings';
  static const String routeNotificationSettings = '/settings/notifications';
  static const String routeCreateMission = '/create-mission';
  static const String routeMissionDetail = '/mission/:id';
  static const String routeProofOfSaving = '/proof-of-saving';
  static const String routeTargetCalculator = '/goals/calculator';
  static const String routeOtherProfile = '/profile/:id';
  static const String routeAnalytics = '/analytics';

  // Storage Keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyPreferredCurrency = 'preferred_currency';
  static const String keyPreferredLanguage = 'preferred_language';
  static const String keyLastSyncTime = 'last_sync_time';
  static const String keyDailyReminderEnabled = 'daily_reminder_enabled';

  // Cloudinary
  static const String cloudinaryCloudName = 'dzl0dstef';
  static const String cloudinaryApiKey = '761781457294933';
  static const String cloudinaryProfileFolder = 'ignisave/profiles';
  static const String cloudinaryProofFolder = 'ignisave/proofs';

  // Firestore Collections
  static const String collectionUsers = 'users';
  static const String collectionMissions = 'missions';
  static const String collectionSavingsHistory = 'savings_history';

  // Currency
  static const String currencyIDR = 'IDR';
  static const String currencyUSD = 'USD';

  // Language
  static const String langEnglish = 'en';
  static const String langIndonesian = 'id';
}
