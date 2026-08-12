import 'package:flutter/material.dart';

/// Asset image with a drawn fallback.
///
/// The original screens called `Image.asset` with paths that could be empty —
/// the `/flight_details` route passed `imagePath: ''` — which throws while
/// painting. Anything unresolvable now renders as a neutral placeholder
/// instead of taking the screen down.
class AppImage extends StatelessWidget {
  const AppImage(
    this.asset, {
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String asset;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final Widget image =
        asset.isEmpty
            ? _Placeholder(height: height, width: width)
            : Image.asset(
              asset,
              height: height,
              width: width,
              fit: fit,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? _) =>
                      _Placeholder(height: height, width: width),
            );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.height, this.width});

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      width: width,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: scheme.onSurfaceVariant,
        size: 28,
      ),
    );
  }
}

/// Dark gradient drawn over a photo so white text stays legible.
class ImageScrim extends StatelessWidget {
  const ImageScrim({super.key, this.opacity = 0.75, this.stopHeight});

  final double opacity;
  final double? stopHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: stopHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[
            Colors.black.withValues(alpha: opacity),
            Colors.black.withValues(alpha: opacity * 0.35),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.45, 1],
        ),
      ),
    );
  }
}
