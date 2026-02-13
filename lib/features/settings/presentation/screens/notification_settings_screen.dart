import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../notification_controller.dart';
import '../../providers/settings_provider.dart';

/// Dedicated screen for notification settings with permission status indicators
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _hasNotificationPermission = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPermissionStatus();
  }

  Future<void> _loadPermissionStatus() async {
    final hasNotif = await NotificationController.isNotificationAllowed();

    if (mounted) {
      setState(() {
        _hasNotificationPermission = hasNotif;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

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
        title: Text('Notifications', style: AppTextStyles.headlineSmall),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppThemeColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Global Toggle
                  _buildSectionHeader('General'),
                  _buildSectionContainer(
                    children: [
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        title: Text(
                          'Enable Notifications',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppThemeColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'Master switch for all goal reminders',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppThemeColors.textSecondary,
                          ),
                        ),
                        value: settings.dailyReminderEnabled,
                        activeThumbColor: AppThemeColors.surface,
                        activeTrackColor: AppThemeColors.primary,
                        inactiveThumbColor: AppThemeColors.textSecondary,
                        inactiveTrackColor: AppThemeColors.borderLight,
                        trackOutlineColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                        onChanged: (value) async {
                          await settingsNotifier.setDailyReminderEnabled(value);
                          await _loadPermissionStatus();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Permission Status Section
                  _buildSectionHeader('Permission Status'),
                  _buildPermissionStatus(),
                  const SizedBox(height: 24),

                  // Test Notification Section
                  _buildSectionHeader('Debugging'),
                  _buildSectionContainer(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppThemeColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: AppThemeColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Send Test Notification',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppThemeColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'Tap to verify notification channel works',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppThemeColors.textTertiary,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppThemeColors.textSecondary,
                        ),
                        onTap: () async {
                          await NotificationController.createLocalNotification(
                            title: '🔔 Test Notification',
                            body:
                                'Jika kamu melihat ini, notifikasi bekerja dengan baik!',
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Test notification sent!'),
                                backgroundColor: AppThemeColors.primary,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppThemeColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppThemeColors.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppThemeColors.info,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Each goal has its own reminder settings. Configure reminder time and repeat days when creating or editing a goal.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppThemeColors.textPrimary.withValues(
                                alpha: 0.8,
                              ),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPermissionStatus() {
    if (_hasNotificationPermission) {
      return _buildSectionContainer(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppThemeColors.success,
                size: 24,
              ),
            ),
            title: Text(
              'Permission Granted',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppThemeColors.success,
              ),
            ),
            subtitle: Text(
              'Notifications will be delivered normally',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppThemeColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    return _buildWarningCard(
      icon: Icons.notifications_off_rounded,
      title: 'Permission Required',
      subtitle: 'Tap to enable notifications',
      onTap: () async {
        await NotificationController.requestPermission();
        await _loadPermissionStatus();
      },
    );
  }

  Widget _buildWarningCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppThemeColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppThemeColors.warning.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemeColors.warning.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppThemeColors.warning, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppThemeColors.warning,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppThemeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppThemeColors.warning,
            ),
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeColors.border),
        boxShadow: AppThemeColors.cardShadow,
      ),
      child: Column(children: children),
    );
  }
}
