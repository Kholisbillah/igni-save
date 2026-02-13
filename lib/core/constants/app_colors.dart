import 'package:flutter/material.dart';

/// App color constants for IgniSave
/// Dark theme with blue electric and orange fire accents
class AppColors {
  AppColors._();

  // Primary Colors (Flat UI Palette)
  static const Color turquoise = Color(0xFF1ABC9C);
  static const Color emerald = Color(0xFF2ECC71);
  static const Color peterRiver = Color(0xFF3498DB);
  static const Color amethyst = Color(0xFF9B59B6);
  static const Color wetAsphalt = Color(0xFF34495E);

  static const Color greenSea = Color(0xFF16A085);
  static const Color nephritis = Color(0xFF27AE60);
  static const Color belizeHole = Color(0xFF2980B9);
  static const Color wisteria = Color(0xFF8E44AD);
  static const Color midnightBlue = Color(0xFF2C3E50);

  static const Color sunFlower = Color(0xFFF1C40F);
  static const Color carrot = Color(0xFFE67E22);
  static const Color alizarin = Color(0xFFE74C3C);
  static const Color clouds = Color(0xFFECF0F1);
  static const Color concrete = Color(0xFF95A5A6);

  static const Color orange = Color(0xFFF39C12);
  static const Color pumpkin = Color(0xFFD35400);
  static const Color pomegranate = Color(0xFFC0392B);
  static const Color silver = Color(0xFFBDC3C7);
  static const Color asbestos = Color(0xFF7F8C8D);

  // App Theme Mappings
  static const Color primary = peterRiver;
  static const Color primaryLight = turquoise;
  static const Color primaryDark = belizeHole;

  static const Color accent =
      sunFlower; // Gold/Yellow for consistency with coins/stars

  static const Color background =
      Colors.white; // User design shows white background
  static const Color surface = clouds;
  static const Color card = Colors.white;

  static const Color textPrimary = midnightBlue;
  static const Color textSecondary = asbestos;
  static const Color textTertiary = concrete;

  static const Color success = nephritis;
  static const Color warning = sunFlower;
  static const Color error = alizarin;
  static const Color info = peterRiver;

  // New Gradients/Special
  static const List<Color> primaryGradient = [peterRiver, belizeHole];

  // Legacy support (to avoid breaks immediately, but should be refactored)
  static const Color surfaceLight = clouds;
  static const Color cardLight = silver;
  static const Color textHint = concrete;
  static const Color border = silver;
  static const Color borderLight = clouds;
  static const Color divider = clouds;

  // League Colors
  static const Color silverLeague = silver;
  static const Color goldLeague = sunFlower;
  static const Color bronzeLeague = pumpkin;
}
