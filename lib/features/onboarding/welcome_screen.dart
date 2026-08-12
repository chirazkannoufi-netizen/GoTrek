import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_image.dart';
import '../../data/seed/seed_catalog.dart';
import '../../state/auth_controller.dart';

/// Onboarding screen with the slide-to-start control from the original design.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  static const double _knobSize = 58;
  static const double _trackHeight = 72;
  static const double _trackPadding = 7;
  static const double _completionThreshold = 0.9;

  late final AnimationController _snapController = AnimationController(
    vsync: this,
    duration: AppDurations.medium,
  )..addListener(_applySnapValue);

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  Animation<double>? _snapAnimation;
  double _dragX = 0;
  double _maxExtent = 1;
  bool _completed = false;

  @override
  void dispose() {
    _snapController.dispose();
    _pulseController.dispose();
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

  /// A restored session skips the login form.
  void _complete() {
    if (_completed) return;
    setState(() => _completed = true);
    _snapController.stop();
    _pulseController.stop();

    final bool signedIn = ref.read(currentUserProvider) != null;
    Navigator.of(
      context,
    ).pushReplacementNamed(signedIn ? AppRoutes.home : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const AppImage(SeedCatalog.welcomeImage),
          const ImageScrim(opacity: 0.85),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Spacer(flex: 2),
                  Image.asset(
                    SeedCatalog.logoImage,
                    height: 72,
                    errorBuilder:
                        (BuildContext context, Object error, StackTrace? _) =>
                            const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'Every trip starts here',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Find a destination, book the flight and the stay, and '
                    'keep the whole trip in one place.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(flex: 3),
                  Center(child: _buildSlider(theme)),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(ThemeData theme) {
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
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(_trackHeight / 2),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Opacity(
                    opacity: 1 - progress,
                    child: Text(
                      'Swipe to start',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (BuildContext context, Widget? child) {
                    final double nudge =
                        _dragX == 0 && !_completed
                            ? _pulseController.value * 8
                            : 0;
                    return Transform.translate(
                      offset: Offset(_dragX + nudge, 0),
                      child: child,
                    );
                  },
                  child: GestureDetector(
                    onHorizontalDragUpdate: _onDragUpdate,
                    onHorizontalDragEnd: _onDragEnd,
                    child: Semantics(
                      button: true,
                      label: 'Swipe to start',
                      child: Container(
                        width: _knobSize,
                        height: _knobSize,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: theme.colorScheme.onPrimary,
                          size: 26,
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
