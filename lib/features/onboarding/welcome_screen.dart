import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_image.dart';
import '../../data/seed/seed_catalog.dart';

/// Onboarding screen.
///
/// The photograph is washed out behind a light veil so the logo carries the
/// screen; the logo itself sits dead centre and the slide control is anchored
/// to the bottom, so neither moves as the other changes size.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  static const double _knobSize = 56;
  static const double _trackHeight = 68;
  static const double _trackPadding = 6;
  static const double _completionThreshold = 0.9;

  late final AnimationController _snapController = AnimationController(
    vsync: this,
    duration: AppDurations.medium,
  )..addListener(_applySnapValue);

  Animation<double>? _snapAnimation;
  double _dragX = 0;
  double _maxExtent = 1;
  bool _completed = false;

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _applySnapValue() {
    final Animation<double>? animation = _snapAnimation;
    if (animation == null) return;
    setState(() => _dragX = animation.value);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_completed) return;
    setState(() {
      _dragX = (_dragX + details.primaryDelta!).clamp(0.0, _maxExtent);
    });
    if (_dragX / _maxExtent >= _completionThreshold) _complete();
  }

  void _onDragEnd(DragEndDetails details) {
    if (_completed) return;
    if (_dragX / _maxExtent >= _completionThreshold) {
      _complete();
    } else {
      _snapBack();
    }
  }

  void _snapBack() {
    _snapAnimation = Tween<double>(begin: _dragX, end: 0).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );
    _snapController.forward(from: 0);
  }

  /// Everyone lands on the home screen — browsing does not need an account.
  void _complete() {
    if (_completed) return;
    setState(() => _completed = true);
    _snapController.stop();
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

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
                          height: 132,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (
                                BuildContext context,
                                Object error,
                                StackTrace? _,
                              ) => Text(
                                'GoTrek',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: scheme.primary,
                                ),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          'Every trip starts here',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Text(
                            'Find a place to stay, book the flight and plan '
                            'the whole trip in one place.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  left: AppSpacing.xxl,
                  right: AppSpacing.xxl,
                  bottom: AppSpacing.xxxl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Center(child: _buildSlider(theme)),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'No account needed to look around',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(ThemeData theme) {
    final ColorScheme scheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          _maxExtent = math.max(
            1,
            constraints.maxWidth - _knobSize - (_trackPadding * 2),
          );
          final double progress = (_dragX / _maxExtent).clamp(0.0, 1.0);

          return Container(
            height: _trackHeight,
            padding: const EdgeInsets.all(_trackPadding),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(_trackHeight / 2),
              border: Border.all(color: scheme.outlineVariant),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Opacity(
                    opacity: 1 - progress,
                    child: Text(
                      'Slide to start',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(_dragX, 0),
                  child: GestureDetector(
                    onHorizontalDragUpdate: _onDragUpdate,
                    onHorizontalDragEnd: _onDragEnd,
                    child: Semantics(
                      button: true,
                      label: 'Slide to start',
                      child: Container(
                        width: _knobSize,
                        height: _knobSize,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
