import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_gate.dart';
import '../theme/app_spacing.dart';
import 'rating_pill.dart';

/// Sticky total and primary action, shared by the trip, stay and experience
/// detail screens so checkout always starts from the same place.
///
/// Booking belongs to an account, so the primary button routes through the
/// sign-in gate before running [onPressed].
class BookingBar extends ConsumerWidget {
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

  Future<void> _handlePressed(BuildContext context, WidgetRef ref) async {
    if (!await ensureSignedIn(context, ref, action: 'book this')) return;
    if (!context.mounted) return;
    onPressed();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              onPressed: () => _handlePressed(context, ref),
              style: FilledButton.styleFrom(minimumSize: const Size(150, 52)),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
