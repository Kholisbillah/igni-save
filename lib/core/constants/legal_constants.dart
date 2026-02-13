class LegalConstants {
  LegalConstants._();

  static const String termsOfService = '''
**1. Introduction**
Welcome to Igni Save ("we," "our," or "us"). By accessing or using our application, you agree to be bound by these Terms of Service. Igni Save is a gamified savings platform designed to help you achieve your financial goals through discipline and community competition.

**2. User Accounts & Identity**
- **Account Creation:** You must provide accurate information when creating an account via Email or Google Sign-In.
- **Profile:** You are responsible for maintaining the confidentiality of your account. You may customize your profile with a photo, username, and bio.
- **Levels:** Your "Saver Level" is determined by your activity and consistency. We reserve the right to adjust level requirements.

**3. Missions & Savings**
- **Active Goals:** You define your own "Missions" (savings targets). These are personal goals and do not represent a deposit into a bank account held by us.
- **Proof of Saving:** To verify progress, you must upload physical evidence (photos of cash or transfer receipts). You warrant that all proofs submitted are authentic and represent actual savings set aside.

**4. Gamification & Streaks**
- **Streaks:** A "Streak" is maintained by verifying a saving action every 24 hours. Missing a check-in may result in the loss of your streak.
- **XP & Rewards:** Experience Points (XP) and badges are virtual rewards with no monetary value.

**5. Leaderboards & Competition**
- **Public Ranking:** By default, your profile appears on public leaderboards based on Total Savings and Streak.
- **Privacy Mode:** You may opt-in to "Privacy Mode" to hide your specific savings amounts while still participating in rankings based on relative performance or streak.

**6. User Conduct**
You agree not to:
- Submit fake or misleading "Proof of Saving" images.
- Harass other users in the community.
- Attempt to manipulate the XP or Streak system through automated means.

**7. Disclaimer**
Igni Save is a productivity and habit-building tool, not a financial institution. We do not hold your funds. You are solely responsible for the safety and management of your actual money.
''';

  static const String privacyPolicy = '''
**1. Data Collection**
We collect the following information to provide our services:
- **Identity Data:** Username, email address, and profile picture (via Firebase Auth).
- **Financial Goal Data:** Mission titles, target amounts, and deadlines (stored in Cloud Firestore).
- **Activity Data:** Savings history, streak records, and XP progress.
- **Media:** Photos uploaded as "Proof of Saving" or profile pictures (stored in Cloudinary).

**2. How We Use Your Data**
- **Gamification:** To calculate your level, streak, and leaderboard position.
- **Verification:** To verify your savings progress through the "Proof of Saving" feature.
- **Notifications:** To send daily reminders (via FCM and local notifications).

**3. Data Sharing & Visibility**
- **Leaderboards:** Your username, profile photo, and streak count are visible to other users on the leaderboard.
- **Financial Privacy:** Your specific savings amounts are visible to others unless you enable "Privacy Mode" in Settings.
- **Third-Party Services:** We use Firebase (Google) for backend services and Cloudinary for image hosting. These providers process data in accordance with their privacy policies.

**4. Data Security**
We implement industry-standard security measures to protect your data. However, no method of transmission over the internet is 100% secure.

**5. Your Rights**
You may request the deletion of your account and associated data at any time through the Settings menu. Upon deletion, your profile will be removed from all leaderboards.

**6. Changes to This Policy**
We may update this Privacy Policy from time to time. We will notify you of any significant changes through the app.
''';
}
