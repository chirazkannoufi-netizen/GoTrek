import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/favorite_button.dart';
import '../../core/widgets/rating_pill.dart';
import '../../data/models/attraction.dart';

/// Attractions are free to visit, so there is nothing to book. This sheet
/// gives the card somewhere to go without inventing a booking flow.
class AttractionSheet extends StatelessWidget {
  const AttractionSheet({super.key, required this.attraction});

  final Attraction attraction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          0,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppImage(
              attraction.imageAsset,
              height: 180,
              width: double.infinity,
              borderRadius: AppRadius.allLg,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    attraction.name,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                FavoriteButton(item: attraction),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              attraction.area,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            RatingPill(
              rating: attraction.rating,
              reviewCount: attraction.reviewCount,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Free to visit — rated by '
                    '${Formatters.compactCount(attraction.reviewCount)} '
                    'travellers.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
