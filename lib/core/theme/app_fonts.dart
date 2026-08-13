import 'package:flutter/material.dart';

/// Typefaces beyond the platform default.
abstract final class AppFonts {
  /// Playfair Display, bundled italic-only (SIL OFL 1.1, see
  /// `assets/fonts/OFL.txt`). Reserved for display copy such as the welcome
  /// tagline — body and UI text stay on the platform font.
  static const String display = 'PlayfairDisplay';

  /// High-contrast italic serif for a tagline.
  ///
  /// The bundled file is a variable font, so the weight comes from a
  /// `FontVariation` rather than picking a separate static face.
  static TextStyle tagline({
    required Color color,
    double fontSize = 36,
    double weight = 500,
  }) => TextStyle(
    fontFamily: display,
    fontStyle: FontStyle.italic,
    fontSize: fontSize,
    height: 1.25,
    letterSpacing: 0.2,
    color: color,
    fontVariations: <FontVariation>[FontVariation('wght', weight)],
  );
}
