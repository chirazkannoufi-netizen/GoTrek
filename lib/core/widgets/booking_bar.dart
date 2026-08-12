import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'rating_pill.dart';

/// Sticky total and primary action, shared by the trip, stay and experience
/// detail screens so checkout always starts from the same place.
class BookingBar extends StatelessWidget {
  const BookingBar({
    super.key,
    required this.total,
    required this.caption,
    required this.actionLabel,
    required this.onPressed,
  });

  final double total;
  final String caption;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  PriceText(amount: total, large: true),
                  Text(
                    caption,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(minimumSize: const Size(150, 52)),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
