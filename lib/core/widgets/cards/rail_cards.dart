import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/attraction.dart';
import '../../../data/models/experience.dart';
import '../../theme/app_spacing.dart';
import '../app_image.dart';
import '../favorite_button.dart';
import '../rating_pill.dart';

/// Card in the "Most visited" rail.
class AttractionCard extends StatelessWidget {
  const AttractionCard({
    super.key,
    required this.attraction,
    required this.onTap,
    this.width = 200,
  });

  final Attraction attraction;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  AppImage(attraction.imageAsset, height: 124, width: width),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: FavoriteButton(
                      item: attraction,
                      onImage: true,
                      size: 18,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      attraction.name,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      attraction.area,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    RatingPill(
                      rating: attraction.rating,
                      reviewCount: attraction.reviewCount,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card in the "Top events" rail.
class ExperienceCard extends StatelessWidget {
  const ExperienceCard({
    super.key,
    required this.experience,
    required this.onTap,
    this.width = 220,
  });

  final Experience experience;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  AppImage(experience.imageAsset, height: 124, width: width),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: FavoriteButton(
                      item: experience,
                      onImage: true,
                      size: 18,
                    ),
                  ),
                  Positioned(
                    bottom: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: RatingPill(rating: experience.rating, onImage: true),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      experience.name,
                      style: theme.textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${Formatters.flightDuration(experience.duration)} · '
                      '${Formatters.dayMonth(experience.startsAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    PriceText(amount: experience.price, unit: '/ person'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
