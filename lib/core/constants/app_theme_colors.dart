import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App Theme Colors - Vibrant Flat Duolingo-Style Light Theme
/// Cheerful, playful, motivational design with custom color palette
class AppThemeColors {
  AppThemeColors._();

  // ============================================
  // PRIMARY & SUCCESS (Main Actions - Blue Tones based on Figma)
  // ============================================
  static const Color primary = AppColors.peterRiver; // Blue from design
  static const Color primaryLight = AppColors.peterRiver;
  static const Color primaryDark = AppColors.belizeHole;
  static const Color primaryDeep = AppColors.midnightBlue;

  // ============================================
  // SECONDARY / ACCENT (Highlights & Active States)
  // ============================================
  static const Color accent = AppColors.sunFlower; // Yellow/Gold
  static const Color accentBlue = AppColors.peterRiver;
  static const Color secondary = accentBlue;
  static const Color accentBlueDark = AppColors.belizeHole;
  static const Color accentPurple = AppColors.amethyst;
  static const Color accentPurpleDark = AppColors.wisteria;

  // ============================================
  // WARNING / MOTIVATION / REWARDS (Yellow-Orange)
  // ============================================
  static const Color reward = AppColors.sunFlower;
  static const Color rewardOrange = AppColors.carrot;
  static const Color rewardOrangeDark = AppColors.pumpkin;

  // Streak Fire Color
  static const Color streak = AppColors.orange;
  static const Color streakGlow = Color(0x40F39C12);

  // XP & Level Colors
  static const Color xpGold = AppColors.sunFlower;
  static const Color levelBadge = AppColors.amethyst;

  // ============================================
  // ERROR / DESTRUCTIVE (Red Tones)
  // ============================================
  static const Color error = AppColors.alizarin;
  static const Color errorDark = AppColors.pomegranate;
  static const Color warning = AppColors.orange;

  // ============================================
  // BACKGROUND & SURFACES (Light Theme)
  // ============================================
  static const Color background = Colors.white;
  static const Color backgroundWhite = Colors.white;
  static const Color surface = AppColors.clouds;
  static const Color surfaceVariant = AppColors.silver;

  // Card Colors
  static const Color card = Colors.white;
  static const Color cardBorder = AppColors.silver;
  static const Color inputBackground = AppColors.clouds;
  static const Color inputFillColor = AppColors.clouds;

  // ============================================
  // TEXT & NEUTRAL
  // ============================================
  static const Color textPrimary = AppColors.midnightBlue;
  static const Color textSecondary = AppColors.asbestos; // Grey text
  static const Color textTertiary = AppColors.concrete;
  static const Color textHint = AppColors.silver;
  static const Color textOnPrimary = Colors.white;

  // Icon colors
  static const Color iconActive = AppColors.midnightBlue;
  static const Color iconInactive = AppColors.concrete;

  // ============================================
  // STATUS / INFO COLORS
  // ============================================
  static const Color success = AppColors.nephritis;
  static const Color successLight = AppColors.emerald;
  static const Color info = AppColors.peterRiver;

  // Legacy compatibility
  static const Color coral = AppColors.carrot;
  static const Color coralLight = AppColors.orange;

  // ============================================
  // BORDER & DIVIDER
  // ============================================
  static const Color border = AppColors.silver;
  static const Color borderLight = AppColors.clouds;
  static const Color divider = AppColors.clouds;

  // ============================================
  // SHADOW COLORS
  // ============================================
  static const Color shadow = Color(0x0D000000);
  static const Color shadowMedium = Color(0x1A000000);

  // ============================================
  // CARD SHADOWS
  // ============================================
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: shadow,
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: shadowMedium,
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // Button pressed shadow
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 3),
      spreadRadius: 0,
    ),
  ];
}
