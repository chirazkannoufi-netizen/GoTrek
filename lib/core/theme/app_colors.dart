import 'package:flutter/material.dart';

/// Brand palette for GoTrek.
///
/// The blue seed is carried over from the original Figma design so the app
/// keeps its identity; every other role is derived from it by [ColorScheme].
abstract final class AppColors {
  static const Color brand = Color(0xFF1565C0);
  static const Color brandDeep = Color(0xFF0D47A1);

  /// The blue in `assets/images/gotrek_logo.png`, taken straight from the
  /// artwork: it is the single most common opaque pixel in the file
  /// (13,492 px sit within a few units of it). Used wherever the brand blue
  /// has to match the logo exactly — the welcome tagline, and the same value
  /// the cahier des charges uses.
  static const Color logoBlue = Color(0xFF1E4A6F);

  /// Ratings, prices and other "value" accents.
  static const Color accent = Color(0xFFF5A524);

  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);

  static const Color lightSurface = Color(0xFFF6F7F9);
  static const Color darkSurface = Color(0xFF101418);
}
