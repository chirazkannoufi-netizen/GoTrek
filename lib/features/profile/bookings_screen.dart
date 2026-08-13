import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/city_cover.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/booking.dart';
import '../../state/bookings_controller.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Booking>> bookings = ref.watch(
      bookingsControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('My bookings')),
      body: bookings.when(
        loading: () => const LoadingView(),
        error:
            (Object error, StackTrace _) => ErrorView(
              message: 'Could not load your bookings.',
              onRetry: () => ref.invalidate(bookingsControllerProvider),
            ),
        data: (List<Booking> results) {
          if (results.isEmpty) {
            return const EmptyView(
              title: 'No bookings yet',
              message:
                  'Trips, stays and experiences you book will be listed here.',
              icon: Icons.confirmation_number_outlined,
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.huge,
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 560,
              mainAxisExtent: 172,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
            ),
            itemCount: results.length,
            itemBuilder:
                (BuildContext context, int index) =>
                    _BookingCard(booking: results[index]),
          );
        },
      ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  Color _statusColor(ThemeData theme) => switch (booking.status) {
    BookingStatus.confirmed => AppColors.success,
    BookingStatus.completed => theme.colorScheme.onSurfaceVariant,
    BookingStatus.cancelled => theme.colorScheme.error,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool cancellable = booking.status == BookingStatus.confirmed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CityCover(
                  imageAsset: booking.imageAsset,
                  title: booking.title,
                  width: 72,
                  height: 72,
                  borderRadius: AppRadius.allMd,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            booking.kind.icon,
                            size: AppTheme.iconCompact,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            booking.reference,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(
                                theme,
                              ).withValues(alpha: 0.12),
                              borderRadius: AppRadius.pill,
                            ),
                            child: Text(
                              booking.status.label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _statusColor(theme),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        booking.title,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${Formatters.shortDate(booking.startDate)} → '
                        '${Formatters.shortDate(booking.endDate)} · '
                        '${Formatters.guests(booking.guests)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: <Widget>[
                Text(
                  Formatters.moneyPrecise(booking.total),
                  style: theme.textTheme.titleSmall,
                ),
                const Spacer(),
                if (cancellable)
                  TextButton(
                    onPressed: () => _confirmCancel(context, ref),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    child: const Text('Cancel booking'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Cancel this booking?'),
            content: Text('${booking.title} (${booking.reference})'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep it'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Cancel booking'),
              ),
            ],
          ),
    );

    if (confirmed ?? false) {
      await ref.read(bookingsControllerProvider.notifier).cancel(booking.id);
    }
  }
}
