import 'package:flutter/material.dart';

import 'app_image.dart';

/// Cover art for a destination.
///
/// Uses the photograph when the catalogue has one. The cities added for
/// Explore have no licensed photography in `assets/`, so rather than showing
/// a broken image those fall back to a generated gradient keyed off the city
/// name — deterministic, so a city always looks the same.
class CityCover extends StatelessWidget {
  const CityCover({
    super.key,
    required this.imageAsset,
    required this.title,
    this.height,
    this.width,
    this.borderRadius,
  });

  final String imageAsset;
  final String title;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  static const List<List<Color>> _palettes = <List<Color>>[
    <Color>[Color(0xFF14476F), Color(0xFF2E88B8)],
    <Color>[Color(0xFF1F5D50), Color(0xFF4FA88C)],
    <Color>[Color(0xFF4A2B63), Color(0xFF9166B0)],
    <Color>[Color(0xFF7A3B22), Color(0xFFCE8A4E)],
    <Color>[Color(0xFF243A5E), Color(0xFF5B7FB9)],
    <Color>[Color(0xFF6B2740), Color(0xFFC1697F)],
  ];

  List<Color> get _palette =>
      _palettes[title.codeUnits.fold<int>(0, (int a, int b) => a + b) %
          _palettes.length];

  String get _monogram {
    final String trimmed = title.trim();
    return trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (imageAsset.isNotEmpty) {
      return AppImage(
        imageAsset,
        height: height,
        width: width,
        borderRadius: borderRadius,
      );
    }

    final Widget cover = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _palette,
        ),
      ),
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned(
              right: -12,
              bottom: -24,
              child: Icon(
                Icons.location_city_rounded,
                size: (height ?? 140) * 0.85,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            Center(
              child: Text(
                _monogram,
                style: TextStyle(
                  fontSize: (height ?? 140) * 0.42,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.22),
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (borderRadius == null) return cover;
    return ClipRRect(borderRadius: borderRadius!, child: cover);
  }
}
