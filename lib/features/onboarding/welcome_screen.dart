import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_image.dart';
import '../../data/seed/seed_catalog.dart';
import 'widgets/takeoff_slider.dart';

/// Onboarding screen.
///
/// The photograph is washed out behind a light veil so the logo and the
/// tagline carry the screen; the slide control is anchored to the bottom, so
/// neither block moves as the other changes size.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  /// Everyone lands on the home screen — browsing does not need an account.
  void _start(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const AppImage(SeedCatalog.welcomeImage),

          // Light veil: keeps a hint of the photograph without letting it
          // compete with the logo.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  scheme.surface.withValues(alpha: 0.82),
                  scheme.surface.withValues(alpha: 0.92),
                  scheme.surface.withValues(alpha: 0.98),
                ],
                stops: const <double>[0, 0.55, 1],
              ),
            ),
          ),

          SafeArea(
            child: Stack(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(
                          SeedCatalog.logoImage,
                          height: 128,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (
                                BuildContext context,
                                Object error,
                                StackTrace? _,
                              ) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        Text(
                          "Let's make our life so life",
                          textAlign: TextAlign.center,
                          style: AppFonts.tagline(color: AppColors.logoBlue),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  left: AppSpacing.xxl,
                  right: AppSpacing.xxl,
                  bottom: AppSpacing.huge,
                  child: Center(
                    child: TakeoffSlider(
                      label: 'Slide to start',
                      onCompleted: () => _start(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
