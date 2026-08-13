import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Light and dark themes for GoTrek.
///
/// Everything is derived from a single seed colour so that contrast stays
/// correct in both modes; screens should read colours from
/// `Theme.of(context).colorScheme` rather than hard-coding them.
abstract final class AppTheme {
  /// One icon size for inline glyphs, one for tappable icon buttons, one for
  /// icons sitting inside a button next to a label. Screens should not pick
  /// their own numbers.
  /// Metadata glyphs inside dense card rows.
  static const double iconCompact = 16;
  static const double iconInline = 20;
  static const double iconAction = 22;
  static const double iconInButton = 20;

  /// Large tile glyphs, e.g. the home service shortcuts.
  static const double iconService = 28;

  /// Every full-width button is this tall, so stacked actions line up.
  static const double buttonHeight = 52;

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: brightness,
    ).copyWith(
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      tertiary: AppColors.accent,
      error: AppColors.danger,
    );

    final TextTheme textTheme = _textTheme(scheme);

    /// Shared by the three button families so they differ only in fill.
    ButtonStyle buttonBase() => ButtonStyle(
      minimumSize: const WidgetStatePropertyAll<Size>(
        Size.fromHeight(buttonHeight),
      ),
      iconSize: const WidgetStatePropertyAll<double>(iconInButton),
      textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelLarge),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: AppRadius.allMd),
      ),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      iconTheme: IconThemeData(
        size: iconInline,
        color: scheme.onSurfaceVariant,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        iconTheme: IconThemeData(size: iconAction, color: scheme.onSurface),
        actionsIconTheme: IconThemeData(
          size: iconAction,
          color: scheme.onSurface,
        ),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),

      cardTheme: CardTheme(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.allLg,
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(style: buttonBase()),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: buttonBase().copyWith(
          backgroundColor: WidgetStatePropertyAll<Color>(scheme.primary),
          foregroundColor: WidgetStatePropertyAll<Color>(scheme.onPrimary),
          elevation: const WidgetStatePropertyAll<double>(0),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: buttonBase().copyWith(
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: scheme.outlineVariant),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
          iconSize: iconInButton,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.allSm),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          iconSize: iconAction,
          minimumSize: const Size(44, 44),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.allSm),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final bool selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final bool selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: iconAction,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        selectedColor: scheme.primary,
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: textTheme.labelMedium,
        iconTheme: IconThemeData(size: 18, color: scheme.onSurfaceVariant),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        minLeadingWidth: 28,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.allMd),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.6),
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.allMd),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
    );
  }

  /// Explicit type ramp.
  ///
  /// Sizes and tracking are set outright rather than inherited from the
  /// Material defaults, so headings read as a deliberate hierarchy instead of
  /// body text at a larger size: display and headline sit at w800 with tight
  /// negative tracking, titles at w700/w600, body stays w400 at a comfortable
  /// line height.
  static TextTheme _textTheme(ColorScheme scheme) {
    final Typography typography = Typography.material2021(colorScheme: scheme);
    final TextTheme source =
        scheme.brightness == Brightness.dark
            ? typography.white
            : typography.black;

    return source.copyWith(
      displayMedium: source.displayMedium?.copyWith(
        fontSize: 42,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.12,
      ),
      displaySmall: source.displaySmall?.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        height: 1.15,
      ),
      headlineMedium: source.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      headlineSmall: source.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.25,
      ),
      titleLarge: source.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.3,
      ),
      titleMedium: source.titleMedium?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.15,
        height: 1.35,
      ),
      titleSmall: source.titleSmall?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.35,
      ),
      bodyLarge: source.bodyLarge?.copyWith(fontSize: 15.5, height: 1.5),
      bodyMedium: source.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
      bodySmall: source.bodySmall?.copyWith(fontSize: 12.5, height: 1.4),
      labelLarge: source.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      labelMedium: source.labelMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelSmall: source.labelSmall?.copyWith(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}
