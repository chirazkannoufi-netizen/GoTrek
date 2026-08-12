import 'package:flutter/widgets.dart';

/// 4pt spacing scale. Every gap in the app should come from here.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  /// Horizontal page margin used by every screen.
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: lg);
}

abstract final class AppRadius {
  static const Radius sm = Radius.circular(8);
  static const Radius md = Radius.circular(12);
  static const Radius lg = Radius.circular(16);
  static const Radius xl = Radius.circular(20);

  static const BorderRadius allSm = BorderRadius.all(sm);
  static const BorderRadius allMd = BorderRadius.all(md);
  static const BorderRadius allLg = BorderRadius.all(lg);
  static const BorderRadius allXl = BorderRadius.all(xl);
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);

  /// Stand-in latency for the seeded repositories, so loading states are real.
  static const Duration fakeNetwork = Duration(milliseconds: 400);
}

/// Breakpoints for the responsive grids.
abstract final class AppBreakpoints {
  static const double tablet = 720;
  static const double desktop = 1080;

  /// Number of grid columns that fits [width].
  static int columnsFor(double width) {
    if (width >= desktop) return 4;
    if (width >= tablet) return 3;
    if (width >= 520) return 2;
    return 1;
  }
}
