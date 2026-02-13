import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../profile/providers/user_profile_provider.dart';
import '../../../missions/providers/missions_provider.dart';
import '../../../missions/data/models/mission_model.dart';

/// Analytics Screen - Shows financial statistics and insights
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(currentUserProfileProvider);
    final user = ref.watch(currentUserProvider);
    final missionsAsync = ref.watch(userMissionsStreamProvider);

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Savings Analytics',
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
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
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: user == null || userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<Map<String, dynamic>>(
              future: _fetchAnalyticsData(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data ?? {};
                final totalSavings = userProfile.totalSavings;
                final currency = userProfile.preferredCurrency;

                // Calculate stats from data
                final thisMonthSavings =
                    (data['thisMonthSavings'] ?? 0.0) as double;
                final thisWeekSavings =
                    (data['thisWeekSavings'] ?? 0.0) as double;
                final totalWithdrawals =
                    (data['totalWithdrawals'] ?? 0.0) as double;
                final totalDeposits = (data['totalDeposits'] ?? 0.0) as double;
                final savingsDays = (data['savingsDays'] ?? 0) as int;
                final bestDayAmount = (data['bestDayAmount'] ?? 0.0) as double;
                final bestDayDate = data['bestDayDate'] as DateTime?;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total Savings Hero Card
                      _buildHeroCard(
                        title: 'Total Savings',
                        amount: totalSavings,
                        currency: currency,
                        icon: Icons.savings_rounded,
                        color: AppThemeColors.primary,
                      ),
                      const SizedBox(height: 24),

                      // Period Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'This Month',
                              amount: thisMonthSavings,
                              currency: currency,
                              icon: Icons.calendar_month_rounded,
                              color: AppThemeColors.success,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: 'This Week',
                              amount: thisWeekSavings,
                              currency: currency,
                              icon: Icons.date_range_rounded,
                              color: AppThemeColors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Insights Section
                      Text(
                        'Insights',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Insights Grid
                      _buildInsightTile(
                        icon: Icons.trending_up_rounded,
                        title: 'Total Deposited',
                        value: CurrencyFormatter.format(
                          totalDeposits,
                          currency,
                        ),
                        subtitle: 'All time deposits',
                        color: AppThemeColors.success,
                      ),
                      const SizedBox(height: 12),
                      _buildInsightTile(
                        icon: Icons.arrow_downward_rounded,
                        title: 'Total Withdrawn',
                        value: CurrencyFormatter.format(
                          totalWithdrawals,
                          currency,
                        ),
                        subtitle: 'All time withdrawals',
                        color: const Color(0xFFEF4444),
                      ),
                      const SizedBox(height: 12),
                      _buildInsightTile(
                        icon: Icons.star_rounded,
                        title: 'Best Day',
                        value: CurrencyFormatter.format(
                          bestDayAmount,
                          currency,
                        ),
                        subtitle: bestDayDate != null
                            ? DateFormat('dd MMM yyyy').format(bestDayDate)
                            : 'No savings yet',
                        color: AppThemeColors.warning,
                      ),
                      const SizedBox(height: 12),
                      _buildInsightTile(
                        icon: Icons.calendar_today_rounded,
                        title: 'Active Days',
                        value: '$savingsDays days',
                        subtitle: 'Days with savings activity',
                        color: AppThemeColors.info,
                      ),
                      const SizedBox(height: 24),

                      // Goals Summary
                      Text(
                        'Goals Summary',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      missionsAsync.when(
                        data: (missions) {
                          final active = missions
                              .where((m) => m.status == MissionStatus.active)
                              .length;
                          final completed = missions
                              .where((m) => m.status == MissionStatus.completed)
                              .length;
                          final total = missions.length;

                          return Row(
                            children: [
                              Expanded(
                                child: _buildGoalStat(
                                  label: 'Active',
                                  count: active,
                                  color: AppThemeColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildGoalStat(
                                  label: 'Completed',
                                  count: completed,
                                  color: AppThemeColors.success,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildGoalStat(
                                  label: 'Total',
                                  count: total,
                                  color: AppThemeColors.textSecondary,
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Error: $e'),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<Map<String, dynamic>> _fetchAnalyticsData(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('savings_history')
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    double thisMonthSavings = 0;
    double thisWeekSavings = 0;
    double totalWithdrawals = 0;
    double totalDeposits = 0;
    double bestDayAmount = 0;
    DateTime? bestDayDate;
    final Set<String> uniqueDays = {};
    final Map<String, double> dailyTotals = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] as num).toDouble();
      final type = data['type'] as String? ?? 'deposit';
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final dateKey = DateFormat('yyyy-MM-dd').format(timestamp);

      uniqueDays.add(dateKey);

      if (type == 'withdrawal') {
        totalWithdrawals += amount;
      } else {
        totalDeposits += amount;

        // Track daily totals for best day calculation
        dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + amount;

        // This month
        if (timestamp.isAfter(startOfMonth)) {
          thisMonthSavings += amount;
        }

        // This week
        if (timestamp.isAfter(startOfWeek)) {
          thisWeekSavings += amount;
        }
      }
    }

    // Find best day
    dailyTotals.forEach((date, total) {
      if (total > bestDayAmount) {
        bestDayAmount = total;
        bestDayDate = DateFormat('yyyy-MM-dd').parse(date);
      }
    });

    return {
      'thisMonthSavings': thisMonthSavings,
      'thisWeekSavings': thisWeekSavings,
      'totalWithdrawals': totalWithdrawals,
      'totalDeposits': totalDeposits,
      'savingsDays': uniqueDays.length,
      'bestDayAmount': bestDayAmount,
      'bestDayDate': bestDayDate,
    };
  }

  Widget _buildHeroCard({
    required String title,
    required double amount,
    required String currency,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            CurrencyFormatter.format(amount, currency),
            style: AppTextStyles.displayMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required double amount,
    required String currency,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppThemeColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(amount, currency),
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightTile({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppThemeColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppThemeColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStat({
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.borderLight),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: AppTextStyles.headlineLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppThemeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
