import 'package:flutter/material.dart';
import '../constants/app_theme_colors.dart';

/// Text styles for IgniSave using Inter and Lexend fonts
/// Vibrant Flat Duolingo-Style Light Theme
class AppTextStyles {
  AppTextStyles._();

  // Font Families
  static const String fontInter = 'Inter';
  static const String fontLexend = 'Lexend';

  // ============================================
  // DISPLAY STYLES (Lexend - for big headers)
  // ============================================
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontLexend,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppThemeColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontLexend,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppThemeColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontLexend,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppThemeColors.textPrimary,
    height: 1.3,
  );

  // ============================================
  // HEADLINE STYLES (Lexend - section headers)
  // ============================================
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontLexend,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppThemeColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontLexend,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppThemeColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontLexend,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppThemeColors.textPrimary,
    height: 1.4,
  );

  // ============================================
  // TITLE STYLES (Inter - screen titles)
  // ============================================
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontLexend, // Changed to Lexend for screen titles
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppThemeColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontLexend,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppThemeColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontInter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppThemeColors.textPrimary,
    height: 1.4,
  );

  // ============================================
  // BODY STYLES (Inter - descriptions & content)
  // ============================================
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontInter,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppThemeColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontInter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppThemeColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontInter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppThemeColors.textSecondary,
    height: 1.5,
  );

  // ============================================
  // LABEL STYLES (Inter - input labels, helpers)
  // ============================================
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontInter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppThemeColors.textPrimary,
    letterSpacing: 0.3,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontInter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppThemeColors.textSecondary,
    letterSpacing: 0.3,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontInter,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppThemeColors.textTertiary,
    letterSpacing: 0.3,
    height: 1.4,
  );

  // ============================================
  // BUTTON STYLE (Lexend - CTA buttons)
  // ============================================
  static const TextStyle button = TextStyle(
    fontFamily: fontLexend,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppThemeColors.textOnPrimary,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: fontInter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppThemeColors.primary,
    letterSpacing: 0.3,
    height: 1.2,
  );

  // ============================================
  // CAPTION & SMALL TEXT (Inter)
  // ============================================
  static const TextStyle caption = TextStyle(
    fontFamily: fontInter,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppThemeColors.textTertiary,
    letterSpacing: 0.2,
    height: 1.4,
  );

  // ============================================
  // AMOUNT/NUMBER DISPLAY (Lexend - important numbers)
  // ============================================
  static const TextStyle amountLarge = TextStyle(
    fontFamily: fontLexend,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppThemeColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle amountMedium = TextStyle(
    fontFamily: fontLexend,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppThemeColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle amountSmall = TextStyle(
    fontFamily: fontLexend,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppThemeColors.textPrimary,
    height: 1.2,
  );

  // ============================================
  // STREAK DISPLAY (Lexend - big streak numbers)
  // ============================================
  static const TextStyle streakNumber = TextStyle(
    fontFamily: fontLexend,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppThemeColors.streak,
    height: 1.1,
  );

  // ============================================
  // BADGES & CHIPS
  // ============================================
  static const TextStyle xpBadge = TextStyle(
    fontFamily: fontLexend,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppThemeColors.xpGold,
    letterSpacing: 0.3,
  );

  static const TextStyle chipLabel = TextStyle(
    fontFamily: fontInter,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppThemeColors.textPrimary,
    letterSpacing: 0.2,
  );

  // ============================================
  // LINK STYLE
  // ============================================
  static const TextStyle link = TextStyle(
    fontFamily: fontInter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppThemeColors.accentBlue,
    height: 1.4,
  );

  // ============================================
  // SECTION HEADER (for list sections)
  // ============================================
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: fontLexend,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppThemeColors.textSecondary,
    letterSpacing: 0.5,
    height: 1.4,
  );
}
