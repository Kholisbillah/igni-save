import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/models/currency_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../missions/presentation/widgets/currency_picker_modal.dart';
import '../../../missions/providers/missions_provider.dart';
import '../../../profile/providers/user_profile_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final userProfileAsync = ref.watch(userProfileStreamProvider);

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppThemeColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppThemeColors.borderLight),
              boxShadow: AppThemeColors.cardShadow,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppThemeColors.textPrimary,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: Text('Settings', style: AppTextStyles.headlineSmall),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader('Account'),
            _buildSectionContainer(
              children: [
                userProfileAsync.when(
                  data: (profile) => _buildSwitchTile(
                    title: 'Private Account',
                    subtitle: 'Hide your profile and streak from others',
                    value: profile?.isPrivate ?? false,
                    onChanged: (value) async {
                      await ref
                          .read(userProfileNotifierProvider.notifier)
                          .updateProfile(isPrivate: value);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Account is now private'
                                  : 'Account is now public',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: AppThemeColors.primary,
                      ),
                    ),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                _buildDivider(),
                _buildListTile(
                  context,
                  title: 'Edit Profile',
                  icon: Icons.person_outline_rounded,
                  onTap: () => context.push(AppStrings.routeEditProfile),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // General Section
            _buildSectionHeader('General'),
            _buildSectionContainer(
              children: [
                _buildListTile(
                  context,
                  title: 'Currency',
                  subtitle: settings.preferredCurrency,
                  icon: Icons.attach_money_rounded,
                  onTap: () async {
                    final selected = CurrencyModel.getByCode(
                      settings.preferredCurrency,
                    );
                    final result = await showCurrencyPicker(
                      context,
                      selected: selected,
                    );
                    if (result != null) {
                      // 1. Show Loading Dialog
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(
                              color: AppThemeColors.primary,
                            ),
                          ),
                        );
                      }

                      try {
                        // 2. Convert all missions
                        final userId = ref
                            .read(currentUserProfileProvider)
                            ?.uid;
                        if (userId != null) {
                          await ref
                              .read(missionRepositoryProvider)
                              .convertAllMissionsCurrency(userId, result.code);
                        }

                        // 3. Update Profile & Settings
                        settingsNotifier.setPreferredCurrency(result.code);
                        await ref
                            .read(userProfileNotifierProvider.notifier)
                            .updateProfile(preferredCurrency: result.code);

                        // 4. Close Loading & Show Success
                        if (context.mounted) {
                          context.pop(); // Close Dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Currency updated to ${result.name}',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        // Handle Error
                        if (context.mounted) {
                          context.pop(); // Close Dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update currency: $e'),
                              backgroundColor: AppThemeColors.error,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  context,
                  title: 'Language',
                  subtitle:
                      settings.preferredLanguage == AppStrings.langIndonesian
                      ? 'Bahasa Indonesia'
                      : 'English',
                  icon: Icons.language_rounded,
                  onTap: () {
                    _showLanguagePicker(context, settings.preferredLanguage, (
                      val,
                    ) {
                      settingsNotifier.setPreferredLanguage(val);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader('Notifications'),
            _buildSectionContainer(
              children: [
                _buildListTile(
                  context,
                  title: 'Notification Settings',
                  subtitle: settings.dailyReminderEnabled
                      ? 'Enabled'
                      : 'Disabled',
                  icon: Icons.notifications_none_rounded,
                  onTap: () =>
                      context.push(AppStrings.routeNotificationSettings),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader('About'),
            _buildSectionContainer(
              children: [
                _buildListTile(
                  context,
                  title: 'Version',
                  trailingText: '1.0.0',
                  icon: Icons.info_outline_rounded,
                ),
                _buildDivider(),
                _buildListTile(
                  context,
                  title: 'Terms of Service',
                  icon: Icons.description_outlined,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Terms of Service coming soon'),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  context,
                  title: 'Privacy Policy',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy Policy coming soon'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppThemeColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      title: Text('Logout', style: AppTextStyles.titleLarge),
                      content: Text(
                        'Are you sure you want to logout?',
                        style: AppTextStyles.bodyMedium,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppThemeColors.textSecondary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'Logout',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppThemeColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go(AppStrings.routeLogin);
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppThemeColors.error,
                  side: const BorderSide(color: AppThemeColors.error, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                ),
                child: Text(
                  'Log Out',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppThemeColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelLarge.copyWith(
          color: AppThemeColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(24), // More rounded
        border: Border.all(color: AppThemeColors.border),
        boxShadow: AppThemeColors.cardShadow,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: AppThemeColors.borderLight,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    IconData? icon,
    VoidCallback? onTap,
    String? trailingText,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: icon != null
          ? Icon(icon, color: AppThemeColors.textSecondary)
          : null,
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: AppThemeColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppThemeColors.textTertiary,
              ),
            )
          : null,
      trailing: trailingText != null
          ? Text(
              trailingText,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppThemeColors.textSecondary,
              ),
            )
          : const Icon(
              Icons.chevron_right_rounded,
              color: AppThemeColors.textTertiary,
            ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: AppThemeColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppThemeColors.textTertiary,
        ),
      ),
      value: value,
      activeThumbColor: AppThemeColors.surface,
      activeTrackColor: AppThemeColors.primary,
      inactiveThumbColor: AppThemeColors.textSecondary,
      inactiveTrackColor: AppThemeColors.borderLight,
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      onChanged: onChanged,
    );
  }

  // _showCurrencyPicker removed - now using showCurrencyPicker from currency_picker_modal.dart

  void _showLanguagePicker(
    BuildContext context,
    String current,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppThemeColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppThemeColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Select Language', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 24),
            _buildOptionItem(
              context,
              'Bahasa Indonesia',
              current == AppStrings.langIndonesian,
              () {
                onSelect(AppStrings.langIndonesian);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildOptionItem(
              context,
              'English',
              current == AppStrings.langEnglish,
              () {
                onSelect(AppStrings.langEnglish);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppThemeColors.primary
                : AppThemeColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(
                color: isSelected
                    ? AppThemeColors.primary
                    : AppThemeColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppThemeColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
