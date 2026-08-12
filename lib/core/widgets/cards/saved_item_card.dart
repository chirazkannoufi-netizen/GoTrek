import 'package:flutter/material.dart';

import '../../../data/models/catalog_item.dart';
import '../../theme/app_spacing.dart';
import '../app_image.dart';
import '../favorite_button.dart';
import '../rating_pill.dart';

/// One row on the Favourites screen.
///
/// Works for all four content types because they share [CatalogItem].
class SavedItemCard extends StatelessWidget {
  const SavedItemCard({super.key, required this.item, required this.onTap});

  final CatalogItem item;
  final VoidCallback onTap;

  String get _kindLabel => switch (item.kind) {
    SavedKind.destination => 'Destination',
    SavedKind.hotel => 'Stay',
    SavedKind.experience => 'Experience',
    SavedKind.attraction => 'Attraction',
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double? price = item.priceFrom;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              AppImage(
                item.imageAsset,
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
                      _kindLabel.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: <Widget>[
                        RatingPill(rating: item.rating),
                        if (price != null) ...<Widget>[
                          const SizedBox(width: AppSpacing.md),
                          Flexible(child: PriceText(amount: price)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FavoriteButton(item: item),
            ],
          ),
        ),
      ),
    );
  }
}
