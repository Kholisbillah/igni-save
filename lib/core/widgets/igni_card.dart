import 'package:flutter/material.dart';
import '../constants/app_theme_colors.dart';
import '../constants/app_sizes.dart';

/// Card widget with flat design and subtle shadow - Duolingo Style
class IgniCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool showBorder;
  final bool elevated;
  final Color? borderColor;

  const IgniCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius = AppSizes.radiusLg,
    this.onTap,
    this.showBorder = false,
    this.elevated = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppSizes.md),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppThemeColors.card,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: borderColor ?? AppThemeColors.cardBorder,
                width: 1,
              )
            : null,
        boxShadow: elevated
            ? AppThemeColors.elevatedShadow
            : AppThemeColors.cardShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Stat card for displaying numbers - Duolingo style
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppThemeColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: AppThemeColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (iconColor ?? AppThemeColors.primary).withValues(
                alpha: 0.15,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppThemeColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppThemeColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Goal progress card - Duolingo style with colorful progress
class GoalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final String amount;
  final String target;
  final Color? progressColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const GoalCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.amount,
    required this.target,
    this.progressColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = progressColor ?? AppThemeColors.primary;

    return IgniCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppThemeColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppThemeColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSizes.md),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                target,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppThemeColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
