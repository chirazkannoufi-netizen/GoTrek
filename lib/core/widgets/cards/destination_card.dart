import 'package:flutter/material.dart';

import '../../../data/models/destination.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatters.dart';
import '../app_image.dart';
import '../favorite_button.dart';
import '../rating_pill.dart';

/// Full-bleed destination card that opens the Explore list.
class DestinationHeroCard extends StatelessWidget {
  const DestinationHeroCard({
    super.key,
    required this.destination,
    required this.onTap,
    this.height = 260,
  });

  final Destination destination;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ClipRRect(
      borderRadius: AppRadius.allXl,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            AppImage(destination.imageAsset),
            const ImageScrim(),
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: FavoriteButton(item: destination, onImage: true),
            ),
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: RatingPill(rating: destination.rating, onImage: true),
            ),
            Positioned(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              bottom: AppSpacing.xl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    destination.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    Formatters.distance(destination.distanceKm),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: <Widget>[
                      PriceText(
                        amount: destination.trip.pricePerTraveller,
                        unit: 'return',
                        onImage: true,
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.near_me_outlined, size: 18),
                        label: const Text('View trip'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact destination row used in the Explore list.
class DestinationListCard extends StatelessWidget {
  const DestinationListCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  final Destination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              AppImage(
                destination.imageAsset,
                width: 84,
                height: 84,
                borderRadius: AppRadius.allMd,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      destination.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      Formatters.distance(destination.distanceKm),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: <Widget>[
                        RatingPill(rating: destination.rating),
                        const SizedBox(width: AppSpacing.md),
                        Flexible(
                          child: PriceText(
                            amount: destination.trip.pricePerTraveller,
                            unit: 'return',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FavoriteButton(item: destination),
            ],
          ),
        ),
      ),
    );
  }
}
