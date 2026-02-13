import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/mission_model.dart';

/// Goal Card widget matching Figma design - Based on dashboard _GoalCard
/// Uses absolute positioning for precise pixel-perfect layout
class GoalCard extends StatelessWidget {
  final MissionModel mission;
  final VoidCallback? onTap;
  final bool showDaysRemaining;

  const GoalCard({
    super.key,
    required this.mission,
    this.onTap,
    this.showDaysRemaining = true,
  });

  /// Parse hex color string to Color
  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF9B59B6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _parseColor(mission.colorTheme);
    final isCompleted = mission.isCompleted;
    final percent = (mission.progress * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 130,
        decoration: BoxDecoration(
          color: themeColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // 1. Title
            Positioned(
              left: 21,
              top: 17,
              width: 171,
              child: Text(
                mission.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  height: 1.0,
                ),
              ),
            ),

            // 2. Pills Row (Daily Amount + Percentage/Completed)
            Positioned(
              left: 21,
              top: 52,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Daily Amount Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${CurrencyFormatter.formatCompact(mission.currentFillingNominal, mission.currency)}/${mission.fillingPlanDisplayText}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: themeColor,
                        letterSpacing: 0.5,
                        height: 1.0,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Percentage or Completed Pill
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Completed',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: themeColor,
                          letterSpacing: 0.5,
                          height: 1.0,
                        ),
                      ),
                    )
                  else
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.5,
                        height: 1.0,
                      ),
                    ),
                ],
              ),
            ),

            // 3. Progress Bar (only for active goals)
            if (!isCompleted)
              Positioned(
                left: 21,
                top: 84,
                right: 135,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: mission.progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),

            // 4. Amounts Row
            Positioned(
              left: 21,
              top: isCompleted ? 84 : 98,
              right: 135,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Current/Final Amount
                  Flexible(
                    child: Text(
                      CurrencyFormatter.format(
                        isCompleted
                            ? mission.targetAmount
                            : mission.currentAmount,
                        mission.currency,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.6,
                        height: 1.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Target Amount (only for active)
                  if (!isCompleted)
                    Flexible(
                      child: Text(
                        CurrencyFormatter.format(
                          mission.targetAmount,
                          mission.currency,
                        ),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.7),
                          letterSpacing: 0.5,
                          height: 1.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            // 5. Right Image (104x104, aligned right)
            Positioned(
              right: 17,
              top: 13,
              width: 104,
              height: 104,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: mission.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: mission.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  _buildPlaceholder(),
                              errorWidget: (context, url, error) =>
                                  _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                  ),
                  // Days Badge (top-right corner of image)
                  if (showDaysRemaining && !isCompleted)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${mission.daysRemaining}',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: themeColor,
                                height: 1.0,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              'Days',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: themeColor,
                                height: 1.0,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
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

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.white.withValues(alpha: 0.2),
      child: Icon(
        Icons.savings_rounded,
        color: Colors.white.withValues(alpha: 0.5),
        size: 40,
      ),
    );
  }
}
