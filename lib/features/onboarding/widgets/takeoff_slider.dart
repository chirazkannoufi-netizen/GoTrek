import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Slide-to-start control with an aeroplane for a knob.
///
/// Three pieces of motion, all tied to what the user is doing:
///  * **Idle** — a slow halo expands and fades out from behind the plane
///    (roughly two seconds a cycle) while the plane itself drifts a few
///    pixels back and forth on a sine. Enough to read as "drag me", quiet
///    enough not to nag.
///  * **Dragging** — the halo stops, a tinted trail fills the track behind
///    the plane, and the nose lifts progressively as you approach the end,
///    so the gesture feels like a take-off roll.
///  * **Released past the threshold** — the plane accelerates out to the
///    right, climbing and fading, and only then does [onCompleted] fire.
class TakeoffSlider extends StatefulWidget {
  const TakeoffSlider({super.key, required this.onCompleted, this.label});

  final VoidCallback onCompleted;
  final String? label;

  @override
  State<TakeoffSlider> createState() => _TakeoffSliderState();
}

class _TakeoffSliderState extends State<TakeoffSlider>
    with TickerProviderStateMixin {
  static const double _knobSize = 58;
  static const double _trackHeight = 70;
  static const double _trackPadding = 6;
  static const double _completionThreshold = 0.9;

  /// Material's flight glyph points north; a quarter turn aims it along the
  /// drag, and the nose lifts from there.
  static const double _baseAngle = math.pi / 2;
  static const double _maxClimb = 0.28;

  late final AnimationController _idleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat();

  late final AnimationController _snapController = AnimationController(
    vsync: this,
    duration: AppDurations.medium,
  )..addListener(_applySnapValue);

  late final AnimationController _takeoffController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  Animation<double>? _snapAnimation;
  double _dragX = 0;
  double _maxExtent = 1;
  bool _completed = false;

  @override
  void dispose() {
    _idleController.dispose();
    _snapController.dispose();
    _takeoffController.dispose();
    super.dispose();
  }

  void _applySnapValue() {
    final Animation<double>? animation = _snapAnimation;
    if (animation == null) return;
    setState(() => _dragX = animation.value);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_completed) return;
    if (_idleController.isAnimating) _idleController.stop();
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
    _snapController.forward(from: 0).whenComplete(() {
      if (mounted && !_completed) _idleController.repeat();
    });
  }

  Future<void> _complete() async {
    if (_completed) return;
    setState(() => _completed = true);
    _idleController.stop();
    _snapController.stop();

    await _takeoffController.forward();
    if (mounted) widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          _maxExtent = math.max(
            1,
            constraints.maxWidth - _knobSize - (_trackPadding * 2),
          );

          return SizedBox(
            // Claim the full width offered, so the track does not collapse to
            // its label when the parent hands down loose constraints.
            width: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
            height: _trackHeight,
            child: AnimatedBuilder(
              animation: Listenable.merge(<Listenable>[
                _idleController,
                _takeoffController,
              ]),
              builder: (BuildContext context, Widget? child) {
                final double progress = (_dragX / _maxExtent).clamp(0.0, 1.0);
                final double takeoff = _takeoffController.value;

                // Idle drift: a few pixels either side, only while resting.
                final double drift =
                    _completed || _dragX > 0
                        ? 0
                        : math.sin(_idleController.value * 2 * math.pi) * 3;

                // Departure: accelerate right and climb as it fades.
                final double exitX =
                    Curves.easeInCubic.transform(takeoff) * _maxExtent * 0.6;
                final double exitY =
                    -Curves.easeInCubic.transform(takeoff) * 26;

                return Stack(
                  children: <Widget>[
                    _Track(
                      progress: progress,
                      label: widget.label,
                      knobSize: _knobSize,
                      trackPadding: _trackPadding,
                      trackHeight: _trackHeight,
                      fillWidth: _dragX + _knobSize + (_trackPadding * 2),
                    ),
                    Positioned(
                      left: _trackPadding + _dragX + drift + exitX,
                      top: _trackPadding + exitY,
                      child: Opacity(
                        opacity: (1 - takeoff).clamp(0.0, 1.0),
                        child: GestureDetector(
                          onHorizontalDragUpdate: _onDragUpdate,
                          onHorizontalDragEnd: _onDragEnd,
                          child: Semantics(
                            button: true,
                            label: widget.label ?? 'Slide to start',
                            child: SizedBox(
                              width: _knobSize,
                              height: _knobSize,
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  if (!_completed && _dragX == 0)
                                    _Halo(
                                      t: _idleController.value,
                                      color: scheme.primary,
                                      size: _knobSize,
                                    ),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: scheme.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: scheme.primary.withValues(
                                            alpha: 0.32,
                                          ),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: SizedBox(
                                      width: _knobSize,
                                      height: _knobSize,
                                      child: Center(
                                        child: Transform.rotate(
                                          angle:
                                              _baseAngle -
                                              (progress * _maxClimb) -
                                              (takeoff * _maxClimb),
                                          child: Icon(
                                            Icons.flight,
                                            size: 26,
                                            color: scheme.onPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Expanding, fading ring that reads as a soft ping behind the plane.
class _Halo extends StatelessWidget {
  const _Halo({required this.t, required this.color, required this.size});

  final double t;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final double eased = Curves.easeOut.transform(t);
    return IgnorePointer(
      child: Transform.scale(
        scale: 1 + (eased * 0.85),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.26 * (1 - eased)),
          ),
        ),
      ),
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({
    required this.progress,
    required this.label,
    required this.knobSize,
    required this.trackPadding,
    required this.trackHeight,
    required this.fillWidth,
  });

  final double progress;
  final String? label;
  final double knobSize;
  final double trackPadding;
  final double trackHeight;
  final double fillWidth;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      height: trackHeight,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(trackHeight / 2),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          // Trail left behind the plane.
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: fillWidth,
              height: trackHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.10 * progress),
                  borderRadius: BorderRadius.circular(trackHeight / 2),
                ),
              ),
            ),
          ),
          if (label != null)
            Center(
              child: Padding(
                padding: EdgeInsets.only(left: knobSize * 0.6),
                child: Opacity(
                  opacity: (1 - (progress * 1.6)).clamp(0.0, 1.0),
                  child: Text(
                    label!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
