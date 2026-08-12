import 'package:flutter/material.dart';

import '../../data/models/place_category.dart';
import '../theme/app_spacing.dart';

/// Horizontally scrolling category filter.
///
/// Selecting a chip filters the destination list; tapping the selected chip
/// again clears the filter.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
    this.padding = AppSpacing.pageHorizontal,
  });

  final PlaceCategory? selected;
  final ValueChanged<PlaceCategory> onSelected;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: PlaceCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final PlaceCategory category = PlaceCategory.values[index];
          final bool isSelected = category == selected;

          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(category),
            avatar: Icon(
              category.icon,
              size: 18,
              color:
                  isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
            ),
            label: Text(category.label),
            labelStyle: theme.textTheme.labelMedium?.copyWith(
              color:
                  isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          );
        },
      ),
    );
  }
}
