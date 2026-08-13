import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_search_field.dart';
import '../../core/widgets/rating_pill.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/booking.dart';
import '../../data/models/booking_draft.dart';
import '../../data/models/city_location.dart';
import '../../data/models/daily_flight.dart';
import '../../state/catalog_providers.dart';
import '../auth/auth_gate.dart';

/// Departure board: every flight leaving the user's city today, with fares.
class FlightsScreen extends ConsumerStatefulWidget {
  const FlightsScreen({super.key});

  @override
  ConsumerState<FlightsScreen> createState() => _FlightsScreenState();
}

class _FlightsScreenState extends ConsumerState<FlightsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CityLocation city = ref.watch(currentCityProvider);
    final AsyncValue<List<DailyFlight>> flights = ref.watch(
      dailyFlightsProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flights today'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(26),
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              'Departing ${city.city} (${city.airportCode}) · '
              '${Formatters.dayMonth(DateTime.now())}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: AppSearchField(
              hintText: 'Search by city, airline or flight',
              onChanged: (String value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: flights.when(
              loading: () => const LoadingView(),
              error:
                  (Object error, StackTrace _) => ErrorView(
                    message: describeCatalogError(error),
                    onRetry: () => ref.invalidate(dailyFlightsProvider),
                  ),
              data: (List<DailyFlight> all) {
                final List<DailyFlight> results =
                    all
                        .where((DailyFlight flight) => flight.matches(_query))
                        .toList();

                if (results.isEmpty) {
                  return EmptyView(
                    title: 'No flights match "$_query"',
                    message: 'Try another city or airline.',
                    icon: Icons.flight_takeoff_outlined,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.huge,
                  ),
                  itemCount: results.length,
                  separatorBuilder:
                      (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder:
                      (BuildContext context, int index) =>
                          _FlightCard(flight: results[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FlightCard extends StatelessWidget {
  const _FlightCard({required this.flight});

  final DailyFlight flight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool departed = flight.hasDeparted(DateTime.now());

    return Opacity(
      opacity: departed ? 0.55 : 1,
      child: Card(
        child: InkWell(
          onTap:
              departed
                  ? null
                  : () => showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    isScrollControlled: true,
                    builder: (_) => _FlightBookingSheet(flight: flight),
                  ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.flight_takeoff,
                      size: AppTheme.iconCompact,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        '${flight.airline} · ${flight.flightNumber}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (departed)
                      Text('Departed', style: theme.textTheme.labelSmall)
                    else if (flight.isAlmostFull)
                      Text(
                        '${flight.seatsLeft} seats left',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _Endpoint(
                      time: Formatters.time(flight.departsAt),
                      code: flight.fromCode,
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            Formatters.flightDuration(flight.duration),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Divider(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                              Icon(
                                Icons.flight,
                                size: AppTheme.iconCompact,
                                color: theme.colorScheme.primary,
                              ),
                              Expanded(
                                child: Divider(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            flight.isDirect ? 'Direct' : '1 stop',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _Endpoint(
                      time: Formatters.time(flight.arrivesAt),
                      code: flight.toCode,
                      alignEnd: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        flight.toCity,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PriceText(amount: flight.price, unit: 'one way'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Endpoint extends StatelessWidget {
  const _Endpoint({
    required this.time,
    required this.code,
    this.alignEnd = false,
  });

  final String time;
  final String code;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: 68,
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(time, style: theme.textTheme.titleMedium),
          Text(
            code,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pick how many are travelling, then go to the normal checkout.
class _FlightBookingSheet extends ConsumerStatefulWidget {
  const _FlightBookingSheet({required this.flight});

  final DailyFlight flight;

  @override
  ConsumerState<_FlightBookingSheet> createState() =>
      _FlightBookingSheetState();
}

class _FlightBookingSheetState extends ConsumerState<_FlightBookingSheet> {
  static const int _maxTravellers = 6;

  int _travellers = 1;

  DailyFlight get _flight => widget.flight;

  BookingDraft get _draft => BookingDraft(
    kind: BookingKind.trip,
    title: '${_flight.fromCity} to ${_flight.toCity}',
    subtitle: '${_flight.airline} · ${_flight.flightNumber}',
    imageAsset: '',
    startDate: _flight.departsAt,
    endDate: _flight.arrivesAt,
    guests: _travellers,
    lineItems: <BookingLineItem>[
      BookingLineItem(
        label:
            '${Formatters.money(_flight.price)} × $_travellers '
            '${_travellers == 1 ? 'traveller' : 'travellers'}',
        amount: _flight.totalFor(_travellers),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          0,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '${_flight.fromCity} to ${_flight.toCity}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${_flight.airline} · ${_flight.flightNumber} · '
              '${Formatters.time(_flight.departsAt)} → '
              '${Formatters.time(_flight.arrivesAt)} · '
              '${Formatters.flightDuration(_flight.duration)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text('Travellers', style: theme.textTheme.titleSmall),
                ),
                IconButton.filledTonal(
                  onPressed:
                      _travellers > 1
                          ? () => setState(() => _travellers--)
                          : null,
                  icon: const Icon(Icons.remove),
                  tooltip: 'Remove a traveller',
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    '$_travellers',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed:
                      _travellers < _maxTravellers
                          ? () => setState(() => _travellers++)
                          : null,
                  icon: const Icon(Icons.add),
                  tooltip: 'Add a traveller',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: <Widget>[
                Text('Total', style: theme.textTheme.titleMedium),
                const Spacer(),
                PriceText(amount: _flight.totalFor(_travellers), large: true),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () async {
                final BookingDraft draft = _draft;
                final NavigatorState navigator = Navigator.of(context);
                if (!await ensureSignedIn(
                  context,
                  ref,
                  action: 'book this flight',
                )) {
                  return;
                }
                if (!context.mounted) return;
                navigator.pop();
                await AppRoutes.openCheckout(context, draft);
              },
              child: const Text('Continue to checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
