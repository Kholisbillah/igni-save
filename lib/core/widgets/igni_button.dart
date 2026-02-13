import 'package:flutter/material.dart';
import '../constants/app_theme_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/text_styles.dart';

/// Primary button with solid color - Vibrant Flat Duolingo Style
class IgniButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;
  final bool showArrow;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;

  const IgniButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.showArrow = false,
    this.width,
    this.height = AppSizes.buttonHeight,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppThemeColors.primary;
    final fgColor = textColor ?? AppThemeColors.textOnPrimary;
    final isEnabled = enabled && !isLoading && onPressed != null;

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: isEnabled ? bgColor : AppThemeColors.border,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          splashColor: Colors.white.withValues(alpha: 0.2),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: isEnabled
                              ? fgColor
                              : AppThemeColors.textTertiary,
                          size: AppSizes.iconSm,
                        ),
                        const SizedBox(width: AppSizes.sm),
                      ],
                      Text(
                        text,
                        style: AppTextStyles.button.copyWith(
                          color: isEnabled
                              ? fgColor
                              : AppThemeColors.textTertiary,
                        ),
                      ),
                      if (showArrow && !isLoading) ...[
                        const SizedBox(width: AppSizes.sm),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: isEnabled
                              ? fgColor
                              : AppThemeColors.textTertiary,
                          size: AppSizes.iconSm,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Secondary button with outline - Flat Duolingo Style
class IgniOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? borderColor;
  final Color? textColor;

  const IgniOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = AppSizes.buttonHeight,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? AppThemeColors.primary;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          foregroundColor: color,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: textColor ?? color,
                      size: AppSizes.iconSm,
                    ),
                    const SizedBox(width: AppSizes.sm),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(
                      color: textColor ?? color,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Text button for links - Flat style
class IgniTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? textColor;

  const IgniTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? AppThemeColors.primary;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: AppSizes.iconSm),
            const SizedBox(width: AppSizes.xs),
          ],
          Text(
            text,
            style: AppTextStyles.buttonSecondary.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Small action button / chip button - Colorful Duolingo style
class IgniChipButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSelected;

  const IgniChipButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? (backgroundColor ?? AppThemeColors.primary)
        : AppThemeColors.surfaceVariant;
    final fgColor = isSelected
        ? (textColor ?? AppThemeColors.textOnPrimary)
        : AppThemeColors.textSecondary;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: fgColor, size: 16),
                const SizedBox(width: AppSizes.xs),
              ],
              Text(
                text,
                style: AppTextStyles.chipLabel.copyWith(color: fgColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
