import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/trip_offer.dart';

/// One direction of a return trip: departure, duration, arrival.
///
/// The original screen accepted times as parameters but then rendered
/// hard-coded strings, so every flight showed 14:00 → 19:00. This renders the
/// leg it is given.
class FlightLegTile extends StatelessWidget {
  const FlightLegTile({super.key, required this.leg, required this.label});

  final FlightLeg leg;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.6,
                  ),
                ),
                const Spacer(),
                Text(
                  '${leg.flightNumber} · ${Formatters.dayMonth(leg.departsAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _Endpoint(
                  time: Formatters.time(leg.departsAt),
                  code: leg.fromCode,
                  city: leg.fromCity,
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(
                        Formatters.flightDuration(leg.duration),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Divider(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          Icon(
                            Icons.flight,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          Expanded(
                            child: Divider(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Direct',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _Endpoint(
                  time: Formatters.time(leg.arrivesAt),
                  code: leg.toCode,
                  city: leg.toCity,
                  alignEnd: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Endpoint extends StatelessWidget {
  const _Endpoint({
    required this.time,
    required this.code,
    required this.city,
    this.alignEnd = false,
  });

  final String time;
  final String code;
  final String city;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: 84,
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
          Text(
            city,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          ),
        ],
      ),
    );
  }
}
