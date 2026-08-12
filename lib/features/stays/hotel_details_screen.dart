import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/booking_bar.dart';
import '../../core/widgets/favorite_button.dart';
import '../../core/widgets/rating_pill.dart';
import '../../data/models/amenity.dart';
import '../../data/models/booking.dart';
import '../../data/models/booking_draft.dart';
import '../../data/models/hotel.dart';

class HotelDetailsScreen extends StatefulWidget {
  const HotelDetailsScreen({super.key, required this.hotel});

  final Hotel hotel;

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  static const int _maxRooms = 4;

  late DateTimeRange _stay = _defaultStay();
  int _rooms = 1;
  bool _descriptionExpanded = false;

  Hotel get _hotel => widget.hotel;

  int get _nights => _stay.duration.inDays;

  double get _total => _hotel.totalFor(nights: _nights, rooms: _rooms);

  static DateTimeRange _defaultStay() {
    final DateTime now = DateTime.now();
    final DateTime checkIn = DateTime(now.year, now.month, now.day + 1);
    return DateTimeRange(
      start: checkIn,
      end: checkIn.add(const Duration(days: 3)),
    );
  }

  BookingDraft get _draft => BookingDraft(
    kind: BookingKind.stay,
    title: _hotel.name,
    subtitle: _hotel.subtitle,
    imageAsset: _hotel.imageAsset,
    startDate: _stay.start,
    endDate: _stay.end,
    guests: _rooms,
    lineItems: <BookingLineItem>[
      BookingLineItem(
        label:
            '${Formatters.money(_hotel.pricePerNight)} × '
            '${Formatters.nights(_nights)} × '
            '$_rooms ${_rooms == 1 ? 'room' : 'rooms'}',
        amount: _total,
      ),
    ],
  );

  Future<void> _pickDates() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _stay,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1, now.month, now.day),
      helpText: 'Select your stay',
    );
    if (picked == null || !mounted) return;
    // A same-day range would make the total zero; keep at least one night.
    setState(() {
      _stay =
          picked.duration.inDays == 0
              ? DateTimeRange(
                start: picked.start,
                end: picked.start.add(const Duration(days: 1)),
              )
              : picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: FavoriteButton(item: _hotel, onImage: true),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  AppImage(_hotel.imageAsset),
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
                Text(_hotel.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        _hotel.subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                RatingPill(
                  rating: _hotel.rating,
                  reviewCount: _hotel.reviewCount,
                ),
                const SizedBox(height: AppSpacing.xxl),

                Text('About', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                AnimatedSize(
                  duration: AppDurations.fast,
                  alignment: Alignment.topCenter,
                  child: Text(
                    _hotel.description,
                    style: theme.textTheme.bodyLarge,
                    maxLines: _descriptionExpanded ? null : 4,
                    overflow:
                        _descriptionExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed:
                        () => setState(
                          () => _descriptionExpanded = !_descriptionExpanded,
                        ),
                    child: Text(
                      _descriptionExpanded ? 'Show less' : 'Read more',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                Text('Facilities', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                _AmenityGrid(amenities: _hotel.amenities),
                const SizedBox(height: AppSpacing.xxl),

                Text('Your stay', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                _StayPicker(
                  stay: _stay,
                  nights: _nights,
                  onPickDates: _pickDates,
                ),
                const SizedBox(height: AppSpacing.md),
                _RoomStepper(
                  value: _rooms,
                  max: _maxRooms,
                  onChanged: (int value) => setState(() => _rooms = value),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BookingBar(
        total: _total,
        caption:
            '${Formatters.money(_hotel.pricePerNight)} / night · '
            '${Formatters.nights(_nights)}',
        actionLabel: 'Reserve',
        onPressed: () => AppRoutes.openCheckout(context, _draft),
      ),
    );
  }
}

class _AmenityGrid extends StatelessWidget {
  const _AmenityGrid({required this.amenities});

  final List<Amenity> amenities;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        for (final Amenity amenity in amenities)
          Chip(
            avatar: Icon(
              amenity.icon,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            label: Text(amenity.label),
          ),
      ],
    );
  }
}

class _StayPicker extends StatelessWidget {
  const _StayPicker({
    required this.stay,
    required this.nights,
    required this.onPickDates,
  });

  final DateTimeRange stay;
  final int nights;
  final VoidCallback onPickDates;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onPickDates,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.calendar_month_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${Formatters.shortDate(stay.start)}  →  '
                      '${Formatters.shortDate(stay.end)}',
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      Formatters.nights(nights),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_outlined, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomStepper extends StatelessWidget {
  const _RoomStepper({
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            Expanded(child: Text('Rooms', style: theme.textTheme.titleSmall)),
            IconButton.filledTonal(
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove),
              tooltip: 'Remove a room',
            ),
            SizedBox(
              width: 44,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton.filledTonal(
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add),
              tooltip: 'Add a room',
            ),
          ],
        ),
      ),
    );
  }
}
