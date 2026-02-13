import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../services/currency_service.dart';
import '../../data/models/mission_model.dart';
import '../../providers/missions_provider.dart';
import '../../../savings/providers/savings_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../services/analytics_service.dart';

class MissionDetailScreen extends ConsumerWidget {
  final MissionModel mission;

  const MissionDetailScreen({super.key, required this.mission});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = mission.progress;
    final daysRemaining = mission.daysRemaining;
    final isCompleted = mission.status == MissionStatus.completed;
    final user = ref.watch(currentUserProvider);

    // Analytics: Goal Viewed (Fire once)
    ref.listenManual(analyticsServiceProvider, (previous, current) {
      if (user != null) {
        current.logGoalViewed(mission.id, user.uid);
      }
    }, fireImmediately: true);

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.background,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppThemeColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppThemeColors.borderLight),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              color: AppThemeColors.textPrimary,
              onPressed: () => context.pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppThemeColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppThemeColors.borderLight),
              ),
              child: IconButton(
                icon: const Icon(Icons.edit_rounded, size: 20),
                color: AppThemeColors.textPrimary,
                onPressed: () async {
                  await context.pushNamed('createMission', extra: mission);
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon & Title
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppThemeColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppThemeColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: mission.imageUrl != null && mission.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: mission.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: AppThemeColors.textTertiary,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.flag_rounded,
                          size: 48,
                          color: AppThemeColors.primary,
                        ),
                      )
                    : const Icon(
                        Icons.flag_rounded,
                        size: 48,
                        color: AppThemeColors.primary,
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              mission.title,
              style: AppTextStyles.headlineSmall.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            if (mission.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                mission.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppThemeColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),

            // Progress Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppThemeColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppThemeColors.borderLight, width: 2),
                boxShadow: AppThemeColors.cardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Collected',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppThemeColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatCompact(
                              mission.currentAmount,
                              mission.currency,
                            ),
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppThemeColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Target',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppThemeColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatCompact(
                              mission.targetAmount,
                              mission.currency,
                            ),
                            style: AppTextStyles.headlineSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 16, // Thicker for playful look
                      backgroundColor: AppThemeColors.inputBackground,
                      color: isCompleted
                          ? AppThemeColors.success
                          : AppThemeColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        isCompleted
                            ? 'Completed!'
                            : (daysRemaining < 0
                                  ? 'Overdue'
                                  : '$daysRemaining days left'),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isCompleted
                              ? AppThemeColors.success
                              : (daysRemaining < 0
                                    ? AppThemeColors.error
                                    : AppThemeColors.textSecondary),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons Row
            if (!isCompleted)
              Row(
                children: [
                  // Add Saving Button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Analytics: Add Saving Clicked
                          if (user != null) {
                            ref
                                .read(analyticsServiceProvider)
                                .logAddSavingClicked(mission.id, user.uid);
                          }
                          // Navigate to Add Savings Screen with this mission pre-selected
                          context.pushNamed('proofOfSaving', extra: mission);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemeColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                          ),
                          elevation: 0,
                          shadowColor: AppThemeColors.primaryDark,
                        ),
                        icon: const Icon(Icons.add_rounded, size: 24),
                        label: Text(
                          'Add',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Withdraw Button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: mission.currentAmount > 0
                            ? () => _showWithdrawBottomSheet(
                                context,
                                ref,
                                mission,
                              )
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: BorderSide(
                            color: mission.currentAmount > 0
                                ? const Color(0xFFEF4444)
                                : AppThemeColors.borderLight,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.remove_rounded, size: 24),
                        label: Text(
                          'Withdraw',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: mission.currentAmount > 0
                                ? const Color(0xFFEF4444)
                                : AppThemeColors.textTertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 32),

            // History Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text('History', style: AppTextStyles.titleMedium),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final historyAsync = ref.watch(
                  missionSavingsProvider(mission.id),
                );

                return historyAsync.when(
                  data: (history) {
                    if (history.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppThemeColors.inputBackground,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.history,
                                size: 32,
                                color: AppThemeColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No savings yet. Start now!',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppThemeColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: history.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final record = history[index];
                        final amount = (record['amount'] as num).toDouble();
                        final currency = record['currency'] ?? mission.currency;
                        final timestamp = record['timestamp'] as Timestamp?;
                        final note = record['note'] as String?;
                        final proofImageUrl =
                            record['proof_image_url'] as String?;
                        // Check if this is a withdrawal
                        final type = record['type'] as String? ?? 'deposit';
                        final isWithdrawal = type == 'withdrawal';
                        final displayColor = isWithdrawal
                            ? const Color(0xFFEF4444)
                            : AppThemeColors.success;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppThemeColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppThemeColors.borderLight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              if (proofImageUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: proofImageUrl,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: displayColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isWithdrawal
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                    size: 24,
                                    color: displayColor,
                                  ),
                                ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${isWithdrawal ? '-' : '+'}${CurrencyFormatter.format(amount, currency)}',
                                      style: AppTextStyles.labelLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: displayColor,
                                      ),
                                    ),
                                    if (note != null && note.isNotEmpty)
                                      Text(
                                        note,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppThemeColors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                timestamp != null
                                    ? DateFormat(
                                        'dd MMM',
                                      ).format(timestamp.toDate())
                                    : '',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppThemeColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                );
              },
            ),

            const SizedBox(height: 48),

            // Delete Button
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _showDeleteConfirmation(context, ref),
                style: TextButton.styleFrom(
                  foregroundColor: AppThemeColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppThemeColors.error.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(
                  'Delete Goal',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppThemeColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppThemeColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppThemeColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppThemeColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                size: 36,
                color: AppThemeColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text('Delete Goal?', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppThemeColors.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppThemeColors.error.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppThemeColors.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Deleting this goal will permanently reduce your Total Savings. This cannot be undone.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppThemeColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Your savings history will be preserved, but you won\'t see this goal in your active list anymore.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppThemeColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(modalContext),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(
                        color: AppThemeColors.borderLight,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppThemeColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(modalContext); // Close bottom sheet
                      final navigator = Navigator.of(
                        context,
                        rootNavigator: true,
                      );

                      // Show loading indicator
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          useRootNavigator: true,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                      }

                      try {
                        if (user == null) throw Exception("User not logged in");

                        await ref
                            .read(missionRepositoryProvider)
                            .deleteMission(mission.id, user.uid);

                        // Analytics: Goal Deleted
                        ref
                            .read(analyticsServiceProvider)
                            .logGoalDeleted(
                              mission.id,
                              user.uid,
                              mission.currentAmount,
                            );

                        if (navigator.mounted) {
                          navigator.pop(); // Close loading
                        }

                        if (context.mounted) {
                          GoRouter.of(
                            context,
                          ).pop(true); // Return to previous screen with success
                        }
                      } catch (e) {
                        if (navigator.mounted) {
                          navigator.pop(); // Close loading
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error deleting goal: $e'),
                              backgroundColor: AppThemeColors.error,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showWithdrawBottomSheet(
    BuildContext context,
    WidgetRef ref,
    MissionModel mission,
  ) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppThemeColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Withdraw Savings',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Available balance: ${CurrencyFormatter.format(mission.currentAmount, mission.currency)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppThemeColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Amount Input
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount to withdraw',
                  prefixText:
                      '${CurrencyService.getCurrencySymbol(mission.currency)} ',
                  filled: true,
                  fillColor: AppThemeColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFEF4444),
                      width: 2,
                    ),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter amount';
                  }

                  // Remove formatting for validation
                  final cleanVal = val.replaceAll(RegExp(r'[^\d]'), '');
                  final amount = double.tryParse(cleanVal);

                  if (amount == null || amount <= 0) {
                    return 'Invalid amount';
                  }

                  // Check balance
                  if (amount > mission.currentAmount) {
                    return 'Insufficient balance';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Note Input (optional)
              TextFormField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Reason (optional)',
                  hintText: 'e.g., Emergency expense',
                  filled: true,
                  fillColor: AppThemeColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Withdraw Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      // Withdraw action
                      final text = amountController.text.replaceAll(
                        RegExp(r'[^\d]'),
                        '',
                      );
                      final amount =
                          double.tryParse(text) ?? 0.0; // Validated above
                      final navigator = Navigator.of(context);

                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        final success = await ref
                            .read(savingsNotifierProvider.notifier)
                            .withdrawSavings(
                              missionId: mission.id,
                              amount: amount,
                              note: noteController.text.isNotEmpty
                                  ? noteController.text
                                  : null,
                            );

                        if (navigator.mounted) {
                          navigator.pop(); // Close loading
                        }

                        if (success && navigator.mounted) {
                          navigator.pop(); // Close bottom sheet
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Withdrawn ${CurrencyFormatter.format(amount, mission.currency)}',
                                ),
                                backgroundColor: const Color(0xFFEF4444),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (navigator.mounted) {
                          navigator.pop(); // Close loading
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: AppThemeColors.error,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Withdraw',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
