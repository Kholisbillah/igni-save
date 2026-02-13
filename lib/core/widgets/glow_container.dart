import 'package:flutter/material.dart';
import '../constants/app_theme_colors.dart';
import '../constants/app_sizes.dart';

/// Legacy compatibility widget - now renders as a flat container with subtle shadow
/// Replaces neon glow with soft drop shadow for the clean Duolingo aesthetics
class GlowContainer extends StatelessWidget {
  final Widget child;
  final Color?
  glowColor; // Maintained for API compatibility, used as shadow color
  final double glowRadius;
  final double glowSpread;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool enableGlow;
  final Border? border;
  final Gradient? gradient;
  final bool clipContent;

  const GlowContainer({
    super.key,
    required this.child,
    this.glowColor,
    this.glowRadius = 10.0,
    this.glowSpread = 0.0,
    this.borderRadius = AppSizes.radiusLg,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.enableGlow = true,
    this.border,
    this.gradient,
    this.clipContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null
            ? (backgroundColor ?? AppThemeColors.card)
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: enableGlow
            ? [
                BoxShadow(
                  color: (glowColor ?? AppThemeColors.shadow).withValues(
                    alpha: 0.1,
                  ),
                  blurRadius: glowRadius,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: clipContent
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
            )
          : Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );
  }
}
