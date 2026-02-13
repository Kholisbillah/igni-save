import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'IgniSave'**
  String get appName;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK'**
  String get welcomeBack;

  /// No description provided for @ownYourMoney.
  ///
  /// In en, this message translates to:
  /// **'Own Your Money,'**
  String get ownYourMoney;

  /// No description provided for @shapeYourLife.
  ///
  /// In en, this message translates to:
  /// **'Shape Your Life.'**
  String get shapeYourLife;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'From saving smart to spending wise, your financial goals begin to rise.'**
  String get tagline;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'EMAIL ADDRESS'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get passwordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PASSWORD'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get confirmPasswordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @signUpBtn.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpBtn;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'OR CONTINUE WITH'**
  String get orContinueWith;

  /// No description provided for @orJoinWith.
  ///
  /// In en, this message translates to:
  /// **'OR JOIN WITH'**
  String get orJoinWith;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @termsAgreement.
  ///
  /// In en, this message translates to:
  /// **'By tapping Continue, you agree to our Terms and Privacy Policy.'**
  String get termsAgreement;

  /// No description provided for @signUpAgreement.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to IgniSave\'s Terms and Privacy Policy.'**
  String get signUpAgreement;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Save Your Money,'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Shape Your Life.'**
  String get onboarding1Subtitle;

  /// No description provided for @onboarding1Desc.
  ///
  /// In en, this message translates to:
  /// **'Achieve your financial goals with a gamified experience that makes saving effortless and fun.'**
  String get onboarding1Desc;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Achieve Goals with'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Gamified Habits.'**
  String get onboarding2Subtitle;

  /// No description provided for @onboarding2Desc.
  ///
  /// In en, this message translates to:
  /// **'Level up your finances. Complete daily challenges and build streaks to reach your targets faster.'**
  String get onboarding2Desc;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Join the'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Community.'**
  String get onboarding3Subtitle;

  /// No description provided for @onboarding3Desc.
  ///
  /// In en, this message translates to:
  /// **'Connect with friends and family to motivate each other and celebrate your shared financial victories.'**
  String get onboarding3Desc;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @leagues.
  ///
  /// In en, this message translates to:
  /// **'Leagues'**
  String get leagues;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @masterSaver.
  ///
  /// In en, this message translates to:
  /// **'MASTER SAVER'**
  String get masterSaver;

  /// No description provided for @wealthWizard.
  ///
  /// In en, this message translates to:
  /// **'WEALTH WIZARD'**
  String get wealthWizard;

  /// No description provided for @totalLoot.
  ///
  /// In en, this message translates to:
  /// **'TOTAL LOOT'**
  String get totalLoot;

  /// No description provided for @dailyStreak.
  ///
  /// In en, this message translates to:
  /// **'DAILY STREAK'**
  String get dailyStreak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @keepFireBurning.
  ///
  /// In en, this message translates to:
  /// **'Keep the fire burning!'**
  String get keepFireBurning;

  /// No description provided for @xpBonus.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String xpBonus(int xp);

  /// No description provided for @activeGoals.
  ///
  /// In en, this message translates to:
  /// **'Active Goals'**
  String get activeGoals;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL'**
  String get viewAll;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} days left'**
  String daysLeft(int count);

  /// No description provided for @noLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// No description provided for @newTarget.
  ///
  /// In en, this message translates to:
  /// **'NEW TARGET'**
  String get newTarget;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @initializeNewMission.
  ///
  /// In en, this message translates to:
  /// **'Initialize'**
  String get initializeNewMission;

  /// No description provided for @newMission.
  ///
  /// In en, this message translates to:
  /// **'New Mission'**
  String get newMission;

  /// No description provided for @missionDesc.
  ///
  /// In en, this message translates to:
  /// **'Define your objective and set the parameters.'**
  String get missionDesc;

  /// No description provided for @missionName.
  ///
  /// In en, this message translates to:
  /// **'MISSION NAME'**
  String get missionName;

  /// No description provided for @missionNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. MacBook Pro M3'**
  String get missionNameHint;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'TARGET AMOUNT'**
  String get targetAmount;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'DEADLINE'**
  String get deadline;

  /// No description provided for @thirtyDays.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get thirtyDays;

  /// No description provided for @threeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get threeMonths;

  /// No description provided for @sixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get sixMonths;

  /// No description provided for @missionBriefing.
  ///
  /// In en, this message translates to:
  /// **'MISSION BRIEFING'**
  String get missionBriefing;

  /// No description provided for @createTarget.
  ///
  /// In en, this message translates to:
  /// **'Create Target'**
  String get createTarget;

  /// No description provided for @proofOfSaving.
  ///
  /// In en, this message translates to:
  /// **'PROOF OF SAVING'**
  String get proofOfSaving;

  /// No description provided for @uploadProof.
  ///
  /// In en, this message translates to:
  /// **'Upload Proof'**
  String get uploadProof;

  /// No description provided for @uploadProofDesc.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your savings or upload a digital receipt.'**
  String get uploadProofDesc;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'REQUIRED'**
  String get required;

  /// No description provided for @amountSaved.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT SAVED'**
  String get amountSaved;

  /// No description provided for @allocateTo.
  ///
  /// In en, this message translates to:
  /// **'ALLOCATE TO'**
  String get allocateTo;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'TARGET'**
  String get target;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'SAFETY'**
  String get safety;

  /// No description provided for @lifestyle.
  ///
  /// In en, this message translates to:
  /// **'LIFESTYLE'**
  String get lifestyle;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @vacation.
  ///
  /// In en, this message translates to:
  /// **'Vacation'**
  String get vacation;

  /// No description provided for @streakBonus.
  ///
  /// In en, this message translates to:
  /// **'Streak Bonus'**
  String get streakBonus;

  /// No description provided for @extendsStreak.
  ///
  /// In en, this message translates to:
  /// **'Extends your streak to {days} Days'**
  String extendsStreak(int days);

  /// No description provided for @confirmAndSave.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Save'**
  String get confirmAndSave;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @totalSavings.
  ///
  /// In en, this message translates to:
  /// **'Total Savings'**
  String get totalSavings;

  /// No description provided for @highestStreak.
  ///
  /// In en, this message translates to:
  /// **'Highest Streak'**
  String get highestStreak;

  /// No description provided for @privacyMode.
  ///
  /// In en, this message translates to:
  /// **'Privacy Mode'**
  String get privacyMode;

  /// No description provided for @hideAmounts.
  ///
  /// In en, this message translates to:
  /// **'Hide amounts'**
  String get hideAmounts;

  /// No description provided for @daysLeftInLeague.
  ///
  /// In en, this message translates to:
  /// **'{count} Days Left'**
  String daysLeftInLeague(int count);

  /// No description provided for @silverLeague.
  ///
  /// In en, this message translates to:
  /// **'Silver League'**
  String get silverLeague;

  /// No description provided for @goldLeague.
  ///
  /// In en, this message translates to:
  /// **'Gold League'**
  String get goldLeague;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'RANK'**
  String get rank;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @ptsToRank.
  ///
  /// In en, this message translates to:
  /// **'{pts} pts to Rank {rank}'**
  String ptsToRank(int pts, int rank);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @savingsReminders.
  ///
  /// In en, this message translates to:
  /// **'Savings Reminders'**
  String get savingsReminders;

  /// No description provided for @achievementAlerts.
  ///
  /// In en, this message translates to:
  /// **'Achievement Alerts'**
  String get achievementAlerts;

  /// No description provided for @leagueUpdates.
  ///
  /// In en, this message translates to:
  /// **'League Updates'**
  String get leagueUpdates;

  /// No description provided for @privacyAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacyAndSecurity;

  /// No description provided for @twoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuth;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String level(int level);

  /// No description provided for @xpToNextLevel.
  ///
  /// In en, this message translates to:
  /// **'\${xp} to Lvl {level}'**
  String xpToNextLevel(int xp, int level);

  /// No description provided for @viewLevelRewards.
  ///
  /// In en, this message translates to:
  /// **'View Level Rewards'**
  String get viewLevelRewards;

  /// No description provided for @totalSaved.
  ///
  /// In en, this message translates to:
  /// **'TOTAL SAVED'**
  String get totalSaved;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get streak;

  /// No description provided for @onFire.
  ///
  /// In en, this message translates to:
  /// **'On fire!'**
  String get onFire;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'BEST STREAK'**
  String get bestStreak;

  /// No description provided for @league.
  ///
  /// In en, this message translates to:
  /// **'LEAGUE'**
  String get league;

  /// No description provided for @trophyCase.
  ///
  /// In en, this message translates to:
  /// **'Trophy Case'**
  String get trophyCase;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'SEE ALL'**
  String get seeAll;

  /// No description provided for @consistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get consistency;

  /// No description provided for @pastThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'Past 3 Months'**
  String get pastThreeMonths;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @shareStats.
  ///
  /// In en, this message translates to:
  /// **'Share Stats'**
  String get shareStats;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @idr.
  ///
  /// In en, this message translates to:
  /// **'IDR'**
  String get idr;

  /// No description provided for @usd.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get usd;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get indonesian;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
