import 'package:flutter/material.dart';

import '../../../data/models/hotel.dart';
import '../../theme/app_spacing.dart';
import '../app_image.dart';
import '../favorite_button.dart';
import '../rating_pill.dart';

/// Stay row used on the Stays list and on a destination's stays section.
///
/// Laid out as a fixed-width photo beside a column that pins the name to the
/// top and the price to the bottom, so a list of these lines up on both edges
/// however long the names run.
class HotelCard extends StatelessWidget {
  const HotelCard({super.key, required this.hotel, required this.onTap});

  /// Height the surrounding list should give each card. Kept here so the
  /// grid delegates and the card cannot drift apart.
  static const double height = 168;

  static const double _imageWidth = 132;

  final Hotel hotel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  AppImage(
                    hotel.imageAsset,
                    width: _imageWidth,
                    height: height,
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: FavoriteButton(item: hotel, onImage: true, size: 18),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        hotel.name,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        hotel.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      RatingPill(
                        rating: hotel.rating,
                        reviewCount: hotel.reviewCount,
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Expanded(
                            child: PriceText(
                              amount: hotel.pricePerNight,
                              unit: '/ night',
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
