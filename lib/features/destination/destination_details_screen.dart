import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/booking_bar.dart';
import '../../core/widgets/cards/hotel_card.dart';
import '../../core/widgets/favorite_button.dart';
import '../../core/widgets/rating_pill.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/booking.dart';
import '../../data/models/booking_draft.dart';
import '../../data/models/destination.dart';
import '../../data/models/hotel.dart';
import '../../data/models/trip_offer.dart';
import '../../state/catalog_providers.dart';
import 'widgets/flight_leg_tile.dart';

/// Trip detail for one destination: the return flight, who is travelling and
/// what it costs, plus the stays available in that city.
class DestinationDetailsScreen extends ConsumerStatefulWidget {
  const DestinationDetailsScreen({super.key, required this.destination});

  final Destination destination;

  @override
  ConsumerState<DestinationDetailsScreen> createState() =>
      _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState
    extends ConsumerState<DestinationDetailsScreen> {
  static const int _maxTravellers = 6;

  int _travellers = 1;

  Destination get _destination => widget.destination;
  TripOffer get _trip => _destination.trip;

  BookingDraft get _draft => BookingDraft(
    kind: BookingKind.trip,
    title: _destination.title,
    subtitle: 'Return from ${_trip.outbound.fromCity}',
    imageAsset: _destination.imageAsset,
    startDate: _trip.outbound.departsAt,
    endDate: _trip.inbound.arrivesAt,
    guests: _travellers,
    lineItems: <BookingLineItem>[
      BookingLineItem(
        label:
            '${Formatters.money(_trip.pricePerTraveller)} × $_travellers '
            '${_travellers == 1 ? 'traveller' : 'travellers'}',
        amount: _trip.totalFor(_travellers),
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
                child: FavoriteButton(item: _destination, onImage: true),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  AppImage(_destination.imageAsset),
                  const ImageScrim(),
                  Positioned(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    bottom: AppSpacing.xl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _destination.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: <Widget>[
                            RatingPill(
                              rating: _destination.rating,
                              onImage: true,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              Formatters.distance(_destination.distanceKm),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                Text(_destination.summary, style: theme.textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.xxl),

                Text('Your flights', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                FlightLegTile(leg: _trip.outbound, label: 'Outbound'),
                const SizedBox(height: AppSpacing.md),
                FlightLegTile(leg: _trip.inbound, label: 'Return'),
                const SizedBox(height: AppSpacing.md),
                _TripFacts(trip: _trip),
                const SizedBox(height: AppSpacing.xxl),

                Text('Travellers', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                _TravellerStepper(
                  value: _travellers,
                  max: _maxTravellers,
                  onChanged: (int value) => setState(() => _travellers = value),
                ),
                const SizedBox(height: AppSpacing.xxl),

                Text(
                  'Where to stay in ${_destination.city}',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                _StaysForDestination(destinationId: _destination.id),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BookingBar(
        total: _trip.totalFor(_travellers),
        caption:
            '${Formatters.money(_trip.pricePerTraveller)} per traveller · '
            '${_trip.cabin}',
        actionLabel: 'Book trip',
        onPressed: () => AppRoutes.openCheckout(context, _draft),
      ),
    );
  }
}

class _TripFacts extends StatelessWidget {
  const _TripFacts({required this.trip});

  final TripOffer trip;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Wrap(
          spacing: AppSpacing.xxl,
          runSpacing: AppSpacing.md,
          children: <Widget>[
            _Fact(label: 'Cabin', value: trip.cabin),
            _Fact(label: 'Trip length', value: Formatters.nights(trip.nights)),
            _Fact(
              label: 'Seats left',
              value: '${trip.seatsLeft}',
              highlight: trip.seatsLeft <= 5,
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: highlight ? theme.colorScheme.error : null,
          ),
        ),
      ],
    );
  }
}

class _TravellerStepper extends StatelessWidget {
  const _TravellerStepper({
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Adults', style: theme.textTheme.titleSmall),
                  Text(
                    'Up to $max per booking',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove),
              tooltip: 'Remove a traveller',
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
              tooltip: 'Add a traveller',
            ),
          ],
        ),
      ),
    );
  }
}

class _StaysForDestination extends ConsumerWidget {
  const _StaysForDestination({required this.destinationId});

  final String destinationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return ref
        .watch(hotelsForDestinationProvider(destinationId))
        .when(
          loading: () => const RailPlaceholder(height: 160),
          error:
              (Object error, StackTrace _) => ErrorView(
                message: describeCatalogError(error),
                compact: true,
              ),
          data: (List<Hotel> hotels) {
            if (hotels.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'No stays listed for this city yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: <Widget>[
                for (final Hotel hotel in hotels.take(3)) ...<Widget>[
                  HotelCard(
                    hotel: hotel,
                    onTap: () => AppRoutes.openHotel(context, hotel),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                OutlinedButton(
                  onPressed: () => AppRoutes.openStays(context),
                  child: const Text('See all stays'),
                ),
              ],
            );
          },
        );
  }
}
