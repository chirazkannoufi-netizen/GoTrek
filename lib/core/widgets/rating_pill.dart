import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/formatters.dart';

/// Star + score, optionally with a review count.
class RatingPill extends StatelessWidget {
  const RatingPill({
    super.key,
    required this.rating,
    this.reviewCount,
    this.onImage = false,
  });

  final double rating;
  final int? reviewCount;

  /// Renders on a translucent dark chip, for use over a photo.
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color labelColor =
        onImage ? Colors.white : theme.colorScheme.onSurface;

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.star_rounded, color: AppColors.accent, size: 18),
        const SizedBox(width: AppSpacing.xs),
        Text(
          Formatters.rating(rating),
          style: theme.textTheme.labelLarge?.copyWith(color: labelColor),
        ),
        if (reviewCount != null) ...<Widget>[
          const SizedBox(width: AppSpacing.xs),
          Text(
            '(${Formatters.compactCount(reviewCount!)})',
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  onImage ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );

    if (!onImage) return content;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: AppRadius.pill,
      ),
      child: content,
    );
  }
}

/// Price plus its unit, e.g. "$250 / night".
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.amount,
    this.unit,
    this.onImage = false,
    this.large = false,
  });

  final double amount;
  final String? unit;
  final bool onImage;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color priceColor = onImage ? Colors.white : theme.colorScheme.primary;

    return RichText(
      text: TextSpan(
        text: Formatters.money(amount),
        style: (large
                ? theme.textTheme.headlineSmall
                : theme.textTheme.titleMedium)
            ?.copyWith(color: priceColor),
        children: <InlineSpan>[
          if (unit != null)
            TextSpan(
              text: ' $unit',
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    onImage
                        ? Colors.white70
                        : theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
