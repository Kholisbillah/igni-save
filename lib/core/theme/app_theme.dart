import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_theme_colors.dart';
import '../constants/app_sizes.dart';
import 'text_styles.dart';

/// App theme configuration for IgniSave
/// Vibrant Flat Duolingo-Style Light Theme
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme - Vibrant Flat Duolingo Style
      colorScheme: const ColorScheme.light(
        primary: AppThemeColors.primary,
        onPrimary: AppThemeColors.textOnPrimary,
        primaryContainer: AppThemeColors.primaryLight,
        secondary: AppThemeColors.accent,
        onSecondary: AppThemeColors.textOnPrimary,
        secondaryContainer: AppThemeColors.accentBlue,
        surface: AppThemeColors.surface,
        onSurface: AppThemeColors.textPrimary,
        error: AppThemeColors.error,
        onError: AppThemeColors.textOnPrimary,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppThemeColors.background,

      // AppBar - Clean flat style
      appBarTheme: const AppBarTheme(
        backgroundColor: AppThemeColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: AppTextStyles.titleLarge,
        iconTheme: IconThemeData(
          color: AppThemeColors.textPrimary,
          size: AppSizes.iconMd,
        ),
      ),

      // Card - White with subtle shadow
      cardTheme: CardThemeData(
        color: AppThemeColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button - Solid green, pill shape
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppThemeColors.primary,
          foregroundColor: AppThemeColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.md,
          ),
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppThemeColors.primary,
          side: const BorderSide(color: AppThemeColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.md,
          ),
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          textStyle: AppTextStyles.button.copyWith(
            color: AppThemeColors.primary,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppThemeColors.primary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Input Decoration - Clean flat style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppThemeColors.inputFillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppThemeColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppThemeColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppThemeColors.error, width: 2),
        ),
        labelStyle: AppTextStyles.labelMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppThemeColors.textHint,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppThemeColors.error,
        ),
        prefixIconColor: AppThemeColors.textTertiary,
        suffixIconColor: AppThemeColors.textTertiary,
      ),

      // Bottom Navigation Bar - Flat style
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppThemeColors.surface,
        selectedItemColor: AppThemeColors.primary,
        unselectedItemColor: AppThemeColors.iconInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.caption,
        unselectedLabelStyle: AppTextStyles.caption,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppThemeColors.primary,
        foregroundColor: AppThemeColors.textOnPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppThemeColors.divider,
        thickness: 1,
        space: 0,
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: AppThemeColors.iconActive,
        size: AppSizes.iconMd,
      ),

      // Switch - Colorful active state
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppThemeColors.surface;
          }
          return AppThemeColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppThemeColors.primary;
          }
          return AppThemeColors.border;
        }),
      ),

      // Progress Indicator - Primary green
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppThemeColors.primary,
        linearTrackColor: AppThemeColors.border,
        circularTrackColor: AppThemeColors.border,
      ),

      // Chip - Rounded colorful
      chipTheme: ChipThemeData(
        backgroundColor: AppThemeColors.surfaceVariant,
        selectedColor: AppThemeColors.primaryLight,
        labelStyle: AppTextStyles.chipLabel,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppThemeColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        titleTextStyle: AppTextStyles.headlineSmall,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppThemeColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXl),
          ),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppThemeColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppThemeColors.textOnPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Tab Bar
      tabBarTheme: const TabBarThemeData(
        labelColor: AppThemeColors.primary,
        unselectedLabelColor: AppThemeColors.textTertiary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelMedium,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppThemeColors.primary, width: 3),
          ),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
    );
  }

  // Keep darkTheme getter for backwards compatibility, but return lightTheme
  static ThemeData get darkTheme => lightTheme;
}
