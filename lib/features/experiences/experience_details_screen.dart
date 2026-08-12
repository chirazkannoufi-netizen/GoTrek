import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/booking_bar.dart';
import '../../core/widgets/favorite_button.dart';
import '../../core/widgets/rating_pill.dart';
import '../../data/models/booking.dart';
import '../../data/models/booking_draft.dart';
import '../../data/models/experience.dart';

class ExperienceDetailsScreen extends StatefulWidget {
  const ExperienceDetailsScreen({super.key, required this.experience});

  final Experience experience;

  @override
  State<ExperienceDetailsScreen> createState() =>
      _ExperienceDetailsScreenState();
}

class _ExperienceDetailsScreenState extends State<ExperienceDetailsScreen> {
  static const int _maxGuests = 8;

  int _guests = 1;

  Experience get _experience => widget.experience;

  BookingDraft get _draft => BookingDraft(
    kind: BookingKind.experience,
    title: _experience.name,
    subtitle: _experience.area,
    imageAsset: _experience.imageAsset,
    startDate: _experience.startsAt,
    endDate: _experience.startsAt.add(_experience.duration),
    guests: _guests,
    lineItems: <BookingLineItem>[
      BookingLineItem(
        label:
            '${Formatters.money(_experience.price)} × $_guests '
            '${_guests == 1 ? 'guest' : 'guests'}',
        amount: _experience.totalFor(_guests),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: FavoriteButton(item: _experience, onImage: true),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  AppImage(_experience.imageAsset),
                  const ImageScrim(opacity: 0.55),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.huge,
            ),
            sliver: SliverList.list(
              children: <Widget>[
                Text(_experience.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _experience.area,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                RatingPill(
                  rating: _experience.rating,
                  reviewCount: _experience.reviewCount,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: _Detail(
                            icon: Icons.schedule,
                            label: 'Duration',
                            value: Formatters.flightDuration(
                              _experience.duration,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _Detail(
                            icon: Icons.event_outlined,
                            label: 'Next date',
                            value: Formatters.dayMonth(_experience.startsAt),
                          ),
                        ),
                        Expanded(
                          child: _Detail(
                            icon: Icons.access_time,
                            label: 'Starts',
                            value: Formatters.time(_experience.startsAt),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text('What is included', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(_experience.description, style: theme.textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.xxl),
                Text('Guests', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'People joining',
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed:
                              _guests > 1
                                  ? () => setState(() => _guests--)
                                  : null,
                          icon: const Icon(Icons.remove),
                          tooltip: 'Remove a guest',
                        ),
                        SizedBox(
                          width: 44,
                          child: Text(
                            '$_guests',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed:
                              _guests < _maxGuests
                                  ? () => setState(() => _guests++)
                                  : null,
                          icon: const Icon(Icons.add),
                          tooltip: 'Add a guest',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BookingBar(
        total: _experience.totalFor(_guests),
        caption:
            '${Formatters.money(_experience.price)} per person · '
            '${Formatters.guests(_guests)}',
        actionLabel: 'Book',
        onPressed: () => AppRoutes.openCheckout(context, _draft),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}
